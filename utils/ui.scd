~appName = 'OctaGroove';
~globalFont = Font("Hiragino Sans", 11);
~titleFont = Font("Hiragino Sans", 20);
~globalColor = Color.fromHexString("#E2E2E2");
~stepColor1 = Color.fromHexString("#fcc010");
~stepColor2 = Color.fromHexString("#e67e2a");
~stepOnColor = Color.fromHexString("#1e1d1c").alpha_(0.85);

w = Window.new(~appName, Rect(400, 410, 995, 400))
.front
.background_(~globalColor)
.alwaysOnTop_(true);

~playStopButton = Button(w, ~ui_bounds[\playStopButton])
.font_(~globalFont)
.states_([
	['■', nil, ~globalColor],
	['►', nil, ~globalColor]
])
.action_({
	|state|
	if (state.value == 0,
		{
			'Playing...'.postln;
			~allSamplersPlaying.do({
				|sampler|
				sampler[\theRoutine].reset;
				sampler[\theRoutine].play;
			});
		},
		{
			'Stopping...'.postln;
			~allSamplersPlaying.do({
				|sampler|
				sampler[\theRoutine].stop;
			});
		}
	);
});

~createNameWindow = {
	|nameToDisplay = ""|
	var saveButton, exitButton, nameWindow, textField;

	textField = TextField.new(w).value_(nameToDisplay);

	saveButton = Button.new(w)
	.font_(~globalFont)
	.states_([["Save as", nil, ~globalColor]])
	.action_({
		var toSave = Dictionary[
			\allEffectValues -> ~allEffectValues.deepCopy,
			\allSamplers -> ~allSamplers.deepCopy,
			\allPatterns -> ~allPatterns.deepCopy,
			\theKit -> ~currentKit,
			\tempo -> ~tempo.tempo,
		];
		toSave.writeArchive(~folderPath ++ '/save/' ++ textField.value ++ '.song');
		~loadFilesPopUp.items_(~loadFilesFunction.value());
		nameWindow.visible_(false);
	});

	exitButton = Button.new(w)
	.font_(~globalFont)
	.states_([["Exit", nil, ~globalColor]])
	.action_({
		nameWindow.visible_(false);
	});

	nameWindow = Window.new(
		name: "Save as",
		bounds: Rect(500,500,200,200),
		resizable: true
	)
	.front
	.alwaysOnTop_(true)
	.visible_(true)
	.layout_(
		VLayout(
			HLayout(
				StaticText(w),
				StaticText(w).string_("Enter name").font_(~globalFont),
				StaticText(w)
			),
			textField,
			saveButton,
			exitButton,
		);
	);

	nameWindow;
};

~mainTitle = StaticText(w, Rect(50, 25, 200, 30))
.string_(~appName)
.font_(~titleFont);

~saveAsProjectButton = Button(w, ~ui_bounds[\saveAsProjectButton])
.font_(~globalFont)
.states_([["Save as", nil, ~globalColor]])
.action_({ ~createNameWindow.value() });

~loadProjectButton = Button(w, ~ui_bounds[\loadProjectButton])
.font_(~globalFont)
.states_([["Load", nil, ~globalColor]])
.action_({
	var isNoFilesCheck = ~loadFilesPopUp.item;
	if (isNoFilesCheck !== '-', {
		var filePathToLoad = ~folderPath ++ 'save/' ++ ~loadFilesPopUp.item ++ '.song';
		var loaded = filePathToLoad.load;
		var tempo;
		~allBeats = loaded[\allPatterns][0].deepCopy;
		~allBeats_original = loaded[\allPatterns][0].deepCopy;
		~allPatterns = loaded[\allPatterns].deepCopy;
		~allSamplers = loaded[\allSamplers].deepCopy;
		~currentKit = loaded[\theKit];
		~editKitPopUp.value(~editKitPopUp.items.indexOf(~currentKit));
		~changeKitFunc.value();
		~allEffectValues = loaded[\allEffectValues].deepCopy;
		~allEffectValues.postln;
		~allEffects.size.do({
			|i|
			if (i > 0, {
				~allEffects[i][3].set(\edit, loaded[\allEffectValues][i][0]);
				~allEffects[i][3].set(\edit2, loaded[\allEffectValues][i][1]);
			});
		});
		{
			~editEffectsLabel1.string_(~allEffects[1][4][0]);
			~editEffectsLabel2.string_(~allEffects[1][4][1]);
		}.defer;
		~effectsSlider1.value_(loaded[\allEffectValues][1][0]);
		~effectsSlider2.value_(loaded[\allEffectValues][1][1]);
		~editEffectChoose.value_(0);
		tempo = loaded[\tempo];
		~tempoString.string_((tempo * 60).floor + "bpm");
		~tempo = TempoClock.tempo_(tempo);
		~eidtModePopUp.value_(0);
		~editModePopUpAction.value(0);
		~patternChoicePopUp.items_(~allPatterns.collect({ |item, index| index; }));
		~allBeats_original = loaded[\allPatterns][0].deepCopy;
		~allBeats_original.flatten.do({
			|step, stepIndex|
			~allButtons[stepIndex].value_(if (step !== \, 1, 0));
		});
		~currentPattern = 0;
		~patternChoiceFunc.value(0);
	});
});

