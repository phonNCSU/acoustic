
import argparse, random
import praatmfc as MFC

parser = argparse.ArgumentParser(description='Split a Praat MFC script into scripts that will play smaller subsets of the clips')
parser.add_argument('--mfc', default='[none listed]', help='your MFC script')
parser.add_argument('--max', default=1000, help='the maximum number of clips you want to listen to in one session')
parser.add_argument('--word', default='False', help='whether to split by word')
parser.add_argument('--shuffle', default='True', help='whether to shuffle the stimuli')
args = parser.parse_args()

print('\n########################################')
if args.word == 'True':
	print('Preparing to split:', args.mfc, 'into scripts by word...')
else:
	print('Preparing to split:', args.mfc, 'into scripts with no more than', args.max, 'clips each...')
print('########################################')
	
max_per_script = int(args.max)

[top_of_script, bottom_of_script, stimuli] = MFC.readscript(args.mfc)

if args.shuffle == "True":
	random.shuffle(stimuli)

output_basename = args.mfc.replace('.praat','')

# MAKE THIS A DICTIONARY	!
stimulus_sets = {}

if args.word == 'True':
	# for s in stimuli:
	# 	print(s)

	for stimulus in stimuli:
		word = stimulus.split('"')[3]

		if not word in stimulus_sets.keys():
			stimulus_sets[word] = []

		stimulus_sets[word].append(stimulus)

	for stimulus_name in stimulus_sets.keys():
		output_name = output_basename + '_' + stimulus_name + '.praat' 
		MFC.writescript(output_name, top_of_script, bottom_of_script, stimulus_sets[stimulus_name])

else:

	if len(stimuli) <= max_per_script:
		print('Number of stimuli is less than requested maximum: nothing to do.')
		print('To split your script, choose max less than '+str(len(stimuli))+'.')

	else:
		print (len(stimuli), 'stimuli')

		stimulus_number = 1
		stimulus_name = str(stimulus_number)
		stimulus_sets[stimulus_name] = []

		while len(stimuli) > 0:

			if len(stimulus_sets[stimulus_name]) == max_per_script:
				print(len(stimulus_sets[stimulus_name]), 'stimuli in', stimulus_name)
				stimulus_number += 1
				stimulus_name = str(stimulus_number)
				stimulus_sets[stimulus_name] = []

			stimulus_sets[stimulus_name].append(stimuli.pop())

		for stimulus_name in stimulus_sets.keys():
			output_name = output_basename + '_' + stimulus_name + '_of_' + str(len(stimulus_sets.keys())) + '.praat' 
			MFC.writescript(output_name, top_of_script, bottom_of_script, stimulus_sets[stimulus_name])

print('########################################\n')
