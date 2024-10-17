
import argparse

# COLLECT USER INPUT (WHAT FILE TO READ AND WHAT TO NAME THE TIER (IF NOT "transcript"))
parser = argparse.ArgumentParser(description='Group similar sounds to present together with a Praat MFC script')
parser.add_argument('--input', default='xxx', help='the path to read')
args = parser.parse_args()

original_filename = args.input

isi = 0.25

new_filename = original_filename.replace('.praat','')+'_grouped_clips.praat'

with open(original_filename) as f:
	lines = f.readlines()


for i,line in enumerate(lines):

	if line.startswith('numberOfDifferentStimuli'):
		first_stimulus = i+1
	elif line.startswith('numberOfReplicationsPerStimulus'):
		first_nonstimulus = i

output = []

token_dict = {}

for line in lines[:first_stimulus]:

	if line.startswith('stimulusMedialSilenceDuration'):
		output.append('stimulusMedialSilenceDuration = '+str(isi)+' seconds\n')
	else:
		output.append(line)

for line in lines[first_stimulus:first_nonstimulus]:

	token = line.strip().split('"')[1]
	token_info = token.split('_')
	word = token_info[-1]
	# clip_time = '_'.join(token_info[-3:-1])
	discourse = '_'.join(token_info[:-3])

	if not discourse in token_dict.keys():
		token_dict[discourse] = {}
	if not word in token_dict[discourse].keys():
		token_dict[discourse][word] = []

	token_dict[discourse][word].append(token)

	# output.append(line)

stimulus_lines = []

for discourse in token_dict.keys():
	for word in token_dict[discourse].keys():
		stimulus_lines.append('    "'+','.join(token_dict[discourse][word])+'" "'+word+'"\n')

output[first_stimulus-1] = 'numberOfDifferentStimuli = '+str(len(stimulus_lines))+'\n'

for line in stimulus_lines:
	output.append(line)

for line in lines[first_nonstimulus:]:
	output.append(line)

with open(new_filename, 'w') as f:
	for o in output:
		f.write(o)
