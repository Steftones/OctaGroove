~topMargin = 65;
~makeContainer = {
	|val1, val2, rows|
	val1.collect({
		|i|
		[
			Rect(val1, val2 + (i * 20), 100, 20),
			Rect(val1 + 80, val2 + (i * 20), 100, 20),
			Rect(val1 + 200, val2 + (i * 20), 100, 20),
		]
	});
};

~box0 = ~makeContainer.value(50, 215, 10);
~box1 = ~makeContainer.value(350, 215, 10);
~box2 = ~makeContainer.value(700, 215, 10);

StaticText(w, Rect(50, 25, 200, 30)).string_("AlgoBeats").font_(Font(size: 20));

~ui_bounds = Dictionary[
	\tempoLabel -> Rect(170, 30, 60, 25),
	\tempoButton1 -> Rect(235, 30, 20, 20),
	\tempoButton2 -> Rect(255, 30, 20, 20),
	\playStopButton -> Rect(290, 30, 30, 20),
	\saveAsProjectButton -> Rect(525, 30, 60, 20),
	\saveProjectButton -> Rect(600, 30, 60, 20),
	\deleteProjectButton -> Rect(675, 30, 60, 20),
	\loadProjectButton -> Rect(750, 30, 60, 20),
	\loadFilesPopUp -> Rect(825, 30, 120, 20),

	// box 0
	\globalTitle -> Rect(50, 210, 100, 20),
	\editModeLabel -> ~box0[1][0],
	\editModePopUp -> ~box0[1][1],
	\editKitLabel -> ~box0[3][0],
	\editKitPopUp -> ~box0[3][1],
	\editThemeLabel -> ~box0[4][0],
	\editThemePopUp  -> ~box0[4][1],
	\editPatternLabel -> ~box0[5][0],
	\patternChoicePopUp -> ~box0[5][1],
	\addPatternButton -> Rect(50, 335, 80, 20),
	\deletePatternButton -> ~box0[6][1],

	// box 1
	\editBoxTitle -> Rect(350, 210, 500, 20),
	\sampleChoiceControlsLabel -> ~box1[1][0],
	\sampleChoiceControlsPopUp -> ~box1[1][1],
	\editAmpLabel -> ~box1[2][0],
	\editAmpSlider -> ~box1[2][1],
	\editAmp -> ~box1[2][2],
	\editBaseRateLabel -> ~box1[3][0],
	\editBaseRatePopUp -> ~box1[3][1],
	\chooseSamplerLabel -> ~box1[4][0],
	\chooseSamplerPopUp -> ~box1[4][1],
	\editRatePopUp -> ~box1[3][2],
	\editProbLabel -> ~box1[4][0],
	\editProbSlider -> ~box1[4][1],
	\measureControlsLabel -> ~box1[5][0],
	\measureControlsPopUp -> ~box1[5][1],
	\editEffectsLabel -> ~box1[6][0],
	\editEffectsPopUp -> ~box1[6][1],

	// box 2
	\editEffectTitle -> Rect(700, 210, 300, 20),
	\editEffectLabel -> ~box2[1][0],
	\editEffectChoose -> ~box2[1][1],
	\editEffectsLabel1 -> ~box2[2][0],
	\effectsSlider1 -> ~box2[2][1],
	\editEffectsLabel2 -> ~box2[3][0],
	\effectsSlider2 -> ~box2[3][1],
];