~deleteProjectButton = Button(w, ~ui_bounds[\deleteProjectButton])
.font_(~globalFont)
.states_([["Delete", nil, ~globalColor]])
.action_({
	var filePathToDelete = ~folderPath ++ 'save/' ++ ~loadFilesPopUp.item ++ '.song';
	File.delete(filePathToDelete);
	~loadFilesPopUp.items_(~loadFilesFunction.value());
});

~saveProjectButton = Button(w, ~ui_bounds[\saveProjectButton])
.font_(~globalFont)
.states_([["Save", nil, ~globalColor]])
.action_({
	var path, toSave, patterns;
	path = ~folderPath ++ 'save/' ++ ~loadFilesPopUp.item ++ '.song';
	File.delete(path);
	patterns = ~allPatterns.deepCopy;
	patterns[~patternChoicePopUp.value] = ~allBeats_original.deepCopy;
	toSave = Dictionary[
		\allEffectValues -> ~allEffectValues.deepCopy,
		\allSamplers -> ~allSamplers.deepCopy,
		\allPatterns -> patterns,
		\theKit -> ~currentKit,
		\tempo -> ~tempo.tempo,
	];
	toSave.writeArchive(path);
});

~loadFilesFunction = {
	var path = ~folderPath ++ 'save/';
	var output = PathName.new(path).entries.collect({
		|filePath|
		filePath.fileNameWithoutExtension;
	});
	if (output.size < 1, {['-']}, {output});
};
~loadFilesPopUp = PopUpMenu(w, ~ui_bounds[\loadFilesPopUp])
.background_(~globalColor)
.font_(~globalFont)
.items_(~loadFilesFunction.value())
.value_(0);

~globalTitle = StaticText(w, ~ui_bounds[\globalTitle]).string_("SETTINGS")
.font_(~globalFont);
~editBoxTitle = StaticText(w, ~ui_bounds[\editBoxTitle]).string_("EDIT PATTERN")
.font_(~globalFont);
~editEffectsTitle = StaticText(w, ~ui_bounds[\editEffectTitle]).string_("GLOBAL EFFECTS")
.font_(~globalFont);

~editEffectLabel = StaticText(w, ~ui_bounds[\editEffectLabel]).string_("Effect:")
.font_(~globalFont);
~editEffectChoose = PopUpMenu(w, ~ui_bounds[\editEffectChoose])
.background_(~globalColor)
.font_(~globalFont)
.items_(~allEffects.collect({ |element| element[0]})[1..~allEffects.size])
.value_(0)
.action_({
	|menu|
	var theEffect = ~allEffects[menu.value + 1];
	~effectsSlider1.value_(~allEffectValues[~editEffectChoose.value + 1][0]);
	~effectsSlider2.value_(~allEffectValues[~editEffectChoose.value + 1][1]);
	{
		~editEffectsLabel1.string_(theEffect[4][0]);
		~editEffectsLabel2.string_(theEffect[4][1]);
	}.defer;
});

~effectsSliderFunc = {
	|slider, i, edit|
	~allEffectValues[~editEffectChoose.value + 1][i] = slider.value;
	~allEffects[~editEffectChoose.value + 1][3].set(\edit, slider.value);
};
~effectsSlider1 = Slider(w, ~ui_bounds[\effectsSlider1])
.background_(~globalColor)
.font_(~globalFont)
.value_(1)
.action_({ ~effectsSliderFunc.value(~effectsSlider1, 0, \edit) });

