~fillWithBeatsFunc = {
	|theBeat, fillNum = 4, isTriplet = false|
	var findInstanceOfBeat = ~allBeats[theBeat].collect({ |i| i.isMemberOf(Array); }).findAll([ true ]);
	if (findInstanceOfBeat == nil, {}, {
		var start = findInstanceOfBeat.choose;
		var beatToAdd, startAr, output;
		beatToAdd = if (isTriplet == true,
			{
				[[Dictionary.newFrom(~baseStepDictionary)], \, \]
			},
			{
				[[Dictionary.newFrom(~baseStepDictionary)], \, \, \]
			}
		);
		startAr = if (start == 0, nil, ~allBeats[theBeat][0..start - 1]);
		output = startAr ++ beatToAdd.dup(fillNum).flatten ++ ~allBeats[theBeat][(start + (fillNum * 2))..~allBeats[theBeat].size];
		output = output[0..(~allBeats[theBeat].size)];
		~patternLength.do({ |i| ~allBeats[theBeat][i] = output[i] });
	});
};

~beatReset = { |i| ~allBeats[i] = ~allBeats_original[i].deepCopy };
~beatResetAll = { ~allBeats.do({ |i, j| ~allBeats[j] = ~allBeats_original[j].deepCopy }) };

~moveBeat = {
	|theBeat, move = 1|
	var output, copy;
	if (move >= ~allBeats[theBeat].size, ~allBeats[theBeat], {

		output = ~allBeats[theBeat].collect({ |i| i.isMemberOf(Array); }).findAll([ true ]);

		if (output !== nil,
			{
				copy = ~allBeats[theBeat].deepCopy;
				output = output.choose;
				if (0.5.coin,
					{
						if (output + move >= copy.size,
							{
								copy.swap(output, output - move);
							},
							{
								copy.swap(output, output + move);
							}
						);
					},
					{
						if (output - move < 0,
							{
								copy.swap(output, output + move);
							},
							{
								copy.swap(output, output - move);
							}
						);
					}
				);
				~allBeats[theBeat] = copy;
			},
			~allBeats[theBeat]
		);
	});
};