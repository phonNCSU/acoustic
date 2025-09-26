############################################################
#  One Script to Rule Them All!
#
#  Jeff Mielke and Eric Wilbanks - Updated Jun 12 2024
#
#  4/14/21 added nasalization procedure
#          added version as variable
#  2/9/22  phone and word tier can be named Phone and Word now
#  10/3/22 changed most references to "sex" to "gender"
#  11/12/22 added one match per word token option (with MFC scripts in mind)
#    version 27
#  11/17/22 handling filenames with space or apostrophe
#  5/12/23 choosing textgrid tiers by name if there is no tier column in the csv file
#  6/4/23 added W option to include only user-selected words
#  2/21/24 added preemphasis option for formant measurement
#  3/2/24 added option to vary formant candidates by max_formant and/or number of poles
#  3/4/24 based best formant measurement only on mdist because energy was bad (29dev3)
#  3/19/24 records presence of overlapping intervals on another word tier
############################################################

# NEED TO ADD:
#
# custom excluded words
# updating an existing csv file (when a job got interrupted)
# updating an existing csv file (to correct bad measurements)
# new sample calls

form Choices
sentence file_list (leave unchanged to test in editor)
sentence phon_string S/AW1/TH
sentence operations formants(output_formants=5,bandwidths=1)
sentence options 
sentence exclude 
endform

#SAMPLE CALL: praat /phon/scripts/one_script.praat /phon/Buckeye/buckeye_files.csv 'HH/AA1/COR' 'formants(),duration()'

############################################################
############################################################
############################################################

@gettime
start_time = gettime.t

#
wordboundary$ = """#"""
delimiter$ = " "
one_script_version$ = "30"
Text writing preferences: "UTF-8"

complete_query$ = "praat /phon/scripts/one_script_"+one_script_version$+".praat '"+file_list$+"' '"+phon_string$+"' '"+operations$+"' '"+options$+"' '"+exclude$+"'"

#INTERACTIVE SESSION PARAMETERS
initial_zoom = 1.0

#MFC PARAMETERS
stim_string_no_words$ = ""
stim_string_with_words$ = ""
stim_n = 0
button_left_margin = 0.10
button_right_margin = 0.90

#DEFAULTS
writePath$ = replace$ ("'shellDirectory$'/", "//", "/", 0)
if writePath$ == "/"
    writePath$ = "./"
endif
#phone_tier = 1
#word_tier = 2
words_to_match$ = ""
speaker$ = ""
gender$ = ""
csv_pitch_floor = undefined
csv_pitch_ceiling = undefined

printline ######################################################
printline ### This is one_script_'one_script_version$'.praat ###
printline ######################################################

printline COMMAND LINE OPTIONS (w f d l o W):
if index (options$, "w") > 0
    consider_word_boundaries = 0
    printline  * ignoring word boundaries
else
    consider_word_boundaries = 1
    printline    considering word boundaries (default)
endif

if index (options$, "d") > 0
    min_duration = 0.05
    printline  * minimum target segment duration is 50 ms
else
    min_duration = 0
    printline    no minimum target segment duration (default)
endif

if index (options$, "l") > 0
    vl = 1
    printline  * including postvocalic liquids in vowels
else
    vl = 0
    printline    not including postvocalic liquids in vowels (default)
endif

if index (options$, "r") > 0
    lv = 1
    printline  * including PREVOCALIC liquids in vowels
else
    lv = 0
    printline    not including postvocalic liquids in vowels (default)
endif

if index (options$, "f") > 0
    @functionwords
    excludedwords$ = functionwords$
    printline  * excluding function words
else
    excludedwords$ = ""
    printline    not excluding function words (default)
endif


lastword_id$ = "XXXXXXXXXX"
if index (options$, "o") > 0
    one_match_per_word_token = 1
    printline  * including one match per word token
else
    one_match_per_word_token = 0
    printline    including any number of matches per word token (default)
endif

if index (options$, "W") > 0
    selected_words_only = 1
    exclude$ = replace$ (exclude$, ";", " ", 0)
    exclude$ = replace$ (exclude$, ",", " ", 0)
    exclude$ = replace$ (exclude$, "  ", " ", 0)
    printline  * including only user-selected words: 'exclude$'
    includedwords$ = " "+exclude$+" "
    includedwords$ = replace$ (includedwords$, "  ", " ", 0)
else
    selected_words_only = 0
endif

# if index (options$, "m") > 0
#     add_for_word_tier = -1
#     printline  * assuming word tiers are above phone tiers, MFA-style
# else
#     add_for_word_tier = 1
#     printline    assuming word tiers are above phone tiers, P2FA-style (default)
# endif

if exclude$ == "" or selected_words_only == 1
    printline    not excluding any user-defined words (default)
else
    excludes$ = replace$ (exclude$, ";", " ", 0)
    excludes$ = replace$ (exclude$, ",", " ", 0)
    excludes$ = replace$ (exclude$, "  ", " ", 0)
    printline  * excluding user-defined words: 'exclude$'
    excludedwords$ = excludedwords$ + " "+excludes$+" "
    excludedwords$ = replace$ (excludedwords$, "  ", " ", 0)
endif

printline #####################################
printline ***'excludedwords$'***

#P2FA SILENCE TAGS
silences$ = ",,sp,sil,{sl},{SL},"
breaks$ = silences$+",{LG},{BR},"

#COUNTERS
tab_number = 0
total_duration = 0
isComplete = 0


############################################################

@split ("/", phon_string$)
if split.length == 1
    preceding_context1$ = ""
    preceding_context$ = ""
    phones_to_match$ = split.array$[1]
    following_context$ = ""
    following_context1$ = ""
elif split.length == 3
    preceding_context1$ = ""
    preceding_context$ = split.array$[1]
    phones_to_match$ = split.array$[2]
    following_context$ = split.array$[3]
    following_context1$ = ""
else
    preceding_context1$ = split.array$[1]
    preceding_context$ = split.array$[2]
    phones_to_match$ = split.array$[3]
    following_context$ = split.array$[4]
    following_context1$ = split.array$[5]
endif

@dateStamp

outfile$ = "one_script_out"+"_"+datestamp$+".csv"
outfile$ = writePath$+outfile$
filedelete 'outfile$'

logfile$ = writePath$+"one_script_log"+"_"+datestamp$+".txt"

clipPath$ = writePath$ + "clips"+"_"+datestamp$

filedelete 'logfile$'
fileappend 'logfile$' complete query: 'complete_query$''newline$'
fileappend 'logfile$' one_script version: one_script_'one_script_version$'.praat'newline$'
fileappend 'logfile$' output file: 'outfile$''newline$'
fileappend 'logfile$' clip path: 'clipPath$''newline$'
fileappend 'logfile$' file list: 'file_list$''newline$'
fileappend 'logfile$' phon_string: 'phon_string$''newline$'
fileappend 'logfile$' operations: 'operations$''newline$'
fileappend 'logfile$' options: 'options$''newline$'
fileappend 'logfile$' exclude: 'exclude$''newline$'

@parseSoundsAndWords

#ARE WE RUNNING THE SCRIPT INTERACTIVELY?
#if file_list$ == "(leave"
if file_list$ == "(leave unchanged to test in editor)"
    interactive_session = 1
else
    interactive_session = 0
endif

if interactive_session == 1

    # if add_for_word_tier == 1
    #     phone_tier = 1
    #     word_tier = 2
    # else
    #     phone_tier = 2
    #     word_tier = 1
    # endif

    #INTERACTIVE

    numberOfSelectedTextGrids = numberOfSelected ("TextGrid")
    if numberOfSelectedTextGrids != 1
        pause Please select one TextGrid and one Sound.
    endif
    numberOfSelectedTextGrids = numberOfSelected ("TextGrid")

    textgrid_name$ = selected$ ("TextGrid", 1)    
    sound_name$ = selected$ ("Sound", 1)
  
    #make the header
    isHeader = 1
    @makeMeasurements
    isHeader = 0

    gender$ = "female"

    if vl==1
        @removeVLboundaries
    endif

    if lv==1
        @removeLVboundaries
    endif

    select TextGrid 'textgrid_name$'

    tieronename$ = Get tier name: 1
    tiertwoname$ = Get tier name: 2
    if index (tieronename$, "ord") > 0 and index (tiertwoname$, "hone") > 0
        phone_tier = 2
        word_tier = 1
        printline tier 1 is word and tier 2 is phone
    else:
        phone_tier = 1
        word_tier = 2
        printline tier 1 is phone and tier 1 is word
    # if add_for_word_tier == 1
    #     phone_tier = 1
    # else
    #     phone_tier = 2
    endif

    # else
    #    phone_tier = Get value... 'data_row' tier
    # endif

    select Sound 'sound_name$'
    plus TextGrid 'textgrid_name$'
    View & Edit
    @transport

    isComplete = 1
    @makeMeasurements