~effectsSlider2 = Slider(w, ~ui_bounds[\effectsSlider2])
.background_(~globalColor)
.font_(~globalFont)
.value_(1)
.action_({ ~effectsSliderFunc.value(~effectsSlider2, 1, \edit2) });

~theSamplerNumbers = 8.collect({
	|i|
	StaticText(w, Rect(40, (~topMargin - 3) + (i * 15.5), 60, 25)).string_(i).font_(Font("Hiragino Sans", size: 11));
});

~tempoString = StaticText(w, ~ui_bounds[\tempoLabel]).string_(((~tempo.tempo * 60) + "bpm"))
.font_(~globalFont)
.align_(\left);
~tempoButtonFunction = {
	|newTempo|
	~tempo = TempoClock.tempo_(newTempo / 60);
	~tempoString.string_(newTempo.floor + "bpm");
};
~tempoButtons = [
	Button(w, ~ui_bounds[\tempoButton1])
	.font_(~globalFont)
	.states_([["+", nil, ~globalColor]])
	.action_({
		var newTempo = (~tempo.tempo * 60) + 10;
		if (newTempo <= 300, { ~tempoButtonFunction.value(newTempo) });
	}),
	Button(w, ~ui_bounds[\tempoButton2])
	.font_(~globalFont)
	.states_([["-", nil, ~globalColor]])
	.action_({
		var newTempo = (~tempo.tempo * 60) - 10;
		if (newTempo >= 10, { ~tempoButtonFunction.value(newTempo) });
	}),
];

~uiUpdateHelperFunc = {
	|i|
	var newTypes = ~randomnessChoiceTypesBasic.collect({ |element| element[0] })
	++ ~allKits[~currentKit][~editMode[\sampler]].collect({
		|element| element[\fileName];
	});
	~mainSeqSampleChoiceControls.items_(newTypes);
	~mainSeqSampleChoiceControls.value_(~allSamplers[i][\theSampler][\streamPopUpItem]);
	~editAmpSlider.value_(~allSamplers[i][\theAmp][\baseAmp]);
	~editAmp.value_(~allSamplers[i][\theAmp][\streamPopUpItem]);
	~editBaseRatePopUp.value_(~editBaseRateItems.indexOf(~allSamplers[i][\theRate][\baseRate]));
	~editRatePopUp.value_(~allSamplers[i][\theRate][\streamPopUpItem]);
	~editEffectsPopUp.value_(~allSamplers[i][\theEffect][0]);
};

~editModePopUpAction = {
	|menu|
	var mainEditMenuItems = [
		~sampleChoiceControlsLabel, ~mainSeqSampleChoiceControls,
		~chooseSamplerLabel, ~chooseSamplerPopUp,
		~editAmpLabel, ~editAmpSlider, ~editAmp,
		~editBaseRateLabel, ~editRatePopUp, ~editBaseRatePopUp,
		~editEffectsLabel, ~editEffectsPopUp,
	];
	var stepEditMenuItems = [
		~sampleChoiceControlsLabel, ~mainSeqSampleChoiceControls,
		~editAmpLabel, ~editAmpSlider,
		~editBaseRateLabel, ~editBaseRatePopUp,
		~editProbLabel, ~editProbSlider,
		~measureControlsLabel, ~measureControlsPopUp,
		~editEffectsLabel, ~editEffectsPopUp,
	];
	var noStepSelectedItems = [
		~sampleChoiceControlsLabel, ~mainSeqSampleChoiceControls,
		~chooseSamplerLabel, ~chooseSamplerPopUp,
		~editAmpLabel, ~editAmpSlider, ~editAmp,
		~editBaseRateLabel, ~editRatePopUp, ~editBaseRatePopUp,
		~editProbLabel, ~editProbSlider,
		~measureControlsLabel, ~measureControlsPopUp,
		~editEffectsLabel, ~editEffectsPopUp,
	];
	noStepSelectedItems.do({ |element| element.visible_(false) });
	if (menu.value == 0,
		{
			var newTypes;
			~editMode[\isEditMode] = false;
			~editMode[\canEditThisStep] = false;

			{~editBoxTitle.string_("EDIT PATTERN")}.defer;
			mainEditMenuItems.do({ |element| element.visible_(true) });

			~chooseSamplerPopUp.value_(0);
			~uiUpdateHelperFunc.value(0);
		},
		{
			~editMode[\isEditMode] = true;
			if (
				~editMode[\canEditThisStep] == true,
				{
					// once a box is clicked in the step menu, show the items
					{~editBoxTitle.string_("EDIT STEP")}.defer;
					stepEditMenuItems.do({ |element| element.visible_(true) });
					~mainSeqSampleChoiceControls
					.items_(~allKits[~currentKit][~editMode[\sampler]].collect({
						|element| element[\fileName];
					}));
				},
				{
					{~editBoxTitle.string_("Select step...").font_(~globalFont)}.defer;
				}
			);
		}
	);
};
~editModeWriting = StaticText(w, ~ui_bounds[\editModeLabel]).string_("Edit mode:")
.font_(~globalFont)
.align_(\left);
~eidtModePopUp = PopUpMenu(w, ~ui_bounds[\editModePopUp])
.background_(~globalColor)
.font_(~globalFont)
.items_(['Pattern', 'Step'])
.value_(0)
.action_({ |menu| ~editModePopUpAction.value(menu) });

