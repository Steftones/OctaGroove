/*
Server.killAll;
s.options.memSize = 2.pow(20);
s.boot;
s.reboot;
ServerOptions.inDevices;
ServerOptions.outDevices;
Server.default.options.inDevice_("MacBook Pro Microphone");
Server.default.options.outDevice_("Background Music");
Server.default.options.outDevice_("External Headphones");
Server.default.options.outDevice_("MacBook Pro Speakers");
s.makeWindow;
Platform.systemExtensionDir;
Platform.userExtensionDir;
*/

// ----- send below -----
(
var s;
s = Server.default;
s.options.memSize = 2.pow(20);
Window.closeAll;
s.meter;
s.plotTree;

s.waitForBoot({
	~tempo = TempoClock.tempo_(180/60);

	~editMode = Dictionary[
		\isEditMode -> false,
		\canEditThisStep -> false,
		\sampler -> 0,
	];

	~baseStepDictionary = [
		\prob, 1,
		\sample, false,
		\rate, false,
		\amp, false,
		\theEffect, false,
		\iteration, [],
	];

	~patternLength = 64;
	// rename the below - sounds dumb
	~editBaseRateItems = [0.1, 0.2, 0.4, 0.5, 0.6, 0.8, 1, 1.2, 2, 3, 4, 5];

	~folderPath = PathName(thisProcess.nowExecutingPath).parentPath;
	(~folderPath ++ 'utils/themes.scd').load;
	(~folderPath ++ 'utils/effects.scd').load;
	(~folderPath ++ 'utils/beatUtils.scd').load;

	SynthDef.new(\bufferPlayer, {
		|amp = 1, theAmp = 0.5, out = 0, buf, freq = 1, t_trig = 1, rate = 1, start = 0, pan = 0|
		var snd, panned;
		snd = PlayBuf.ar(buf.numChannels, buf, BufRateScale.kr(buf) * rate, t_trig, start);
		panned = case
			{buf.numChannels == 1} {Pan2.ar(snd, pan)}
			{buf.numChannels == 2} {Balance2.ar(snd[0], snd[1], pan)};
		snd = panned * (theAmp * amp);
		Out.ar(out, snd);
	}).add;

	~measure = 0;
	~measureCounter = Routine {
		loop {
			8.yield;
			~measure = (~measure + 1) % 4;
		};
	}.play(quant: 4);

	~allPatterns = [] ++ [8.collect({ \.dup(~patternLength).asStream; })];
	~currentKit = PathName(~folderPath ++ 'kits/').entries[0].folderName;

	// todo: perhaps rearange alphabetically?
	~allKits = Dictionary.new;

	PathName(~folderPath ++ 'kits/').entries.do({
		|kitPath, i|
		~allKits.add(
			PathName(kitPath.fullPath).folderName -> 8.collect({
				|i|
				PathName(kitPath.fullPath ++ i).entries.collect({
					|file|
					var buf = Buffer.read(s, file.fullPath);
					Dictionary[
						\fileName -> file.fileName,
						\buffer -> buf,
					];
				});
			});
		);
	});

	~allBeats = \ ! ~patternLength ! 8;
	~allBeats_original = \ ! ~patternLength ! 8;
	~allEffectValues = [1, 1] ! ~allEffects.size;
	~samplerRandomnessStreams = [];

	~changeKitFunc = {
		~samplerRandomnessStreams = 8.collect({
			|i|
			var buffers = ~allKits[~currentKit][i];
			Dictionary[
				\exprand -> Pexprand(0.001, buffers.size, inf).floor.asStream,
				\hprand -> Phprand(0, buffers.size - 1, inf).floor.asStream,
				\lprand -> Plprand(0, buffers.size - 1, inf).floor.asStream,
				\meanrand -> Pmeanrand(0, buffers.size - 1, inf).floor.asStream,
				\xrand -> Pxrand(buffers.collect({ |i, j| j }), inf).asStream,
				\rand -> Prand(buffers.collect({ |i, j| j }), inf).asStream,
			];
		});
	};
	~changeKitFunc.value();

	~otherXrandomnessStreams = 8.collect({
		Dictionary[
			\theAmp -> Pxrand(~editBaseRateItems, inf).asStream,
			\theRate -> Pxrand(~editBaseRateItems, inf).asStream,
		];
	});

	~generalRandomnessStreams = Dictionary[
		\none -> 1,
		\exprand -> Pexprand(1, 5, inf).floor.asStream,
		\hprand -> Phprand(1, 5, inf).floor.asStream,
		\lprand -> Plprand(1, 5, inf).floor.asStream,
		\meanrand -> Pmeanrand(1, 5, inf).floor.asStream,
		\rand -> Prand(~editBaseRateItems, inf).asStream,
	];

	~allSamplers = 8.collect({
		|i|
		Dictionary[
			\theSampler -> Dictionary[
				\streamPopUpItem -> 0,
				\stream -> \exprand,
			],
			\theAmp -> Dictionary[
				\baseAmp -> 1,
				\streamPopUpItem -> 0,
				\stream -> \none,
			],
			\theRate -> Dictionary[
				\baseRate -> 1,
				\streamPopUpItem -> 0,
				\stream -> \none,
			],
			\theEffect -> [0, 0],
		];
	});

	~bufFunc = {
		|theNextBeat, i|
		var output, sampleChoice = ~allSamplers[i][\theSampler][\stream];
		sampleChoice = if (
			sampleChoice.isNumber,
			sampleChoice,
			~samplerRandomnessStreams[i][sampleChoice].next
		);
		try {
			~allKits[~currentKit][i][
				if (theNextBeat[\sample] == false, sampleChoice, theNextBeat[\sample]);
			][\buffer];
		} { ~allKits[~currentKit][i].choose[\buffer] };
	};
	~ampFunc = {
		|theNextBeat, i|
		var theAmp = ~allSamplers[i][\theAmp];
		var theStream = ~generalRandomnessStreams[theAmp[\stream]] ?? ~otherXrandomnessStreams[i][\theAmp];
		if (theNextBeat[\amp] == false,
			{theAmp[\baseAmp] * theStream.next},
			theNextBeat[\amp]
		);
	};
	~rateFunc = {
		|theNextBeat, i|
		var theRate = ~allSamplers[i][\theRate];
		var theStream = ~generalRandomnessStreams[theRate[\stream]] ?? ~otherXrandomnessStreams[i][\theRate];
		if (theNextBeat[\rate] == false,
			{theRate[\baseRate] * theStream.next},
			theNextBeat[\rate]
		);
	};
	~effectFunc = {
		|theNextBeat, i|
		if (theNextBeat[\theEffect] == false, ~allSamplers[i][\theEffect][1], theNextBeat[\theEffect]);
	};

	~allSamplersPlaying = 8.collect({
		|i|
		Routine {
			var theSynth = Synth(\bufferPlayer, [\amp, 0]);
			loop {
				~patternLength.do({
					|step|
					var nextBeat = ~allBeats[i][step];
					if (nextBeat !== \, {
						if (nextBeat[0][\prob].coin, {
							if (nextBeat[0][\iteration].includes(~measure) == false,
								{
									s.bind {
										theSynth.set(
											\buf, ~bufFunc.value(nextBeat[0], i),
											\amp, ~ampFunc.value(nextBeat[0], i),
											\rate, ~rateFunc.value(nextBeat[0], i),
											\out, ~effectFunc.value(nextBeat[0], i),
											\t_trig, 1,
										);
									};
								}
							);
						});
					});
					(1/8).wait;
				});
			};
		}.play(quant: 4);
	});

	~allButtons = [];
	~samplerFillFunc = {
		|i|
		~allButtons = ~allButtons ++ Array.fill(~patternLength, {
			|j|
			Button(w, Rect((50 + (j * 14)), i * 1.4 + (i * 14) + ~topMargin + 2, 14, 14))
			.enabled_(true)
			.action_({
				|button|

				~editMode[\isEditMode].postln;

				if (~editMode[\isEditMode] == true,
					{
						if (button.value == 0,
							{
								var beat = ~allBeats[i][j][0];
								~editMode[\canEditThisStep] = true;
								~editModePopUpAction.value(1);
								{
									var currentStepUI = "EDIT STEP: % / %".format(i, j);
									~editBoxTitle.string_(currentStepUI);
								}.defer;
								button.value_(1);
								~theBeatToEdit = [i, j];
								~editProbSlider.value_(beat[\prob]);

								if (
									beat[\iteration].size !== 0,
									{
										var measureIndex = ~measureControlValues.detectIndex({
											|element|
											element[1] == beat[\iteration];
										});
										~measureControlsPopUp.value_(measureIndex);
									},
									{
										~measureControlsPopUp.value_(0);
									}
								);

								if (
									beat[\rate] !== false,
									{
										var measureIndex = ~editBaseRateItems.detectIndex({
											|element|
											element == beat[\rate];
										});
										~editBaseRatePopUp.value_(measureIndex);
									},
									{
										~editBaseRatePopUp.value_(6); // 6 is default for a rate of 1
									}
								);

								if (
									beat[\theEffect] !== false,
									{
										var measureIndex = ~allEffects.detectIndex({
											|element|
											element[1] == beat[\theEffect];
										});
										~editEffectsPopUp.value_(measureIndex);
									},
									{
										~editEffectsPopUp.value_(0);
									}
								);

								~editAmpSlider.value_(if (beat[\amp] !== false, beat[\amp], 1));
								~mainSeqSampleChoiceControls
								.items_(~allKits[~currentKit][i].collect({ |element| element[\fileName] }));
								~mainSeqSampleChoiceControls.value_(if (beat[\sample] !== false, beat[\sample], 0));
							},
							{
								button.value_(0);
								~editMode[\canEditThisStep] = false;
							}
						);
					},
					{
						if (button.value == 1,
							{
								var newBeat = Dictionary.newFrom(~baseStepDictionary);
								'putting beat down'.postln;
								~allBeats[i][j] = [newBeat];
								~allBeats_original[i][j] = [newBeat];
							},
							{
								~allBeats[i][j] = \;
								~allBeats_original[i][j] = \;
							}
						);
					}
				);
			});
		});
	};

	(~folderPath ++ 'utils/ui.scd').load;

});
)