else

    #make the header
    isHeader = 1
    @makeMeasurements
    isHeader = 0

    #BATCH
    #Read Table in and Get File Locations

    if index (file_list$, ";") == 0
        #OPENING FILES LISTED IN A CSV FILE

        if index (file_list$, ":") > 0
            @split (":", file_list$)
            file_list$ = split.array$[1]
            starting_row = number(split.array$[2])
            if split.length > 2
                ending_row = number(split.array$[3])
            else
                ending_row = 0
            endif
        else
            starting_row = 1
            ending_row = 0
        endif

        Read Table from comma-separated file... 'file_list$'
        Rename... file_list
        data_rows = Get number of rows
        
        starting_row = max(starting_row, 1)

        if ending_row == 0 or ending_row > data_rows
            ending_row = data_rows
        endif

        if starting_row > 1 or ending_row < data_rows
            printline (Processing rows 'starting_row'-'ending_row' out of 'data_rows' total rows)
            actual_data_rows = ending_row - starting_row + 1
        else
            actual_data_rows = data_rows
        endif

        #Iterate over files in list and make measurements
        for data_row to data_rows

            if data_row < starting_row or data_row > ending_row
                printline -----Skipping 'data_row' of 'data_rows'
            else
                @readTableRow

                printline *****Processing 'textgrid_name$': 'data_row' of 'data_rows'

                #Read from file... 'wav_file$'
                #Rename... 'sound_name$'
                #wav_duration = Get total duration
                #total_duration = total_duration + wav_duration
                #sound_samplerate = Get sampling frequency
                wav_is_open = 0

                Read from file... 'tg_file$'
                Rename... 'textgrid_name$'

                textgrid_tiers = Get number of tiers
                all_phone_tiers$ = " "
                all_word_tiers$ = " "
                for i from 1 to textgrid_tiers
                    tiername$ = Get tier name: i
                    if index (tiername$, "phone") > 0 or index (tiername$, "Phone") > 0
                        all_phone_tiers$ = all_phone_tiers$+"'i' "
                    endif
                    if index (tiername$, "word") > 0 or index (tiername$, "Word") > 0
                        all_word_tiers$ = all_word_tiers$+"'i' "
                    endif
                endfor
                #printline word tiers: 'all_word_tiers$'

                tieronename$ = Get tier name: 1
                tiertwoname$ = Get tier name: 2

                if phone_tier == 0
                    tg_tiers = Get number of tiers
                    for tiernumber from 1 to tg_tiers
                        tiername$ = Get tier name: tiernumber
                        if tiername$ == speaker$+" - phones" or tiername$ == speaker$+" - phone"
                            phone_tier = tiernumber
                            printline ...found phone tier 'tiername$' ('phone_tier')
                        elif tiername$ == speaker$+" - words" or tiername$ == speaker$+" - word"
                            word_tier = tiernumber
                            printline ...found word tier 'tiername$' ('word_tier')
                        endif
                    endfor

                    #if index (tieronename$, "ord") > 0 and index (tiertwoname$, "hone") > 0
                    #    phone_tier = 2
                    #    word_tier = 1
                    #    printline word tier is 1 and phone tier is 2
                    #else
                    #    phone_tier = 1
                    #    word_tier = 2
                    #    printline word tier is 2 and phone tier is 1
                    #endif
                else
                    if index (tieronename$, "ord") > 0 and index (tiertwoname$, "hone") > 0
                        word_tier = phone_tier - 1
                        printline word tier is above phone tier
                    else
                        word_tier = phone_tier + 1
                        printline word tier is below phone tier
                    endif
                # else
                #    phone_tier = Get value... 'data_row' tier
                endif
                # word_tier = phone_tier + add_for_word_tier

                if phone_tier == 0
                    printline defaulting to word/phone tier = 1/2
                    word_tier = 1
                    phone_tier = 2
                endif

                if vl==1
                    @removeVLboundaries
                endif
                if lv==1
                    @removeLVboundaries
                endif

            	@transport

                printline

                select TextGrid 'textgrid_name$'
                if wav_is_open
            	   plus Sound 'sound_name$'
                endif

            	Remove
            endif
        endfor
    else
        #OPENING A PAIR OF FILES NAMED IN THE one_script CALL
        @openPairOfFiles
        #THIS IS COPIED FROM RIGHT ABOVE

        if right$(wav_file$,3) == "MTS"
            printline not opening wav file (because only an MTS file was given)
            wav_duration = 0
            total_duration = 0
            sound_samplerate = 0
        else
            Read from file... 'wav_file$'
            wav_is_open = 1
            Rename... 'sound_name$'
            wav_duration = Get total duration
            total_duration = total_duration + wav_duration
            sound_samplerate = Get sampling frequency
        endif

        Read from file... 'tg_file$'
        Rename... 

        tieronename$ = Get tier name: 1
        tiertwoname$ = Get tier name: 2
        if index (tieronename$, "ord") > 0 and index (tiertwoname$, "hone") > 0
            word_tier = 1
            phone_tier = 2
        else
            word_tier = 2
            phone_tier = 1
        endif
        printline word tier is 'word_tier' and phone tier is 'phone_tier'
        printline if you have more than one speaker, please list your files in a csv file with a "tier" column
        if vl==1
            @removeVLboundaries
        endif
        if lv==1
            @removeLVboundaries
        endif

        @transport

        printline

        select TextGrid 'textgrid_name$'
        if right$(wav_file$,3) != "MTS"
            plus Sound 'sound_name$'
        endif
        Remove
        data_rows = 1
    endif

    isComplete = 1
    @makeMeasurements

    total_minutes = total_duration / 60


    @gettime
    end_time = gettime.t
    seconds_elapsed = end_time - start_time

    seconds_per_token = seconds_elapsed/tab_number

    if data_rows == 1
        printline Found 'tab_number' tokens in 1 phone tier ('total_minutes:0' minutes)
    else
        printline Found 'tab_number' tokens in 'actual_data_rows' phone tiers ('total_minutes:0' minutes)
    endif
    printline This took 'seconds_elapsed' seconds ('seconds_per_token:3' seconds per token)
    printline Wrote output to 'outfile$'
    printline Logfile is 'logfile$'
endif

############################################################
############################################################
############################################################

procedure readTableRow

    select Table file_list

    wav_file$ = Get value... 'data_row' wav
    tg_file$ = Get value... 'data_row' textgrid

    @split ("/", wav_file$)
    sound_name$ = split.array$[split.length] - ".wav"

    @split ("/", tg_file$)
    textgrid_name$ = split.array$[split.length] - ".TextGrid" - ".textgrid" - ".Textgrid"

    #to handle filenames with spaces or other special characters in them...
    sound_name$ = replace$(sound_name$, ".", "_", 0)
    sound_name$ = replace$(sound_name$, "'", "_", 0)
    sound_name$ = replace$(sound_name$, " ", "_", 0)
    textgrid_name$ = replace$(textgrid_name$, ".", "_", 0)
    textgrid_name$ = replace$(textgrid_name$, "'", "_", 0)
    textgrid_name$ = replace$(textgrid_name$, " ", "_", 0)

    .listsSpeaker = Get column index: "speaker"
    if .listsSpeaker == 0
        speaker$ = textgrid_name$
    else
        speaker$ = Get value... 'data_row' speaker
    endif

    .listsSex = Get column index: "sex"
    .listsGender = Get column index: "gender"
    if .listsGender == 0
        if .listsSex == 0
            gender$ = "female"
        else
            gender$ = Get value... 'data_row' sex
        endif
    else
        gender$ = Get value... 'data_row' gender
    endif

    .listsTier = Get column index: "tier"
    if .listsTier == 0
        phone_tier = 0
        printline FINDING TIER BY NAME INSTEAD OF NUMBER...
    else
	   phone_tier = Get value... 'data_row' tier
    endif
    #word_tier = phone_tier + add_for_word_tier

    .listsVideo = Get column index: "video"
    if .listsVideo == 0
       video_file$ = wav_file$
    else
       video_file$ = Get value... 'data_row' video
    endif

    .listsPitchFloor = Get column index: "pitch_floor"
    if .listsPitchFloor == 0
       csv_pitch_floor = undefined
    else
       csv_pitch_floor = Get value... 'data_row' pitch_floor
    endif

    .listsPitchCeiling = Get column index: "pitch_ceiling"
    if .listsPitchCeiling == 0
       csv_pitch_ceiling = undefined
    else
       csv_pitch_ceiling = Get value... 'data_row' pitch_ceiling
    endif

endproc

procedure openPairOfFiles

    ### SPLIT BY SEMICOLON
    @split (";", file_list$)

    wav_file$ = split.array$[1]
    tg_file$ = split.array$[2]
    if split.length > 2
        phone_tier = 'split.array$[3]'
    else
        phone_tier = 1
    endif

    printline Processing a pair of files without a table:
    # printline wav file is 'wav_file$', textgrid file is 'tg_file$', and phone_tier is 'phone_tier'
    printline wav file is 'wav_file$', textgrid file is 'tg_file$', and phones and words are in tiers 1 and 2 (in some order)
    printline Assuming speaker = textgrid name, gender = female (probably does not matter)

    gender$ = "female"

    # tieronename$ = Get tier name: 1
    # tiertwoname$ = Get tier name: 2
    # if index (tieronename$, "word") > 0 and index (tiertwoname$, "phone") > 0
    #     phone_tier = 2
    #     word_tier = 1
    # else:
    #     phone_tier = 1
    #     word_tier = 2
    # endif

    # word_tier = phone_tier + add_for_word_tier
    
    @split ("/", wav_file$)
    sound_name$ = split.array$[split.length] - ".wav"

    @split ("/", tg_file$)
    textgrid_name$ = split.array$[split.length] - ".TextGrid" - ".textgrid" - ".Textgrid"

    speaker$ = textgrid_name$

    #to handle filenames with "." in them...
    sound_name$ = replace$(sound_name$, ".", "_", 0)
    textgrid_name$ = replace$(textgrid_name$, ".", "_", 0)

    video_file$ = wav_file$

endproc

