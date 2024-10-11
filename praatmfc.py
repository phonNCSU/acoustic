
def readscript(script_path):

	with open(script_path) as f:
		big_script_lines = f.readlines()

	top_of_script = []
	bottom_of_script = []
	stimuli = []
	reached_stimuli = False
	finished_stimuli = False

	for line in big_script_lines:

		if line.startswith("numberOfDifferentStimuli"):
			reached_stimuli = True
			stated_number_of_stimuli = int(line.split('=')[1])

		elif line.startswith("numberOfReplicationsPerStimulus"):
			finished_stimuli = True

		if reached_stimuli == False:
			top_of_script.append(line)
		elif finished_stimuli:
			bottom_of_script.append(line)
		elif not line.startswith("numberOfDifferentStimuli"):
			stimuli.append(line)

	actual_number_of_stimuli = len(stimuli)

	if stated_number_of_stimuli != actual_number_of_stimuli:
		print('WARNING: script says', stated_number_of_stimuli, 'but lists', actual_number_of_stimuli)

	return [top_of_script, bottom_of_script, stimuli]

def writescript(script_path, top_of_script, bottom_of_script, stimuli):

	with open(script_path, 'w') as f:
		for line in top_of_script:
			f.write(line)
		f.write('numberOfDifferentStimuli = '+str(len(stimuli))+'\n')
		for stim in stimuli:
			f.write(stim)
		for line in bottom_of_script:
			f.write(line)
	print('wrote', script_path, 'with', len(stimuli), 'clips')