~editKitLabel = StaticText(w, ~ui_bounds[\editKitLabel]).string_("Kit:")
.font_(~globalFont)
.align_(\left);
~editKitPopUp = PopUpMenu(w, ~ui_bounds[\editKitPopUp])
.background_(~globalColor)
.font_(~globalFont)
.items_(~allKits.keys.asArray)
.value_(0)
.action_({
	|menu|
	~currentKit = menu.item;
	~changeKitFunc.value();
});
// init values
~currentKit = ~editKitPopUp.item;
~changeKitFunc.value();

~chooseSamplerLabel = StaticText(w, ~ui_bounds[\chooseSamplerLabel])
.string_("Sampler:")
.font_(~globalFont)
.align_(\left);
~chooseSamplerPopUp = PopUpMenu(w, ~ui_bounds[\chooseSamplerPopUp])
.background_(~globalColor)
.font_(~globalFont)
.items_(Array.series(8))
.value_(0)
.action_({
	|menu|
	var newTypes;
	~editMode[\sampler] = menu.value;

	~sampleChoiceControlTypes = ~randomnessChoiceTypesBasic
	++ ~allKits[~currentKit][~editMode[\sampler]].collect({
		|element, index|
		[element[\fileName], index];
	});

	~uiUpdateHelperFunc.value(menu.value);
});

~randomnessChoiceTypesBasic = [
	['Exponential', \exprand],
	['High', \hprand],
	['Low', \lprand],
	['Mean', \meanrand],
	['No repeat', \xrand],
	['True', \rand],
];

// init values
~sampleChoiceControlTypes = ~randomnessChoiceTypesBasic ++ ~allKits[~currentKit][0].collect({
	|element, index|
	[element[\fileName], index];
});

~sampleChoiceControlsLabel = StaticText(w, ~ui_bounds[\sampleChoiceControlsLabel])
.font_(~globalFont)
.string_("Sample:")
.align_(\left);

~mainSeqSampleChoiceControls = PopUpMenu(w, ~ui_bounds[\sampleChoiceControlsPopUp])
.background_(~globalColor)
.font_(~globalFont)
.items_(~sampleChoiceControlTypes.collect({ |element| element[0] }))
.value_(0)
.action_({
	|menu|
	var theSampler = ~editMode[\sampler];

	if ((~editMode[\isEditMode] == true && ~editMode[\canEditThisStep] == true),
		{
			var beat, step;
			# beat, step = ~theBeatToEdit;
			~allBeats[beat][step][0][\sample] = menu.value;
		},
		{
			~allSamplers[theSampler][\theSampler][\streamPopUpItem] = menu.value;
			~allSamplers[theSampler][\theSampler][\stream] = ~sampleChoiceControlTypes[menu.value][1];
		}
	);
});

~editBaseRateLabel = StaticText(w, ~ui_bounds[\editBaseRateLabel])
.font_(~globalFont)
.string_("Rate:")
.align_(\left);
~editBaseRatePopUp = PopUpMenu(w, ~ui_bounds[\editBaseRatePopUp])
.background_(~globalColor)
.font_(~globalFont)
.items_(~editBaseRateItems)
.value_(6)
.action_({
	|menu|
	var theSampler = ~editMode[\sampler];
	if ((~editMode[\isEditMode] == true && ~editMode[\canEditThisStep] == true),
		{
			var beat, step;
			# beat, step = ~theBeatToEdit;
			~allBeats[beat][step][0][\rate] = menu.item;
		},
		{
			~allSamplers[theSampler][\theRate][\baseRate] = menu.item;
		}
	);
});