procedure makeMeasurements

    if isHeader == 1
        .base_header$ = "speaker,textgrid,sound,phonetier,word_id,token_id,leftword,word,rightword,phone,phonestart,phoneend,left2,left1,left,right,right1,right2,speech_overlap"
        fileappend 'outfile$' '.base_header$'
        @parseOperations (operations$)
    	fileappend 'outfile$' 'newline$'
    elif isComplete == 1
        @parseOperations (operations$)
    else
        word_id$ = textgrid_name$+"_"+"'phone_tier'"+"_"+transport.word$+"_"+"'transport.word_start:3'"
        token_id$ = textgrid_name$+"_"+"'phone_tier'"+"_"+transport.word$+"_"+transport.phone$+"_"+"'transport.phone_start:3'"

        if one_match_per_word_token==1 and lastword_id$ == word_id$
            #printline skip
        else
            tab_number = tab_number + 1
            #printline 'word_id$'
            .base_info$ = speaker$+","+textgrid_name$+","+sound_name$+","+"'phone_tier'"+","+word_id$+","+token_id$+","+transport.lastword$+","+transport.word$+","+transport.nextword$+","+transport.phone$+","+"'transport.phone_start:3'"+","+"'transport.phone_end:3'"+","+transport.lastphone2$+","+transport.lastphone1$+","+transport.lastphone$+","+transport.nextphone$+","+transport.nextphone1$+","+transport.nextphone2$+","+transport.overlapping_speech$

            fileappend 'outfile$' '.base_info$'

            #VARIABLES AVAILABLE TO MEASUREMENT PROCEDURES: 
            # - transport.phone$            the phone we're measuring
            # - transport.word$             the word it's in
            # - transport.phone_start       the time the phone starts
            # - transport.phone_end         the time the phone ends
            # - transport.duration          the duration of the target phone
            # - transport.lastphone$        the preceding phone
            # - transport.nextphone$        the following phone
            # - transport.lastphone1$       the phone preceding the preceding phone
            # - transport.nextphone1$       the phone following the following phone
            # - transport.lastphone2$       the third preceding phone
            # - transport.nextphone2$       the third following phone
            # - transport.lastphone_start   the time the preceding phone starts 
            # - transport.nextphone_end     the time the following phone ends
            # - transport.word_start        the time the word starts
            # - transport.word_end          the time the word ends
            # - transport.lastword_start    the time the preceding word starts
            # - transport.nextword_end      the time the next word ends
            # - transport.lastword$         the preceding word
            # - transport.nextword$         the following word

            @parseOperations (operations$)

            print .
            lastword_id$ = word_id$
            fileappend 'outfile$' 'newline$'
        endif
    endif   
    


    

endproc

procedure parseOperations
    #SPLIT UP THE FUNCTIONS
    @split ("),", operations$)
    .n_ops = split.length
    if split.array$[1] != ""
        .n_ops = split.length
        for .i to .n_ops
            ops_array$[.i] = split.array$[.i]
        endfor

        for .i to .n_ops
            funWithArgs$ = ops_array$[.i]
            #SEPARATE THE FUNCTION NAME FROM ITS ARGUMENTS
            if index (funWithArgs$, "(") > 0
                @split ("(", funWithArgs$) 
                funOnly$ = split.array$[1]
                argString$ = split.array$[2]
                argString$ = replace$(argString$, ")", "", 0)
                argString$ = replace$(argString$, ", ", ",", 0)

                if isHeader == 1
                    printline FUNCTION: 'funOnly$'
                endif

            endif

            @'funOnly$' (argString$)
        endfor
    endif
endproc

procedure parseArgs (.argString$)

    #SPLIT UP THE ARGUMENTS
    @split (",", argString$)
    .n_args = split.length
    for .i to .n_args
        .allArgs$[.i] = split.array$[.i]
    endfor

    for .i to .n_args
        @split ("=", .allArgs$[.i])
        .var$[.i] = split.array$[1]
        .val$[.i] = split.array$[2]
        #vv1$ = .var$[.i]
        #vv2$ = .val$[.i]
        #printline ***'vv1$'***'vv2$'***
        if isHeader == 1
            .currentVar$ = .var$[.i]
            .currentVal$ = .val$[.i]
            if .currentVar$ != ""
                printline --ARG: '.currentVar$' = '.currentVal$'
            endif
        endif
    endfor

endproc

############################################################

#Split Procedure Written by Jose J. Atria 20 Feb 2014
#http://www.ucl.ac.uk/~ucjt465/scripts/praat/split.proc.praat

procedure split (.sep$, .str$)
  .seplen = length(.sep$) 
  .length = 0
  repeat
    .strlen = length(.str$)
    .sep = index(.str$, .sep$)
    if .sep > 0
      .part$ = left$(.str$, .sep-1)
      .str$ = mid$(.str$, .sep+.seplen, .strlen)
    else
      .part$ = .str$
    endif
    .length = .length+1
    .array$[.length] = .part$
  until .sep = 0
endproc

######################################################################
# procedures imported from extract_and_label.praat Sept 17, 2015
######################################################################

procedure parseSoundsAndWords
    #PARSE THE LISTS OF SOUNDS AND WORDS TO MATCH

    print preceding context 1: 
    preceding1_1$ = ""
    preceding1_n = 1
    phonefield$ = preceding_context1$
    call handleWildcards
    preceding_context1$ = phonefield$
    string_to_parse$ = preceding_context1$
    call parseString
    if n_strings > 0
        for i to n_strings
            preceding1_'i'$ = split_string'i'$
            printphone$ = preceding1_'i'$+" "
            print 'printphone$'
        endfor
    endif
    preceding1_n = n_strings
    print 'newline$'

    print preceding context  : 
    preceding0_1$ = ""
    preceding0_n = 1
    phonefield$ = preceding_context$
    call handleWildcards
    preceding_context$ = phonefield$
    string_to_parse$ = preceding_context$
    call parseString
    if n_strings > 0
        for i to n_strings
            preceding0_'i'$ = split_string'i'$
            printphone$ = preceding0_'i'$+" "
            print 'printphone$'
        endfor
    endif
    preceding0_n = n_strings
    print 'newline$'

    print target sounds      : 
    target1$ = ""
    targets_n = 1
    phonefield$ = phones_to_match$
    call handleWildcards
    phones_to_match$ = phonefield$
    string_to_parse$ = phones_to_match$
    call parseString
    if n_strings > 0
        for i to n_strings
            target'i'$ = split_string'i'$
            printphone$ = target'i'$+" "
            print 'printphone$'
        endfor
    endif
    targets_n = n_strings
    print 'newline$'

    print following context  : 
    following0_1$ = ""
    following0__n = 1
    phonefield$ = following_context$
    call handleWildcards
    following_context$ = phonefield$
    string_to_parse$ = following_context$
    call parseString
    if n_strings > 0
        for i to n_strings
            following0_'i'$ = split_string'i'$
            printphone$ = following0_'i'$+" "
            print 'printphone$'
        endfor
    endif
    following0_n = n_strings
    print 'newline$'

    print following context 1: 
    following1_1$ = ""
    following1_n = 1
    phonefield$ = following_context1$
    call handleWildcards
    following_context1$ = phonefield$
    string_to_parse$ = following_context1$
    call parseString
    if n_strings > 0
        for i to n_strings
            following1_'i'$ = split_string'i'$
            printphone$ = following1_'i'$+" "
            print *'printphone$'*
        endfor
    endif
    following1_n = n_strings
    print 'newline$'

    print target words: 
    target_word1$ = ""
    target_word_n = 1
    phonefield$ = words_to_match$
    call handleWildcards
    words_to_match$ = phonefield$
    string_to_parse$ = words_to_match$
    call parseString
    for i to n_strings
        printphone$ = target_word'i'$+" "
        print 'printphone$'
    endfor
    target_word_n = n_strings
    print 'newline$'
endproc

