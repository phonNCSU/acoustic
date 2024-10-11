
import argparse, random, glob
import praatmfc as MFC


'''
python ~/scripts/phonNCSU/acoustic/subset_mfc_by_responses.py --mfc 'DFD469_*.praat' --csv '../responses/*Jeff*.csv' --response NA --output DFD469_Jeff_NA.praat
python ~/scripts/phonNCSU/acoustic/subset_mfc_by_responses.py --mfc 'DFD469_*.praat' --csv '../responses/*Jeff*.csv' --response other --output DFD469_Jeff_other.praat
python ~/scripts/phonNCSU/acoustic/subset_mfc_by_responses.py --mfc 'DFD469_*.praat' --csv '../drive-download-20240619T204643Z-001/*Griffin*.csv' --response NA --output DFD469_Griffin_NA.praat
python ~/scripts/phonNCSU/acoustic/subset_mfc_by_responses.py --mfc 'DFD469_*.praat' --csv '../drive-download-20240619T204643Z-001/*Griffin*.csv' --response other --output DFD469_Griffin_other.praat

python ~/scripts/phonNCSU/acoustic/subset_mfc_by_responses.py --mfc 'DFD469_*.praat' --csv '../responses/first43/*Quynh*.csv' --response NA --output DFD469_Quynh_NA.praat
python ~/scripts/phonNCSU/acoustic/subset_mfc_by_responses.py --mfc 'DFD469_*.praat' --csv '../responses/first43/*Quynh*.csv' --response other --output DFD469_Quynh_other.praat

####

python ~/scripts/phonNCSU/acoustic/subset_mfc_by_responses.py --mfc 'DFD469_*.praat' --csv '../responses/first43/*Ayumi*.csv' --response NA --output DFD469_Ayumi_NA.praat
python ~/scripts/phonNCSU/acoustic/subset_mfc_by_responses.py --mfc 'DFD469_*.praat' --csv '../responses/first43/*Ayumi*.csv' --response other --output DFD469_Ayumi_other.praat

python ~/scripts/phonNCSU/acoustic/subset_mfc_by_responses.py --mfc 'DFD469_*.praat' --csv '../responses/first43/*Saipreeti*.csv' --response NA --output DFD469_Saipreeti_NA.praat
python ~/scripts/phonNCSU/acoustic/subset_mfc_by_responses.py --mfc 'DFD469_*.praat' --csv '../responses/first43/*Saipreeti*.csv' --response other --output DFD469_Saipreeti_other.praat

python ~/scripts/phonNCSU/acoustic/subset_mfc_by_responses.py --mfc 'DFD469_*.praat' --csv '../responses/first43/*Olivia*.csv' --response NA --output DFD469_Olivia_NA.praat
python ~/scripts/phonNCSU/acoustic/subset_mfc_by_responses.py --mfc 'DFD469_*.praat' --csv '../responses/first43/*Olivia*.csv' --response other --output DFD469_Olivia_other.praat

python ~/scripts/phonNCSU/acoustic/subset_mfc_by_responses.py --mfc 'DFD469_*.praat' --csv '../responses/first43/*Kasey*.csv' --response NA --output DFD469_Kasey_NA.praat
python ~/scripts/phonNCSU/acoustic/subset_mfc_by_responses.py --mfc 'DFD469_*.praat' --csv '../responses/first43/*Kasey*.csv' --response other --output DFD469_Kasey_other.praat

python ~/scripts/phonNCSU/acoustic/subset_mfc_by_responses.py --mfc 'DFD469_*.praat' --csv '../responses/first43/*Erika*.csv' --response NA --output DFD469_Erika_NA.praat
python ~/scripts/phonNCSU/acoustic/subset_mfc_by_responses.py --mfc 'DFD469_*.praat' --csv '../responses/first43/*Erika*.csv' --response other --output DFD469_Erika_other.praat

####

python ~/scripts/phonNCSU/acoustic/subset_mfc_by_responses.py --mfc 'DFD469_*.praat' --csv '../responses/first43/*Jeannene*.csv' --response NA --output DFD469_Jeannene_NA.praat
python ~/scripts/phonNCSU/acoustic/subset_mfc_by_responses.py --mfc 'DFD469_*.praat' --csv '../responses/first43/*Jeannene*.csv' --response other --output DFD469_Jeannene_other.praat

python ~/scripts/phonNCSU/acoustic/subset_mfc_by_responses.py --mfc 'DFD469_*.praat' --csv '../responses/first43/*Easton*.csv' --response NA --output DFD469_Easton_NA.praat
python ~/scripts/phonNCSU/acoustic/subset_mfc_by_responses.py --mfc 'DFD469_*.praat' --csv '../responses/first43/*Easton*.csv' --response other --output DFD469_Easton_other.praat

python ~/scripts/phonNCSU/acoustic/subset_mfc_by_responses.py --mfc 'DFD469_*.praat' --csv '../responses/first43/*AmolS*.csv' --response NA --output DFD469_AmolS_NA.praat
python ~/scripts/phonNCSU/acoustic/subset_mfc_by_responses.py --mfc 'DFD469_*.praat' --csv '../responses/first43/*AmolS*.csv' --response other --output DFD469_AmolS_other.praat

python ~/scripts/phonNCSU/acoustic/subset_mfc_by_responses.py --mfc 'DFD469_*.praat' --csv '../responses/first43/*Tobin*.csv' --response NA --output DFD469_Tobin_NA.praat
python ~/scripts/phonNCSU/acoustic/subset_mfc_by_responses.py --mfc 'DFD469_*.praat' --csv '../responses/first43/*Tobin*.csv' --response other --output DFD469_Tobin_other.praat

python ~/scripts/phonNCSU/acoustic/subset_mfc_by_responses.py --mfc 'DFD469_*.praat' --csv '../responses/first43/*Shreya*.csv' --response NA --output DFD469_Shreya_NA.praat
python ~/scripts/phonNCSU/acoustic/subset_mfc_by_responses.py --mfc 'DFD469_*.praat' --csv '../responses/first43/*Shreya*.csv' --response other --output DFD469_Shreya_other.praat

python ~/scripts/phonNCSU/acoustic/subset_mfc_by_responses.py --mfc 'DFD469_*.praat' --csv '../responses/first43/*Aliha*.csv' --response NA --output DFD469_Aliha_NA.praat
python ~/scripts/phonNCSU/acoustic/subset_mfc_by_responses.py --mfc 'DFD469_*.praat' --csv '../responses/first43/*Aliha*.csv' --response other --output DFD469_Aliha_other.praat

python ~/scripts/phonNCSU/acoustic/subset_mfc_by_responses.py --mfc 'DFD469_*.praat' --csv '../responses/first43/*Laurel*.csv' --response NA --output DFD469_Laurel_NA.praat
python ~/scripts/phonNCSU/acoustic/subset_mfc_by_responses.py --mfc 'DFD469_*.praat' --csv '../responses/first43/*Laurel*.csv' --response other --output DFD469_Laurel_other.praat

python ~/scripts/phonNCSU/acoustic/subset_mfc_by_responses.py --mfc 'DFD469_*.praat' --csv '../responses/first43/*Rachel*.csv' --response NA --output DFD469_Rachel_NA.praat
python ~/scripts/phonNCSU/acoustic/subset_mfc_by_responses.py --mfc 'DFD469_*.praat' --csv '../responses/first43/*Rachel*.csv' --response other --output DFD469_Rachel_other.praat

python ~/scripts/phonNCSU/acoustic/subset_mfc_by_responses.py --mfc 'DFD469_*.praat' --csv '../responses/first43/*Bode_c*.csv' --response NA --output DFD469_Bode_NA.praat
python ~/scripts/phonNCSU/acoustic/subset_mfc_by_responses.py --mfc 'DFD469_*.praat' --csv '../responses/first43/*Bode*.csv' --response other --output DFD469_Bode_other.praat

python ~/scripts/phonNCSU/acoustic/subset_mfc_by_responses.py --mfc 'DFD469_*.praat' --csv '../responses/first43/*DJZ*.csv' --response NA --output DFD469_DJZ_NA.praat
python ~/scripts/phonNCSU/acoustic/subset_mfc_by_responses.py --mfc 'DFD469_*.praat' --csv '../responses/first43/*DJZ*.csv' --response other --output DFD469_DJZ_other.praat

'''