~editRateTypes = [['None', \none]] ++ ~randomnessChoiceTypesBasic;
~editRateLabel = StaticText(w, ~ui_bounds[\editRateLabel])
.font_(~globalFont)
.string_("Rate alg:")
.align_(\left);
~editRatePopUp = PopUpMenu(w,~ui_bounds[\editRatePopUp])
.background_(~globalColor)
.font_(~globalFont)
.items_(~editRateTypes.collect({ |element| element[0] }))
.value_(0)
.action_({
	|menu|
	var theSampler = ~editMode[\sampler];
	~allSamplers[theSampler][\theRate][\streamPopUpItem] = menu.value;
	~allSamplers[theSampler][\theRate][\stream] = ~editRateTypes[menu.value][1];
});

~editEffectsLabel = StaticText(w, ~ui_bounds[\editEffectsLabel])
.font_(~globalFont)
.string_("Effect:")
.align_(\left);
~editEffectsPopUp = PopUpMenu(w, ~ui_bounds[\editEffectsPopUp])
.background_(~globalColor)
.font_(~globalFont)
.items_(~allEffects.collect({ |element| element[0]}))
.background_(~globalColor)
.font_(~globalFont)
.value_(0)
.action_({
	|menu|
	var theSampler = ~editMode[\sampler];
	if ((~editMode[\isEditMode] == true && ~editMode[\canEditThisStep] == true),
		{
			var beat, step;
			# beat, step = ~theBeatToEdit;
			~allBeats[beat][step][0][\theEffect] = ~allEffects[menu.value][1];
		},
		{
			~allSamplers[theSampler][\theEffect][0] = menu.value;
			~allSamplers[theSampler][\theEffect][1] = ~allEffects[menu.value][1];
		}
	);
});

~editEffectsLabel1 = StaticText(w, ~ui_bounds[\editEffectsLabel1])
.font_(~globalFont)
.string_(~allEffects[1][4][0])
.align_(\left);

~editEffectsLabel2 = StaticText(w, ~ui_bounds[\editEffectsLabel2])
.font_(~globalFont)
.string_(~allEffects[1][4][1])
.align_(\left);

~measureControlValues = [
	['1:1', []],
	['1:2', [1, 3]],
	['2:2', [0, 2]],
	['1:4', [1, 2, 3]],
	['2:4', [0, 2, 3]],
	['3:4', [0, 1, 3]],
	['4:4', [0, 1, 2]],
];
~measureControlsLabel = StaticText(w, ~ui_bounds[\measureControlsLabel])
.font_(~globalFont)
.string_("Measure:")
.visible_(false)
.align_(\left);

~measureControlsPopUp = PopUpMenu(w, ~ui_bounds[\measureControlsPopUp])
.background_(~globalColor)
.font_(~globalFont)
.items_(~measureControlValues.collect({ |i| i[0] }))
.visible_(false)
.value_(0)
.action_({
	|menu|
	if ((~editMode[\isEditMode] == true && ~editMode[\canEditThisStep] == true), {
		var beat, step;
		# beat, step = ~theBeatToEdit;
		~allBeats[beat][step][0][\iteration] = ~measureControlValues[menu.value][1];
	});
});

~editAmpLabel = StaticText(w, ~ui_bounds[\editAmpLabel])
.font_(~globalFont)
.string_("Amp:")
.align_(\left);

~editAmpSlider = Slider(w, ~ui_bounds[\editAmpSlider])
.background_(~globalColor)
.font_(~globalFont)
.value_(1)
.action_({
	var theSampler = ~editMode[\sampler];
	if ((~editMode[\isEditMode] == true && ~editMode[\canEditThisStep] == true),
		{
			var beat, step;
			# beat, step = ~theBeatToEdit;
			~allBeats[beat][step][0][\amp] = ~editAmpSlider.value;
		},
		{
			~allSamplers[theSampler][\theAmp][\baseAmp] = ~editAmpSlider.value;
		}
	);
});

~editAmp = PopUpMenu(w, ~ui_bounds[\editAmp])
.background_(~globalColor)
.font_(~globalFont)
.items_(~editRateTypes.collect({ |element| element[0] }))
.value_(0)
.action_({
	var theSampler = ~editMode[\sampler];
	~allSamplers[theSampler][\theAmp][\streamPopUpItem] = ~editAmp.value;
	~allSamplers[theSampler][\theAmp][\stream] = ~editRateTypes[~editAmp.value][1];
});