procedure handleWildcards

    @handleCustomWildcards

    ###REGULARIZE WILDCARD STRINGS
    phonefield$ = " "+phonefield$+" "
    phonefield$ = replace$(phonefield$, "  ", " ", 0)

    phonefield$ = replace$(phonefield$, " CONSONANT ", " CONS ", 0)
    phonefield$ = replace$(phonefield$, " TENSE ", " TNS ", 0)
    phonefield$ = replace$(phonefield$, " HIGH ", " HI ", 0)
    phonefield$ = replace$(phonefield$, " BACK ", " BCK ", 0)
    phonefield$ = replace$(phonefield$, " CENTRAL ", " CNT ", 0)
    phonefield$ = replace$(phonefield$, " FRONT ", " FRO ", 0)
    phonefield$ = replace$(phonefield$, " UNROUNDED ", " UNR ", 0)
    phonefield$ = replace$(phonefield$, " ROUNDED ", " RND ", 0)
    phonefield$ = replace$(phonefield$, " ROUND ", " RND ", 0)
    phonefield$ = replace$(phonefield$, " DIPHTHONG ", " DIPH ", 0)
    phonefield$ = replace$(phonefield$, " STRESSED ", " STR ", 0)
    phonefield$ = replace$(phonefield$, " SECONDARY ", " 2ND ", 0)
    phonefield$ = replace$(phonefield$, " UNSTRESSED ", " UNS ", 0)
    phonefield$ = replace$(phonefield$, " LABIAL ", " LAB ", 0)
    phonefield$ = replace$(phonefield$, " CORONAL ", " COR ", 0)
    phonefield$ = replace$(phonefield$, " DORSAL ", " DOR ", 0)
    phonefield$ = replace$(phonefield$, " GLOTTAL ", " LAR ", 0)
    phonefield$ = replace$(phonefield$, " LARYNGEAL ", " LAR ", 0)
    phonefield$ = replace$(phonefield$, " AFFRICATE ", " AFFR ", 0)
    phonefield$ = replace$(phonefield$, " FRICATIVE ", " FRIC ", 0)
    phonefield$ = replace$(phonefield$, " NASAL ", " NAS ", 0)
    phonefield$ = replace$(phonefield$, " LIQUID ", " LIQ ", 0)
    phonefield$ = replace$(phonefield$, " APPROXIMANT ", " APPR ", 0)
    phonefield$ = replace$(phonefield$, " APPROX ", " APPR ", 0)
    phonefield$ = replace$(phonefield$, " SIBILANT ", " SIB ", 0)
    phonefield$ = replace$(phonefield$, " GLIDE ", " GLI ", 0)
    phonefield$ = replace$(phonefield$, " VOICELESS ", " VLS ", 0)
    phonefield$ = replace$(phonefield$, " VOICED ", " VOI ", 0)
    phonefield$ = replace$(phonefield$, " SONORANT ", " SON ", 0)
    phonefield$ = replace$(phonefield$, " OBSTRUENT ", " OBS ", 0)
    phonefield$ = replace$(phonefield$, " DENTAL ", " DENT ", 0)
    phonefield$ = replace$(phonefield$, " POSTALVEOLAR ", " PLV ", 0)
    phonefield$ = replace$(phonefield$, " ALVEOLAR ", " ALV ", 0)
    phonefield$ = replace$(phonefield$, " PALATAL ", " PAL ", 0)
    phonefield$ = replace$(phonefield$, " LABIODENTAL ", " LABDENT ", 0)
    phonefield$ = replace$(phonefield$, " BILABIAL ", " BILAB ", 0)
    phonefield$ = replace$(phonefield$, " VELAR ", " VEL ", 0)
   
    ###BORA
    phonefield$ = replace$(phonefield$, " BORA_VOWEL ", " a á aá aá áá ɨ ɨ́ ɨ́ɨ́ ɨɨ́ ɯ ɯ́ ɯɯ́ ɯ́ɯ́ e é eé éé i í ií íí o ó oó óó u ú uú úú ɛ ɛ́ ɛɛ́ ɛ́ɛ́ ", 0)
    phonefield$ = replace$(phonefield$, " BORA_CONS ", " p pʲ pʰ pʲʰ t tʲ tʰ tʲʰ k kʲ kʰ kʲʰ k͡p ʔ ʔʲ ts tsʰ tʃ tʃʰ x h hʲ β βʲ m mʲ n ɲ ɾ j ", 0)
    phonefield$ = replace$(phonefield$, " BORA_PALATALIZED ", " pʲ pʲʰ tʲ tʲʰ kʲ kʲʰ ʔʲ hʲ βʲ mʲ ", 0)
    phonefield$ = replace$(phonefield$, " BORA_LABIOVELAR ", " k͡p ", 0)
    
    ###ENGLISH_MFA
    phonefield$ = replace$(phonefield$, " ENGLISH_MFA_VOWEL ", " a aj aw aː e ej i iː o ow u uː æ ɐ ɑ ɑː ɒ ɒː ɔ ɔj ə əw ɚ ɛ ɛː ɜ ɜː ɝ ɪ ʉ ʉː ʊ ", 0)
    phonefield$ = replace$(phonefield$, " ENGLISH_MFA_CONS ", " b bʲ c cʰ d dʒ dʲ f fʲ h j k kʰ l m mʲ m̩ n n̩ p pʰ pʲ s t tʃ tʰ tʲ v vʲ w z ç ð ŋ ɟ ɡ ɫ ɫ̩ ɱ ɲ ɹ ɾ ʃ ʎ ʒ ʔ θ ", 0)

    ###KALASHA
    phonefield$ = replace$(phonefield$, " KALASHA_CONSONANT ", " KALASHA_CONS ", 0)
    phonefield$ = replace$(phonefield$, " KALASHA_VOWEL ", " a˞ː aː ã˞ː a˞ a ã˞ ãː ã e˞ː ẽ˞ e˞ ẽ e i˞ː iː ĩ˞ i˞ ĩ i o˞ː õ˞ o˞ õ o u˞ː uː ũ˞ u˞ ũ u ", 0)
    phonefield$ = replace$(phonefield$, " KALASHA_CONS ", " KALASHA_SUBSEGMENT KALASHA_OBSTRUENT KALASHA_SONORANT ", 0)

    phonefield$ = replace$(phonefield$, " KALASHA_SUBSEGMENT ", " rel asp ", 0)
    phonefield$ = replace$(phonefield$, " KALASHA_OBSTRUENT ", " KALASHA_PLOSIVE KALASHA_FRICATIVE ", 0)
    phonefield$ = replace$(phonefield$, " KALASHA_SONORANT ", " KALASHA_NASAL KALASHA_LIQUID KALASHA_GLIDE ", 0)

    phonefield$ = replace$(phonefield$, " KALASHA_PLOSIVE ", " p pʰ b bʰ ɓ t tʰ d dʰ ɗ̪ ʈ ʈʰ ɖ ɖʰ ᶑ k kʰ g gʰ ɠ ts tsʰ dz ʈʂ ʈʂʰ ɖʐ tʃ tʃʰ dʒ dʒʰ ʄ VOT R ASP V", 0)
    phonefield$ = replace$(phonefield$, " KALASHA_FRICATIVE ", " s z ʂ ʐ ʃ ʒ h ", 0)

    phonefield$ = replace$(phonefield$, " KALASHA_NASAL ", " m n ɳ ŋ ", 0)
    phonefield$ = replace$(phonefield$, " KALASHA_LIQUID ", " ɻ ɽ ɾ l ɭ ", 0)
    phonefield$ = replace$(phonefield$, " KALASHA_GLIDE ", " w j ", 0)

    ###NATQGU
    phonefield$ = replace$(phonefield$, " NATQGU_VOWEL ", " a e i o u ɔ ʉ ɞ æ ə ә̃ ã ẽ ̃æ̃ ɔ̃ ɞ̃ ", 0)
    phonefield$ = replace$(phonefield$, " NATQGU_CONSONANT ", " NATQGU_CONS ", 0)
    phonefield$ = replace$(phonefield$, " NATQGU_CONS ", " p t k b d g m n ŋ ß s l w j ", 0)

    ###HATANG-KAYI
    phonefield$ = replace$(phonefield$, " HATANG-KAYI_VOWEL ", " HATANG-KAYI_STR HATANG-KAYI_UNS ", 0)
    phonefield$ = replace$(phonefield$, " HATANG-KAYI_STRESSED ", " HATANG-KAYI_STR ", 0)
    phonefield$ = replace$(phonefield$, " HATANG-KAYI_UNSTRESSED ", " HATANG-KAYI_UNS ", 0)
    phonefield$ = replace$(phonefield$, " HATANG-KAYI_STR ", " i1 u1 a1 ", 0)
    phonefield$ = replace$(phonefield$, " HATANG-KAYI_UNS ", " i0 u0 a0 ", 0)
    phonefield$ = replace$(phonefield$, " HATANG-KAYI_CONSONANT ", " HATANG-KAYI ", 0)
    phonefield$ = replace$(phonefield$, " HATANG-KAYI_CONS ", " ɸ t̪ k ʔ b d g s h m ŋ n l r w j ", 0)
    phonefield$ = replace$(phonefield$, " HATANG-KAYI_GLIDE ", " w j ", 0)

    ###MARANAO
    phonefield$ = replace$(phonefield$, " MARANAO_VOWEL ", " a ə ɤ i ɪ ɨ o u ", 0)
    phonefield$ = replace$(phonefield$, " MARANAO_CONSONANT ", " MARANAO_CONS ", 0)
    phonefield$ = replace$(phonefield$, " MARANAO_CONS ", " b d g j k kʰ l m n ŋ p pʰ ɾ s sʰ t tʰ w ʔ ", 0)

    ###MAJOR CLASSES
    #phonefield$ = replace$(phonefield$, " VOWEL ", " TNS LAX ", 0)
    #FRENCH
    phonefield$ = replace$(phonefield$, " VOWEL ", " TNS LAX ", 0)
    phonefield$ = replace$(phonefield$, " APPR ", " GLI LIQ ", 0)
    phonefield$ = replace$(phonefield$, " CONS ", " VLS VOI SON ", 0)
    phonefield$ = replace$(phonefield$, " OBS ", " VLS VOI ", 0)

    ###VOWEL QUALITY
    phonefield$ = replace$(phonefield$, " TNS ", " IY1 IY2 IY0 EY1 EY2 EY0 EYR1 EYR2 EYR0 OW1 OW2 OW0 UW1 UW2 UW0 ", 0)
    phonefield$ = replace$(phonefield$, " LAX ", " IH1 IH2 IH0 IR1 IR2 IR0 EH1 EH2 EH0 AH1 AH2 AH0 AE1 AE2 AE0 AY1 AY2 AY0 AW1 AW2 AW0 AA1 AA2 AA0 AAR1 AAR2 AAR0 AO1 AO2 AO0 OY1 OY2 OY0 OR1 OR2 OR0 ER1 ER2 ER0 UH1 UH2 UH0 UR1 UR2 UR0 ", 0)
    phonefield$ = replace$(phonefield$, " UNR ", " IY1 IY2 IY0 IH1 IH2 IH0 IR1 IR2 IR0 EY1 EY2 EY0 EYR1 EYR2 EYR0 EH1 EH2 EH0 AH1 AH2 AH0 AE1 AE2 AE0 AY1 AY2 AY0 AA1 AA2 AA0 AAR1 AAR2 AAR0 ", 0)
    phonefield$ = replace$(phonefield$, " RND ", " AW1 AW2 AW0 AO1 AO2 AO0 OW1 OW2 OW0 OY1 OY2 OY0 OR1 OR2 OR0 ER1 ER2 ER0 UH1 UH2 UH0 UW1 UW2 UW0 UR1 UR2 UR0 ", 0)
    phonefield$ = replace$(phonefield$, " BCK ", " AA1 AA2 AA0 AAR1 AAR2 AAR0 AO1 AO2 AO0 OW1 OW2 OW0 OY1 OY2 OY0 OR1 OR2 OR0 UH1 UH2 UH0 UW1 UW2 UW0 UR1 UR2 UR0 ", 0)
    phonefield$ = replace$(phonefield$, " CNT ", " AH1 AH2 AH0 AY1 AY2 AY0 AW1 AW2 AW0 ER1 ER2 ER0 ", 0)
    phonefield$ = replace$(phonefield$, " FRO ", " IY1 IY2 IY0 IH1 IH2 IH0 IR1 IR2 IR0 EY1 EY2 EY0 EYR1 EYR2 EYR0 EH1 EH2 EH0 AE1 AE2 AE0 ", 0)
    phonefield$ = replace$(phonefield$, " HI ", " IY1 IY2 IY0 IH1 IH2 IH0 IR1 IR2 IR0 UH1 UH2 UH0 UW1 UW2 UW0 UR1 UR2 UR0 ", 0)
    phonefield$ = replace$(phonefield$, " MID ", " EY1 EY2 EY0 EYR1 EYR2 EYR0 EH1 EH2 EH0 AH1 AH2 AH0 AO1 AO2 AO0 OW1 OW2 OW0 OY1 OY2 OY0 OR1 OR2 OR0 ER1 ER2 ER0 ", 0)
    phonefield$ = replace$(phonefield$, " LOW ", " AE1 AE2 AE0 AY1 AY2 AY0 AW1 AW2 AW0 AA1 AA2 AA0 AAR1 AAR2 AAR0 ", 0)
    phonefield$ = replace$(phonefield$, " DIPH ", " AY1 AY2 AY0 AW1 AW2 AW0 OY1 OY2 OY0 ", 0)
    
    phonefield$ = replace$(phonefield$, " VL ", " IY1L IY2L IY0L EY1L EY2L EY0L OW1L OW2L OW0L UW1L UW2L UW0L IH1L IH2L IH0L EH1L EH2L EH0L AH1L AH2L AH0L AE1L AE2L AE0L AY1L AY2L AY0L AW1L AW2L AW0L AA1L AA2L AA0L AO1L AO2L AO0L OY1L OY2L OY0L UH1L UH2L UH0L ", 0)
    phonefield$ = replace$(phonefield$, " VR ", " IY1R IY2R IY0R EY1R EY2R EY0R OW1R OW2R OW0R UW1R UW2R UW0R IH1R IH2R IH0R EH1R EH2R EH0R AH1R AH2R AH0R AE1R AE2R AE0R AY1R AY2R AY0R AW1R AW2R AW0R AA1R AA2R AA0R AO1R AO2R AO0R OY1R OY2R OY0R UH1R UH2R UH0R ", 0)
    phonefield$ = replace$(phonefield$, " VLSTR ", " IY1L IY2L EY1L EY2L OW1L OW2L UW1L UW2L IH1L IH2L EH1L EH2L AH1L AH2L AE1L AE2L AY1L AY2L AW1L AW2L AA1L AA2L AO1L AO2L OY1L OY2L UH1L UH2L ", 0)
    phonefield$ = replace$(phonefield$, " VRSTR ", " IY1R IY2R EY1R EY2R OW1R OW2R UW1R UW2R IH1R IH2R EH1R EH2R AH1R AH2R AE1R AE2R AY1R AY2R AW1R AW2R AA1R AA2R AO1R AO2R OY1R OY2R UH1R UH2R ", 0)

    phonefield$ = replace$(phonefield$, " LV ", " LIY1 LIY2 LIY0 LEY1 LEY2 LEY0 LOW1 LOW2 LOW0 LUW1 LUW2 LUW0 LIH1 LIH2 LIH0 LEH1 LEH2 LEH0 LAH1 LAH2 LAH0 LAE1 LAE2 LAE0 LAY1 LAY2 LAY0 LAW1 LAW2 LAW0 LAA1 LAA2 LAA0 LAO1 LAO2 LAO0 LOY1 LOY2 LOY0 LUH1 LUH2 LUH0 ", 0)
    phonefield$ = replace$(phonefield$, " RV ", " RIY1 RIY2 RIY0 REY1 REY2 REY0 ROW1 ROW2 ROW0 RUW1 RUW2 RUW0 RIH1 RIH2 RIH0 REH1 REH2 REH0 RAH1 RAH2 RAH0 RAE1 RAE2 RAE0 RAY1 RAY2 RAY0 RAW1 RAW2 RAW0 RAA1 RAA2 RAA0 RAO1 RAO2 RAO0 ROY1 ROY2 ROY0 RUH1 RUH2 RUH0 ", 0)
    phonefield$ = replace$(phonefield$, " LVST ", " LIY1 LIY2 LEY1 LEY2 LOW1 LOW2 LUW1 LUW2 LIH1 LIH2 LEH1 LEH2 LAH1 LAH2 LAE1 LAE2 LAY1 LAY2 LAW1 LAW2 LAA1 LAA2 LAO1 LAO2 LOY1 LOY2 LUH1 LUH2 ", 0)
    phonefield$ = replace$(phonefield$, " RVST ", " RIY1 RIY2 REY1 REY2 ROW1 ROW2 RUW1 RUW2 RIH1 RIH2 REH1 REH2 RAH1 RAH2 RAE1 RAE2 RAY1 RAY2 RAW1 RAW2 RAA1 RAA2 RAO1 RAO2 ROY1 ROY2 RUH1 RUH2 ", 0)

    ###FRENCH
    phonefield$ = replace$(phonefield$, " VOYELLES ", " VOYELLE ", 0)
    phonefield$ = replace$(phonefield$, " CONSONNES ", " CONSONNE ", 0)

    #phonefield$ = replace$(phonefield$, " VOYELLE ", " a i œ̃ œ ø u y ɑ̃ o ɛ ə e ɛ̃ ɔ ɔ̃ ɑ ʊ ɪ ", 0)
    phonefield$ = replace$(phonefield$, " VOYELLE ", " VOYELLE_FRR VOYELLE_FRU VOYELLE_BKR VOYELLE_CENT ", 0)
    phonefield$ = replace$(phonefield$, " VOYELLE_FRR ", " œ̃ œ ø y ", 0)
    phonefield$ = replace$(phonefield$, " VOYELLE_FRU ", " i ɪ ɛ e ɛ̃ ", 0)
    phonefield$ = replace$(phonefield$, " VOYELLE_BKR ", " u o ɔ ɔ̃ ʊ ", 0)
    phonefield$ = replace$(phonefield$, " VOYELLE_CENT ", " a ɑ̃ ə ɑ ", 0)
    #
    phonefield$ = replace$(phonefield$, " VOYELLE_ORAL ", " a i œ ø u y o ɛ ə e ɔ ɑ ʊ ɪ ", 0)
    phonefield$ = replace$(phonefield$, " VOYELLE_NAS ", " œ̃ ɑ̃ ɛ̃ ɔ̃ ", 0)
    #
    phonefield$ = replace$(phonefield$, " CONSONNE ", " CONSONNE_STOP CONSONNE_NAS CONSONNE_FRIC CONSONNE_APPROX ", 0)
    phonefield$ = replace$(phonefield$, " CONSONNE_STOP ", " p t k b d g ʤ ", 0)
    phonefield$ = replace$(phonefield$, " CONSONNE_NAS ", " m n ɲ ŋ ", 0)
    phonefield$ = replace$(phonefield$, " CONSONNE_FRIC ", " f s ʃ v z ʒ ʁ r ", 0)
    phonefield$ = replace$(phonefield$, " CONSONNE_APPROX ", " l j ɥ w ", 0)
    #
    phonefield$ = replace$(phonefield$, " CONSONNE_VLS_OBS ", " p t k f s ʃ ", 0)
    phonefield$ = replace$(phonefield$, " CONSONNE_VCD_OBS ", " b d g ʤ v z ʒ ʁ r ", 0)
    phonefield$ = replace$(phonefield$, " CONSONNE_SON ", " m n ɲ ŋ l j ɥ w ", 0)

    ###SPANISH - FASE
    phonefield$ = replace$(phonefield$, " VOCALES ", " VOCALE ", 0)
    phonefield$ = replace$(phonefield$, " CONSONANTES ", " CONSONANTE ", 0)

    phonefield$ = replace$(phonefield$, " VOCALE ", " VOCALE_HI VOCALE_MID VOCALE_LOW ", 0)
    phonefield$ = replace$(phonefield$, " VOCALE_HI ", " i u ", 0)
    phonefield$ = replace$(phonefield$, " VOCALE_MID ", " e o ", 0)
    phonefield$ = replace$(phonefield$, " VOCALE_LOW ", " a ", 0)
    phonefield$ = replace$(phonefield$, " VOCALE_FR ", " i e ", 0)
    phonefield$ = replace$(phonefield$, " VOCALE_CENT ", " a ", 0)
    phonefield$ = replace$(phonefield$, " VOCALE_BK ", " u o ", 0)
    #
    phonefield$ = replace$(phonefield$, " CONSONANTE ", " CONSONANTE_STOP CONSONANTE_NAS CONSONANTE_FRIC CONSONANTE_APPROX CONSONANTE_RHOT ", 0)
    phonefield$ = replace$(phonefield$, " CONSONANTE_STOP ", " p t k b d g ", 0)
    phonefield$ = replace$(phonefield$, " CONSONANTE_NAS ", " m n NY ", 0)
    phonefield$ = replace$(phonefield$, " CONSONANTE_FRIC ", " f s x ", 0)
    phonefield$ = replace$(phonefield$, " CONSONANTE_APPROX ", " l y ", 0)
    phonefield$ = replace$(phonefield$, " CONSONANTE_RHOT ", " R r ", 0)
    #
    phonefield$ = replace$(phonefield$, " CONSONANTE_VLS_OBS ", " p t k f s x CH ", 0)
    phonefield$ = replace$(phonefield$, " CONSONANTE_VCD_OBS ", " b d g R r ", 0)
    phonefield$ = replace$(phonefield$, " CONSONANTE_SON ", " l m n NY y ", 0)

    ###VOWEL STRESS
    phonefield$ = replace$(phonefield$, " STR ", " IY1 IH1 IR1 EY1 EYR1 EH1 AH1 AE1 AY1 AW1 AA1 AAR1 AO1 OW1 OY1 OR1 ER1 UH1 UW1 UR1 ", 0)
    phonefield$ = replace$(phonefield$, " 2ND ", " IY2 IH2 IR2 EY2 EYR2 EH2 AH2 AE2 AY2 AW2 AA2 AAR2 AO2 OW2 OY2 OR2 ER2 UH2 UW2 UR2 ", 0)
    phonefield$ = replace$(phonefield$, " UNS ", " IY0 IH0 IR0 EY0 EYR0 EH0 AH0 AE0 AY0 AW0 AA0 AAR0 AO0 OW0 OY0 OR0 ER0 UH0 UW0 UR0 ", 0)

    ###CONSONANT PLACE
    phonefield$ = replace$(phonefield$, " COR ", " DENT ALV POSTALV PAL LIQ ", 0)
    phonefield$ = replace$(phonefield$, " LAB ", " BILAB LABDENT W ", 0)
    phonefield$ = replace$(phonefield$, " DOR ", " VEL W ", 0)
    phonefield$ = replace$(phonefield$, " BILAB ", " P B M em ", 0)
    phonefield$ = replace$(phonefield$, " LABDENT ", " F V ", 0)
    phonefield$ = replace$(phonefield$, " DENT ", " TH DH ", 0)
    phonefield$ = replace$(phonefield$, " ALV ", " T D S Z N dx tq el eln en ", 0)
    phonefield$ = replace$(phonefield$, " PLV ", " CH JH SH ZH ", 0)
    phonefield$ = replace$(phonefield$, " PAL ", " Y ", 0)
    phonefield$ = replace$(phonefield$, " VEL ", " K G NG ", 0)
    phonefield$ = replace$(phonefield$, " LAR ", " HH ", 0)

    ###CONSONANT MANNER
    phonefield$ = replace$(phonefield$, " STOP ", " P T K B D G dx tq ", 0)
    phonefield$ = replace$(phonefield$, " AFFR ", " CH JH ", 0)
    phonefield$ = replace$(phonefield$, " FRIC ", " F TH S SH HH V DH Z ZH ", 0)
    phonefield$ = replace$(phonefield$, " NAS ", " M N NG em en ", 0)
    phonefield$ = replace$(phonefield$, " LIQ ", " L R el eln ", 0)
    phonefield$ = replace$(phonefield$, " SIB ", " CH S SH JH Z ZH ", 0)
    phonefield$ = replace$(phonefield$, " GLI ", " W Y ", 0)

    ###CONSONANT VOICING/SONORANCE
    phonefield$ = replace$(phonefield$, " VLS ", " P T K CH F TH S SH HH ", 0)
    phonefield$ = replace$(phonefield$, " VOI ", " B D G JH V DH Z ZH ", 0)
    phonefield$ = replace$(phonefield$, " SON ", " M N NG L W R Y ", 0)

    ###MISC
    phonefield$ = replace$(phonefield$, " ""#"" ", " # ", 0)
    phonefield$ = replace$(phonefield$, " # ", " ""#"" ", 0)

    ###BUCKEYE VOWELS
    phonefield$ = replace$(phonefield$, " AA1 ", " AA1 aa aan ", 0)
    phonefield$ = replace$(phonefield$, " AE1 ", " AE1 ae aen ", 0)
    phonefield$ = replace$(phonefield$, " AH1 ", " AH1 ah ahn ", 0)
    phonefield$ = replace$(phonefield$, " AO1 ", " AO1 ao aon ", 0)
    phonefield$ = replace$(phonefield$, " AW1 ", " AW1 aw awn ", 0)
    phonefield$ = replace$(phonefield$, " AY1 ", " AY1 ay ayn ", 0)
    phonefield$ = replace$(phonefield$, " EH1 ", " EH1 eh ehn ", 0)
    phonefield$ = replace$(phonefield$, " ER1 ", " ER1 er ern ", 0)
    phonefield$ = replace$(phonefield$, " EY1 ", " EY1 ey eyn ", 0)
    phonefield$ = replace$(phonefield$, " IH1 ", " IH1 ih ihn ", 0)
    phonefield$ = replace$(phonefield$, " IY1 ", " IY1 iy iyn ", 0)
    phonefield$ = replace$(phonefield$, " OW1 ", " OW1 ow own ", 0)
    phonefield$ = replace$(phonefield$, " OY1 ", " OY1 oy oyn ", 0)
    phonefield$ = replace$(phonefield$, " UH1 ", " UH1 uh uhn ", 0)
    phonefield$ = replace$(phonefield$, " UW1 ", " UW1 uw uwn ", 0)

    ###BUCKEYE CONSONANTS
    phonefield$ = replace$(phonefield$, " B ", " B b ", 0)
    phonefield$ = replace$(phonefield$, " CH ", " CH ch ", 0)
    phonefield$ = replace$(phonefield$, " D ", " D d dx ", 0)
    phonefield$ = replace$(phonefield$, " DH ", " DH dh ", 0)
    phonefield$ = replace$(phonefield$, " F ", " F f ", 0)
    phonefield$ = replace$(phonefield$, " G ", " G g ", 0)
    phonefield$ = replace$(phonefield$, " HH ", " HH hh ", 0)
    phonefield$ = replace$(phonefield$, " JH ", " JH jh ", 0)
    phonefield$ = replace$(phonefield$, " K ", " K k ", 0)
    phonefield$ = replace$(phonefield$, " L ", " L l ", 0)
    phonefield$ = replace$(phonefield$, " M ", " M m ", 0)
    phonefield$ = replace$(phonefield$, " N ", " N n ", 0)
    phonefield$ = replace$(phonefield$, " NG ", " NG ng ", 0)
    phonefield$ = replace$(phonefield$, " P ", " P p ", 0)
    phonefield$ = replace$(phonefield$, " R ", " R r ", 0)
    phonefield$ = replace$(phonefield$, " S ", " S s ", 0)
    phonefield$ = replace$(phonefield$, " SH ", " SH sh ", 0)
    phonefield$ = replace$(phonefield$, " T ", " T t tq dx ", 0)
    phonefield$ = replace$(phonefield$, " TH ", " TH th ", 0)
    phonefield$ = replace$(phonefield$, " V ", " V v ", 0)
    phonefield$ = replace$(phonefield$, " W ", " W w ", 0)
    phonefield$ = replace$(phonefield$, " Y ", " Y y ", 0)
    phonefield$ = replace$(phonefield$, " Z ", " Z z ", 0)
    phonefield$ = replace$(phonefield$, " ZH ", " ZH zh ", 0)

    phonefield$ = phonefield$ - " "
    if index (phonefield$, " ") == 1
        phonefield$ = right$ (phonefield$, length(phonefield$)-1)
    endif
    #printline *'phonefield$'*

    ###BUCKEYE SYLLABIC LATERAL AND SYLLABIC NASALS ARE NOT HANDLED PROPERLY YET
    #el eln em en

