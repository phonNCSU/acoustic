
import argparse
import os

#PARSE ARGUMENTS
parser = argparse.ArgumentParser(description='Make a praat script that will let you do MFC-like coding while looking at the editor')
parser.add_argument('--timestamp', default='', help='the one_script timestamp')
args = parser.parse_args()

#EXAMPLE
# python /phon/scripts/make_editor_mfc.py --timestamp 2023Sep24_10h30m33

mfc_script_filenames = [i for i in os.listdir('./') if i.startswith('one_script_out_'+args.timestamp+'_MF') and i.endswith('.praat')]
mfc_script_filenames.sort()

for mfc_script_filename in mfc_script_filenames:

	with open(mfc_script_filename) as f:
		mfc_script_lines = f.readlines()

	for i,line in enumerate(mfc_script_lines):
		if line.startswith('numberOfDifferentResponses'):
			first_button = i+1
		if line.startswith('numberOfGoodnessCategories'):
			non_button = i

	buttons = []
	for i in range(first_button, non_button):
		buttons.append('"'+mfc_script_lines[i].split('"')[-2]+'"')

	clip_path = mfc_script_lines[3].split('"')[1]
	one_script_out_fn = 'one_script_out_'+args.timestamp+'.csv'
	results_filename = 'editor_mfc_results_'+args.timestamp+'.csv'
	dummy_subject = 'one_script_out_'+args.timestamp+'_MFC'

	editor_mfc_script_filename = mfc_script_filename.replace('MFC', 'editor_mfc')

	with open(editor_mfc_script_filename, 'w') as f:
		f.write('clip_path$ = "'+clip_path+'"\n')
		f.write('one_script_out_path$ = "'+one_script_out_fn+'"\n')
		f.write('results_filename$ = "'+results_filename+'"\n')
		f.write('\n')
		f.write('Read Table from comma-separated file: one_script_out_path$\n')
		f.write('Rename: "one_script_out"\n')
		f.write('n_wavs = Get number of rows\n')
		f.write('\n')
		f.write("filedelete 'results_filename$'\n")
		f.write("fileappend 'results_filename$' subject,stimulus,response,notes'newline$'\n")
		f.write('\n')
		f.write('for i from 1 to n_wavs\n')
		f.write('	selectObject: "Table one_script_out"\n')
		f.write('	stimulus$ = Get value: i, "stimulus"\n')
		f.write('	wav_filename$ = stimulus$ + ".wav"\n')
		f.write('	tg_filename$ = stimulus$ + ".TextGrid"\n')
		f.write('	Read from file: clip_path$+wav_filename$\n')
		f.write('	Rename: "current_clip"\n')
		f.write('	Read from file: clip_path$+tg_filename$\n')
		f.write('	Rename: "current_clip"	\n')
		f.write('\n')
		f.write('	selectObject: "Sound current_clip"\n')
		f.write('	clip_end = Get end time\n')
		f.write('	plusObject: "TextGrid current_clip"\n')
		f.write('	View & Edit\n')
		f.write('\n')
		f.write('	editor: "TextGrid current_clip"\n')
		f.write('	Play: 0, clip_end\n')
		f.write('\n')
		f.write('	notes$ = ""\n')
		f.write('	beginPause: "code token \'i\' of \'n_wavs\'"\n')
		f.write('	sentence ("notes", notes$)\n')
		f.write('	clicked = endPause: '+', '.join(buttons)+', '+str(len(buttons))+'\n')
		f.write('\n')
		f.write('	endeditor\n')
		f.write('\n')
		for i,b in enumerate(buttons):
			f.write('	category'+str(i+1)+'$ = '+b+'\n')
		f.write('\n')
		f.write("	response$ = category'clicked'$\n")
		f.write('\n')
		f.write('	subject$ = "'+dummy_subject+'"\n')
		f.write("	fileappend 'results_filename$' 'subject$','stimulus$','response$','notes$''newline$'\n")
		f.write('	Remove\n')
		f.write('endfor\n')
		print('wrote', editor_mfc_script_filename)
