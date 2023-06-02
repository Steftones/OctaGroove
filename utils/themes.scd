~basicThemes = [
	Dictionary[
		\name -> "None",
		\theme -> Routine {
			'No theme is playing...'.postln;
		}.play(quant: 1),
	],
	Dictionary[
		\name -> "Basic",
		\theme -> Routine {
			var randomChoice = Pxrand([4, 8, 12], inf).asStream;
			var theme = Pxrand(
				(
					[
						[{ ~moveBeat.value(0, randomChoice.next) }, { ~beatReset.value(0) }, \, \]
						++ [{ ~moveBeat.value(0, randomChoice.next) }, \, \, { ~beatReset.value(0) }]
						++ [{ ~moveBeat.value(1, randomChoice.next) }, \, \, { ~beatReset.value(1) }]
						++ ([{ ~moveBeat.value(1, randomChoice.next) }, { ~beatReset.value(1) }, \, \] ! 2)
						++ [\, { ~moveBeat.value(1, randomChoice.next) }, \, { ~beatReset.value(1) }]
						++ [{ ~moveBeat.value(1, randomChoice.next) }, { ~moveBeat.value(0, randomChoice.next) }, { ~beatReset.value(1) }, { ~beatReset.value(0) }]
						++ [{ ~fillWithBeatsFunc.value(1, 2) }, { ~beatReset.value(1) }, \, \]
						++ ([{ ~fillWithBeatsFunc.value(2, 2) }, { ~beatReset.value(2) }, \, \] ! 4)
						++ ([{ ~fillWithBeatsFunc.value(2, 8) }, { ~beatReset.value(2) }, \, \] ! 2)
						++ ([{ ~fillWithBeatsFunc.value(1, 4) }, { ~beatReset.value(1) }, \, \] ! 2)
						++ [{ ~fillWithBeatsFunc.value(2, 4) }, { ~fillWithBeatsFunc.value(1, 4) }, { ~beatReset.value(1) }, { ~beatReset.value(2) }]
					]
				).collect({ |i| Pseq(i, 1) })
				, inf).asStream;
			'Basic theme is playing...'.postln;
			loop {
				theme.next.();
				4.wait
			};
		}.play(quant: 1),
	],
	Dictionary[
		\name -> "Burst",
		\theme -> Routine {
			'Burst theme is playing...'.postln;
			loop {
				var choice1 = [0, 1, 2].choose;
				var choice2 = [2, 3, 4, 6, 8].wchoose([10, 2, 10, 10, 10].normalizeSum);
				var choice3 = 0.3.coin;
				~fillWithBeatsFunc.value(choice1, choice2, choice3);
				12.wait;
        ~beatReset.value([0, 1, 2].choose);
				12.wait;
			};
		}.play(quant: 1),
	],
];