endproc



procedure functionwords

    #COMMON ENGLISH FUNCTION WORDS FROM http://myweb.tiscali.co.uk/wordscape/museum/funcword.html
    adverbs$ = " AGAIN AGO ALMOST ALREADY ALSO ALWAYS ANYWHERE BACK ELSE EVEN EVER EVERYWHERE FAR HENCE HERE HITHER HOW HOWEVER NEAR NEARBY NEARLY NEVER NOT NOW NOWHERE OFTEN ONLY QUITE RATHER SOMETIMES SOMEWHERE SOON STILL THEN THENCE THERE THEREFORE THITHER THUS TODAY TOMORROW TOO UNDERNEATH VERY WHEN WHENCE WHERE WHITHER WHY YES YESTERDAY YET "
    aux_verbs$ = " AM ARE AREN'T BE BEEN BEING CAN CAN'T COULD COULDN'T DID DIDN'T DO DOES DOESN'T DOING DONE DON'T GET GETS GETTING GOT HAD HADN'T HAS HASN'T HAVE HAVEN'T HAVING HE'D HE'LL HE'S I'D I'LL I'M IS I'VE ISN'T IT'S MAY MIGHT MUST MUSTN'T OUGHT OUGHTN'T SHALL SHAN'T SHE'D SHE'LL SHE'S SHOULD SHOULDN'T THAT'S THEY'D THEY'LL THEY'RE WAS WASN'T WE'D WE'LL WERE WE'RE WEREN'T WE'VE WILL WON'T WOULD WOULDN'T YOU'D YOU'LL YOU'RE YOU'VE "
    prepositions$ = " ABOUT ABOVE AFTER ALONG ALTHOUGH AMONG AND AROUND AS AT BEFORE BELOW BENEATH BESIDE BETWEEN BEYOND BUT BY DOWN DURING EXCEPT FOR FROM IF IN INTO NEAR NOR OF OFF ON OR OUT OVER ROUND SINCE SO THAN THAT THOUGH THROUGH TILL TO TOWARDS UNDER UNLESS UNTIL UP WHEREAS WHILE WITH WITHIN WITHOUT "
    determiners$ = " A ALL AN ANOTHER ANY ANYBODY ANYTHING BOTH EACH EITHER ENOUGH EVERY EVERYBODY EVERYONE EVERYTHING FEW FEWER HE HER HERS HERSELF HIM HIMSELF HIS I IT ITS ITSELF LESS MANY ME MINE MORE MOST MUCH MY MYSELF NEITHER NO NOBODY NONE NOONE NOTHING OTHER OTHERS OUR OURS OURSELVES SHE SOME SOMEBODY SOMEONE SOMETHING SUCH THAT THE THEIR THEIRS THEM THEMSELVES THESE THEY THIS THOSE US WE WHAT WHICH WHO WHOM WHOSE YOU YOUR YOURS YOURSELF YOURSELVES "
    numbers$ = " BILLION BILLIONTH EIGHT EIGHTEEN EIGHTEENTH EIGHTH EIGHTIETH EIGHTY ELEVEN ELEVENTH FIFTEEN FIFTEENTH FIFTH FIFTIETH FIFTY FIRST FIVE FORTIETH FORTY FOUR FOURTEEN FOURTEENTH FOURTH HUNDRED HUNDREDTH LAST MILLION MILLIONTH NEXT NINE NINETEEN NINETEENTH NINETIETH NINETY NINTH ONCE ONE SECOND SEVEN SEVENTEEN SEVENTEENTH SEVENTH SEVENTIETH SEVENTY SIX SIXTEEN SIXTEENTH SIXTH SIXTIETH SIXTY TEN TENTH THIRD THIRTEEN THIRTEENTH THIRTIETH THIRTY THOUSAND THOUSANDTH THREE THRICE TWELFTH TWELVE TWENTIETH TWENTY TWICE TWO "
    functionwords$ = adverbs$+aux_verbs$+prepositions$+determiners$+numbers$
    functionwords$ = replace$(functionwords$, "  ", " ", 0)