~editProbLabel = StaticText(w, ~ui_bounds[\editProbLabel])
.font_(~globalFont)
.string_("Prob:")
.align_(\left)
.visible_(false);

~editProbSlider = Slider(w, ~ui_bounds[\editProbSlider])
.background_(~globalColor)
.font_(~globalFont)
.visible_(false)
.value_(1)
.action_({
	if ((~editMode[\isEditMode] == true && ~editMode[\canEditThisStep] == true), {
		var beat, step;
		# beat, step = ~theBeatToEdit;
		~allBeats[beat][step][0][\prob] = ~editProbSlider.value;
	});
});

~basicThemes.do({ |theme| theme[\theme].stop });
~editThemeLabel = StaticText(w, ~ui_bounds[\editThemeLabel])
.font_(~globalFont)
.string_("Theme:")
.align_(\left);
~editThemePopUp = PopUpMenu(w, ~ui_bounds[\editThemePopUp])
.background_(~globalColor)
.font_(~globalFont)
.items_(~basicThemes.collect({ |element| element[\name] }))
.value_(0)
.action_({
	|element|
	~basicThemes.do({ |theme| theme[\theme].stop });
	~beatResetAll.value();
	~basicThemes[element.value][\theme].reset;
	~basicThemes[element.value][\theme].play;
});

~paintSquaresFunc = {
	|line|
	var count = -1;
	var isButtonColor = true;

	line.do({
		|element|
		count = count + 1;
		if (count == 8,  {
			isButtonColor = isButtonColor.not;
			count = 0;
		});
		element.states_([
			[nil, nil, if (isButtonColor == true, ~stepColor1, ~stepColor2)],
			[nil, nil, ~stepOnColor],
		]);
	});
};

~allSamplers.size.do({
	|index|
	~paintSquaresFunc.value(~samplerFillFunc.value(index))
});

~paintButtonFunc = {
	~allBeats_original.flatten.do({
		|step, stepIndex|
		~allButtons[stepIndex].value_(if (step !== \, 1, 0));
	});
};
~paintButtonFunc.value();

~patternChoiceFunc = {
	|item|
	var selectedPattern;
	~allPatterns[~currentPattern] = ~allBeats_original.deepCopy;
	~currentPattern = ~patternChoicePopUp.value;
	selectedPattern = ~allPatterns[item];
	~allBeats.size.do({
		|element, samplerIndex|
		~allBeats[samplerIndex].do({
			|element, stepIndex|
			~allBeats[samplerIndex][stepIndex] = selectedPattern[samplerIndex][stepIndex];
			~allBeats_original[samplerIndex][stepIndex] = selectedPattern[samplerIndex][stepIndex];
		});
	});
	~paintButtonFunc.value();
};

~currentPattern = 0;
~editPatternLabel = StaticText(w, ~ui_bounds[\editPatternLabel])
.font_(~globalFont)
.string_("Pattern:")
.align_(\left);
~patternChoicePopUp = PopUpMenu(w, ~ui_bounds[\patternChoicePopUp])
.background_(~globalColor)
.font_(~globalFont)
.items_(~allPatterns.collect({ |item, index| index; }))
.value_(0)
.action_({ |item| ~patternChoiceFunc.value(item.value); });

~addPatternButton = Button(w, ~ui_bounds[\addPatternButton])
.font_(~globalFont)
.states_([["Add new", nil, ~globalColor]])
.action_({
	~allPatterns = ~allPatterns ++ [8.collect({ \.dup(~patternLength).asStream; })];
	~patternChoicePopUp.items_(~allPatterns.collect({ |item, index| index; }));
});

~deletePatternButton = Button(w, ~ui_bounds[\deletePatternButton])
.font_(~globalFont)
.states_([["Delete", nil, ~globalColor]])
.action_({
	var patternValue = ~patternChoicePopUp.value;
	~patternChoiceFunc.value(patternValue - 1);
	~allPatterns.removeAt(patternValue);
	~patternChoicePopUp.items_(~allPatterns.collect({ |item, index| index; }));
	~patternChoicePopUp.value_(patternValue - 1);
	~currentPattern = patternValue - 1;
});