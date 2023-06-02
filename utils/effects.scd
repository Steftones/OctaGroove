~allEffects = [
	[
		"None",
		0,
		nil,
		nil,
		['-', '-'],
	],
	[
		"Reverb",
		5,
		SynthDef.new(\reverb, {
			|in = 5, out = 0, reverbTime = 5, preDelay = 0.025, lpf1 = 2800, lpf2 = 6000, edit = 1, edit2 = 1|
			var dry, wet;
			dry = In.ar(in, 2);
			wet = In.ar(in, 2);
			wet = DelayN.ar(wet, 0.5, preDelay.clip(0.0001, 0.5));
			wet = 16.collect({
				var temp;
				temp = CombL.ar(
					wet, 0.1,
					LFNoise1.kr({ ExpRand(0.02, 0.04) } ! 2).exprange(0.02, 0.098),
					reverbTime * edit
				);
				temp = LPF.ar(temp, lpf1 * edit2);
			}).sum * 0.25;
			8.do({
				wet = AllpassL.ar(
					wet, 0.1,
					LFNoise1.kr({ ExpRand(0.02, 0.04) } ! 2).exprange(0.02, 0.098),
					reverbTime * edit
				);
			});
			wet = LeakDC.ar(wet);
			wet = LPF.ar(wet, lpf2, 0.5);
			wet = XFade2.ar(dry, wet, edit * 2 - 1);
			Out.ar(out, wet);
		}).add,
		Synth.new(\reverb).set(\in, 5),
		['Rev time:', 'LPF:'],
	],
	[
		"Comb Delay",
		7,
		SynthDef.new(\combDelay, {
			|in = 7, out = 0, delayTime = 0.5, edit = 1, edit2 = 1|
			var wet;
			var dry = In.ar(in, 2);
			var input = In.ar(in, 2);
			wet = CombL.ar(
				in: input,
				maxdelaytime: delayTime,
				delaytime: 4 * edit,
				decaytime: 4 * edit2,
			);
			wet = LeakDC.ar(wet);
			wet = XFade2.ar(dry, wet, 1 * 2 - 1);
			Out.ar(out, wet);
		}).add,
		Synth.new(\combDelay).set(\in, 7),
		['Delay time:', 'Decay time:'],
	],
	[
		"Delay",
		9,
		SynthDef.new(\delay, {
			|in = 9, out = 0, reverbTime = 6, preDelay = 0.025, lpf1 = 2800, lpf2 = 6000, mix = 0.7, edit = 1, edit2 = 1|
			var dry, wet;
			dry = In.ar(in, 2);
			wet = In.ar(in, 2);
			wet = DelayN.ar(wet, edit2, edit);
			wet = LPF.ar(wet, lpf2, 0.5);
			wet = LeakDC.ar(wet);
			wet = XFade2.ar(dry, wet, mix * 2 - 1);
			Out.ar(out, wet);
		}).add,
		Synth.new(\delay).set(\in, 9),
		['Delay time:', 'Max delay:'],
	],
];