endproc


procedure parseString
    remaining$ = string_to_parse$+delimiter$
    i = 0
    #printline PARSING STRING
    if index(remaining$, "  ") > 0
    	.has_empty_string = 1
    else
    	.has_empty_string = 0
    endif
    while index(remaining$, delimiter$) > 0 and length(remaining$) > 1
        space = index(remaining$, delimiter$)
        substring$ = left$(remaining$, space-1)
        i = i + 1
        split_string'i'$ = substring$
        #print 'substring$'
        remaining$ = right$(remaining$, length(remaining$)-space)
        #print  
    endwhile
    
    if .has_empty_string == 1
    	#printline EMPTY STRING
    	i = i + 1
    	split_string'i'$ = ""
    endif
    
    n_strings = i
endproc

procedure dateStamp
    date$ = date$ ()
    year$ = mid$ (date$, 21, 4)
    month$ = mid$ (date$, 5, 3)
    day$ = mid$ (date$, 9, 2)
    hour$ = mid$ (date$, 12, 2) 
    minute$ = mid$ (date$, 15, 2) 
    seconds$ = mid$ (date$, 18, 2) 
    datestamp$ = year$+month$+day$+"_"+hour$+"h"+minute$+"m"+seconds$
    datestamp$ = replace$ (datestamp$, " ", "0", 0)
