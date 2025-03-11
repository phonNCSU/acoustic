
textgrid_read_path$ = "/home/jimielke/orthognathic/data_24_12_12/"
textgrid_write_path$ = "/home/jimielke/orthognathic/data_24_12_12_with_segmentation/"

# csv_file_path$ = "/home/jimielke/orthognathic/class_III_2024_analysis/DFD_Fall2024_obstruent/orthognathic_2024_10_17_original_plosives.csv"
csv_file_path$ = "/home/jimielke/orthognathic/october_2024_with_vp_hf_segmentation_2024_12_12.csv"

Read Table from comma-separated file: csv_file_path$
Rename: "one_script_table"
table_rows = Get number of rows

open_textgrid$ = ""

for i from 1 to table_rows
	selectObject: "Table one_script_table"
	textgrid_name$ = Get value: i, """textgrid"""
	# right$ = Get value: i, """right"""

	# if right$=="AA1" or right$=="AE1" or right$=="IY1" or right$=="UW1"

		release_start = Get value: i, """release_start"""
		release_end = Get value: i, """release_end"""
		# release_start2 = Get value: i, """release_start2"""
		# release_end2 = Get value: i, """release_end2"""
	
		# if release_end2 == release_start2
		# 	release_end2 = release_end2 + 0.001
		# 	printline added 1 ms 'open_textgrid$' 'release_start'
		# endif

		# if release_end2 == undefined
		# 	release_end2 = release_start2 + 0.001
		# 	printline undefined end 'open_textgrid$' 'release_start'
		# endif

		# if release_start2 == undefined
		# 	printline undefined start 'open_textgrid$' 'release_start'
		# else

		if textgrid_name$ != open_textgrid$
			#printline 'textgrid_name$'
			if open_textgrid$ != ""
				selectObject: "TextGrid "+open_textgrid$
				Save as text file: textgrid_write_path$+open_textgrid$+".TextGrid"
				Remove
			endif
			
			Read from file: textgrid_read_path$+textgrid_name$+".TextGrid"
			Insert interval tier: 3, "window"
			Insert interval tier: 4, "automatic"
			Insert interval tier: 5, "corrected"
			open_textgrid$ = textgrid_name$
		endif
	
		selectObject: "TextGrid "+open_textgrid$
	
		Insert boundary: 3, release_start
		Insert boundary: 3, release_start+0.02
		Insert boundary: 4, release_start
		Insert boundary: 4, release_end
		Insert boundary: 5, release_start
		Insert boundary: 5, release_end


		endif

	# endif
	


endfor

selectObject: "TextGrid "+open_textgrid$
Save as text file: textgrid_write_path$+open_textgrid$+".TextGrid"
Remove