parser = argparse.ArgumentParser(description='Split a Praat MFC script into scripts that will play smaller subsets of the clips')
parser.add_argument('--mfc', default='[none listed]', help='path to your MFC scripts')
parser.add_argument('--csv', default='[none listed]', help='path to your MFC responses')
parser.add_argument('--response', default='[none listed]', help='the response to look for')
# parser.add_argument('--max', default=1000, help='the maximum number of clips you want to listen to in one session')
# parser.add_argument('--word', default='False', help='whether to split by word')
parser.add_argument('--shuffle', default='True', help='whether to shuffle the stimuli')
parser.add_argument('--output', default='[none listed]', help='what to name the resulting script')
args = parser.parse_args()

mfc_filelist = glob.glob(args.mfc)
csv_filelist = glob.glob(args.csv)

print('found',len(mfc_filelist),'matching MFC scripts and',len(csv_filelist),'matching response files')

response_dict = {}
stimlines = ''

for filepath in csv_filelist:
	# print(filepath)
	with open(filepath) as f:
		lines = f.readlines()
		lines.pop(0)
		for line in lines:
			# print(line)
			if '"' in line:
				x1, stimulus, x2 = line.strip().split('"')
				subject = x1.split(',')[0]
				x2a, response, reactionTime = x2.split(',')
			else:
				subject, stimulus, response, reactionTime = line.strip().split(',')
			# print(response)
			if response in response_dict.keys():
				response_dict[response].append(stimulus)
			else:
				response_dict[response] = [stimulus]

print('response summary:')
for k in response_dict.keys():
	print(k, len(response_dict[k]))
	# if k=='NA':
	# 	print(response_dict[k])
target_stimuli = response_dict[args.response]

selected_stimuli = []

for filepath in mfc_filelist:
	# print(filepath)
	[top_of_script, bottom_of_script, stimuli] = MFC.readscript(filepath)
	for stim_line in stimuli:
		for stim_name in target_stimuli:
			if stim_name in stim_line and not stim_line in selected_stimuli:
				selected_stimuli.append(stim_line)
# print(selected_stimuli)
MFC.writescript(args.output, top_of_script, bottom_of_script, selected_stimuli)