endproc

procedure excludeWords (.word$)
    testword$ = " "+.word$+" "
    if selected_words_only == 1
        exclude_word = 1
        if index(includedwords$, testword$) > 0
            exclude_word = 0
        endif
    else
        exclude_word = 0
        exclude_index = index(silences$, testword$)
        if exclude_index > 0
            exclude_word = 1
        elif excludedwords$ != "" and index(excludedwords$, testword$) > 0
            exclude_word = 1
            #print '.word$' is an excluded word'newline$'
        endif
    endif
endproc

procedure removeVLboundaries

    # remove word-internal pre-liquid boundaries (HACK)

    select TextGrid 'textgrid_name$'
    .final_p_interval = Get number of intervals... phone_tier

    #GO THROUGH PHONE INTERVALS ONE BY ONE
    .p = 1
    while .p < .final_p_interval

        select TextGrid 'textgrid_name$'
        .phone_start = Get starting point... phone_tier .p
        .phone_end = Get end point... phone_tier .p
        .phone_mid = (.phone_start+.phone_end)/2

        .phone$ = Get label of interval... phone_tier .p
        .nextphone$ = Get label of interval... phone_tier .p+1
        .w = Get interval at time... word_tier .phone_mid
        .word$ = Get label of interval... word_tier .w

        .word_end = Get end point... word_tier .w
        .nextphone_end = Get end point... phone_tier .p+1 

        if index(.phone$, "0") > 0 or index(.phone$, "1") > 0 or index(.phone$, "2") > 0
            if .nextphone$ == "L" or .nextphone$ == "R" or .nextphone$ == "r" or .nextphone$ == "l" or .nextphone$ == "ɻ" or .nextphone$ == "ɽ" or .nextphone$ == "ɾ" or .nextphone$ == "ɭ"
                #printline '.phone$' '.nextphone$' '.nextphone_end' '.word_end'
                if .nextphone_end <= .word_end
                    #printline REMOVING A BOUNDARY BETWEEN '.phone$' AND '.nextphone$' IN '.word$'
                    Remove right boundary... phone_tier .p
                    .final_p_interval = .final_p_interval - 1
                endif
            endif
        endif
        
        .p = .p + 1

    endwhile
endproc

procedure removeLVboundaries

    # remove word-internal post-liquid boundaries (HACK)

    select TextGrid 'textgrid_name$'
    .final_p_interval = Get number of intervals... phone_tier

    #GO THROUGH PHONE INTERVALS ONE BY ONE
    .p = 2
    while .p < .final_p_interval

        select TextGrid 'textgrid_name$'
        .phone_start = Get starting point... phone_tier .p
        .phone_end = Get end point... phone_tier .p
        .phone_mid = (.phone_start+.phone_end)/2

        .phone$ = Get label of interval... phone_tier .p
        .lastphone$ = Get label of interval... phone_tier .p-1
        .w = Get interval at time... word_tier .phone_mid
        .word$ = Get label of interval... word_tier .w

        .word_start = Get start point... word_tier .w
        .lastphone_start = Get start point... phone_tier .p-1 

        if index(.phone$, "0") > 0 or index(.phone$, "1") > 0 or index(.phone$, "2") > 0
            if .lastphone$ == "L" or .lastphone$ == "R" or .lastphone$ == "r" or .lastphone$ == "l" or .lastphone$ == "ɻ" or .lastphone$ == "ɽ" or .lastphone$ == "ɾ" or .lastphone$ == "ɭ"
                #printline '.phone$' '.nextphone$' '.nextphone_end' '.word_end'
                if .lastphone_start >= .word_start
                    # printline REMOVING A BOUNDARY BETWEEN '.lastphone$' AND '.phone$' IN '.word$'
                    Remove left boundary... phone_tier .p
                    .final_p_interval = .final_p_interval - 1
                endif
            endif
        endif
        
        .p = .p + 1

    endwhile
endproc

procedure transport
    
    # adapted from procedure saveIntervalsRoutine in extract_and_label.praat

    select TextGrid 'textgrid_name$'
    .w_intervals = Get number of intervals... word_tier
    .p_intervals = Get number of intervals... phone_tier
    any_matches_yet = 0
    textgrid_start = Get start time
    textgrid_end = Get end time

    .first_p_interval = 1
    .final_p_interval = .p_intervals
    word_tier_end = Get end point... word_tier .w_intervals

    #GO THROUGH PHONE INTERVALS ONE BY ONE
    for p from .first_p_interval to .final_p_interval
	    select TextGrid 'textgrid_name$'
        phone_start = Get starting point... phone_tier p
        phone_end = Get end point... phone_tier p
        phone_mid = (phone_start+phone_end)/2

        if phone_mid > word_tier_end
            #THIS ADDRESSES A BUCKEYE CORPUS ISSUE
            fileappend 'logfile$' 'textgrid_name$': tried to read word interval at time 'phone_mid''newline$'
        else
            w = Get interval at time... word_tier phone_mid
        
            .phone$ = Get label of interval... phone_tier p
    	    .word$ = Get label of interval... word_tier w

            #THIS IS BECAUSE WE OCCASIONALLY SEE COMMAS ON THE WORD TIER
            .word$ = replace$ (.word$, ",", "", 0)

            #SEE IF IT'S A WORD WE WANT
            word_match = 0 
            
            if target_word1$ = ""
                word_match = 1
            else
                for i to target_word_n
                    if word$ = target_word'i'$
                        word_match = 1
                    endif
                endfor
            endif

            if word_match
    	        #GET TIMES DURING THE WORD
    	        .word_start = Get starting point... word_tier w
    	        .word_end = Get end point... word_tier w
                        
                is_a_match = 0

                if .word_end - .word_start <= 0.001
                    startphone = Get interval at time... phone_tier (.word_start+.word_end)/2
                    endphone = Get interval at time... phone_tier (.word_start+.word_end)/2
                else
                    startphone = Get interval at time... phone_tier .word_start+0.001
                    endphone = Get interval at time... phone_tier .word_end-0.001
                endif
                #printline '.word$', '.word_end', 'endphone'

                short_context$ = ""

                target_match = 0
                if target1$ = ""
                    target_match = 1
                else
                    for i to targets_n
                        if .phone$ = target'i'$
                            target_match = 1
                        endif
                    endfor
                endif

                if target_match

                    for wp from startphone to endphone
                        wp$ = Get label of interval... phone_tier wp
                        if wp = p
                            wp$ = "["+wp$+"]"
                        endif
                        if short_context$ = ""
            	            short_context$ = wp$
                        else
            	            short_context$ = short_context$+" "+wp$
                        endif
                        if consider_word_boundaries
    	                    short_context$ = wordboundary$+wp$+wordboundary$
                        endif
                    endfor

                    targetphone$ = .phone$


                    if consider_word_boundaries

                        if p == 1
                            .lastphone$ = wordboundary$
                            .lastphone1$ = "--undefined--"
                            .lastphone2$ = "--undefined--"
                        elif p == 2
                            if p == startphone
                                .lastphone$ = wordboundary$
                                .lastphone1$ = Get label of interval... phone_tier p-1
                                .lastphone2$ = "--undefined--"
                            elif p == startphone + 1
                                .lastphone$ = Get label of interval... phone_tier p-1
                                .lastphone1$ = wordboundary$
                                .lastphone2$ = "--undefined--"
                            else
                                .lastphone$ = Get label of interval... phone_tier p-1
                                .lastphone1$ = "--undefined--"
                                .lastphone2$ = "--undefined--"
                            endif
                        else
                            if p == startphone
                                .lastphone$ = wordboundary$
                                .lastphone1$ = Get label of interval... phone_tier p-1
                                .lastphone2$ = Get label of interval... phone_tier p-2
                            elif p == startphone + 1
                                .lastphone$ = Get label of interval... phone_tier p-1
                                .lastphone1$ = wordboundary$
                                .lastphone2$ = Get label of interval... phone_tier p-2
                            elif p == startphone + 2
                                .lastphone$ = Get label of interval... phone_tier p-1
                                .lastphone1$ = Get label of interval... phone_tier p-2
                                .lastphone2$ = wordboundary$
                            else
                                .lastphone$ = Get label of interval... phone_tier p-1
                                .lastphone1$ = Get label of interval... phone_tier p-2
                                .lastphone2$ = Get label of interval... phone_tier p-3
                            endif
                        endif

                        if p == .final_p_interval
                            .nextphone$ = wordboundary$
                            .nextphone1$ = "--undefined--"
                            .nextphone2$ = "--undefined--"
                        elif p == .final_p_interval - 1
                            if p == endphone
                                .nextphone$ = wordboundary$
                                .nextphone1$ = Get label of interval... phone_tier p+1
                                .nextphone2$ = "--undefined--"
                            elif p == endphone - 1
                                .nextphone$ = Get label of interval... phone_tier p+1
                                .nextphone1$ = wordboundary$
                                .nextphone2$ = "--undefined--"
                            else
                                .nextphone$ = Get label of interval... phone_tier p+1
                                .nextphone1$ = "--undefined--"
                                .nextphone2$ = "--undefined--"
                            endif
                        else
                            if p == endphone
                                .nextphone$ = wordboundary$
                                .nextphone1$ = Get label of interval... phone_tier p+1
                                .nextphone2$ = Get label of interval... phone_tier p+2
                            elif p == endphone - 1
                                .nextphone$ = Get label of interval... phone_tier p+1
                                .nextphone1$ = wordboundary$
                                .nextphone2$ = Get label of interval... phone_tier p+2
                            elif p == endphone - 2
                                .nextphone$ = Get label of interval... phone_tier p+1
                                .nextphone1$ = Get label of interval... phone_tier p+2
                                .nextphone2$ = wordboundary$
                            else 
                                .nextphone$ = Get label of interval... phone_tier p+1
                                .nextphone1$ = Get label of interval... phone_tier p+2
                                .nextphone2$ = Get label of interval... phone_tier p+3
                            endif
                        endif

                    else

                        if p == 1
                            .lastphone$ = "--undefined--"
                            .lastphone1$ = "--undefined--"
                            .lastphone2$ = "--undefined--"
                        elif p == 2
                            .lastphone$ = Get label of interval... phone_tier p-1
                            .lastphone1$ = "--undefined--"
                            .lastphone2$ = "--undefined--"
                        elif p == 3
                            .lastphone$ = Get label of interval... phone_tier p-1
                            .lastphone1$ = Get label of interval... phone_tier p-2
                            .lastphone2$ = "--undefined"
                        else
                            .lastphone$ = Get label of interval... phone_tier p-1
                            .lastphone1$ = Get label of interval... phone_tier p-2
                            .lastphone2$ = Get label of interval... phone_tier p-3
                        endif

                        if p == .final_p_interval
                            .nextphone$ = "--undefined--"
                            .nextphone1$ = "--undefined--"
                            .nextphone2$ = "--undefined--"
                        elif p == .final_p_interval - 1
                            .nextphone$ = Get label of interval... phone_tier p+1
                            .nextphone1$ = "--undefined--"
                            .nextphone2$ = "--undefined--"
                        elif p == .final_p_interval - 2
                            .nextphone$ = Get label of interval... phone_tier p+1
                            .nextphone1$ = Get label of interval... phone_tier p+2
                            .nextphone2$ = "--undefined--"
                        else
                            .nextphone$ = Get label of interval... phone_tier p+1
                            .nextphone1$ = Get label of interval... phone_tier p+2
                            .nextphone2$ = Get label of interval... phone_tier p+3
                        endif

                    endif

                    if .lastphone$ == wordboundary$ or .lastphone$ == "--undefined--"
                        .lastphone_start = phone_start
                    else
                        .lastphone_start = Get starting point... phone_tier p-1                            
                    endif

                    if .nextphone$ == wordboundary$ or .nextphone$ == "--undefined--"
                        .nextphone_end = phone_end
                    else
                        .nextphone_end = Get end point... phone_tier p+1                            
                    endif

                    if w > 1
                        .lastword_start = Get starting point... word_tier w-1
                        .lastword$ = Get label of interval... word_tier w-1
                        #THIS IS BECAUSE WE OCCASIONALLY SEE COMMAS ON THE WORD TIER
                        .lastword$ = replace$ (.lastword$, ",", "", 0)
                    else
                        .lastword_start = undefined
                        .lastword$ = ""
                    endif

                    if w < .w_intervals
                        .nextword_end = Get end point... word_tier w+1
                        .nextword$ = Get label of interval... word_tier w+1
                        #THIS IS BECAUSE WE OCCASIONALLY SEE COMMAS ON THE WORD TIER
                        .nextword$ = replace$ (.nextword$, ",", "", 0)
                    else
                        .nextword_end = undefined
                        .nextword$ = ""
                    endif

                    preceding0_match = 0
                    if preceding0_1$ = ""
                        preceding0_match = 1
                    else
                        for i to preceding0_n
                            if .lastphone$ = preceding0_'i'$
                                preceding0_match = 1
                            endif
                        endfor
                    endif

                    preceding1_match = 0
                    if preceding1_1$ = ""
                        preceding1_match = 1
                    else
                        for i to preceding1_n
                            if .lastphone1$ = preceding1_'i'$
                                preceding1_match = 1
                            endif
                        endfor
                    endif

                    following0_match = 0
                    if following0_1$ = ""
                        following0_match = 1
                    else
                        for i to following0_n
                            if .nextphone$ = following0_'i'$
                                following0_match = 1
                            endif
                        endfor
                    endif

                    following1_match = 0
                    if following1_1$ = ""
                        following1_match = 1
                    else
                        for i to following1_n
                            if .nextphone1$ = following1_'i'$
                                following1_match = 1
                            endif
                        endfor
                    endif
                    #printline 'preceding1_match' 'preceding0_match' 'following0_match' 'following1_match'
                    if preceding0_match and following0_match and preceding1_match and following1_match
                        is_a_match = 1
                        .phone_start = Get starting point... phone_tier p
                        .phone_end = Get end point... phone_tier p
                        .duration = .phone_end - .phone_start
                    endif
                endif

                if is_a_match
                    @excludeWords (.word$)
                    if exclude_word
                        is_a_match = 0
                    elif .duration < min_duration
                        is_a_match = 0
                    endif
                endif
                
                if is_a_match

                    if wav_is_open == 0
                        Read from file... 'wav_file$'
                        Rename... 'sound_name$'
                        wav_duration = Get total duration
                        total_duration = total_duration + wav_duration
                        sound_samplerate = Get sampling frequency
                        wav_is_open = 1
                    endif

                    skip_this_token = 0
                    #tab_number = tab_number + 1

                    if interactive_session == 1
                        editor TextGrid 'textgrid_name$'
                        Zoom... (.phone_start+.phone_end-initial_zoom)/2 (.phone_start+.phone_end+initial_zoom)/2
                        Select... .phone_start .phone_end                        
                        endeditor
                    endif

                    .overlapping_speech$ = ""
                    select TextGrid 'textgrid_name$'
                    for .i from 1 to textgrid_tiers
                        #if .i != phone_tier and index (all_phone_tiers$, " '.i' ") > 0
                        if .i != word_tier and index (all_word_tiers$, " '.i' ") > 0

                            .other_tier_at_start = Get interval at time: .i, .phone_start
                            .other_tier_at_end = Get interval at time: .i, .phone_end
                            
                            for .j from .other_tier_at_start to .other_tier_at_end
                                .other_phone_label$ = Get label of interval: .i, .j
                                if .other_phone_label$ != "sp"
                                    if .overlapping_speech$ == ""
                                        .overlapping_speech$ = .other_phone_label$
                                    else
                                        .overlapping_speech$ = .overlapping_speech$ + " " + .other_phone_label$
                                    endif
                                endif
                            endfor                            
                            #printline '.i' is another word tier, intervals '.other_tier_at_start' to '.other_tier_at_end' *'.overlapping_speech$'*
                        endif
                    endfor


                    @makeMeasurements

                    if interactive_session == 1 and skip_this_token == 0
                        editor TextGrid 'textgrid_name$'
                        beginPause("Look at this token")
                        okay = endPause ("Okay", 1)                        
                        endeditor
                    endif

                endif
            endif
	    endif
    endfor

endproc















































































































































































































































































































































<<<<<<< HEAD
=======





























































>>>>>>> 2f65283dc18afc74c5d4f4fa6097dffd9e6abb93
#including procedures on line 2001 so that error messages will be more informative (subtract 2000 from the line number to find the line in the procedures file)
include one_script_procedures_dev.praat
