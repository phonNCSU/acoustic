############################################################
#  procedures for One Script to Rule Them All!
#
#  contributed by Jeff Mielke, Eric Wilbanks, Lyra Magloughlin, Michael Fox, Bridget Smith, Jessica Hatcher, Sarah Chetty
# - Updated Oct 6, 2023
#
#  4/21/21 formantModeler arguments are now sensitive to Praat version
#  4/26/21 nasalization(): improved LTAS measures of A1, P0, FP0, and P1
#  4/29/21 nasalization(): added corrections for vowel quality
# changes to document
#  block unnecessary warnings from clips() and trigrams() when running mfc()
#  5/13/23 clips(), phone_clips(), trigrams(): makes long textgrids now
#
#######################################################################################
# general utility functions
#######################################################################################

procedure handleCustomWildcards

    nonsiblist$ = "# IY1 IY2 IY0 EY1 EY2 EY0 EYR1 EYR2 EYR0 OW1 OW2 OW0 UW1 UW2 UW0 IH1 IH2 IH0 IR1 IR2 IR0"
    nonsiblist$ = nonsiblist$ + " EH1 EH2 EH0 AH1 AH2 AH0 AE1 AE2 AE0 AY1 AY2 AY0 AW1 AW2 AW0"
    nonsiblist$ = nonsiblist$ + " AA1 AA2 AA0 AAR1 AAR2 AAR0 AO1 AO2 AO0 OY1 OY2 OY0 OR1 OR2 OR0 ER1 ER2 ER0 UH1 UH2 UH0 UR1 UR2 UR0"
    nonsiblist$ = nonsiblist$ + " M N NG L W R Y P T K F TH HH B D G V DH"
    #THIS MATCHES EVERYTHING THAT IS NOT A SIBILANT ("CH S SH JH Z ZH")
    phonefield$ = replace$(phonefield$, "NONSIB", nonsiblist$, 0)
    
endproc

procedure gettime
    .d$ = date$()
    .t$ = mid$ (.d$, 12, 8)
    .h$ = left$ (.t$, 2)
    .m$ = mid$ (.t$, 4, 2)
    .s$ = right$ (.t$, 2)
    .t = number(.s$) + 60*number(.m$) + 3600*number(.h$)
endproc

procedure logtime
    #printline '.h$' '.m$' '.s$'
    @gettime
    fileappend 'timelog$' ,'gettime.t'
endproc

#######################################################################################
# utility procedures for drawing
#######################################################################################

procedure viewportDefaults
    viewport_left = 0
    viewport_right = 4
    viewport_cursor = 0
    figure_overlap = 0.35
endproc

procedure drawWaveform
    .figure_height = 1.5
    Select outer viewport: viewport_left, viewport_right, viewport_cursor, viewport_cursor+.figure_height
    viewport_cursor = viewport_cursor+.figure_height-figure_overlap
    select Sound 'sound_name$'
    Extract part... 'picture_start' 'picture_end' rectangular 1.0 yes
    Rename: "sound_to_paint" 
    Black
    Draw: picture_start, picture_end, 0, 0, "yes", "Curve"
    Remove
endproc

procedure drawSpectrogram (.max_freq)
    .figure_height = 1.5
    Select outer viewport: viewport_left, viewport_right, viewport_cursor, viewport_cursor+.figure_height
    viewport_cursor = viewport_cursor+.figure_height-figure_overlap
    select Sound 'sound_name$'
    Extract part... 'picture_start' 'picture_end' rectangular 1.0 yes
    Rename: "sound_to_paint" 
    selectObject: "Sound sound_to_paint"
    Black
    To Spectrogram: 0.005, .max_freq, 0.002, 20, "Gaussian"
    Paint: picture_start, picture_end, 0, 0, 100, "yes", 50, 6, 0, "yes"
    Green
    Draw arrow: transport.phone_start, -1000, transport.phone_start, 0
    Red
    Draw arrow: transport.phone_end, -1000, transport.phone_end, 0
    Black
    #CLEAN UP OBJECTS
    selectObject: "Sound sound_to_paint"
    plusObject: "Spectrogram sound_to_paint"
    Remove
endproc

procedure drawBandDiff
    .figure_height = 1.5
    Select outer viewport: viewport_left, viewport_right, viewport_cursor, viewport_cursor+.figure_height
    viewport_cursor = viewport_cursor+.figure_height-figure_overlap
    selectObject: "Table spectrum_info"
    Black
    Scatter plot (mark): "time", picture_start, picture_end, "banddiff", 0, 0, 1.5, "yes", "."
    #Red
    #Draw line: picture_start, make_Table_spectrum_info.band_diff_on_threshold, picture_end, make_Table_spectrum_info.band_diff_on_threshold
    #Blue
    #Draw line: picture_start, make_Table_spectrum_info.band_diff_off_threshold, picture_end, make_Table_spectrum_info.band_diff_off_threshold
    Black
endproc

procedure drawCOG
    .figure_height = 1.5
    Select outer viewport: viewport_left, viewport_right, viewport_cursor, viewport_cursor+.figure_height
    viewport_cursor = viewport_cursor+.figure_height-figure_overlap
    selectObject: "Table spectrum_info"
    Black
    Scatter plot (mark): "time", picture_start, picture_end, "cog", 0, 0, 1.5, "yes", "."
    #Red
    #Draw line: picture_start, make_Table_spectrum_info.cog_threshold, picture_end, make_Table_spectrum_info.cog_threshold
    Black
endproc

procedure drawFreqBands
    .figure_height = 1.5
    Select outer viewport: viewport_left, viewport_right, viewport_cursor, viewport_cursor+.figure_height
    viewport_cursor = viewport_cursor+.figure_height-figure_overlap
    selectObject: "Table spectrum_info"
    .bands_min = Get minimum: "0-500"
    .bands_max = Get maximum: "0-500"
    .bands_range = .bands_max - .bands_min
    Red
    Scatter plot (mark): "time", picture_start, picture_end, make_Table_spectrum_info.band1_name$, 0, 0, 1.5, "no", "."
    Text: picture_start+0.05*picture_duration, "Centre", .bands_min+0.2*.bands_range, "Half", make_Table_spectrum_info.band1_name$
    Olive
    Text: picture_start+0.05*picture_duration, "Centre", .bands_min+0.4*.bands_range, "Half", make_Table_spectrum_info.band2_name$
    Green
    Text: picture_start+0.05*picture_duration, "Centre", .bands_min+0.6*.bands_range, "Half", make_Table_spectrum_info.band3_name$
    Blue
    Text: picture_start+0.05*picture_duration, "Centre", .bands_min+0.8*.bands_range, "Half", make_Table_spectrum_info.band4_name$
    Purple
    Text: picture_start+0.05*picture_duration, "Centre", .bands_min+1.0*.bands_range, "Half", make_Table_spectrum_info.band5_name$
    Olive
    Scatter plot (mark): "time", picture_start, picture_end, make_Table_spectrum_info.band2_name$, 0, 0, 1.5, "no", "."
    Green
    Scatter plot (mark): "time", picture_start, picture_end, make_Table_spectrum_info.band3_name$, 0, 0, 1.5, "no", "."
    Blue
    Scatter plot (mark): "time", picture_start, picture_end, make_Table_spectrum_info.band4_name$, 0, 0, 1.5, "no", "."
    Purple
    Scatter plot (mark): "time", picture_start, picture_end, make_Table_spectrum_info.band5_name$, 0, 0, 1.5, "no", "."
    Black
endproc

#########

procedure make_Table_spectrum_info (.left_bound, .right_bound)

    #Defaults
    .error$ = ""
    .step_size = 0.005
    .window_size = 0.03

    #for COG
    .band_low = 500
    .band_high = 15000
    .band_smooth = 100
 
    #for band_diff
    .low_band_floor = 0
    .low_band_ceiling = 500 
    .high_band_floor = 1500
    .high_band_ceiling = 2500

    #for bands figure
    .band_split0 = 0
    .band_split1 = 500
    .band_split2 = 1000
    .band_split3 = 1500
    .band_split4 = 2500
    .band_split5 = 3500

    ###

    .band1_name$ = replace$("'.band_split0'-'.band_split1'", "000", "k", 0)
    .band2_name$ = replace$("'.band_split1'-'.band_split2'", "000", "k", 0)
    .band3_name$ = replace$("'.band_split2'-'.band_split3'", "000", "k", 0)
    .band4_name$ = replace$("'.band_split3'-'.band_split4'", "000", "k", 0)
    .band5_name$ = replace$("'.band_split4'-'.band_split5'", "000", "k", 0)

    .duration = .right_bound - .left_bound
    .number_of_intervals = .duration/.step_size
    .rounded_num_int = '.number_of_intervals:0'

    Create Table with column names: "spectrum_info", 0, "time cog banddiff banddiffdelta '.band1_name$' '.band2_name$' '.band3_name$' '.band4_name$' '.band5_name$'"

    for .k from 0 to .rounded_num_int

        .window_center = '.left_bound' + .k*.step_size
        .window_start = .window_center - .window_size/2
        .window_end = .window_center + .window_size/2

        select Sound 'sound_name$'
        Extract part... '.window_start' '.window_end' rectangular 1.0 yes
        To Spectrum... yes
        .band_diff = Get band energy difference: .low_band_floor, .low_band_ceiling, .high_band_floor, .high_band_ceiling

        #BAND DIFFERENCE VELOCITY
        if .k == 0
            .band_diff_delta = 0
        else
            .band_diff_delta = .band_diff - .last_band_diff
        endif
        .last_band_diff = .band_diff

        .energy_band1 = Get band energy: .band_split0, .band_split1
        .energy_band2 = Get band energy: .band_split1, .band_split2
        .energy_band3 = Get band energy: .band_split2, .band_split3
        .energy_band4 = Get band energy: .band_split3, .band_split4
        .energy_band5 = Get band energy: .band_split4, .band_split5

        select Sound 'sound_name$'_part
        Filter (pass Hann band): .band_low, .band_high, .band_smooth
        To Spectrum... yes
        .cog = Get centre of gravity... 2

        #ADD DATA TO THE TABLE
        selectObject: "Table spectrum_info"
        Append row
        .lastrow = .k+1
        Set numeric value: .lastrow, "time", .window_center
        Set numeric value: .lastrow, "cog", .cog
        Set numeric value: .lastrow, "banddiff", .band_diff
        Set numeric value: .lastrow, "banddiffdelta", .band_diff_delta
        Set numeric value: .lastrow, .band1_name$, .energy_band1
        Set numeric value: .lastrow, .band2_name$, .energy_band2
        Set numeric value: .lastrow, .band3_name$, .energy_band3
        Set numeric value: .lastrow, .band4_name$, .energy_band4
        Set numeric value: .lastrow, .band5_name$, .energy_band5

        #CLEAN UP OBJECTS CREATED IN THE LOOP
        select Sound 'sound_name$'_part
        plus Spectrum 'sound_name$'_part
        plus Sound 'sound_name$'_part_band
        plus Spectrum 'sound_name$'_part_band
        Remove

    endfor
endproc

#######################################################################################
# PROBLEMATIC: liquid_energy()
# measure the energy in a liquid
#######################################################################################

procedure liquid_energy (.argString$)

    if isHeader = 1 
        fileappend 'outfile$' ,cog
    elif isComplete == 1
        printline FINISHED  
    else
        #select Sound 'sound_name$'
        #Extract part... 'transport.phone_start' 'transport.phone_end' rectangular 1.0 yes
 
        .left_bound = transport.phone_start - 0.05
        .right_bound = transport.phone_end + 0.05
        @make_Table_spectrum_info (.left_bound, .right_bound)

        #DRAW THE PICTURE IF THIS IS AN INTERACTIVE SESSION
        if interactive_session == 1
            picture_start = .left_bound
            picture_end = .right_bound
            picture_duration = picture_end - picture_start
            @viewportDefaults
            Erase all
            @drawWaveform
            @drawSpectrogram (5000)
            @drawFreqBands
            @drawBandDiff
            @drawCOG
        endif

        #CLEAN UP OBJECTS
        selectObject: "Table spectrum_info"
        Remove

        fileappend 'outfile$' ,'.cog:0'
 
    endif

endproc

#######################################################################################
# drawSibilantInfo
# 
# requires Sound 'sound_name$'
# requires Table spectrum_info 
# requires Table burst_info
#######################################################################################

procedure drawSibilantInfo (picture_start, picture_end)

    picture_duration = picture_end - picture_start
    Select outer viewport: 0, 6, 0, 1.5
    Erase all
    Black

    #DRAW WAVEFORM (AND TEXTGRID)
    select Sound 'sound_name$'
    Extract part... 'picture_start' 'picture_end' rectangular 1.0 yes
    Rename: "sound_to_paint"
    Select outer viewport: 0, 6, 0, 1.5
    Draw: picture_start, picture_end, 0, 0, "yes", "Curve"

    #DRAW SPECTROGRAM
    selectObject: "Sound sound_to_paint"
    To Spectrogram: 0.005, 10000, 0.002, 20, "Gaussian"
    Select outer viewport: 0, 6, 1, 2.5
    Paint: picture_start, picture_end, 0, 0, 100, "yes", 50, 6, 0, "yes"
    Red
    Draw arrow: resegmentSibilant.original_start, -1000, resegmentSibilant.original_start, 0
    Green
    Draw arrow: resegmentSibilant.start, -1000, resegmentSibilant.start, 0
    Blue
    Draw arrow: resegmentSibilant.end, -1000, resegmentSibilant.end, 0
    Olive
    Draw arrow: resegmentSibilant.band_diff_max_time, -1000, resegmentSibilant.band_diff_max_time, 0
    Black

    #DRAW ACOUSTIC MEASURES USED FOR SEGMENTATION
    selectObject: "Table spectrum_info"
    Select outer viewport: 0, 6, 2, 3.5
    Scatter plot (mark): "time", picture_start, picture_end, "banddiff", 0, 0, 1.5, "yes", "."
    Red
    Draw line: picture_start, resegmentSibilant.band_diff_on_threshold, picture_end, resegmentSibilant.band_diff_on_threshold
    Blue
    Draw line: picture_start, resegmentSibilant.band_diff_off_threshold, picture_end, resegmentSibilant.band_diff_off_threshold
    Black
    ##############################################
    Select outer viewport: 0, 6, 3, 4.5
    Scatter plot (mark): "time", picture_start, picture_end, "cog", 0, 0, 1.5, "yes", "."
    Red
    Draw line: picture_start, resegmentSibilant.cog_threshold, picture_end, resegmentSibilant.cog_threshold
    Black

    ##############################################
    .bands_min = Get minimum: "0-500"
    .bands_max = Get maximum: "0-500"
    .bands_range = .bands_max - .bands_min
    Select outer viewport: 0, 6, 4, 5.5
    Red
    Scatter plot (mark): "time", picture_start, picture_end, "0-500", 0, 0, 1.5, "no", "."
    Text: picture_start+0.05*picture_duration, "Centre", .bands_min+0.2*.bands_range, "Half", "0-500"
    Olive
    Text: picture_start+0.05*picture_duration, "Centre", .bands_min+0.4*.bands_range, "Half", "500-1k"
    Green
    Text: picture_start+0.05*picture_duration, "Centre", .bands_min+0.6*.bands_range, "Half", "1k-2k"
    Blue
    Text: picture_start+0.05*picture_duration, "Centre", .bands_min+0.8*.bands_range, "Half", "2k-4k"
    Purple
    Text: picture_start+0.05*picture_duration, "Centre", .bands_min+1.0*.bands_range, "Half", "4k-8k"
    Olive
    Scatter plot (mark): "time", picture_start, picture_end, "500-1k", 0, 0, 1.5, "no", "."
    Green
    Scatter plot (mark): "time", picture_start, picture_end, "1k-2k", 0, 0, 1.5, "no", "."
    Blue
    Scatter plot (mark): "time", picture_start, picture_end, "2k-4k", 0, 0, 1.5, "no", "."
    Purple
    Scatter plot (mark): "time", picture_start, picture_end, "4k-8k", 0, 0, 1.5, "no", "."
    Black

    #DRAW ACOUSTIC MEASURES USED FOR REFINING BURST
    selectObject: "Table burst_info"
    Select outer viewport: 0, 6, 5.5, 7
    Scatter plot (mark): "time", picture_start, picture_end, "ampratio", 0, 0, 0.5, "yes", "."
    Green
    Draw arrow: picture_start, resegmentSibilant.releasemin_threshold, resegmentSibilant.start, resegmentSibilant.releasemin_threshold
    Black

    #CLEAN UP OBJECTS
    selectObject: "Sound sound_to_paint"
    plusObject: "Spectrogram sound_to_paint"
    Remove

endproc

#######################################################################################
#                                                                                     #
#                   PROCEDURES FOR EXTRACTING AND CODING CLIPS                        #
#                                                                                     #
#######################################################################################

#######################################################################################
# PROCEDURE: clips(pad=0.1,filter_low=0,filter_high=22050,sanitize=1,scale=0)
# extract word clips. 
# clips will only be filtered if filter_low or filter_high arguments are specified. 
# (0,22050 are defaults if only one is specified)
#
# EXAMPLE: 'clips()'
#######################################################################################

procedure clips (.argString$)

    @parseArgs (.argString$)
   
    .pad = 0.1
    .rate = 44100
    .filter_low = 0
    .filter_high = 22050
    .filtering = 0
    .sanitize = 1
    .scale_peak = 0
    .spectrograms = 0

    for i to parseArgs.n_args
        x$ = parseArgs.var$[i]
        if parseArgs.var$[i] == "pad"
            .pad = number(parseArgs.val$[i])
        elif parseArgs.var$[i] == "rate"
            .rate = number(parseArgs.val$[i])
        elif parseArgs.var$[i] == "filter_low"
            .filter_low = number(parseArgs.val$[i])
            .filtering = 1
        elif parseArgs.var$[i] == "filter_high"
            .filter_high = number(parseArgs.val$[i])
            .filtering = 1
        elif parseArgs.var$[i] == "sanitize"
            .sanitize = number(parseArgs.val$[i])
        elif parseArgs.var$[i] == "scale"
            .scale_peak = number(parseArgs.val$[i])
        elif parseArgs.var$[i] == "spectrograms"
            .spectrograms = number(parseArgs.val$[i])
        elif parseArgs.var$[i] == "categories"
            # pass
        elif parseArgs.var$[i] == "trigrams"
            # pass
        elif parseArgs.var$[i] == "show_words"
            # pass
        elif parseArgs.var$[i] != ""
            if isHeader == 1
                .unknown_var$ = parseArgs.var$[i]
                printline skipped unknown argument '.unknown_var$'
            endif
        endif
    endfor

    if isHeader = 1 
        createDirectory: clipPath$
        #fileappend 'outfile$' ,clip_start,clip_end,clip_filename
        fileappend 'outfile$' ,clip_start,clip_end,stimulus
    elif isComplete == 1
        printline FINISHED  

        if .spectrograms == 1
            .pdfunite_command$ = "pdfunite "+clipPath$+"/*.pdf clips_"+datestamp$+".pdf"
            printline #####################################
            printline Created individual spectrogram pdfs. Combine to one pdf with this command:
            printline '.pdfunite_command$'             
            printline #####################################
        endif


    else
        select Sound 'sound_name$'
        .clip_start = round(1000*(transport.word_start - .pad))/1000
        .clip_end = round(1000*(transport.word_end + .pad))/1000
        Extract part... '.clip_start' '.clip_end' rectangular 1.0 yes
        .original_rate = Get sampling frequency
        #printline '.original_rate' '.rate'
        if .original_rate != .rate
            # printline resampling 'sound_name$' to '.rate' Hz
            Resample: .rate, 50
            selectObject: "Sound 'sound_name$'_part"
            Remove
            selectObject: "Sound 'sound_name$'_part_'.rate'"
            Rename: sound_name$+"_part"
        endif
        if .filtering == 1
            Filter (pass Hann band): '.filter_low', '.filter_high', 100
        endif  
        timestring$ = replace$ ("'.clip_start'", ".", "_", 0)
        if .clip_start == round(.clip_start)
            printline 'timestring$'
            timestring$ = timestring$+"_0"
        endif

        .word_for_filename$ = transport.word$
        if .sanitize==1
            .word_for_filename$ = replace$ (.word_for_filename$, "{", "", 0)
            .word_for_filename$ = replace$ (.word_for_filename$, "}", "", 0)
            .word_for_filename$ = replace$ (.word_for_filename$, "<", "", 0)
            .word_for_filename$ = replace$ (.word_for_filename$, ">", "", 0)
            .word_for_filename$ = replace$ (.word_for_filename$, "[", "", 0)
            .word_for_filename$ = replace$ (.word_for_filename$, "]", "", 0)
            .word_for_filename$ = replace$ (.word_for_filename$, " ", "", 0)
        endif

        if .scale_peak == 1
            # printline scaling peak
            Scale peak: 0.99
        endif
        .sound_filename$ = "'sound_name$'_'timestring$'_'.word_for_filename$'"
        Write to WAV file... 'clipPath$'/'.sound_filename$'.wav

        # THIS IS TO SAVE TEXTGRIDS TOO ###################
        selectObject: "TextGrid 'textgrid_name$'"
        Extract part: .clip_start, .clip_end, "no"
        Save as text file: "'clipPath$'/'.sound_filename$'.TextGrid"
        ###################################################

        # THIS IS TO SAVE SPECTROGRAMS TOO ################
        if .spectrograms == 1
            Erase all

            .token_label_no_underscores$ = replace$(token_id$, "_", " ", 0)
            #printline '.token_label_no_underscores$'

            selectObject: "Sound "+sound_name$+"_part"
            To Spectrogram: 0.005, 5000, 0.002, 20, "Gaussian"

            Select outer viewport: 0, 6, 0.5, 3.5
            Paint: 0, 0, 0, 0, 100, "yes", 50, 6, 0, "yes"
            Text: .clip_start, "left", 5300, "half", .token_label_no_underscores$

            selectObject: "TextGrid "+textgrid_name$
            plusObject: "Sound "+sound_name$
            Select outer viewport: 0, 6, 3.5, 5.5
            Draw: .clip_start, .clip_end, "yes", "yes", "yes"

            Select outer viewport: 0, 6, 0, 6
            Save as PDF file: clipPath$+"/"+.sound_filename$+".pdf"

            selectObject: "Spectrogram "+sound_name$+"_part"
            Remove
        endif
        ###################################################

        ###################################################
        selectObject: "TextGrid 'textgrid_name$'_part"
        Remove
        ###################################################

        select Sound 'sound_name$'_part
        if .filtering == 1
            plus Sound 'sound_name$'_part_band
        endif
        Remove
		fileappend 'outfile$' ,'.clip_start','.clip_end','.sound_filename$'
    endif

endproc


#######################################################################################
# PROCEDURE: mfcc(pad=0.1,filter_low=0,filter_high=22050,sanitize=1,coefficients=12,window=0.015,step=0.005,first_melfilter=100,between_melfilters=100,max_melfilter=0,wav=1)
# create mfcc matrices and save them as headerless spreadsheet files.
# sounds will only be filtered if filter_low or filter_high arguments are specified. 
# (0,22050 are defaults if only one is specified)
#
# EXAMPLE: 'mfcc()'
#######################################################################################

procedure mfcc (.argString$)

    @parseArgs (.argString$)
   
    .pad = 0.1
    .filter_low = 0
    .filter_high = 22050
    .filtering = 0
    .sanitize = 1
    .coefficients=12
    .window=0.015
    .step=0.005
    .first_melfilter=100
    .between_melfilters=100
    .max_melfilter=0
    .wav=1

    for i to parseArgs.n_args
        x$ = parseArgs.var$[i]
        if parseArgs.var$[i] == "pad"
            .pad = number(parseArgs.val$[i])
        elif parseArgs.var$[i] == "filter_low"
            .filter_low = number(parseArgs.val$[i])
            .filtering = 1
        elif parseArgs.var$[i] == "filter_high"
            .filter_high = number(parseArgs.val$[i])
            .filtering = 1
        elif parseArgs.var$[i] == "sanitize"
            .sanitize = number(parseArgs.val$[i])
        elif parseArgs.var$[i] == "coefficients"
            .coefficients = number(parseArgs.val$[i])
        elif parseArgs.var$[i] == "window"
            .window = number(parseArgs.val$[i])
        elif parseArgs.var$[i] == "step"
            .step = number(parseArgs.val$[i])
        elif parseArgs.var$[i] == "first_melfilter"
            .first_melfilter = number(parseArgs.val$[i])
        elif parseArgs.var$[i] == "between_melfilters"
            .between_melfilters = number(parseArgs.val$[i])
        elif parseArgs.var$[i] == "max_melfilter"
            .max_melfilter = number(parseArgs.val$[i])
        elif parseArgs.var$[i] == "wav"
            .wav = number(parseArgs.val$[i])
        elif parseArgs.var$[i] == "categories"
            # pass
        elif parseArgs.var$[i] == "trigrams"
            # pass
        elif parseArgs.var$[i] == "show_words"
            # pass
        elif parseArgs.var$[i] != ""
            if isHeader == 1
                .unknown_var$ = parseArgs.var$[i]
                printline skipped unknown argument '.unknown_var$'
            endif
        endif
    endfor

    if isHeader = 1 
        createDirectory: clipPath$
        #fileappend 'outfile$' ,clip_start,clip_end,clip_filename
        fileappend 'outfile$' ,clip_start,clip_end,stimulus
    elif isComplete == 1
        printline FINISHED  
    else
        select Sound 'sound_name$'
        .clip_start = round(1000*(transport.word_start - .pad))/1000
        .clip_end = round(1000*(transport.word_end + .pad))/1000
        Extract part... '.clip_start' '.clip_end' rectangular 1.0 yes
        if .filtering == 1
            Filter (pass Hann band): '.filter_low', '.filter_high', 100
        endif    
        timestring$ = replace$ ("'.clip_start'", ".", "_", 0)
        if .clip_start == round(.clip_start)
            printline 'timestring$'
            timestring$ = timestring$+"_0"
        endif

        .word_for_filename$ = transport.word$
        if .sanitize==1
            .word_for_filename$ = replace$ (.word_for_filename$, "{", "", 0)
            .word_for_filename$ = replace$ (.word_for_filename$, "}", "", 0)
            .word_for_filename$ = replace$ (.word_for_filename$, "<", "", 0)
            .word_for_filename$ = replace$ (.word_for_filename$, ">", "", 0)
            .word_for_filename$ = replace$ (.word_for_filename$, "[", "", 0)
            .word_for_filename$ = replace$ (.word_for_filename$, "]", "", 0)
            .word_for_filename$ = replace$ (.word_for_filename$, " ", "", 0)
        endif

        .sound_filename$ = "'sound_name$'_'timestring$'_'.word_for_filename$'"
        if .wav==1
            Write to WAV file... 'clipPath$'/'.sound_filename$'.wav
        endif 
        To MFCC: .coefficients, .window, .step, .first_melfilter, .between_melfilters, .max_melfilter
        To Matrix
        Save as headerless spreadsheet file: "'clipPath$'/'.sound_filename$'.txt"

        # THIS IS TO SAVE TEXTGRIDS TOO ###################
        selectObject: "TextGrid 'textgrid_name$'"
        Extract part: .clip_start, .clip_end, "no"
        Save as text file: "'clipPath$'/'.sound_filename$'.TextGrid"
        Remove
        ###################################################

        select Sound 'sound_name$'_part
        plus MFCC 'sound_name$'_part
        plus Matrix 'sound_name$'_part
        if .filtering == 1
            plus Sound 'sound_name$'_part_band
        endif
        Remove
        fileappend 'outfile$' ,'.clip_start','.clip_end','.sound_filename$'
    endif

endproc


#######################################################################################
# PROCEDURE: phone_clips(filter_low=0,filter_high=22050,sanitize=1)
# extract phone clips. 
# clips will only be filtered if filter_low or filter_high arguments are specified. 
# (0,22050 are defaults if only one is specified)
#
# EXAMPLE: 'phone_clips()'
#######################################################################################

procedure phone_clips (.argString$)

    @parseArgs (.argString$)
   
    .pad = 0.0
    .filter_low = 0
    .filter_high = 22050
    .filtering = 0
    .sanitize = 1

    for i to parseArgs.n_args
        x$ = parseArgs.var$[i]
        if parseArgs.var$[i] == "pad"
            .pad = number(parseArgs.val$[i])
        elif parseArgs.var$[i] == "filter_low"
            .filter_low = number(parseArgs.val$[i])
            .filtering = 1
        elif parseArgs.var$[i] == "filter_high"
            .filter_high = number(parseArgs.val$[i])
            .filtering = 1
        elif parseArgs.var$[i] == "sanitize"
            .sanitize = number(parseArgs.val$[i])
        elif parseArgs.var$[i] == "categories"
            # pass
        elif parseArgs.var$[i] == "trigrams"
            # pass
        elif parseArgs.var$[i] == "segments"
            # pass
        elif parseArgs.var$[i] == "show_words"
            # pass
        elif parseArgs.var$[i] != ""
            if isHeader == 1
                .unknown_var$ = parseArgs.var$[i]
                printline skipped unknown argument '.unknown_var$'
            endif
        endif
    endfor

    if isHeader = 1 
        createDirectory: clipPath$
        #fileappend 'outfile$' ,clip_start,clip_end,clip_filename
        fileappend 'outfile$' ,clip_start,clip_end,stimulus
    elif isComplete == 1
        printline FINISHED  
    else
        select Sound 'sound_name$'
        #.clip_start = round(1000*(transport.word_start - .pad))/1000
        #.clip_end = round(1000*(transport.word_end + .pad))/1000
        .clip_start = round(1000*(transport.phone_start - .pad))/1000
        .clip_end = round(1000*(transport.phone_end + .pad))/1000
        Extract part... '.clip_start' '.clip_end' rectangular 1.0 yes
        if .filtering == 1
            Filter (pass Hann band): '.filter_low', '.filter_high', 100
        endif    
        timestring$ = replace$ ("'.clip_start'", ".", "_", 0)
        if .clip_start == round(.clip_start)
            printline 'timestring$'
            timestring$ = timestring$+"_0"
        endif

        .word_for_filename$ = transport.word$
        if .sanitize==1
            .word_for_filename$ = replace$ (.word_for_filename$, "{", "", 0)
            .word_for_filename$ = replace$ (.word_for_filename$, "}", "", 0)
            .word_for_filename$ = replace$ (.word_for_filename$, "<", "", 0)
            .word_for_filename$ = replace$ (.word_for_filename$, ">", "", 0)
            .word_for_filename$ = replace$ (.word_for_filename$, "[", "", 0)
            .word_for_filename$ = replace$ (.word_for_filename$, "]", "", 0)
            .word_for_filename$ = replace$ (.word_for_filename$, " ", "", 0)
        endif

        .sound_filename$ = "'sound_name$'_'timestring$'_'.word_for_filename$'"
        Write to WAV file... 'clipPath$'/'.sound_filename$'.wav

        # THIS IS TO SAVE TEXTGRIDS TOO ###################
        selectObject: "TextGrid 'textgrid_name$'"
        Extract part: .clip_start, .clip_end, "no"
        Save as text file: "'clipPath$'/'.sound_filename$'.TextGrid"
        Remove
        ###################################################

        select Sound 'sound_name$'_part
        if .filtering == 1
            plus Sound 'sound_name$'_part_band
        endif
        Remove
        fileappend 'outfile$' ,'.clip_start','.clip_end','.sound_filename$'
    endif

endproc

#######################################################################################
# PROCEDURE: trigrams(sanitize=1)
# extract three-word clips
#
# EXAMPLE: 'trigrams()'
#######################################################################################

procedure trigrams (.argString$)

    @parseArgs (.argString$)
    .sanitize = 1

    for i to parseArgs.n_args
        if parseArgs.var$[i] == "sanitize"
            .sanitize = number(parseArgs.val$[i])
        elif parseArgs.var$[i] == "categories"
            # pass
        elif parseArgs.var$[i] == "trigrams"
            # pass
        elif parseArgs.var$[i] == "show_words"
            # pass
        elif parseArgs.var$[i] != ""
            if isHeader == 1
                .unknown_var$ = parseArgs.var$[i]
                printline skipped unknown argument '.unknown_var$'
            endif
        endif
    endfor

    if isHeader = 1 
        createDirectory: clipPath$
		#fileappend 'outfile$' ,clip_start,clip_end,trigram_filename
        fileappend 'outfile$' ,clip_start,clip_end,stimulus
    elif isComplete == 1
        printline FINISHED 
    else

        if transport.lastword_start == undefined
            .trigram_start = transport.word_start
            .trigram_word1$ = ""
        elif (transport.lastword$ == "" or transport.lastword$ == "{SL}" or transport.lastword$ == "sp") and transport.word_start - transport.lastword_start > 1
            .trigram_start = transport.word_start - 1
            .trigram_word1$ = "{SL}"
        else
            .trigram_start = transport.lastword_start
            .trigram_word1$ = transport.lastword$
        endif

        if transport.nextword_end == undefined
            .trigram_end = transport.word_end
            .trigram_word3$ = ""
        elif (transport.nextword$ == "" or transport.nextword$ == "{SL}" or transport.nextword$ == "sp") and transport.nextword_end - transport.word_end > 1
            .trigram_end = transport.word_end + 1
            .trigram_word3$ = "{SL}"
        else
            .trigram_end = transport.nextword_end
            .trigram_word3$ = transport.nextword$
        endif

        .trigram_word2$ = transport.word$

        .trigram_start = round(1000*.trigram_start)/1000
        .trigram_end = round(1000*.trigram_end)/1000

        select Sound 'sound_name$'
        Extract part... '.trigram_start' '.trigram_end' rectangular 1.0 yes
        timestring$ = replace$ ("'.trigram_start'", ".", "_", 0)
        if .trigram_start == round(.trigram_start)
            printline 'timestring$'
            timestring$ = timestring$+"_0"
        endif

        .word_for_filename$ = "'.trigram_word1$'_'.trigram_word2$'_'.trigram_word3$'"
        if .sanitize==1
            .word_for_filename$ = replace$ (.word_for_filename$, "{", "", 0)
            .word_for_filename$ = replace$ (.word_for_filename$, "}", "", 0)
            .word_for_filename$ = replace$ (.word_for_filename$, "<", "", 0)
            .word_for_filename$ = replace$ (.word_for_filename$, ">", "", 0)
            .word_for_filename$ = replace$ (.word_for_filename$, "[", "", 0)
            .word_for_filename$ = replace$ (.word_for_filename$, "]", "", 0)
            .word_for_filename$ = replace$ (.word_for_filename$, " ", "", 0)
        endif

        .sound_filename$ = "'sound_name$'_'timestring$'_'.word_for_filename$'"
        #.sound_filename$ = "'sound_name$'_'timestring$'_'.trigram_word1$'_'.trigram_word2$'_'.trigram_word3$'"
        Write to WAV file... 'clipPath$'/'.sound_filename$'.wav

        # THIS IS TO SAVE TEXTGRIDS TOO ###################
        selectObject: "TextGrid 'textgrid_name$'"
        Extract part: .trigram_start, .trigram_end, "no"
        Save as text file: "'clipPath$'/'.sound_filename$'.TextGrid"
        Remove
        ###################################################
        
        select Sound 'sound_name$'_part
        Remove
		fileappend 'outfile$' ,'.trigram_start','.trigram_end','.sound_filename$'
    endif

endproc

#######################################################################################
# makeMFCscript() is a utility script for mfc()
#######################################################################################

procedure makeMFCscript (.labeling_categories$, .show_words$)

    #name_of_log_file$ = outfile$ - ".csv" + "_MFC.praat" 
    repetitions = 1
    #show_words = 1

    string_to_parse$ = .labeling_categories$
    @parseString
    for i to n_strings
        cat'i'$ = split_string'i'$
        cat'i'$ = replace$(cat'i'$, "_", " ", 0)
    endfor
    cats_n = n_strings
    buttons_n = cats_n + 1
    button_width = (button_right_margin - button_left_margin - 0.01*(cats_n-1)) / cats_n
    script$ = outfile$ - ".csv" + "_MFC.praat" 

    @split ("/", clipPath$)
    clipPathRelative$ = split.array$[split.length]

    filedelete 'script$'
    fileappend 'script$' "ooTextFile"'newline$'
    fileappend 'script$' "ExperimentMFC 5"'newline$'
    fileappend 'script$' stimuliAreSounds? <yes>'newline$'
    fileappend 'script$' stimulusFileNameHead = "'clipPathRelative$'/"'newline$'
    fileappend 'script$' stimulusFileNameTail = ".wav"'newline$'
    fileappend 'script$' stimulusCarrierBefore = ""'newline$'
    fileappend 'script$' stimulusCarrierAfter = ""'newline$'
    fileappend 'script$' stimulusInitialSilenceDuration = 0.25 seconds'newline$'
    fileappend 'script$' stimulusMedialSilenceDuration = 0'newline$'
    fileappend 'script$' numberOfDifferentStimuli = 'stim_n''newline$'
    if .show_words$ == "T" or .show_words$ == "True" or .show_words$ == "TRUE" or .show_words$ == "true"
        fileappend 'script$' 'stim_string_with_words$'
    else
        fileappend 'script$' 'stim_string_no_words$'
    endif
    fileappend 'script$' numberOfReplicationsPerStimulus = 'repetitions''newline$'
    fileappend 'script$' breakAfterEvery = 0'newline$'
    fileappend 'script$' randomize = <PermuteBalancedNoDoublets>'newline$''newline$'
    fileappend 'script$' startText = "Please code the following sound clips"'newline$''newline$'
    fileappend 'script$' runText = "Which category?"'newline$''newline$'
    fileappend 'script$' pauseText = "Please take a break. Click to proceed."'newline$''newline$'
    fileappend 'script$' endText = "Done.  You can close this window now and go click to save the results."'newline$''newline$'
    fileappend 'script$' maximumNumberOfReplays = 1000'newline$''newline$'
    fileappend 'script$' replayButton = 'button_left_margin' 'button_right_margin' 0.27 0.42 "Replay" ""'newline$'
    fileappend 'script$' okButton     = 0.00 0.00 0.00 0.00 "" ""'newline$'
    fileappend 'script$' oopsButton   = 'button_left_margin' 'button_right_margin' 0.11 0.26 "Go back" ""'newline$'
    fileappend 'script$' responsesAreSounds? <no> "" "" "" "" 0 0'newline$'
    fileappend 'script$' numberOfDifferentResponses = 'buttons_n''newline$'
    for n to cats_n
        button_left = round(1000*(button_left_margin + (n-1)*(button_width+0.01)))/1000
        button_right = round(1000*(button_left + button_width))/1000
        catn$ = cat'n'$
        fileappend 'script$'     'button_left' 'button_right' 0.60 0.85 "'catn$'" 40 "" "'catn$'"'newline$'
    endfor
    fileappend 'script$'     'button_left_margin' 'button_right_margin' 0.44 0.59 "N/A (wrong sound or other problem)" 40 "" "NA"'newline$'
    fileappend 'script$' numberOfGoodnessCategories = 0'newline$'

    printline ###############################################
    printline MFC script 'script$' has been created.
    printline Please open the script as an object in Praat, run it, and then follow the instructions to extract and save results
    printline ###############################################
endproc

#######################################################################################
# PROCEDURE: mfc(categories="A B",trigrams=False,segments=False,scale=1)
# Extract word clips and make a script for a multiple forced-choice experiment.
# 
# The mfc procedure will default to categories A and B.
# 
# To use different labeling categories, include the argument "categories",
# with the categories separated by front slashes or spaces and spaces within labels replaced by underscores,
# like this:
#
# praat one_script_8.praat arizona_r.csv 'T/R/' 'mfc(categories="affricated/not_affricated")'
#
# EXAMPLE: 'mfc(categories=vocalized/ambiguous/non-vocalized/NA)'
#######################################################################################

procedure mfc (.argString$)

    @parseArgs (.argString$)
    
    .labeling_categories$ = "A B"
    .extract_trigrams$ = "False"
    .extract_segments$ = "False"
    .show_words$ = "True"
    .scale_peak = 1
    .pad = 0.1
    .rate = 44100

    for i to parseArgs.n_args
        x$ = parseArgs.var$[i]
		if parseArgs.var$[i] == "categories"
            .labeling_categories$ = parseArgs.val$[i]
        	.labeling_categories$ = replace$(.labeling_categories$, "/", " ", 0)
        	.labeling_categories$ = replace$(.labeling_categories$, """", "", 0)
    	elif parseArgs.var$[i] == "trigrams"
            .extract_trigrams$ = parseArgs.val$[i]
	    	.extract_trigrams$ = replace$(.extract_trigrams$, """", "", 0)
	    	.extract_trigrams$ = replace$(.extract_trigrams$, "''", "", 0)
        elif parseArgs.var$[i] == "segments"
            .extract_segments$ = parseArgs.val$[i]
            .extract_segments$ = replace$(.extract_segments$, """", "", 0)
            .extract_segments$ = replace$(.extract_segments$, "''", "", 0)
        elif parseArgs.var$[i] == "show_words"
            .show_words$ = parseArgs.val$[i]
            .show_words$ = replace$(.show_words$, """", "", 0)
            .show_words$ = replace$(.show_words$, "''", "", 0)
        elif parseArgs.var$[i] == "scale"
            .scale_peak = number(parseArgs.val$[i])
        elif parseArgs.var$[i] == "pad"
            .pad = number(parseArgs.val$[i])
        elif parseArgs.var$[i] == "rate"
            .rate = number(parseArgs.val$[i])
        elif parseArgs.var$[i] != ""
            if isHeader == 1
                .unknown_var$ = parseArgs.var$[i]
                printline skipped unknown argument '.unknown_var$'
            endif
        endif
    endfor

    if isHeader == 1 
        createDirectory: clipPath$       
        if .extract_trigrams$ == "T" or .extract_trigrams$ == "True" or .extract_trigrams$ == "TRUE" or .extract_trigrams$ == "true"
	    	@trigrams ("dummy")
        elif .extract_segments$ == "T" or .extract_segments$ == "True" or .extract_segments$ == "TRUE" or .extract_segments$ == "true"
            @phone_clips ("dummy")
        else
	    	@clips ("dummy")
		endif
    elif isComplete == 1
        if stim_string_no_words$ == ""
            printline No matches, so no MFC script will be created.
        else
            @makeMFCscript (.labeling_categories$, .show_words$)
        endif
    else
        if .extract_trigrams$ == "T" or .extract_trigrams$ == "True" or .extract_trigrams$ == "TRUE" or .extract_trigrams$ == "true"
            @trigrams ("dummy")
            sound_filename$ = trigrams.sound_filename$
            word_for_mfc$ = trigrams.trigram_word1$+" "+trigrams.trigram_word2$+" "+trigrams.trigram_word3$
        elif .extract_segments$ == "T" or .extract_segments$ == "True" or .extract_segments$ == "TRUE" or .extract_segments$ == "true"
            @phone_clips ("dummy")
            sound_filename$ = phone_clips.sound_filename$
            word_for_mfc$ = transport.word$
        else
            if .scale_peak == 1
                @clips ("scale=1,pad='.pad'",rate='.rate'")
            else
                @clips ("pad='.pad'",rate='.rate'")
            endif
            sound_filename$ = clips.sound_filename$
            word_for_mfc$ = transport.word$
        endif

        stim_string_no_words$ = stim_string_no_words$+"    """+sound_filename$+""" """""+newline$
        stim_string_with_words$ = stim_string_with_words$+"    """+sound_filename$+""" """+word_for_mfc$+""""+newline$
        stim_n = stim_n + 1
    endif

endproc

#######################################################################################
# PROCEDURE: frames(framepath=FRAMES)
# extract video frames using avconv
# framepath argument indicates the path of the directory containing frames.
#
# EXAMPLE: 'frames(framepath=directorywheremyvideosare)'
#######################################################################################

procedure frames (.argString$)

    @parseArgs (.argString$)

    #.video_name$ = "VIDNAME"
    .framepath$ = "FRAMES"

    avconvfile$ = writePath$+"one_script_frames"+"_"+datestamp$

    for i to parseArgs.n_args
        #if parseArgs.var$[i] == "video"
        #    .video_name$ = parseArgs.val$[i]
        if parseArgs.var$[i] == "framepath"
            .framepath$ = parseArgs.val$[i]
        elif parseArgs.var$[i] != ""
            if isHeader == 1
                .unknown_var$ = parseArgs.var$[i]
                printline skipped unknown argument '.unknown_var$'
            endif
        endif
    endfor

    if isHeader = 1 
        printline frames('.argString$')
        fileappend 'outfile$' ,duration,framename
        fileappend 'avconvfile$' #!/bin/bash'newline$'
    elif isComplete == 1
        printline FINISHED  
        system chmod +x  'avconvfile$'
        printline 'newline$'TO EXTRACT FRAMES:'newline$''avconvfile$''newline$'
    else
        .duration = transport.phone_end - transport.phone_start
        .texttime$ = "'transport.phone_start:3'"
        .texttime$ = replace$ (.texttime$, ".", "_", 0)
        .framename$ = textgrid_name$+"_"+.texttime$+"_%04d.png"
        fileappend 'outfile$' ,'.duration:3','.framename$'
        fileappend 'avconvfile$' avconv -i 'video_file$' -vf yadif -r 30 -ss 'transport.phone_start:3' -t '.duration:3' -f image2 '.framepath$'/'.framename$''newline$'
    endif

endproc

#######################################################################################
#                                                                                     #
#                 PROCEDURES THAT INVOLVE TEXTGRIDS BUT NOT SOUNDS                    #
#                                                                                     #
#######################################################################################

#######################################################################################
# PROCEDURE: duration(lastphone=no,nextphone=no)
# simply measure segment duration.
# duration of all preceding and/or following phones can be included by setting lastphone or nextphone to "yes"
#
# EXAMPLE: 'duration()'
#######################################################################################

procedure duration (.argString$)

    .lastphone$ = "no"
    .nextphone$ = "no"

    @parseArgs (.argString$)
    
    for i to parseArgs.n_args
        if parseArgs.var$[i] == "lastphone"
            .lastphone$ = parseArgs.val$[i]
        elif parseArgs.var$[i] == "nextphone"
            .nextphone$ = parseArgs.val$[i]
        elif parseArgs.var$[i] != ""
            if isHeader == 1
                .unknown_var$ = parseArgs.var$[i]
                printline skipped unknown argument '.unknown_var$'
            endif
        endif
    endfor

    if isHeader = 1 
        printline duration('.argString$')
        fileappend 'outfile$' ,duration
    elif isComplete == 1
        printline FINISHED  
    else
        if .lastphone$ == "yes" or .lastphone$ == "true"
            .first_measure = transport.lastphone_start
        else
            .first_measure = transport.phone_start
        endif

        if .nextphone$ == "yes" or .nextphone$ == "true"
            .last_measure = transport.nextphone_end
        else
            .last_measure = transport.phone_end
        endif
        .duration = .last_measure - .first_measure
        fileappend 'outfile$' ,'.duration:3'
    endif

endproc

#######################################################################################
# PROCEDURE: word_duration()
# simply measure duration of word and preceding and following words
#
# EXAMPLE: 'word_duration()'
#######################################################################################

procedure word_duration (.argString$)

    @parseArgs (.argString$)
    
    for i to parseArgs.n_args
        if parseArgs.var$[i] != ""
            if isHeader == 1
                .unknown_var$ = parseArgs.var$[i]
                printline skipped unknown argument '.unknown_var$'
            endif
        endif
    endfor

    if isHeader = 1 
        printline duration('.argString$')
        fileappend 'outfile$' ,leftword_duration,word_duration,rightword_duration
    elif isComplete == 1
        printline FINISHED  
    else
        .leftword_duration = transport.word_start - transport.lastword_start
        .word_duration = transport.word_end - transport.word_start
        .rightword_duration = transport.nextword_end - transport.word_end
        fileappend 'outfile$' ,'.leftword_duration:3','.word_duration:3','.rightword_duration:3'
    endif

endproc


#######################################################################################
# PROCEDURE: check_words()
# check word segmentation by showing the phones overlapping the word and checking boundary alignment
#
# EXAMPLE: 'check_words()'
#######################################################################################

procedure check_words (.argString$)

    @parseArgs (.argString$)
    
    for i to parseArgs.n_args
        if parseArgs.var$[i] != ""
            if isHeader == 1
                .unknown_var$ = parseArgs.var$[i]
                printline skipped unknown argument '.unknown_var$'
            endif
        endif
    endfor

    if isHeader = 1 
        printline duration('.argString$')
        fileappend 'outfile$' ,start_match,end_match,all_phones
    elif isComplete == 1
        printline FINISHED  
    else
        .first_interval = Get interval at time: phone_tier, transport.word_start+0.001
        .last_interval = Get interval at time: phone_tier, transport.word_end-0.001

        .first_interval_start = Get start time of interval: phone_tier, .first_interval
        .last_interval_end = Get end time of interval: phone_tier, .last_interval

        .start_match = .first_interval_start == transport.word_start
        .end_match = .last_interval_end == transport.word_end

        .all_phones$ = ""

        for .i from .first_interval to .last_interval
            .phone$ = Get label of interval: phone_tier, .i
            if .all_phones$ == ""
                .all_phones$ = .all_phones$ + .phone$
            else
                .all_phones$ = .all_phones$ + "," + .phone$
            endif
        endfor

        .all_phones$ = """" + .all_phones$ + """"

        fileappend 'outfile$' ,'.start_match','.end_match','.all_phones$'
    endif

endproc




#######################################################################################
# PROCEDURE: context()
# output the target words in the context of a particular number of preceding and following words 
#
# EXAMPLE to extract a total of 11 words: 'context(words=5)' 
#######################################################################################

procedure context (.argString$)

    .words = 10 
    .gap_threshold = 1

    @parseArgs (.argString$)
    
    for i to parseArgs.n_args
        if parseArgs.var$[i] == "words"
            .words = number(parseArgs.val$[i])
        elif parseArgs.var$[i] != ""
            if isHeader == 1
                .unknown_var$ = parseArgs.var$[i]
                printline skipped unknown argument '.unknown_var$'
            endif
        endif
    endfor

    if isHeader = 1 
        printline context('.argString$')
        fileappend 'outfile$' ,context
    elif isComplete == 1
        printline FINISHED  
    else
        select TextGrid 'textgrid_name$'
        .final_w_interval = Get number of intervals... word_tier
        .left_context$ = ""
        .right_context$ = ""

        .last_left_start = transport.word_start
        .last_right_end = transport.word_end

        for .i from 1 to .words
            # LEFT
            .ww = w - .i
            if .ww >= 1
                .word$ = Get label of interval... word_tier .ww
                .word_start = Get start time of interval... word_tier .ww
                .word_end = Get end time of interval... word_tier .ww
                .word_gap = .last_left_start - .word_end

                if .word_gap < .gap_threshold
                    if .word$ != ""
                        # .left_context$ =  .word$ + " " + "'.word_gap'" + " " + .left_context$
                        .left_context$ =  .word$ + " " + .left_context$
                        .last_left_start = .word_start
                    endif
                # else
                #     if .word$ != ""
                #         .left_context$ =  "["+.word$+"]" + " " + "'.word_gap'" + " " + .left_context$
                #     endif
                endif
            endif

            # RIGHT
            .ww = w + .i
            if .ww <= .final_w_interval
                # printline '.ww' '.final_w_interval'
                .word$ = Get label of interval... word_tier .ww
                .word_start = Get start time of interval... word_tier .ww
                .word_end = Get end time of interval... word_tier .ww
                .word_gap = .word_start - .last_right_end

                if .word_gap < .gap_threshold
                    if .word$ != ""
                        # .right_context$ = .right_context$ + " " + "'.word_gap'" + " " + .word$
                        .right_context$ = .right_context$ + " " + .word$
                        .last_right_end = .word_end
                    endif
                # else
                #     if .word$ != ""
                #         .right_context$ = .right_context$ + " " + "'.word_gap'" + " " + "["+.word$+"]"
                #     endif
                endif
            endif
        endfor
        .context$ = .left_context$ + transport.word$ + .right_context$
        #printline '.context$'

        fileappend 'outfile$' ,'.context$'
    endif

endproc

#######################################################################################
# PROCEDURE: tier3()
# resegment selected intervals by adding a third tier to a 2-tier phone/word textgrid (only to be used interactively)
#
# EXAMPLE: [should only be used interactively in the Praat GUI]
#######################################################################################

procedure tier3 (.argString$)

    if isHeader = 1 
        printline tier3('.argString$')
    elif isComplete == 1
        printline FINISHED  
    else

        if interactive_session == 1
            select TextGrid 'textgrid_name$'
            editor TextGrid 'textgrid_name$'
                beginPause("Select the interval you want to label on tier 3")
                boolean ("skip this token", 0)
                .okay = endPause ("Okay", 1)       
                .start = Get start of selection
                .end = Get end of selection
            endeditor

            if skip_this_token==0 and .start < .end
                .mid = (.start+.end)/2
                .phoneinterval = Get interval at time... phone_tier .mid
                .phonelabel$ = Get label of interval... phone_tier .phoneinterval

                Insert boundary... 3 '.start'
                Insert boundary... 3 '.end'
                .new_interval = Get interval at time... 3 '.mid'
                Set interval text... 3 '.new_interval' '.phonelabel$'
            endif
        endif
    endif

endproc

#######################################################################################
# PROCEDURE: annotation_tier()
# include an annotation from a tier specified by name
#
# EXAMPLE: 'annotation_tier(tier_name=phrase)' [record the label of an interval in a phrase tier]
#######################################################################################

procedure annotation_tier (.argString$)

    @parseArgs (.argString$)
    
    for .i to parseArgs.n_args
        if parseArgs.var$[.i] == "tier_name"
            .tier_name$ = parseArgs.val$[.i]
        elif parseArgs.var$[.i] != ""
            if isHeader == 1
                .unknown_var$ = parseArgs.var$[.i]
                printline skipped unknown argument '.unknown_var$'
            endif
        endif
    endfor

    if isHeader = 1 
        printline annotation_tier('.argString$')
        fileappend 'outfile$' ,'.tier_name$'
    elif isComplete == 1
        printline FINISHED  
    else
        select TextGrid 'textgrid_name$'
        .phone_mid = transport.phone_start + (transport.duration / 2)
        .tier_number = -1
        .tiers = Get number of tiers
        for .i from 1 to .tiers
            .i_name$ = Get tier name: .i
            if .i_name$ == .tier_name$
                .tier_number = .i
            endif
        endfor

        if .tier_number == -1
            printline did not find a tier named '.tier_name$'
            .annotation$ = undefined
        else 
            .annotation_interval = Get interval at time: .tier_number, .phone_mid
            .annotation$ = Get label of interval... .tier_number .annotation_interval
            printline '.annotation$'
        endif

        fileappend 'outfile$' ,'.annotation$'
    endif

endproc

#######################################################################################
# PROCEDURE: erik_vot()
# measure a VOT that Erik has segmented in a point tier
#
# EXAMPLE: 'erik_vot(tier=4)' [to measure between points in tier 3]
#######################################################################################

procedure erik_vot (.argString$)

    .tier = 0

    @parseArgs (.argString$)
    
    for .i to parseArgs.n_args
        if parseArgs.var$[.i] == "tier"
            .tier = number(parseArgs.val$[.i])
        elif parseArgs.var$[.i] != ""
            if isHeader == 1
                .unknown_var$ = parseArgs.var$[.i]
                printline skipped unknown argument '.unknown_var$'
            endif
        endif
    endfor

    if isHeader = 1 
        printline erik_vot('.argString$')
        fileappend 'outfile$' ,VOT,VOT_label1,VOT_label2
    elif isComplete == 1
        printline FINISHED  
    else
        .first_point = Get high index from time: .tier, transport.phone_start
        .first_point_time = Get time of point: .tier, .first_point
        .first_point_label$ = Get label of point: .tier, .first_point
        .second_point_time = Get time of point: .tier, .first_point+1
        .second_point_label$ = Get label of point: .tier, .first_point+1
        .vot = .second_point_time - .first_point_time
        fileappend 'outfile$' ,'.vot:3','.first_point_label$','.second_point_label$'
    endif

endproc

#######################################################################################
# PROCEDURE: erik_cpps()
# measure a VOT that Erik has segmented in a point tier
#
# EXAMPLE: 'erik_cpps(tier=5)' [to measure CPPS in an interval between points in tier 5]
#######################################################################################

procedure erik_cpps (.argString$)

    .tier = 0

    @parseArgs (.argString$)
    
    for .i to parseArgs.n_args
        if parseArgs.var$[.i] == "tier"
            .tier = number(parseArgs.val$[.i])
        elif parseArgs.var$[.i] != ""
            if isHeader == 1
                .unknown_var$ = parseArgs.var$[.i]
                printline skipped unknown argument '.unknown_var$'
            endif
        endif
    endfor

    if isHeader = 1 
        printline erik_vot('.argString$')
        fileappend 'outfile$' ,CPPS,CPPS_label1,CPPS_label2
    elif isComplete == 1
        printline FINISHED  
    else
        .first_point = Get high index from time: .tier, transport.phone_start
        .first_point_time = Get time of point: .tier, .first_point
        .first_point_label$ = Get label of point: .tier, .first_point
        .second_point_time = Get time of point: .tier, .first_point+1
        .second_point_label$ = Get label of point: .tier, .first_point+1
        selectObject: "Sound 'sound_name$'"
        Extract part: .first_point_time, .second_point_time, "rectangular", 1.0, "yes"
        To PowerCepstrogram: 60, 0.002, 5000, 50
        #.cpps = Get CPPS: "yes", 0.02, 0.00005, 60, 330, 0.05, "parabolic", 0.001, 0, "Exponential decay", "Robust"
        .cpps = Get CPPS: "yes", 0.02, 0.0005, 60, 330, 0.05, "parabolic", 0.001, 0.05, "Exponential decay", "Robust slow"
        plusObject: "Sound 'sound_name$'_part"
        Remove
      
        fileappend 'outfile$' ,'.cpps:3','.first_point_label$','.second_point_label$'
    endif

endproc

#######################################################################################
# PROCEDURE: pvi()
# make duration measurements and calculate Pairwise Variability Index
#
# possible improvements:
# - try to find syllabic nasals other than AXN
# 
# keep in mind
#  - (someday consider whether the whole foot needs to be excluded)
#  - prolongation -> IP or ip: use length as a cue to intonational phrase breaks (word, maybe phone)
#  - glottalization -> intonational phrase boundary
#  - intermediate phrases (often just drop/rise in pitch that isn't otherwise accounted for)
#
# EXAMPLE: 'pvi()'
# EXAMPLE: 'pvi(pauses="um uh")'
#######################################################################################

procedure pvi (.argString$)

    .pauses$ = ""
    .include_prepausal$ = "0"

    @parseArgs (.argString$)
    
    for .i to parseArgs.n_args
        if parseArgs.var$[.i] == "pauses"
            .pauses$ = parseArgs.val$[.i]
            .pauses$ = replace$(.pauses$, " ", ",", 0)
            .pauses$ = replace$(.pauses$, """", "", 0)
            .pauses$ = ","+.pauses$+","
        elif parseArgs.var$[.i] == "include_prepausal"
            .include_prepausal$ = parseArgs.val$[.i]
            .include_prepausal$ = replace$(.include_prepausal$, " ", ",", 0)
        elif parseArgs.var$[.i] != ""
            if isHeader == 1
                .unknown_var$ = parseArgs.var$[.i]
                printline skipped unknown argument '.unknown_var$'
            endif
        endif
    endfor

    .info_message$ = "Be advised that the pvi() procedure now includes prepausal feet by default. You can filter them out later using the prepausal and break_duration columns of the output, or you can exclude them with pvi(include_prepausal=0)"

    .pvi_breaks$ = breaks$ + .pauses$

    if isHeader = 1 
        fileappend 'outfile$' ,nucleus,vowel_duration,nucleus_duration,last_nucleus_duration,pvi,word_duration,n_phones,syllables,feet,stress,last_stress,stress_pattern,final,prepausal,break_duration

        phonefield$ = "COR"
        call handleWildcards
        .coronals$ = phonefield$
        .last_nucleus_duration = undefined
        .last_stress$ = "--undefined--"
        printline '.info_message$'
        
    elif isComplete == 1
        printline FINISHED
        printline '.info_message$'
    else

        .vowel_duration = transport.phone_end - transport.phone_start
        .nucleus_duration = .vowel_duration

        .nucleus$ = transport.phone$

        #IS THERE A POSTVOCALIC LIQUID, OR IS THIS A CORONAL + SCHWA + N SEQUENCE?
        if transport.nextphone$ == "L" or transport.nextphone$ == "R" or (transport.phone$ == "AH0" and transport.nextphone$ == "N" and index(.coronals$, transport.lastphone$+" ") > 0)
            #IS THE NEXT PHONE WORD-FINAL?
            if transport.nextphone_end == transport.word_end
                .nucleus_duration = .nucleus_duration + transport.nextphone_end - transport.phone_end
                .nucleus$ = .nucleus$+" "+transport.nextphone$
            #IS THE NEXT PHONE NON-PREVOCALIC
            elif index (transport.nextphone1$, "0") + index (transport.nextphone1$, "1") + index (transport.nextphone1$, "2") == 0
                .nucleus_duration = .nucleus_duration + transport.nextphone_end - transport.phone_end
                .nucleus$ = .nucleus$+" "+transport.nextphone$
            endif
        endif

        .stress$ = right$(transport.phone$, 1)

        .word_duration = transport.word_end - transport.word_start 

        .startphone = Get interval at time... phone_tier transport.word_start+0.001
        .endphone = Get interval at time... phone_tier transport.word_end-0.001

        .vs_before$ = ""
        .vs_after$ = ""                
        for .wp from .startphone to .endphone
            .wp$ = Get label of interval... phone_tier .wp

            if index ("012", right$(.wp$, 1)) > 0
                if .wp < p
                    .vs_before$ = .vs_before$ + right$(.wp$, 1)
                elif .wp > p
                    .vs_after$ = .vs_after$ + right$(.wp$, 1)
                endif
            endif
        endfor

        .n_phones = .endphone - .startphone + 1
        if .vs_after$ == ""
            .final = 1
        else
            .final = 0
        endif

        .stress_pattern$ = .vs_before$+.stress$+.vs_after$

        .n_syllables = length (.stress_pattern$)

        .n_feet = length (replace$(.stress_pattern$, "0", "", 0))
        #printline '.pvi_breaks$'
        if index(.pvi_breaks$, ","+transport.nextword$+",") > 0 and (index (.vs_after$, "1") + index (.vs_after$, "2") == 0)
            #printline found break: 'transport.nextword$'
            .prepausal = 1
            .break_duration = transport.nextword_end - transport.word_end
        else
            .prepausal = 0
            .break_duration = 0
        endif

        if .prepausal == 0 and .last_nucleus_duration != undefined
            .pvi = abs(.nucleus_duration - .last_nucleus_duration) / ((.nucleus_duration + .last_nucleus_duration)/2)
        elif .prepausal == 1 and .last_nucleus_duration != undefined and (.include_prepausal$ == "1" or .include_prepausal$ == "yes")
            .pvi = abs(.nucleus_duration - .last_nucleus_duration) / ((.nucleus_duration + .last_nucleus_duration)/2)
        else
            .pvi = undefined
        endif

        fileappend 'outfile$' ,'.nucleus$','.vowel_duration:3','.nucleus_duration:3','.last_nucleus_duration:3','.pvi:3','.word_duration:3','.n_phones','.n_syllables','.n_feet','.stress$','.last_stress$','.stress_pattern$','.final','.prepausal','.break_duration'

        if .prepausal == 1
            .last_nucleus_duration = undefined
            .last_stress$ = "--undefined--"
        else
            .last_nucleus_duration = .nucleus_duration
            .last_stress$ = .stress$
        endif

    endif

endproc

#######################################################################################
# PROCEDURE: syllables()
# Outputs information on syllable stress and segment type (Onset, Coda, Vowel)
# Requires a textgrid that has been syllabified using syllable_parse.praat or equivalent.
#
# EXAMPLE: 'syllables()'
#######################################################################################

procedure syllables (.argString$)

    #@parseArgs (.argString$)

    if isHeader == 1
        .check_names = 0
        .syll_tier = 'word_tier' + 1
        .seg_tier = 'word_tier' + 2
        fileappend 'outfile$' ,prev_syllable,current_syllable,foll_syllable,prev_seg_type1,prev_seg_type,seg_type,foll_seg_type,foll_seg_type1
        
    elif isComplete == 1
        printline FINISHED
    else

        select TextGrid 'textgrid_name$'
        .syll_tier_name$ = Get tier name: .syll_tier
        .seg_tier_name$ = Get tier name: .seg_tier

        if .syll_tier_name$ == "syllables" & .seg_tier_name$ == "segmentType"
            select TextGrid 'textgrid_name$'
            
            .phone_mid = transport.phone_start + (transport.duration / 2)
            .max_syll_int = Get number of intervals: .syll_tier
            .max_seg_int = Get number of intervals: .seg_tier
            
            ## GATHER INFORMATION ABOUT SYLLABLES
            .current_syll_int = Get interval at time: .syll_tier, .phone_mid
            .current_syllable$ = Get label of interval: .syll_tier, .current_syll_int
            
            # PREVIOUS SYLLABLE
            if .current_syll_int > 1
                .prev_syllable$ = Get label of interval: .syll_tier, .current_syll_int - 1
                if .prev_syllable$ == ""
                    .prev_syllable$ = "--undefined--"
                endif
            else
                .prev_syllable$ = "--undefined--"
            endif
            
            # FOLLOWING SYLLABLE
            if .current_syll_int < .max_syll_int
                .foll_syllable$ = Get label of interval: .syll_tier, .current_syll_int + 1
                if .foll_syllable$ == ""
                    .foll_syllable$ = "--undefined--"
                endif
            else
                .foll_syllable$ == "--undefined--"
            endif
            
            
            ## GATHER SEGMENT TYPE INFORMATION
            .current_seg_int = Get interval at time: .seg_tier, .phone_mid

            # PREVIOUS SEGMENT1
            if .current_seg_int > 2
                .segmentType_prev1$ = Get label of interval: .seg_tier, .current_seg_int-2
                if .segmentType_prev1$ == ""
                    .segmentType_prev1$ = "--undefined--"
                endif
            else
                .segmentType_prev1$ = "--undefined--"
            endif


            # PREVIOUS SEGMENT
            if .current_seg_int > 1
                .segmentType_prev$ = Get label of interval: .seg_tier, .current_seg_int-1
                if .segmentType_prev$ == ""
                    .segmentType_prev$ = "--undefined--"
                endif
            else
                .segmentType_prev$ = "--undefined--"
            endif
            
            
            # CURRENT SEGMENT
            .segmentType$ = Get label of interval: .seg_tier, .current_seg_int
            
            # FOLLOWING SEGMENT
            if .current_seg_int < .max_seg_int
                .segmentType_foll$ = Get label of interval: .seg_tier, .current_seg_int+1
                if .segmentType_foll$ == ""
                    .segmentType_foll$ = "--undefined--"
                endif
            else
                .segmentType_foll$ = "--undefined--"
            endif
            
            # FOLLOWING SEGMENT1
            if .current_seg_int < .max_seg_int - 1
                .segmentType_foll1$ = Get label of interval: .seg_tier, .current_seg_int+2
                if .segmentType_foll1$ == ""
                    .segmentType_foll1$ = "--undefined--"
                endif
            else
                .segmentType_foll1$ = "--undefined--"
            endif
            
            # APPEND OUTPUT
            fileappend 'outfile$' ,'.prev_syllable$','.current_syllable$','.foll_syllable$','.segmentType_prev1$','.segmentType_prev$','.segmentType$','.segmentType_foll$','.segmentType_foll1$'

        else
            printline ERROR! Expected "syllables" and "segmentType" tiers, found instead '.syll_tier_name$' and '.seg_tier_name$' instead.
            exit
        endif
    endif

endproc

#######################################################################################
#                                                                                     #
#              PROCEDURES THAT DEAL WITH BAND ENERGY OR SPECTRAL MOMENTS              #
#                                                                                     #
#######################################################################################

#######################################################################################
# PROCEDURE: cog()
# simply measure center of gravity for entire phone intervals
#
# EXAMPLE 'cog()'
#######################################################################################

procedure cog (.argString$)

    if isHeader = 1 
        fileappend 'outfile$' ,cog
    elif isComplete == 1
        printline FINISHED  
    else
        select Sound 'sound_name$'
        Extract part... 'transport.phone_start' 'transport.phone_end' rectangular 1.0 yes
        To Spectrum... yes
        .cog = Get centre of gravity... 2
        fileappend 'outfile$' ,'.cog:0'
        plus Sound 'sound_name$'_part
        Remove
    endif

endproc

#######################################################################################
# PROCEDURE: cogs(measurements=31,window=0.030,lastphone=no,nextphone=no,filter_low=0,filter_high=22050)
# measure center of gravity at many time points
#
# clips will only be filtered if filter_low or filter_high arguments are specified. 
# (0,22050 are defaults if only one is specified)
# All preceding and/or following phones can be included by setting lastphone or nextphone to "yes"
#
# EXAMPLE: 'cogs(measurements=11)' [to measure cog at 0%, 10%, ... , 100% of duration]
#######################################################################################

procedure cogs (.argString$)

    @parseArgs (.argString$)
   
    .time_step = 0.0
    .mps = 31
    .window = 0.030
    .halfwindow = 0.015
    .lastphone$ = "no"
    .nextphone$ = "no"
    .filter_low = 0
    .filter_high = 22050
    .filtering = 0

    for .i to parseArgs.n_args
        # if parseArgs.var$[.i] == "time_step"
        #    .time_step = number(parseArgs.val$[.i])
        if parseArgs.var$[.i] == "measurements"
            .mps = number(parseArgs.val$[.i])
        elif parseArgs.var$[.i] == "window"
            .window = number(parseArgs.val$[.i])
        elif parseArgs.var$[.i] == "lastphone"
            .lastphone$ = parseArgs.val$[.i]
        elif parseArgs.var$[.i] == "nextphone"
            .nextphone$ = parseArgs.val$[.i]
        elif parseArgs.var$[.i] == "filter_low"
            .filter_low = number(parseArgs.val$[.i])
            .filtering = 1
        elif parseArgs.var$[.i] == "filter_high"
            .filter_high = number(parseArgs.val$[.i])
            .filtering = 1
        elif parseArgs.var$[.i] != ""
            if isHeader == 1
                .unknown_var$ = parseArgs.var$[.i]
                printline skipped unknown argument '.unknown_var$'
            endif
        endif
    endfor

    if isHeader = 1 
        printline cogs ('.argString$')
        .cogsheader$ = ",first_measure,last_measure,step"
        if .filtering == 1
            #printline band filtering between '.filter_low' and '.filter_high' Hz 
        endif
        for .mp to .mps
            .mpct = round(1000*(.mp-1)/(.mps-1))
            .cogsheader$ = .cogsheader$ + ",C'.mp'"
        endfor
        fileappend 'outfile$' '.cogsheader$'
        #printline '.mps' in Header
    elif isComplete == 1
        printline FINISHED  

    else
        if .lastphone$ == "yes" or .lastphone$ == "true"
            .first_measure = transport.lastphone_start
        else
            .first_measure = transport.phone_start
        endif

        if .nextphone$ == "yes" or .nextphone$ == "true"
            .last_measure = transport.nextphone_end
        else
            #printline only target phone
            .last_measure = transport.phone_end
        endif

        .measurement_step_size = (.last_measure-.first_measure)/(.mps-1)

        .cogs_data$ = ",'.first_measure','.last_measure','.measurement_step_size'"
        #printline '.mps' when measuring
        for .mp to .mps
            .measure_time = .first_measure + .measurement_step_size*(.mp-1)
            select Sound 'sound_name$'
            Extract part... '.measure_time'-'.halfwindow' '.measure_time'+'.halfwindow' Hamming 1.0 yes
            if .filtering == 1
                Filter (pass Hann band): '.filter_low', '.filter_high', 100
            endif 
            To Spectrum... yes
            .cog = Get centre of gravity... 2
            .cogs_data$ = .cogs_data$ + ",'.cog'"
        
            #REMOVE OBJECTS WE'RE FINISHED WITH
            select Sound 'sound_name$'_part
            if .filtering == 1
                plus Sound 'sound_name$'_part_band
                plus Spectrum 'sound_name$'_part_band
            else
                plus Spectrum 'sound_name$'_part
            endif
            Remove
        endfor
        fileappend 'outfile$' '.cogs_data$'

    endif
    
endproc

#######################################################################################
# PROCEDURE: cog_pro(from_time=0.2,to_time=0.8,from_freq=0,to_freq=11025)
# measure center of gravity of a specified part of an interval with band filtering
#
# EXAMPLE: 'cog_pro()'
#######################################################################################

procedure cog_pro (.argString$)

    @parseArgs (.argString$)
    .from_time = 0.2
    .to_time = 0.8
    .from_freq = 0
    .to_freq = 11025

    for i to parseArgs.n_args
        if parseArgs.var$[i] == "from_time"
            .from_time = number(parseArgs.val$[i])
        elif parseArgs.var$[i] == "to_time"
            .to_time = number(parseArgs.val$[i]) 
        elif parseArgs.var$[i] == "from_freq"
            .from_freq = number(parseArgs.val$[i])
        elif parseArgs.var$[i] == "to_freq"
            .to_freq = number(parseArgs.val$[i])
        elif parseArgs.var$[i] != ""
            if isHeader == 1
                .unknown_var$ = parseArgs.var$[i]
                printline skipped unknown argument '.unknown_var$'
            endif
        endif
    endfor

    if isHeader = 1 
        fileappend 'outfile$' ,cog
    elif isComplete == 1
        printline FINISHED  
    else
        select Sound 'sound_name$'
        viscincrement20 = transport.phone_start + transport.duration*.from_time
        viscincrement80 = transport.phone_start + transport.duration*.to_time
        Extract part... viscincrement20 viscincrement80 rectangular 1.0 yes
        Filter (pass Hann band)... .from_freq .to_freq 100
        To Spectrum... yes
        .cog = Get centre of gravity... 2
        fileappend 'outfile$' ,'.cog:0'
        plus Sound 'sound_name$'_part
        plus Sound 'sound_name$'_part_band
        Remove

        if interactive_session == 1
            echo 
            printline 'transport.phone$' 'transport.phone_start' '.cog'

        endif
    endif

endproc

#######################################################################################
# PROCEDURE: nasalization(measurements=31,window=0.030,lastphone=no,nextphone=no)
# apply various acoustic measures of nasalization described in Pruthi and Espy-Wilson (2007)
#
# All preceding and/or following phones can be included by setting lastphone or nextphone to "yes"
#
# EXAMPLE: 'nasalization(measurements=11)' [to get nasalization measures at 0%, 10%, ... , 100% of duration]
#######################################################################################

# praat /phon/scripts/one_script_21_dev.praat /phon/ENG536/files/lab2_corpus/lab2_files.csv 'NASAL/VOWEL/' 'formants(),nasalization()'

procedure nasalization (.argString$)

    @parseArgs (.argString$)
   
    .time_step = 0.0
    .mps = 11
    .window = 0.030
    .halfwindow = 0.015
    .lastphone$ = "no"
    .nextphone$ = "no"

    .pitch_floor = 75
    .pitch_ceiling = 400

    for .i to parseArgs.n_args
        if parseArgs.var$[.i] == "measurements"
            .mps = number(parseArgs.val$[.i])
        elif parseArgs.var$[.i] == "window"
            .window = number(parseArgs.val$[.i])
        elif parseArgs.var$[.i] == "lastphone"
            .lastphone$ = parseArgs.val$[.i]
        elif parseArgs.var$[.i] == "nextphone"
            .nextphone$ = parseArgs.val$[.i]
        elif parseArgs.var$[.i] != ""
            if isHeader == 1
                .unknown_var$ = parseArgs.var$[.i]
                printline skipped unknown argument '.unknown_var$'
            endif
        endif
    endfor

    if isHeader = 1 
        printline nasalization ('.argString$')
        .nasalization_header$ = ",first_measure,last_measure,step"
        .na1p0_header$ = ""
        .na1p1_header$ = ""
        .nf1fp0_header$ = ""
        #.ntef1_header$ = ""
        .npeaks_header$ = ""
        #.na1h1m_header$ = ""
        .na1h1_header$ = ""
        .nb1_header$ = ""
        .nsd_header$ = ""
        .na1_header$ = ""
        .np0_header$ = ""
        .nfp0_header$ = ""
        .np1_header$ = ""
        .nfp1_header$ = ""
        .nah1_header$ = ""
        .nfh1_header$ = ""

        for .mp to .mps
            .mpct = round(1000*(.mp-1)/(.mps-1))

            # sgA1 - P0
            .na1p0_header$ = .na1p0_header$ + ",NA1P0_'.mp'"

            # sgA1 - P1
            .na1p1_header$ = .na1p1_header$ + ",NA1P1_'.mp'"

            # sgF1 - F_P0
            .nf1fp0_header$ = .nf1fp0_header$ + ",NF1P0_'.mp'"

            # teF1
            #.ntef1_header$ = .ntef1_header$ + ",NteF1_'.mp'"

            # nPeaks40dB
            .npeaks_header$ = .npeaks_header$ + ",Npeaks_'.mp'"

            # a1 - h1max800
            #.na1h1m_header$ = .na1h1m_header$ + ",NA1H1m_'.mp'"

            # a1 - h1fmt
            .na1h1_header$ = .na1h1_header$ + ",NA1H1_'.mp'"

            # F1BW
            .nb1_header$ = .nb1_header$ + ",NB1_'.mp'"

            # std0 - 1K
            .nsd_header$ = .nsd_header$ + ",Nsd_'.mp'"

            # just A1, P0, F_P0, P1, F_P1, h1, F_h1
            .na1_header$ = .na1_header$ + ",NA1_'.mp'"
            .np0_header$ = .np0_header$ + ",NP0_'.mp'"
            .nfp0_header$ = .nfp0_header$ + ",NFP0_'.mp'"
            .np1_header$ = .np1_header$ + ",NP1_'.mp'"
            .nfp1_header$ = .nfp1_header$ + ",NFP1_'.mp'"
            .nah1_header$ = .nah1_header$ + ",NH1_'.mp'"
            .nfh1_header$ = .nfh1_header$ + ",NFH1_'.mp'"

        endfor

        .nasalization_header$ = .nasalization_header$ + .na1p0_header$ + .na1p1_header$ + .nf1fp0_header$ + .npeaks_header$
        .nasalization_header$ = .nasalization_header$ + .na1h1_header$ + .nb1_header$ + .nsd_header$
        .nasalization_header$ = .nasalization_header$ + .na1_header$ + .np0_header$ + .nfp0_header$ + .np1_header$ + .nfp1_header$ + .nah1_header$ + .nfh1_header$

        fileappend 'outfile$' '.nasalization_header$'
        printline '.mps' in Header
    elif isComplete == 1
        printline FINISHED  

    else
        .ltas_bandwidth = ceiling(sound_samplerate/2048) # changed 2025/09/16
        .ltas_bandwidth = ceiling(sound_samplerate/1024)
        
        if .lastphone$ == "yes" or .lastphone$ == "true"
            .first_measure = transport.lastphone_start
        else
            .first_measure = transport.phone_start
        endif

        if .nextphone$ == "yes" or .nextphone$ == "true"
            .last_measure = transport.nextphone_end
        else
            #printline only target phone
            .last_measure = transport.phone_end
        endif

        .measurement_step_size = (.last_measure-.first_measure)/(.mps-1)

        # use information from formants procedure
        select Sound 'sound_name$'
        Extract part... '.first_measure'-0.025 '.last_measure'+0.025 rectangular 1.0 yes
        Rename: "sound_for_formants"
        To Formant (burg)... 0.0 'formants.best_total_formants' 'formants.max_formant' 0.025 50
        
        selectObject: "Sound sound_for_formants"
        To Pitch (cc): 0, .pitch_floor, 15, "no", 0.03, 0.45, 0.01, 0.35, 0.14, .pitch_ceiling

        .nasalization_data$ = ",'.first_measure','.last_measure','.measurement_step_size'"
        #printline '.mps' when measuring

        .na1p0_data$ = ""
        .na1p1_data$ = ""
        .nf1fp0_data$ = ""
        #.ntef1_data$ = ""
        .npeaks_data$ = ""
        #.na1h1m_data$ = ""
        .na1h1f_data$ = ""
        .nb1_data$ = ""
        .nsd_data$ = ""
        .na1_data$ = ""
        .np0_data$ = ""
        .nfp0_data$ = ""
        .np1_data$ = ""
        .nfp1_data$ = ""
        .nah1_data$ = ""
        .nfh1_data$ = ""

        for .mp to .mps
            .measure_time = .first_measure + .measurement_step_size*(.mp-1)

            selectObject: "Pitch sound_for_formants"
            .ffreq = Get value at time: .measure_time, "Hertz", "Linear"

            selectObject: "Formant sound_for_formants"
            .b1 = Get bandwidth at time... 1 '.measure_time' Hertz Linear
            .f1 = Get value at time... 1 '.measure_time' Hertz Linear
            .f2 = Get value at time... 2 '.measure_time' Hertz Linear
        
            .nb1_data$ = .nb1_data$ + ",'.b1'"

            # select Sound 'sound_name$'
            selectObject: "Sound sound_for_formants"
            Extract part... '.measure_time'-'.halfwindow' '.measure_time'+'.halfwindow' Hamming 1.0 yes

            To Ltas: .ltas_bandwidth

            if .f1 == undefined or .ffreq == undefined
                .a1 = undefined
                .p0 = undefined
                .fp0 = undefined
            else
                #.a1 = Get maximum: .f1-.ffreq, .f1+.ffreq, "None"
                #.p0 = Get maximum: .ffreq*2, .f1-.ffreq, "None"
                #.fp0 = Get frequency of maximum: .ffreq*2, .f1-.ffreq, "None"
                .a1 = Get maximum: .f1-.ffreq/2, .f1+.ffreq/2, "None"
                .p0 = Get maximum: 0, .f1-.ffreq/2-.ltas_bandwidth, "None"
                .fp0 = Get frequency of maximum: 0, .f1-.ffreq/2-.ltas_bandwidth, "None"
            endif

            if .f1 == undefined or .f2 == undefined or .ffreq == undefined
                .p1 = undefined
                .fp0 = undefined
                .fp1 = undefined
            else
                #.p1 = Get maximum: .f1+.ffreq, .f2-.ffreq, "None"
                .p1 = Get maximum: .f1+.ffreq/2, .f2-.ffreq/2, "None"
                .fp1 = Get frequency of maximum: .f1+.ffreq/2, .f2-.ffreq/2, "None"
            endif

            if .ffreq == undefined
                .ah1 = undefined
                .peaks = undefined
            else
                .ah1 = Get maximum: .ffreq*0.5, .ffreq*1.5, "None"

                selectObject: "Ltas sound_for_formants_part"
                .hifreq = Get highest frequency
                .maxamp = Get maximum: 0, 0, "None"
                .freqsteps = floor(.hifreq/.ffreq)
                #printline '.freqsteps'

                Create Table with column names: "harmonics", 0, "freq amp" 

                for .i from 1 to .freqsteps
                    selectObject: "Ltas sound_for_formants_part"
                    .amp = Get maximum: .ffreq*(.i-0.5), .ffreq*(.i+0.5), "None"
                    selectObject: "Table harmonics"
                    Append row
                    Set numeric value: .i, "freq", .ffreq*.i
                    Set numeric value: .i, "amp", .amp*.i
                endfor

                .peaks = 0
                selectObject: "Table harmonics"

                .amp = Get value: 1, "amp"
                .next_amp = Get value: 2, "amp"
                if .amp > .next_amp and .maxamp - .amp < 40
                    .peaks = .peaks + 1
                endif

                for .i from 2 to .freqsteps-1
                    .last_amp = Get value: .i-1, "amp"
                    .amp = Get value: .i, "amp"
                    .next_amp = Get value: .i+1, "amp"

                    if .amp > .last_amp and .amp > .next_amp and .maxamp - .amp < 40
                        .peaks = .peaks + 1
                    endif
                endfor

            endif

            .a1_p0 = .a1 - .p0
            .a1_p1 = .a1 - .p1
            .f1_fp0 = .f1 - .fp0
            .a1_ah1 = .a1 - .ah1

            .na1p0_data$ = .na1p0_data$ + ",'.a1_p0'"
            .na1p1_data$ = .na1p1_data$ + ",'.a1_p1'"
            .nf1fp0_data$ = .nf1fp0_data$ + ",'.f1_fp0'"
            #.ntef1_data$ = .ntef1_data$ + ",'undefined'"
            .npeaks_data$ = .npeaks_data$ + ",'.peaks'"
            #.na1h1m_data$ = .na1h1m_data$ + ",'undefined'"
            .na1h1f_data$ = .na1h1f_data$ + ",'.a1_ah1'"

            .na1_data$ = .na1_data$ + ",'.a1'"
            .np0_data$ = .np0_data$ + ",'.p0'"
            .nfp0_data$ = .nfp0_data$ + ",'.fp0'"
            .np1_data$ = .np1_data$ + ",'.p1'"
            .nfp1_data$ = .nfp1_data$ + ",'.fp1'"
            .nah1_data$ = .nah1_data$ + ",'.ah1'"
            .nfh1_data$ = .nfh1_data$ + ",'.ffreq'"

            select Sound sound_for_formants_part
            Filter (pass Hann band): 0, 1000, 100
            To Spectrum... yes
            .sd = Get standard deviation... 2
            .nsd_data$ = .nsd_data$ + ",'.sd'"
        
            #REMOVE OBJECTS WE'RE FINISHED WITH
            select Sound sound_for_formants_part
            plus Sound sound_for_formants_part_band
            plus Spectrum sound_for_formants_part_band
            plus Ltas sound_for_formants_part
            if .ffreq != undefined
                plus Table harmonics
            endif
            Remove
        endfor

        .nasalization_data$ = .nasalization_data$ + .na1p0_data$ + .na1p1_data$ + .nf1fp0_data$ + .npeaks_data$
        .nasalization_data$ = .nasalization_data$ + .na1h1f_data$ + .nb1_data$ + .nsd_data$
        .nasalization_data$ = .nasalization_data$ + .na1_data$ + .np0_data$ + .nfp0_data$ + .np1_data$ + .nfp1_data$ + .nah1_data$ + .nfh1_data$

        fileappend 'outfile$' '.nasalization_data$'

        selectObject: "Formant sound_for_formants"
        plusObject: "Pitch sound_for_formants"
        plusObject: "Sound sound_for_formants"
        Remove

    endif
    
endproc


#######################################################################################
# PROCEDURE: band_energy(from_time=0.2,to_time=0.8,from_freq=750,to_freq=11025)
# measure band energy of a specified part of an interval
#
# EXAMPLE: 'band_energy(from_freq=100, to_freq=400)'
#######################################################################################

procedure band_energy (.argString$)

    @parseArgs (.argString$)
    .from_time = 0.2
    .to_time = 0.8
    .from_freq = 750
    .to_freq = 11025

    for i to parseArgs.n_args
        if parseArgs.var$[i] == "from_time"
            .from_time = number(parseArgs.val$[i])
        elif parseArgs.var$[i] == "to_time"
            .to_time = number(parseArgs.val$[i]) 
        elif parseArgs.var$[i] == "from_freq"
            .from_freq = number(parseArgs.val$[i])
        elif parseArgs.var$[i] == "to_freq"
            .to_freq = number(parseArgs.val$[i])
        elif parseArgs.var$[i] != ""
            if isHeader == 1
                .unknown_var$ = parseArgs.var$[i]
                printline skipped unknown argument '.unknown_var$'
            endif
        endif
    endfor

    if isHeader = 1 
        fileappend 'outfile$' ,band_energy_'.from_freq'_'.to_freq'
    elif isComplete == 1
        printline FINISHED  
    else
        select Sound 'sound_name$'
        viscincrement20 = transport.phone_start + transport.duration*.from_time
        viscincrement80 = transport.phone_start + transport.duration*.to_time
        Extract part... viscincrement20 viscincrement80 rectangular 1.0 yes
        #Filter (pass Hann band)... .from_freq .to_freq 100
        To Spectrum... yes
        .band_energy = Get band energy: .from_freq, .to_freq
        fileappend 'outfile$' ,'.band_energy:0'
        plus Sound 'sound_name$'_part
        #plus Sound 'sound_name$'_part_band
        Remove

        if interactive_session == 1
            echo 
            printline 'transport.phone$' 'transport.phone_start' '.band_energy'

        endif
    endif

endproc

#######################################################################################
# PROCEDURE: band_energy_diff()
# measures the difference in band energy comparing 3.5-5.5 kHz with 1.5-2.5 kHz
# this procedure needs to be modified to make the bands user-specifiable
#
# EXAMPLE: 'band_energy_diff()'
#######################################################################################

procedure band_energy_diff (.argString$)

    if isHeader = 1 
        fileappend 'outfile$' ,band_energy_diff
    elif isComplete == 1
        print FINISHED 
    else
        select Sound 'sound_name$'
        Extract part... 'transport.phone_start' 'transport.phone_end' rectangular 1.0 yes
        To Spectrum... yes
        .b_e_d = Get band energy difference: 1500, 2500, 3500, 5500
        fileappend 'outfile$' ,'.b_e_d:0'
    endif

endproc



#######################################################################################
# findIntensityCutoff() is a utility script for segment_release()
#######################################################################################

procedure findIntensityCutoff (.interval_start, .interval_end)

    # find the start of the release as the boundary between optimal low- and  
    # high-intensity intervals within a time interval
    # uses global variable sound_name$

    .max_energy_diff = -999999
    .min_energy_diff = 999999
    #.closure_energy = 999999
    .best_cutoff_time = transport.phone_start + 0.001

    .phone_start_time_ms = ceiling(.interval_start*1000) 
    .phone_end_time_ms = floor(.interval_end*1000)
    #printline 'i' 'transport.phone_start:3' '.interval_start:3' 'transport.phone_end:3' '.interval_end:3'

    for .t from .phone_start_time_ms to .phone_end_time_ms
        .cutoff_time = .t/1000
        selectObject: "Intensity 'sound_name$'_part"
        #.first_energy = Get mean: phone_start_time, .cutoff_time, "dB"
        .first_energy = Get mean: .interval_start, .cutoff_time, "dB"
        .second_energy = Get mean: .cutoff_time, .interval_end, "dB"
        .energy_diff = .second_energy - .first_energy
        #printline 't' 'phone_label$' '.cutoff_time:3' '.first_energy:3' '.second_energy:3' '.energy_diff:3'
        if .energy_diff > .max_energy_diff
            .max_energy_diff = .energy_diff
            .best_cutoff_time_positive = .cutoff_time
            #.closure_energy = .first_energy
        endif

        if .energy_diff < .min_energy_diff
            .min_energy_diff = .energy_diff
            .best_cutoff_time_negative = .cutoff_time
            #.closure_energy = .first_energy
        endif

    endfor

endproc

#######################################################################################
# findGlottalPulse() is a utility script for segment_release()
#######################################################################################

procedure findGlottalPulse (.interval_start, .interval_end)

    # find the boundaries by looking for glottal pulses
    # uses global variable sound_name$

    selectObject: "PointProcess 'sound_name$'_part"
    .phone_midpoint = (.interval_start + .interval_end)/2
    .last_pulse = Get low index: .phone_midpoint
    .first_pulse = Get high index: .phone_midpoint
    
    .closure_start = .interval_start
    if .last_pulse > 0
        .last_pulse_time = Get time from index: .last_pulse
        if .last_pulse_time != undefined
            .closure_start = .last_pulse_time
        endif           
    endif

    .release_end = .interval_end
    if .first_pulse > 0
        .first_pulse_time = Get time from index: .first_pulse
        if .first_pulse_time != undefined
            .release_end = .first_pulse_time
        endif
    endif

endproc

#######################################################################################
# PROCEDURE: segment_release()
# try to resegment the release phase of a stop or affricate
#
# EXAMPLE: 'segment_release()'
#
# praat /phon/scripts/one_script_dev25.praat /phon/orthognathic/ortho_files_all_07_07_21.csv 'P T K CH' 'segment_release()' '' 'PLEASE SAY AGAIN'
#
#######################################################################################

procedure segment_release (.argString$)

    @parseArgs (.argString$)

    # variables that are not available as command-line options

    .pad = 0.100
    .resegment_window = 0.050
    .min_pitch = 100
    #.min_pitch_for_intensity = 3200  
    .min_pitch_for_intensity = 320 
    # the effective duration of the analysis window is 3.2 / .min_pitch_for_intensity

    # find the start of the closure phase using intensity cutoff or pulses
    .method_left$ = "cutoff"
    # find the start of the release phase using silences or intensity cutoff 
    # (silences can override placement of release end if a pause is found after the release)
    .method_release$ = "silences"
    # find the end of the release phase using intensity cutoff or pulses
    #.method_right$ = "pulses"
    #.method_right$ = "cutoff_negative"
    .method_right$ = "cutoff"

    # TRY CHANGING THE SILENCE THRESHOLD USED TO FIND THE RELEASE: 
    # lower values for silence_threshold_ratio mean more sounds will get counted as silence
    # (originally 0.75)
    .silence_threshold_ratio = 0.75
    .silence_threshold_ratio_for_bursts = 0.75

    # TRY CHANGING WHETHER THE VOWEL IS INCLUDED WHEN LOOKING FOR SILENCE:
    # vowels are loud but consistent. If we change this to 0, we will only be trying to distinguish
    # the silence of the closure from the noise of the burst. Changing this to 0 seems like
    # a good idea. Keep in mind that this will change the effect of silence_threshold_ratio above
    # (originally 1)
    .include_vowel_in_silence_textgrid = 0
    .min_silent_interval = 0.02
    .min_sounding_interval = 0.01    
  
    .min_silent_interval_for_bursts = 0.0025
    .min_sounding_interval_for_bursts = 0.0025

    # TRY CHANGING THE RANGE OF FREQUENCIES INCLUDED BY THE FILTER: 
    # filter_from and filter_to define the range of frequencies that will be included
    # when we filter the sound before measuring intensity
    # (originally 5000 Hz and 22050 Hz)
    .filter_from = 5000
    .filter_to = 16000

    for i to parseArgs.n_args
        if parseArgs.var$[i] == "filter_low"
            .filter_low = number(parseArgs.val$[i])
            .filtering = 1
        elif parseArgs.var$[i] == "filter_high"
            .filter_high = number(parseArgs.val$[i])
            .filtering = 1
        elif parseArgs.var$[i] != ""
            if isHeader == 1
                .unknown_var$ = parseArgs.var$[i]
                printline skipped unknown argument '.unknown_var$'
            endif
        endif
    endfor

    if isHeader = 1 
        printline segment_release ('.argString$')
        .xheader$ = ",closure_start,release_start,release_end,nextphone_end,intensity_range,closure_bursts,release_bursts"
        fileappend 'outfile$' '.xheader$'
    elif isComplete == 1
        printline FINISHED  
    else

        selectObject: "TextGrid 'sound_name$'"
        .total_tiers = Get number of tiers
        .release_tier = .total_tiers + 1
        Insert interval tier: .release_tier, "plosive"
        
        .extract_start = transport.phone_start - .pad
        .extract_end = transport.phone_end + .pad

        # Make the objects to use for segmentation
        selectObject: "Sound 'sound_name$'"
        Extract part: .extract_start, .extract_end, "rectangular", 1, "yes"
        To PointProcess (periodic, cc): .min_pitch, 300
        selectObject: "Sound 'sound_name$'_part"

        selectObject: "Sound 'sound_name$'_part"    
        To Intensity: .min_pitch_for_intensity, 0, "yes"

        selectObject: "Sound 'sound_name$'_part"    
        #Filter (stop Hann band): 0, 5000, 100
        Filter (pass Hann band): .filter_from, .filter_to, 100
        To Intensity: .min_pitch_for_intensity, 0, "yes"

        ####################################################
        # find the start and end of the voiceless interval using glottal pulses or intensity
        ####################################################

        if .method_left$ == "pulses"
            @findGlottalPulse (transport.phone_start, transport.phone_end)
            .closure_start = findGlottalPulse.closure_start
        else
            @findIntensityCutoff (transport.phone_start-.resegment_window/2, transport.phone_start+.resegment_window/2)
            .closure_start = findIntensityCutoff.best_cutoff_time_negative
        endif

        if .method_right$ == "pulses"
            @findGlottalPulse (transport.phone_start, transport.phone_end)
            .release_end = findGlottalPulse.release_end
        elif .method_right$ == "cutoff_negative"
            #@findIntensityCutoff (transport.phone_end-.resegment_window/2, transport.phone_end+.resegment_window/2)
            @findIntensityCutoff (.closure_start+0.001, transport.phone_end+.resegment_window/2)
            .release_end = findIntensityCutoff.best_cutoff_time_negative
            #printline '.closure_start' '.release_end'
        else
            @findIntensityCutoff (transport.phone_end-.resegment_window/2, transport.phone_end+.resegment_window/2)
            .release_end = findIntensityCutoff.best_cutoff_time_positive
        endif

        if .closure_start > .release_end
            .closure_start = transport.phone_start
            .release_end = transport.phone_end
        endif

        ####################################################
        # find the start of the release either using silences or 
        # as the boundary between optimal low- and high-intensity intervals within the phone tier's plosive interval
        ####################################################

        if .method_release$ == "silences"
        
            selectObject: "Intensity 'sound_name$'_part_band"

            # 3/7/22 changed to examine shorter intensity interval 
            if .include_vowel_in_silence_textgrid
                .min_intensity = Get minimum: 0, 0, "parabolic"
                .max_intensity = Get maximum: 0, 0, "parabolic"
                .min_intensity_time = Get time of minimum: 0, 0, "parabolic"
            else
                .min_intensity = Get minimum: .closure_start, .release_end, "parabolic"
                .max_intensity = Get maximum: .closure_start, .release_end, "parabolic"
                .min_intensity_time = Get time of minimum: .closure_start, .release_end, "parabolic"
            endif

            .silence_threshold = (.min_intensity - .max_intensity) * .silence_threshold_ratio
            .silence_threshold = min (-1,.silence_threshold)

            # 4/11/22 added intensity_range
            .intensity_range = .max_intensity - .min_intensity

            To TextGrid (silences): .silence_threshold, .min_silent_interval, .min_sounding_interval, "silent", "sounding"
            #silence_total_intervals = Get number of intervals: 1
            #printline 'silence_total_intervals'
            #.first_silences_label$ = Get label of interval: 1, 1
            #.silent_intervals = Count intervals where: 1, "is equal to", "silent"

            .closure_start_interval = Get interval at time: 1, .closure_start
            .release_end_interval = Get interval at time: 1, .release_end

            .release_start = undefined
            .new_release_end = undefined
            for .si from .closure_start_interval to .release_end_interval
                .silence_label$ = Get label of interval: 1, .si
                #printline '.si' '.silence_label$'
                if .silence_label$ == "silent"
                    if .release_start == undefined
                        .release_start = Get end time of interval: 1, .si
                        #printline found release start '.release_start'
                    elif .new_release_end == undefined
                        .new_release_end = Get start time of interval: 1, .si
                        printline '.release_start' '.new_release_end'
                        .release_end = .new_release_end
                        #printline found release end '.release_end'
                    else
                        #printline found nothing new
                    endif
                endif
            endfor

            if .release_start == undefined
                .release_start = (.closure_start+.release_end)/2
            endif

            Remove

            #4/11/22 trying to count intervals by making another silences textgrid
            .silence_threshold_for_bursts = (.min_intensity - .max_intensity) * .silence_threshold_ratio_for_bursts
            .silence_threshold_for_bursts = min (-1,.silence_threshold_for_bursts)

            selectObject: "Intensity 'sound_name$'_part_band"
            To TextGrid (silences): .silence_threshold_for_bursts, .min_silent_interval_for_bursts, .min_sounding_interval_for_bursts, "silent", "sounding"
            Rename: "burst_counter_'transport.phone$'_'.closure_start'"
            .closure_start_burst_interval = Get interval at time: 1, .closure_start
            .release_start_burst_interval = Get interval at time: 1, .release_start
            .release_end_burst_interval = Get interval at time: 1, .release_end
            .closure_bursts = floor((.release_start_burst_interval - .closure_start_burst_interval)/2)
            .release_bursts = ceiling((1+.release_end_burst_interval - .release_start_burst_interval)/2)
            Remove

        else
            @findIntensityCutoff (.closure_start+0.001, .release_end-0.001)
            .release_start = findIntensityCutoff.best_cutoff_time_positive
        endif

        ####################################################
        # record the segmentation
        ####################################################

        selectObject: "TextGrid 'sound_name$'"

        #printline '.closure_start:6' '.release_start:6' '.release_end:6'

        Insert boundary: .release_tier, .closure_start

        # This is because the release start is sometimes after the end of the textgrid
        if .release_start < wav_duration
            Insert boundary: .release_tier, .release_start
        endif

        # This is because the release end is sometimes after the end of the textgrid
        if .release_end < wav_duration
            Insert boundary: .release_tier, .release_end
        endif

        .tier3_interval = Get interval at time: .release_tier, .closure_start+0.0001
        Set interval text: .release_tier, .tier3_interval, "closure"
        Set interval text: .release_tier, .tier3_interval+1, "release"

        selectObject: "Sound 'sound_name$'_part"
        plusObject: "Intensity 'sound_name$'_part"
        plusObject: "Sound 'sound_name$'_part_band"
        plusObject: "Intensity 'sound_name$'_part_band"
        plusObject: "PointProcess 'sound_name$'_part"
        Remove

        .xdata$ = ",'.closure_start:6','.release_start:6','.release_end:6','transport.nextphone_end:6','.intensity_range:3','.closure_bursts','.release_bursts'"

        fileappend 'outfile$' '.xdata$'


    endif
#    endfor

endproc

#######################################################################################
# PROCEDURE: release_spectrum(filter_low=0,filter_high=22050)
# measure spectral moments of the release burst
# clips will only be filtered if filter_low or filter_high arguments are specified. 
# (0,22050 are defaults if only one is specified)
# NOTE: this procedure expects the release intervals to be segmented separately
#
# EXAMPLE: 'release_spectrum()'
#######################################################################################

procedure release_spectrum (.argString$)

    @parseArgs (.argString$)
   
    #.min_pitch = 100
    #.pad = 0.0
    .lastphone$ = "no"
    .nextphone$ = "no"
    .release$ = "no"
    .filter_low = 0
    .filter_high = 22050
    .filtering = 0
    .halfwindow = 0.015

    for i to parseArgs.n_args
        if parseArgs.var$[i] == "filter_low"
            .filter_low = number(parseArgs.val$[i])
            .filtering = 1
        elif parseArgs.var$[i] == "filter_high"
            .filter_high = number(parseArgs.val$[i])
            .filtering = 1
        elif parseArgs.var$[i] != ""
            if isHeader == 1
                .unknown_var$ = parseArgs.var$[i]
                printline skipped unknown argument '.unknown_var$'
            endif
        endif
    endfor

    if isHeader = 1 
        printline release_spectrum ('.argString$')
        if .filtering == 1
            printline band filtering between '.filter_low' and '.filter_high' Hz 
        endif

        .xheader$ = ",cog,sd,skew,kurt"
        fileappend 'outfile$' '.xheader$'
    elif isComplete == 1
        printline FINISHED  
    else

        if transport.nextphone$ == "rel"
            selectObject: "Sound 'sound_name$'"
            Extract part... 'transport.phone_end' 'transport.nextphone_end' rectangular 1.0 yes
            if .filtering == 1
                Filter (pass Hann band): '.filter_low', '.filter_high', 100
            endif
            To Spectrum: "yes"
            .cog = Get centre of gravity: 2
            .sd = Get standard deviation: 2
            .skew = Get skewness: 2
            .kurt = Get kurtosis: 2
            plusObject: "Sound 'sound_name$'_part"
            if .filtering == 1
                plusObject: "Sound 'sound_name$'_part_band"
            endif            
            Remove
        else
            .cog = undefined
            .sd = undefined
            .skew = undefined
            .kurt = undefined
        endif
        .xdata$ = ",'.cog','.sd','.skew','.kurt'"
        fileappend 'outfile$' '.xdata$'
        

    endif
endproc



#######################################################################################
# PROCEDURE: sibilant_jane(from_time=0.0,to_time=1.0,window="Rectangular",filter_low=0,filter_high=22050)
# measure spectral peak, spectral slope, center of gravity, and spectral spread in the style of Jane Stuart-Smith
# clips will only be filtered if filter_low or filter_high arguments are specified. 
# (0,22050 are defaults if only one is specified)
#
# EXAMPLE: 'sibilant_jane()'
#######################################################################################

procedure sibilant_jane (.argString$)

    @parseArgs (.argString$)
    .from_time = 0.0
    .to_time = 1.0
    .window$ = "Rectangular"
    .filter_low = 0
    .filter_high = 22050
    .filtering = 0

    #PARSE THE ARGUMENTS
    for i to parseArgs.n_args
        if parseArgs.var$[i] == "from_time"
            .from_time = number(parseArgs.val$[i])
        elif parseArgs.var$[i] == "to_time"
            .to_time = number(parseArgs.val$[i]) 
        elif parseArgs.var$[i] == "window"
            .window$ = parseArgs.val$[i] 
        elif parseArgs.var$[i] == "filter_low"
            .filter_low = number(parseArgs.val$[i])
            .filtering = 1
        elif parseArgs.var$[i] == "filter_high"
            .filter_high = number(parseArgs.val$[i])
            .filtering = 1
        elif parseArgs.var$[i] != ""
            if isHeader == 1
                .unknown_var$ = parseArgs.var$[i]
                printline skipped unknown argument '.unknown_var$'
            endif
        endif
    endfor

    #THIS WILL BE CALLED ONCE TO MAKE THE HEADER, ONCE AT THE END, AND ONCE FOR EACH MATCHING TOKEN...
    if isHeader = 1 
        fileappend 'outfile$' ,peak,slope,cog,spread
    elif isComplete == 1
        printline FINISHED  
    else
        #EXTRACT AND FILTER
        select Sound 'sound_name$'
        .extract_start = transport.phone_start + transport.duration*.from_time
        .extract_end = transport.phone_start + transport.duration*.to_time
        Extract part: '.extract_start', '.extract_end', .window$, 1.0, "yes"
        if .filtering == 1
            #.newsamplerate = .filter_high*2      
            .newsamplerate = 16000         
            Resample: .newsamplerate, 50
            Filter (pass Hann band): '.filter_low', '.filter_high', 100
        endif 
           
        #MEASURE THE SPECTRUM
        To Spectrum... yes
        .cog = Get centre of gravity... 2
        .spread = Get standard deviation... 2

        #MEASURE THE LONG-TERM AVERAGE SPECTRUM
        To Ltas (1-to-1)
        .peak = Get frequency of maximum... 0 0 Parabolic
        .slope = Get slope... 0 1000 1000 4000 energy

        #WRITE TO THE OUTPUT FILE
        fileappend 'outfile$' ,'.peak:3','.slope:3','.cog:3','.spread:3'
        
        #REMOVE OBJECTS
        select Sound 'sound_name$'_part
        if .filtering == 1
            plus Sound 'sound_name$'_part_'.newsamplerate'
            plus Sound 'sound_name$'_part_'.newsamplerate'_band
            plus Spectrum 'sound_name$'_part_'.newsamplerate'_band
            plus Ltas 'sound_name$'_part_'.newsamplerate'_band
            #plus Sound 'sound_name$'_part_band
            #plus Spectrum 'sound_name$'_part_band
            #plus Ltas 'sound_name$'_part_band
        else
            plus Spectrum 'sound_name$'_part
            plus Ltas 'sound_name$'_part
        endif
        Remove
       
        #SHOW THE NUMBERS IF THIS IS RUNNING IN THE GUI
        if interactive_session == 1
            echo 
            printline 'transport.phone$' 'transport.phone_start' '.peak' '.slope' '.cog' '.spread'
        endif
    endif

endproc

#######################################################################################
# PROCEDURE: spec_window(num_windows=9,window_size=0.03,skip_band=0,band_low=500,band_high=11000,band_smooth=100,cog=0,std=0,skew=0,kurt=0,only_clips=0)
# Calculate various spectral moments
# Defaults to band pass of 500-11000hz unless skip_band = 1
# Defaults to nine 30ms windows with variable overlap, these values can be overridden
# 
# optional arguments: window_n, window_size, skip_band, band_low, band_high, band_smooth, do_cog, do_std, do_skew, do_kurt
# 
# Will not make any spectral measurements unless one of the optional 'do' arguments is set to 1
#
# If the 'only_clips' argument is chosen, no measurements will be taken and the windowed clips will be stored. This option is for interfacing with multitaper_batch.r
#
# EXAMPLE: 'spec_window(cog=1,std=1,skew=1,kurt=1)'
#######################################################################################

procedure spec_window (.argString$)
    
    @parseArgs (.argString$)

    #Defaults
    .window_n = 9
    .window_size = 0.03
    .skip_band = 0
    .band_low = 500
    .band_high = 11000
    .band_smooth = 100
    .do_cog = 0
    .do_std = 0
    .do_skew = 0
    .do_kurt = 0
    .do_clips = 0

    #Set arguments
    for i to parseArgs.n_args        
        if parseArgs.var$[i] == "num_windows"
            .window_n = number(parseArgs.val$[i])        
        elif parseArgs.var$[i] == "window_size"
            if parseArgs.var$[i] >= 1 & isHeader ==1
                exitScript: "please give window size in seconds"
            else
                .window_size = number(parseArgs.val$[i])
            endif

        elif parseArgs.var$[i] == "skip_band"
            if number(parseArgs.val$[i]) != 1 & isHeader == 1
                printline select a value of 1 (to skip band pass); not 'parseArgs.val$[i]'; reverting to default of band-pass
            else
                .skip_band = number(parseArgs.val$[i])
            endif

        elif parseArgs.var$[i] == "band_low"
            if .skip_band > 0
                exitScript: "Cannot set band_low when skip_band is true"
            else
                .band_low = number(parseArgs.val$[i])
            endif

        elif parseArgs.var$[i] == "band_high"
            if .skip_band > 0
                exitScript: "Cannot set band_high when skip_band is true"
            else
                .band_high = number(parseArgs.val$[i])
            endif

        elif parseArgs.var$[i] == "band_smooth"
            .band_smooth= number(parseArgs.val$[i])


        elif parseArgs.var$[i] == "cog"
            if number(parseArgs.val$[i]) != 1 & isHeader == 1
                printline please select a value of 1 (to measure cog); not 'parseArgs.val$[i]'
            else
                .do_cog = number(parseArgs.val$[i])
            endif        

        elif parseArgs.var$[i] == "std"
            if number(parseArgs.val$[i]) != 1 & isHeader == 1
                printline please select a value of 1 (to measure std); not 'parseArgs.val$[i]'
            else
                .do_std = number(parseArgs.val$[i])
            endif  

        elif parseArgs.var$[i] == "skew"
            if number(parseArgs.val$[i]) != 1 & isHeader == 1
                printline please select a value of 1 (to measure skew); not 'parseArgs.val$[i]'
            else
                .do_skew = number(parseArgs.val$[i])
            endif

        elif parseArgs.var$[i] == "kurt"
            if number(parseArgs.val$[i]) != 1 & isHeader == 1
                printline please select a value of 1 (to measure kurtosis); not 'parseArgs.val$[i]'
            else
                .do_kurt = number(parseArgs.val$[i])
            endif  


        elif parseArgs.var$[i] == "only_clips"
            .do_clips = 1

        elif parseArgs.var$[i] != ""
            if isHeader == 1
                .unknown_var$ = parseArgs.var$[i]
                printline skipped unknown argument '.unknown_var$'
            endif
        endif
    endfor

    #Make Header and Measurements

    if isHeader == 1
            if .do_clips = 1
        createDirectory: clipPath$
        endif
        .append_str$ = ""
            for window to .window_n
                    if .do_cog == 1
                        .append_str$ = .append_str$ + ",cog_'window'"
                    endif
                    if .do_std == 1
                        .append_str$ = .append_str$ + ",std_'window'"
                    endif
                    if .do_skew == 1
                        .append_str$ = .append_str$ + ",skew_'window'"
                    endif
                    if .do_kurt == 1
                        .append_str$ = .append_str$ + ",kurt_'window'"
                    endif
            if .do_clips == 1
            .append_str$ = .append_str$ + ",soundPath_'window'"
            .append_str$ = .append_str$ + ",windowBegin_'window'"
            .append_str$ = .append_str$ + ",windowEnd_'window'"
            endif
            endfor
            fileappend 'outfile$' '.append_str$'

    elif isComplete == 1
            printline FINISHED  

    else
            .window_dur = 'transport.phone_end' - 'transport.phone_start'
            .displacement = ('.window_dur' - '.window_size')/('.window_n' - 1)
            .all_windows$ = ""

        # This is probably unnecessary. 
            if .displacement >= .window_size
                #printline 'newline$'Warning: spectral windows have no overlap; you are possibly missing data. (time = 'transport.phone_start:2', window_dur = '.window_dur:5', displacement = '.displacement:5')'newline$'
            endif

            for window to .window_n

                    .window_begin = 'transport.phone_start' + (('window'-1) * '.displacement')
                    .window_end = '.window_begin' + '.window_size'

                    select Sound 'sound_name$'
                    Extract part... '.window_begin' '.window_end' rectangular 1.0 yes
 
            if .do_clips == 0
                        #Bandpass
                        if .skip_band == 0
                            if .band_low >= .band_high
                                    exitScript: "incorrect specifications of band_low ('.band_low') and band_high ('.band_high')"
                            else
                    Filter (pass Hann band): '.band_low', '.band_high', '.band_smooth'
                endif
                        endif

                        To Spectrum... yes
                    
            #Actual Measurements

                    if .do_cog == 1
                            .cog = Get centre of gravity: 2
                            .all_windows$ = .all_windows$ + ",'.cog:0'"
                        endif
                        if .do_std == 1
                            .std = Get standard deviation: 2
                            .all_windows$ = .all_windows$ + ",'.std:0'"
                        endif
                        if .do_skew == 1
                            .skew = Get skewness: 2
                            .all_windows$ = .all_windows$ + ",'.skew:0'"
                        endif
                        if .do_kurt == 1
                            .kurt = Get kurtosis: 2
                            .all_windows$ = .all_windows$ + ",'.kurt:0'"
                        endif
                    


                        #Object Removal
                        select Sound 'sound_name$'_part
                        if .skip_band = 0
                            plus Sound 'sound_name$'_part_band
                            plus Spectrum 'sound_name$'_part_band
                        else
                            plus Spectrum 'sound_name$'_part
                        endif
                        Remove
        else
        timestring$ = "'transport.word_start:1'"
        timestring$ = replace$ (timestring$, ".", "_", 0)
        sound_filename$ = "'sound_name$'_'timestring$'_'transport.word$'_'window'"
        Write to WAV file... 'clipPath$'/'sound_filename$'.wav
        .all_windows$ = .all_windows$ + ",'sound_filename$','.window_begin','.window_end'"
        select Sound 'sound_name$'_part
        Remove
        endif
            endfor

            #Append the output line
            fileappend 'outfile$' '.all_windows$'
    endif
endproc

#######################################################################################
#                                                                                     #
#            PROCEDURES THAT DEAL WITH PITCH, VOICE QUALITY, OR INTENSITY             #
#                                                                                     #
#######################################################################################

#######################################################################################
# PROCEDURE: intensity(min_pitch=100,time_step=0.0,subtract_mean=yes,measurements=31,pad=0.025,lastphone=no,nextphone=no,filter_low=0,filter_high)
# measure intensity at many time points
# clips will only be filtered if filter_low or filter_high arguments are specified. 
# (0,22050 are defaults if only one is specified)
#
# EXAMPLE: 'intensity(measurements=11)' [to measure at 0%, 10%, ... , 100% of duration]
#######################################################################################

procedure intensity (.argString$)

    @parseArgs (.argString$)
   
    .min_pitch = 100
    .time_step = 0.0
    .subtract_mean$ = "yes"
    .mps = 31
    .pad = 0.025
    .lastphone$ = "no"
    .nextphone$ = "no"
    .filter_low = 0
    .filter_high = 22050
    .filtering = 0

    for i to parseArgs.n_args
        if parseArgs.var$[i] == "min_pitch"
            .min_pitch = number(parseArgs.val$[i])
        elif parseArgs.var$[i] == "time_step"
            .time_step = number(parseArgs.val$[i])
        elif parseArgs.var$[i] == "subtract_mean"
            .subtract_mean = parseArgs.val$[i]
        elif parseArgs.var$[i] == "measurements"
            .mps = number(parseArgs.val$[i])
        elif parseArgs.var$[i] == "pad"
            .pad = number(parseArgs.val$[i])
        elif parseArgs.var$[i] == "lastphone"
            .lastphone$ = parseArgs.val$[i]
        elif parseArgs.var$[i] == "nextphone"
            .nextphone$ = parseArgs.val$[i]
        elif parseArgs.var$[i] == "filter_low"
            .filter_low = number(parseArgs.val$[i])
            .filtering = 1
        elif parseArgs.var$[i] == "filter_high"
            .filter_high = number(parseArgs.val$[i])
            .filtering = 1
        elif parseArgs.var$[i] != ""
            if isHeader == 1
                .unknown_var$ = parseArgs.var$[i]
                printline skipped unknown argument '.unknown_var$'
            endif
        endif
    endfor

    if isHeader = 1 
        printline intensity ('.argString$')
        .intensityheader$ = ",first_measure,last_measure,step"
        #fileappend 'outfile$' ,first_measure,last_measure,step
        if .filtering == 1
            printline band filtering between '.filter_low' and '.filter_high' Hz 
        endif
        for .mp to .mps
            .mpct = round(1000*(.mp-1)/(.mps-1))
            .intensityheader$ = .intensityheader$ + ",I'.mp'"
            #fileappend 'outfile$' ,I'.mp'
        endfor
        fileappend 'outfile$' '.intensityheader$'
    elif isComplete == 1
        printline FINISHED  
    else
        .windowpad = 1.6/.min_pitch + 0.1

        if .lastphone$ == "yes" or .lastphone$ == "true"
            .first_measure = transport.lastphone_start - .pad
        else
            .first_measure = transport.phone_start - .pad
        endif

        if .nextphone$ == "yes" or .nextphone$ == "true"
            .last_measure = transport.nextphone_end + .pad
        else
            #printline only target phone
            .last_measure = transport.phone_end + .pad
        endif
            
        select Sound 'sound_name$'
        Extract part... '.first_measure'-'.windowpad' '.last_measure'+'.windowpad' rectangular 1.0 yes
        if .filtering == 1
            Filter (pass Hann band): '.filter_low', '.filter_high', 100
        endif    

        To Intensity: '.min_pitch', '.time_step', .subtract_mean$

        .measurement_step_size = (.last_measure-.first_measure)/(.mps-1)

        .intensity_data$ = ",'.first_measure','.last_measure','.measurement_step_size'"
        #fileappend 'outfile$' ,'.first_measure','.last_measure','.measurement_step_size'
        for .mp to .mps
            .measure_time = .first_measure + .measurement_step_size*(.mp-1)
            .intensity = Get value at time: .measure_time, "Cubic"
            .intensity_data$ = .intensity_data$ + ",'.intensity'"
            #fileappend 'outfile$' ,'.intensity'
        endfor
        fileappend 'outfile$' '.intensity_data$'
        
        # REMOVE OBJECTS WE'RE FINISHED WITH
        select Sound 'sound_name$'_part
        if .filtering == 1
            plus Sound 'sound_name$'_part_band
            plus Intensity 'sound_name$'_part_band
        else
            plus Intensity 'sound_name$'_part
        endif
        Remove

    endif
endproc


#######################################################################################
# PROCEDURE: harmonicity(from_time=0,to_time=1,from_freq=0,to_freq=11025)
# measure harmonics-to-noise ratio
#
# EXAMPLE: 'harmonicity(from_time=0.2,to_time=0.8)' [to measure the middle 60% of the interval]
#######################################################################################

procedure harmonicity (.argString$)

    @parseArgs (.argString$)
    .from_time = 0
    .to_time = 1
    .from_freq = 0
    .to_freq = 11025

    for i to parseArgs.n_args
        if parseArgs.var$[i] == "from_time"
            .from_time = number(parseArgs.val$[i])
        elif parseArgs.var$[i] == "to_time"
            .to_time = number(parseArgs.val$[i]) 
        elif parseArgs.var$[i] == "from_freq"
            .from_freq = number(parseArgs.val$[i])
        elif parseArgs.var$[i] == "to_freq"
            .to_freq = number(parseArgs.val$[i])
        elif parseArgs.var$[i] != ""
            if isHeader == 1
                .unknown_var$ = parseArgs.var$[i]
                printline skipped unknown argument '.unknown_var$'
            endif
        endif
    endfor

    if isHeader = 1 
        fileappend 'outfile$' ,harmonicity
    elif isComplete == 1
        printline FINISHED  
    else
        select Sound 'sound_name$'
        .extract_start = transport.phone_start - 0.05
        .extract_end = transport.phone_start + 0.05
        Extract part... .extract_start .extract_end rectangular 1.0 yes
        To Harmonicity (cc): 0.01, 75, 0.1, 4.5
        .mean_hnr = Get mean: transport.phone_start + transport.duration*.from_time, transport.phone_start + transport.duration*.to_time
        
        fileappend 'outfile$' ,'.mean_hnr:3'
        plus Sound 'sound_name$'_part
        #plus Sound 'sound_name$'_part_band
        Remove

        if interactive_session == 1
            echo 
            printline 'transport.phone$' 'transport.phone_start' '.mean_hnr'

        endif
    endif

endproc

#######################################################################################
# PROCEDURE: harmonicities(measurements=41,lastphone=no,nextphone=no,release=no,filter_low=0,filter_high=22050)
# measure harmonics-to-noise ratio at many time points
# clips will only be filtered if filter_low or filter_high arguments are specified. 
# (0,22050 are defaults if only one is specified)
# "release=yes" argument targets stop/affricate releases in a non-obvious way
#
# EXAMPLE: 'harmonicities(measurements=11)' [to measure at 0%, 10%, ... , 100% of duration]
#######################################################################################

procedure harmonicities (.argString$)

    @parseArgs (.argString$)
   
    #.min_pitch = 100
    #.time_step = 0.0
    .mps = 41
    #.pad = 0.0
    .lastphone$ = "no"
    .nextphone$ = "no"
    .release$ = "no"
    .filter_low = 0
    .filter_high = 22050
    .filtering = 0

    for i to parseArgs.n_args
        if parseArgs.var$[i] == "measurements"
            .mps = number(parseArgs.val$[i])
        elif parseArgs.var$[i] == "lastphone"
            .lastphone$ = parseArgs.val$[i]
        elif parseArgs.var$[i] == "nextphone"
            .nextphone$ = parseArgs.val$[i]
        elif parseArgs.var$[i] == "release"
            .release$ = parseArgs.val$[i]
        elif parseArgs.var$[i] == "filter_low"
            .filter_low = number(parseArgs.val$[i])
            .filtering = 1
        elif parseArgs.var$[i] == "filter_high"
            .filter_high = number(parseArgs.val$[i])
            .filtering = 1
        elif parseArgs.var$[i] != ""
            if isHeader == 1
                .unknown_var$ = parseArgs.var$[i]
                printline skipped unknown argument '.unknown_var$'
            endif
        endif
    endfor

    if isHeader = 1 
        printline harmonicities ('.argString$')
        if .filtering == 1
            printline band filtering between '.filter_low' and '.filter_high' Hz 
        endif

        .harmonicityheader$ = ",first_measure,last_measure,step"
        if .release$ == "yes"   
            .harmonicityheader$ = .harmonicityheader$ + ",rel_time,asp_start,vowel_start,vowel_end,vowel_label"
        endif
        for .mp to .mps
            .mpct = round(1000*(.mp-1)/(.mps-1))
            .harmonicityheader$ = .harmonicityheader$ + ",H'.mp'"
        endfor
        fileappend 'outfile$' '.harmonicityheader$'
    elif isComplete == 1
        printline FINISHED  
    else
        #.windowpad = 1.6/.min_pitch + 0.1
        .windowpad = 0.1

        if .release$ == "yes"
            .first_measure = transport.phone_start
            .rel_time = transport.phone_end
            if transport.nextphone$ == "rel"                
                if transport.nextphone1$ == "asp"
                    .asp_start = transport.nextphone_end
                    .vowel_start = transport.nextphone1_end
                    .vowel_end = transport.nextphone2_end
                    .vowel_label$ = transport.nextphone2$
                    .last_measure = transport.nextphone2_end
                else
                    .asp_start = undefined
                    .vowel_start = transport.nextphone_end
                    .vowel_end = transport.nextphone1_end 
                    .vowel_label$ = transport.nextphone1$
                    .last_measure = transport.nextphone1_end
                endif
            else
                .asp_start = undefined
                .vowel_start = transport.phone_end
                .vowel_end = transport.nextphone_end
                .vowel_label$ = transport.nextphone$
                .last_measure = transport.nextphone_end
            endif
            #if .vowel_label$ == "#"
            #    .vowel_label$ = wordboundary$
            #endif
        else
            if .lastphone$ == "yes" or .lastphone$ == "true"
                .first_measure = transport.lastphone_start
            else
                .first_measure = transport.phone_start
            endif

            if .nextphone$ == "yes" or .nextphone$ == "true"
                .last_measure = transport.nextphone_end
            else
                #printline only target phone
                .last_measure = transport.phone_end
            endif
        endif
            
        select Sound 'sound_name$'
        Extract part... '.first_measure'-'.windowpad' '.last_measure'+'.windowpad' rectangular 1.0 yes
        if .filtering == 1
            Filter (pass Hann band): '.filter_low', '.filter_high', 100
        endif  
        To Harmonicity (cc): 0.01, 75, 0.1, 4.5

        .measurement_step_size = (.last_measure-.first_measure)/(.mps-1)

        .harmonicity_data$ = ",'.first_measure','.last_measure','.measurement_step_size'"

        if .release$ == "yes"
            .harmonicity_data$ = .harmonicity_data$ + ",'.rel_time','.asp_start','.vowel_start','.vowel_end',"+.vowel_label$
        endif

        #fileappend 'outfile$' ,'.first_measure','.last_measure','.measurement_step_size'
        for .mp to .mps
            .measure_time = .first_measure + .measurement_step_size*(.mp-1)
            .harmonicity = Get value at time: .measure_time, "Cubic"
            #if .harmonicity == -200
            #    .harmonicity = undefined
            #endif
            .harmonicity_data$ = .harmonicity_data$ + ",'.harmonicity'"
        endfor
        fileappend 'outfile$' '.harmonicity_data$'
        
        # REMOVE OBJECTS WE'RE FINISHED WITH
        select Sound 'sound_name$'_part
        if .filtering == 1
            plus Sound 'sound_name$'_part_band
            plus Harmonicity 'sound_name$'_part_band
        else
            plus Harmonicity 'sound_name$'_part
        endif
        Remove

    endif
endproc

#######################################################################################
# PROCEDURE: cppss(measurements=41,lastphone=no,nextphone=no,release=no,filter_low=0,filter_high=22050,window=0.05)
# measure Cepstral Peak Prominence (smoothed) at many time points
# clips will only be filtered if filter_low or filter_high arguments are specified. 
# (0,22050 are defaults if only one is specified)
# "release=yes" argument targets stop/affricate releases in a non-obvious way
#
# EXAMPLE: 'cppss(measurements=11)' [to measure at 0%, 10%, ... , 100% of duration]
#######################################################################################

procedure cppss (.argString$)

    @parseArgs (.argString$)
   
    #.min_pitch = 100
    #.time_step = 0.0
    .mps = 41
    #.pad = 0.0
    .lastphone$ = "no"
    .nextphone$ = "no"
    .release$ = "no"
    .filter_low = 0
    .filter_high = 22050
    .filtering = 0
    .window = 0.05

    for i to parseArgs.n_args
        if parseArgs.var$[i] == "measurements"
            .mps = number(parseArgs.val$[i])
        elif parseArgs.var$[i] == "lastphone"
            .lastphone$ = parseArgs.val$[i]
        elif parseArgs.var$[i] == "nextphone"
            .nextphone$ = parseArgs.val$[i]
        elif parseArgs.var$[i] == "release"
            .release$ = parseArgs.val$[i]
        elif parseArgs.var$[i] == "filter_low"
            .filter_low = number(parseArgs.val$[i])
            .filtering = 1
        elif parseArgs.var$[i] == "filter_high"
            .filter_high = number(parseArgs.val$[i])
            .filtering = 1
        elif parseArgs.var$[i] == "window"
            .window = number(parseArgs.val$[i])
        elif parseArgs.var$[i] != ""
            if isHeader == 1
                .unknown_var$ = parseArgs.var$[i]
                printline skipped unknown argument '.unknown_var$'
            endif
        endif
    endfor
    
    .halfwindow = .window/2

    if isHeader = 1 
        printline cppss ('.argString$')
        if .filtering == 1
            printline band filtering between '.filter_low' and '.filter_high' Hz 
        endif

        .cppsheader$ = ",first_measure,last_measure,step"
        if .release$ == "yes"   
            .cppsheader$ = .cppsheader$ + ",rel_time,asp_start,vowel_start,vowel_end,vowel_label"
        endif
        for .mp to .mps
            .mpct = round(1000*(.mp-1)/(.mps-1))
            .cppsheader$ = .cppsheader$ + ",C'.mp'"
        endfor
        fileappend 'outfile$' '.cppsheader$'
    elif isComplete == 1
        printline FINISHED  
    else
        #.windowpad = 1.6/.min_pitch + 0.1
        .windowpad = 0.1

        if .release$ == "yes"
            .first_measure = transport.phone_start
            .rel_time = transport.phone_end
            if transport.nextphone$ == "rel"                
                if transport.nextphone1$ == "asp"
                    .asp_start = transport.nextphone_end
                    .vowel_start = transport.nextphone1_end
                    .vowel_end = transport.nextphone2_end
                    .vowel_label$ = transport.nextphone2$
                    .last_measure = transport.nextphone2_end
                else
                    .asp_start = undefined
                    .vowel_start = transport.nextphone_end
                    .vowel_end = transport.nextphone1_end 
                    .vowel_label$ = transport.nextphone1$
                    .last_measure = transport.nextphone1_end
                endif
            else
                .asp_start = undefined
                .vowel_start = transport.phone_end
                .vowel_end = transport.nextphone_end
                .vowel_label$ = transport.nextphone$
                .last_measure = transport.nextphone_end
            endif
            #if .vowel_label$ == "#"
            #    .vowel_label$ = wordboundary$
            #endif
        else
            if .lastphone$ == "yes" or .lastphone$ == "true"
                .first_measure = transport.lastphone_start
            else
                .first_measure = transport.phone_start
            endif

            if .nextphone$ == "yes" or .nextphone$ == "true"
                .last_measure = transport.nextphone_end
            else
                #printline only target phone
                .last_measure = transport.phone_end
            endif
        endif
            
        select Sound 'sound_name$'
        # Extract part... '.first_measure'-'.windowpad' '.last_measure'+'.windowpad' rectangular 1.0 yes
        # if .filtering == 1
        #     Filter (pass Hann band): '.filter_low', '.filter_high', 100
        # endif  
        # To Harmonicity (cc): 0.01, 75, 0.1, 4.5

        .measurement_step_size = (.last_measure-.first_measure)/(.mps-1)

        .cpps_data$ = ",'.first_measure','.last_measure','.measurement_step_size'"

        if .release$ == "yes"
            .cpps_data$ = .cpps_data$ + ",'.rel_time','.asp_start','.vowel_start','.vowel_end',"+.vowel_label$
        endif

        #fileappend 'outfile$' ,'.first_measure','.last_measure','.measurement_step_size'
        for .mp to .mps
            .measure_time = .first_measure + .measurement_step_size*(.mp-1)
            selectObject: "Sound 'sound_name$'"
            Extract part... '.measure_time'-'.halfwindow' '.measure_time'+'.halfwindow' rectangular 1.0 yes
            To PowerCepstrogram: 60, 0.002, 5000, 50
            .cpps = Get CPPS: "yes", 0.001, 5e-05, 60, 330, 0.05, "Parabolic", 0.001, 0, "Exponential decay", "Robust"
            plusObject: "Sound 'sound_name$'_part"
            Remove
            # .harmonicity = Get value at time: .measure_time, "Cubic"
            # .harmonicity_data$ = .harmonicity_data$ + ",'.harmonicity'"
            .cpps_data$ = .cpps_data$ + ",'.cpps'"
        endfor
        fileappend 'outfile$' '.cpps_data$'
        
        # REMOVE OBJECTS WE'RE FINISHED WITH
        # select Sound 'sound_name$'_part
        # if .filtering == 1
        #     plus Sound 'sound_name$'_part_band
        #     plus Harmonicity 'sound_name$'_part_band
        # else
        #     plus Harmonicity 'sound_name$'_part
        # endif
        # Remove

    endif
endproc

#######################################################################################
# PROCEDURE: pitches(measurements=41,lastphone=no,nextphone=no,release=no,pitch_floor=75,pitch_ceiling=300,male_pitch_floor=75,male_pitch_ceiling=300)
# measure F0 at many time points
# sounds will be filtered at 0, 22050
# "release=yes" argument targets stop/affricate releases in a non-obvious way
#
# EXAMPLE: 'pitches(measurements=11)' [to measure at 0%, 10%, ... , 100% of duration]
#######################################################################################

procedure pitches (.argString$)

    @parseArgs (.argString$)
    .time_step = 0.0
    .pitch_floor = 75
    .pitch_ceiling = 300
    .mps = 41
    #.pad = 0.0
    .lastphone$ = "no"
    .nextphone$ = "no"
    .release$ = "no"
    .filter_low = 0
    .filter_high = 22050
    .filtering = 0

    for i to parseArgs.n_args
        if parseArgs.var$[i] == "measurements"
            .mps = number(parseArgs.val$[i])
        elif parseArgs.var$[i] == "lastphone"
            .lastphone$ = parseArgs.val$[i]
        elif parseArgs.var$[i] == "nextphone"
            .nextphone$ = parseArgs.val$[i]
        elif parseArgs.var$[i] == "release"
            .release$ = parseArgs.val$[i]
        elif parseArgs.var$[i] == "pitch_floor"
            .pitch_floor = number(parseArgs.val$[i])
        elif parseArgs.var$[i] == "pitch_ceiling"
            .pitch_ceiling = number(parseArgs.val$[i])
        elif parseArgs.var$[i] == "male_pitch_floor"
            if gender$ == "male"
                .pitch_floor = number(parseArgs.val$[i])
            endif
        elif parseArgs.var$[i] == "male_pitch_ceiling"
            if gender$ == "male"
                .pitch_ceiling = number(parseArgs.val$[i])
            endif
        elif parseArgs.var$[i] != ""
            if isHeader == 1
                .unknown_var$ = parseArgs.var$[i]
                printline skipped unknown argument '.unknown_var$'
            endif
        endif
    endfor

    if isHeader = 1 
        printline pitches ('.argString$')
        if .filtering == 1
            printline band filtering between '.filter_low' and '.filter_high' Hz 
        endif

        .pitchheader$ = ",first_measure,last_measure,step"
        if .release$ == "yes"   
            .pitchheader$ = .pitchheader$ + ",rel_time,asp_start,vowel_start,vowel_end,vowel_label"
        endif
        for .mp to .mps
            .mpct = round(1000*(.mp-1)/(.mps-1))
            .pitchheader$ = .pitchheader$ + ",P'.mp'"
        endfor
        fileappend 'outfile$' '.pitchheader$'
    elif isComplete == 1
        printline FINISHED  
    else
        #.windowpad = 1.6/.min_pitch + 0.1
        .windowpad = 0.1

        if .release$ == "yes"
            .first_measure = transport.phone_start
            .rel_time = transport.phone_end
            if transport.nextphone$ == "rel"                
                if transport.nextphone1$ == "asp"
                    .asp_start = transport.nextphone_end
                    .vowel_start = transport.nextphone1_end
                    .vowel_end = transport.nextphone2_end
                    .vowel_label$ = transport.nextphone2$
                    .last_measure = transport.nextphone2_end
                else
                    .asp_start = undefined
                    .vowel_start = transport.nextphone_end
                    .vowel_end = transport.nextphone1_end 
                    .vowel_label$ = transport.nextphone1$
                    .last_measure = transport.nextphone1_end
                endif
            else
                .asp_start = undefined
                .vowel_start = transport.phone_end
                .vowel_end = transport.nextphone_end
                .vowel_label$ = transport.nextphone$
                .last_measure = transport.nextphone_end
            endif
            #if .vowel_label$ == "#"
            #    .vowel_label$ = wordboundary$
            #endif
        else
            if .lastphone$ == "yes" or .lastphone$ == "true"
                .first_measure = transport.lastphone_start
            else
                .first_measure = transport.phone_start
            endif

            if .nextphone$ == "yes" or .nextphone$ == "true"
                .last_measure = transport.nextphone_end
            else
                #printline only target phone
                .last_measure = transport.phone_end
            endif
        endif
            
        select Sound 'sound_name$'
        Extract part... '.first_measure'-'.windowpad' '.last_measure'+'.windowpad' rectangular 1.0 yes
        if .filtering == 1
            Filter (pass Hann band): '.filter_low', '.filter_high', 100
        endif  
        #printline speaker listed as 'gender$': using pitch range of '.pitch_floor'-'.pitch_ceiling'
        To Pitch: .time_step, .pitch_floor, .pitch_ceiling

        .measurement_step_size = (.last_measure-.first_measure)/(.mps-1)

        .pitch_data$ = ",'.first_measure','.last_measure','.measurement_step_size'"

        if .release$ == "yes"
            .pitch_data$ = .pitch_data$ + ",'.rel_time','.asp_start','.vowel_start','.vowel_end',"+.vowel_label$
        endif

        #fileappend 'outfile$' ,'.first_measure','.last_measure','.measurement_step_size'
        for .mp to .mps
            .measure_time = .first_measure + .measurement_step_size*(.mp-1)
            .pitch = Get value at time: .measure_time, "Hertz", "Linear"
            .pitch_data$ = .pitch_data$ + ",'.pitch'"
        endfor
        fileappend 'outfile$' '.pitch_data$'
        
        # REMOVE OBJECTS WE'RE FINISHED WITH
        select Sound 'sound_name$'_part
        if .filtering == 1
            plus Sound 'sound_name$'_part_band
            plus Pitch 'sound_name$'_part_band
        else
            plus Pitch 'sound_name$'_part
        endif
        Remove

    endif
endproc

#######################################################################################
# PROCEDURE: harmonicity_rise()
# find the time when harmonicity is rising fastest (may be the onset of voicing)
# "release" argument targets stop/affricate releases in a non-obvious way
#
# EXAMPLE: 'harmonicity_rise()'
#######################################################################################

procedure harmonicity_rise (.argString$)

    if isHeader = 1 
        fileappend 'outfile$' ,harmonicity_delta_max,hdm_time,hdm_rel_time,harmonicity_delta_max2,hdm_time2,hdm_rel_time2
    elif isComplete == 1
        printline FINISHED  
    else
        select Sound 'sound_name$'
        Extract part: transport.phone_start, transport.nextphone_end, "rectangular", 1, "yes"
        To Harmonicity (cc): 0.001, 75, 0.1, 1
        Formula: "self [col+1] - self [col]"
        .harmonicity_delta_max = Get maximum: 0, 0, "Parabolic"
        .harmonicity_delta_max_time = Get time of maximum: 0, 0, "Parabolic"
        if .harmonicity_delta_max_time > transport.phone_end
            .harmonicity_delta_max_rel_time = (.harmonicity_delta_max_time - transport.phone_end) / (transport.nextphone_end - transport.phone_end)
        else
            .harmonicity_delta_max_rel_time = (.harmonicity_delta_max_time - transport.phone_end) / (transport.phone_end - transport.phone_start)
        endif
        Remove
        select Sound 'sound_name$'
        Extract part: transport.phone_start+transport.duration/2, transport.nextphone_end+0.05, "rectangular", 1, "yes"
        To Harmonicity (cc): 0.001, 75, 0.1, 1
        Formula: "self [col+1] - self [col]"
        .harmonicity_delta_max2 = Get maximum: 0, 0, "Parabolic"
        .harmonicity_delta_max_time2 = Get time of maximum: 0, 0, "Parabolic"
        if .harmonicity_delta_max_time2 > transport.phone_end
            .harmonicity_delta_max_rel_time2 = (.harmonicity_delta_max_time - transport.phone_end) / (transport.nextphone_end - transport.phone_end)
        else
            .harmonicity_delta_max_rel_time2 = (.harmonicity_delta_max_time - transport.phone_end) / (transport.phone_end - transport.phone_start)
        endif
        fileappend 'outfile$' ,'.harmonicity_delta_max:3','.harmonicity_delta_max_time:3','.harmonicity_delta_max_rel_time:3','.harmonicity_delta_max2:3','.harmonicity_delta_max_time2:3','.harmonicity_delta_max_rel_time2:3'
        Remove
    endif

endproc

#######################################################################################
# PROCEDURE: voice_report(pitch_floor=75,pitch_ceiling=500)
# make many voice quality measurements
#
# EXAMPLE: 'voice_report()' [to use default pitch range]
# EXAMPLE: 'voice_report(pitch_floor=100,pitch_ceiling=600)' [to set a custom pitch range]
#######################################################################################

procedure voice_report (.argString$)

    @parseArgs (.argString$)
    .pitch_floor = 75
    .pitch_ceiling = 500

    for i to parseArgs.n_args
        if parseArgs.var$[i] == "pitch_floor"
            .pitch_floor = number(parseArgs.val$[i])
        elif parseArgs.var$[i] == "pitch_ceiling"
            .pitch_ceiling = number(parseArgs.val$[i]) 
        elif parseArgs.var$[i] != ""
            if isHeader == 1
                .unknown_var$ = parseArgs.var$[i]
                printline skipped unknown argument '.unknown_var$'
            endif
        endif
    endfor

    if csv_pitch_floor != undefined
        .pitch_floor = csv_pitch_floor
    endif
    if csv_pitch_ceiling != undefined
        .pitch_ceiling = csv_pitch_ceiling
    endif

    if isHeader = 1 
        fileappend 'outfile$' ,pitch_floor,pitch_ceiling,median_pitch,mean_pitch,standard_deviation_of_pitch,minimum_pitch,maximum_pitch,number_of_pulses,number_of_periods,mean_period,standard_deviation_of_period,unvoiced_rate,unvoiced_numerator,unvoiced_denominator,number_of_voice_breaks,degree_of_voice_breaks,jitter_local,jitter_local_absolute,jitter_rap,jitter_ppq5,jitter_ddp,shimmer_local,shimmer_local_db,shimmer_apq3,shimmer_apq5,shimmer_apq11,shimmer_dda,mean_autocorrelation,mean_noise_to_harmonics_ratio,mean_harmonics_to_noise_ratio
    elif isComplete == 1
        printline FINISHED  
    else
        # make the Pitch object
        selectObject: "Sound 'sound_name$'"

        .extract_start = max(0, transport.phone_start-0.1)
        .extract_end = transport.phone_end+0.1
        Extract part: .extract_start, .extract_end, "rectangular", 1.0, "yes"
        To Pitch (ac): 0, .pitch_floor, 15, "no", 0.03, 0.45, 0.01, 0.35, 0.14, .pitch_ceiling

        # make the PointProcess object

        selectObject: "Sound 'sound_name$'_part"
        plusObject: "Pitch 'sound_name$'_part"
        To PointProcess (cc)
        Rename: "'sound_name$'_part"

        # make the Voice report

        selectObject: "Sound 'sound_name$'_part"
        plusObject: "Pitch 'sound_name$'_part"
        plusObject: "PointProcess 'sound_name$'_part"
        voiceReport$ = Voice report: transport.phone_start, transport.phone_end, .pitch_floor, .pitch_ceiling, 1.3, 1.6, 0.03, 0.45

        # extract all the numbers from the Voice report

        .median_pitch = extractNumber (voiceReport$, "Median pitch: ")
        .mean_pitch = extractNumber (voiceReport$, "Mean pitch: ")
        .standard_deviation_of_pitch = extractNumber (voiceReport$, "Standard deviation: ")
        .minimum_pitch = extractNumber (voiceReport$, "Minimum pitch: ")
        .maximum_pitch = extractNumber (voiceReport$, "Maximum pitch: ")
        .number_of_pulses = extractNumber (voiceReport$, "Number of pulses: ")
        .number_of_periods = extractNumber (voiceReport$, "Number of periods: ")
        .mean_period = extractNumber (voiceReport$, "Mean period: ")
        .standard_deviation_of_period = extractNumber (voiceReport$, "Standard deviation of period: ")
        .unvoiced_rate = extractNumber (voiceReport$, "Fraction of locally unvoiced frames: ")
        .unvoiced_numerator = extractNumber (voiceReport$, "Fraction of locally unvoiced frames: "+percent$ (.unvoiced_rate, 3)+"   (")
        .unvoiced_denominator = extractNumber (voiceReport$, "Fraction of locally unvoiced frames: "+percent$ (.unvoiced_rate, 3)+"   ('.unvoiced_numerator' / ")
        .number_of_voice_breaks = extractNumber (voiceReport$, "Number of voice breaks: ")
        .degree_of_voice_breaks = extractNumber (voiceReport$, "Degree of voice breaks: ")
        .jitter_local = extractNumber (voiceReport$, "Jitter (local): ")
        .jitter_local_absolute = extractNumber (voiceReport$, "Jitter (local, absolute): ")
        .jitter_rap = extractNumber (voiceReport$, "Jitter (rap): ")
        .jitter_ppq5 = extractNumber (voiceReport$, "Jitter (ppq5): ")
        .jitter_ddp = extractNumber (voiceReport$, "Jitter (ddp): ")
        .shimmer_local = extractNumber (voiceReport$, "Shimmer (local): ")
        .shimmer_local_db = extractNumber (voiceReport$, "Shimmer (local, dB): ")
        .shimmer_apq3 = extractNumber (voiceReport$, "Shimmer (apq3): ")
        .shimmer_apq5 = extractNumber (voiceReport$, "Shimmer (apq5): ")
        .shimmer_apq11 = extractNumber (voiceReport$, "Shimmer (apq11): ")
        .shimmer_dda = extractNumber (voiceReport$, "Shimmer (dda): ")
        .mean_autocorrelation = extractNumber (voiceReport$, "Mean autocorrelation: ")
        .mean_noise_to_harmonics_ratio = extractNumber (voiceReport$, "Mean noise-to-harmonics ratio: ")
        .mean_harmonics_to_noise_ratio = extractNumber (voiceReport$, "Mean harmonics-to-noise ratio: ")
        
        fileappend 'outfile$' ,'.pitch_floor','.pitch_ceiling','.median_pitch','.mean_pitch','.standard_deviation_of_pitch','.minimum_pitch','.maximum_pitch','.number_of_pulses','.number_of_periods','.mean_period','.standard_deviation_of_period','.unvoiced_rate','.unvoiced_numerator','.unvoiced_denominator','.number_of_voice_breaks','.degree_of_voice_breaks','.jitter_local','.jitter_local_absolute','.jitter_rap','.jitter_ppq5','.jitter_ddp','.shimmer_local','.shimmer_local_db','.shimmer_apq3','.shimmer_apq5','.shimmer_apq11','.shimmer_dda','.mean_autocorrelation','.mean_noise_to_harmonics_ratio','.mean_harmonics_to_noise_ratio'

        selectObject: "Sound 'sound_name$'_part"
        plusObject: "Pitch 'sound_name$'_part"
        plusObject: "PointProcess 'sound_name$'_part"
        Remove

        if interactive_session == 1
            echo 
            printline 'transport.phone$' 'transport.phone_start' '.median_pitch','.mean_pitch','.standard_deviation_of_pitch','.minimum_pitch','.maximum_pitch','.number_of_pulses','.number_of_periods','.mean_period','.standard_deviation_of_period','.unvoiced_rate','.unvoiced_numerator','.unvoiced_denominator','.number_of_voice_breaks','.degree_of_voice_breaks','.jitter_local','.jitter_local_absolute','.jitter_rap','.jitter_ppq5','.jitter_ddp','.shimmer_local','.shimmer_local_db','.shimmer_apq3','.shimmer_apq5','.shimmer_apq11','.shimmer_dda','.mean_autocorrelation','.mean_noise_to_harmonics_ratio','.mean_harmonics_to_noise_ratio'
        endif
    endif
endproc

#######################################################################################
#                                                                                     #
#                          PROCEDURES THAT MEASURE FORMANTS                           #
#                                                                                     #
#######################################################################################

#######################################################################################
# utility functions for measuring formants
#######################################################################################

procedure subtractMu (.phone$, .token_name$)

    #FIND THE MEANS FOR THIS PHONE
    selectObject: "Table phone_means"
    Extract rows where column (text): "phone", "is equal to", .phone$
    Remove column: "phone"
    Rename: .phone$+"_means"

    #SUBTRACT THE MEAN FROM THE TOKEN MEASUREMENTS
    .phonemeans$ = .phone$+"_means"

    selectObject: "Table "+.phonemeans$
    plusObject: "Table "+.token_name$
    Append
    Down to Matrix
    Transpose
    To TableOfReal
    To Table: "dummy"
    Remove column: "dummy"
    Rename: "x_minus_mu"
    Set column label (index): 1, "mu"
    Set column label (index): 2, "x"

    #THIS ALTERNATIVE TO Append difference column IS NECESSARY TO CATCH UNDEFINED VALUES
    #Append difference column: "x", "mu", "diff"
    Append column: "diff"
    .x_mu_size = Get number of rows
    for .i to .x_mu_size
        .row_x = Get value: '.i', "x"
        .row_mu = Get value: '.i', "mu"
        if .row_mu == undefined
            .row_diff = 9999
            #printline WARNING: USED 9999 BECAUSE OF UNDEFINED MU VALUE
            #print m
        else
            .row_diff = .row_x - .row_mu
        endif
        Set numeric value: .i, "diff", .row_diff
    endfor

    #REMOVE OBJECTS
    selectObject: "Table appended"
    plusObject: "Matrix appended"
    plusObject: "Matrix appended_transposed"
    plusObject: "TableOfReal appended_transposed"
    plusObject: "Table "+.phonemeans$
    Remove

endproc

##############

procedure mahalanobis (.phone$, .token_name$)

    #FIND THE DIFFERENCE BETWEEN THE TOKEN MEASUREMENTS AND THE MEANS
    @subtractMu (.phone$, .token_name$)

    #PREPARE THE INVERTED COVARIANCE MATRIX FOR THIS PHONE
    selectObject: "Table phone_matrices"
    Extract rows where column (text): "phone", "is equal to", .phone$
    Remove column: "phone"
    .phonematrix$ = .phone$+"_covmat_inv"
    Rename: .phonematrix$
    selectObject: "Table "+.phonematrix$
    Down to TableOfReal: "rl"
    .covmat_size = Get number of rows

    #CALCULATE MAHALANOBIS DISTANCE
    .mdist2 = 0
    for .i to .covmat_size
        .mdist2_part = 0

        #MULTIPLY THE COLUMN VECTOR BY THE INVERTED COVARIANCE MATRIX
        for .j to .covmat_size
            selectObject: "Table x_minus_mu"
            .diff_j = Get value: '.j', "diff"
            selectObject:  "TableOfReal "+.phonematrix$
            .covmat_ij = Get value: '.i', '.j'
            .mdist2_part = .mdist2_part + .diff_j * .covmat_ij
        endfor

        #THEN MULTIPLY THE RESULT BY THE ROW VECTOR (WITH THE SAME VALUES)
        selectObject: "Table x_minus_mu"
        .diff_i = Get value: '.i', "diff"
        .mdist2 = .mdist2 + .mdist2_part * .diff_i

    endfor

    #MATRIX MULTIPLICATION RESULTS IN THE MAHALANOBIS DISTANCE SQUARED
    .dist = sqrt(.mdist2)

    #REMOVE OBJECTS
    selectObject: "Table "+.phonematrix$
    plusObject: "TableOfReal "+.phonematrix$
    plusObject: "Table x_minus_mu"
    Remove

endproc


procedure outputFormantData(.total_formants, .max_formant)

    #######################################
    # BEGIN MEASURING FROM FORMANT OBJECT #
    #######################################
    #select Sound 'sound_name$'_part_final
    #To Formant (burg)... 0.0 'formants.best_total_formants' 'formants.max_formant' 0.025 50
    #Rename: "final"
    .total_formants_times_ten = .total_formants*10
    .formant_name$ = "'.total_formants_times_ten'_'.max_formant'"
    selectObject: "Formant "+.formant_name$
    Copy: "final"

    if praatVersion <= 6038 or praatVersion==6109
        To FormantModeler: 0, 0, 'formants.int_formants', 3, "Bandwidth"
    else
        To FormantModeler: 0, 0, 'formants.int_formants', 3
    endif
    Rename: "this_model"

    Create Table with column names: "formant_data", 0, formants.formant_data_column_names$

    for .mp to formants.mps+formants.omps*2
        selectObject: "Table formant_data"
        Append row
        Set numeric value: .mp, "mp", .mp

        .mpt = (.mp-1)/(formants.mps-1) - formants.overmeasure
        .measure_t = transport.phone_start + transport.duration * .mpt

        if formants.measure_amplitudes == 1
            selectObject: "Sound 'sound_name$'_part_final"
            # Extract part: .measure_t-0.125, .measure_t+0.125, "rectangular", 1, "yes"
            Extract part: .measure_t-0.0125, .measure_t+0.0125, "rectangular", 1, "yes"
            To Ltas: formants.ltas_bandwidth
        endif

        for .fn to formants.output_formants

            #RECORD FORMANT FREQUENCIES
            selectObject: "Formant final"
            .fv = Get value at time... .fn .measure_t Hertz Linear
            selectObject: "Table formant_data"
            Set numeric value: .mp, "F'.fn'", round(.fv)

            #RECORD FORMANT BANDWIDTHS
            if formants.measure_bandwidths == 1 or formants.measure_amplitudes == 1
                selectObject: "Formant final"                    
                .fb = Get bandwidth at time... .fn .measure_t Hertz Linear
                selectObject: "Table formant_data"
                Set numeric value: .mp, "B'.fn'", round(.fb)
            endif

            #RECORD FORMANT AMPLITUDES
            if formants.measure_amplitudes == 1

                if .fv == undefined
                    selectObject: "Table formant_data"
                    Set numeric value: .mp, "A'.fn'", .fv
                    Set numeric value: .mp, "P'.fn'", .fv
                else
                    #ORIGINAL VERSION: LOOK FOR AN AMPLITUDE WITHIN ONE FORMANT BANDWIDTH, CENTERED ON THE FORMANT FREQUENCY
                    #.arange_low = .fv-.fb/2
                    #.arange_high = .fv+.fb/2

                    #NEWER VERSION: 
                    # - LIMIT THE DISTANCE AWAY FROM THE CENTER TO LOOK FOR A MAXIMUM (EVEN IF THE BANDWIDTH IS LARGE)
                    .hb_up_for_a = min(.fb, formants.max_fb_for_a)/2
                    .hb_down_for_a = .hb_up_for_a

                    # - DON'T GO MORE THAN HALFWAY TOWARD THE CENTER OF ANOTHER FORMANT
                    if .fn < formants.output_formants
                        selectObject: "Formant final"
                        .fv_up = Get value at time... .fn+1 .measure_t Hertz Linear
                        if .fv_up != undefined
                            .hb_up_for_a = min(.hb_up_for_a, (.fv_up-.fv)/2)
                        endif
                    else
                        .fv_up = .fv + 500
                    endif

                    if .fv_up == undefined
                        .fv_up = .fv + 500
                    endif

                    if .fn == 1
                        #TRY TO AVOID F0
                        .fv_down = max(.fv/2, 200)
                    else
                        selectObject: "Formant final"
                        .fv_down = Get value at time... .fn-1 .measure_t Hertz Linear
                    endif
                    if .fv_down != undefined
                        .hb_down_for_a = min(.hb_down_for_a, (.fv-.fv_down)/2)
                    endif

                    .arange_low = .fv-.hb_down_for_a
                    .arange_high = .fv+.hb_up_for_a

                    selectObject: "Ltas 'sound_name$'_part_final_part"
                    #NOW FORMANT AMPLITUDE
                    .fa = Get maximum: .arange_low, .arange_high, "None"

                    #NOW MEASURE ZEROS ABOVE AND BELOW
                    .z_down = Get minimum: .fv_down, .fv, "None"
                    .z_up = Get minimum: .fv, .fv_up, "None"
                    .fp = .fa - min(.z_down, .z_up)

                    selectObject: "Table formant_data"
                    Set numeric value: .mp, "A'.fn'", round(.fa*1000)/1000
                    Set numeric value: .mp, "P'.fn'", round(.fp*1000)/1000
                    Set numeric value: .mp, "T'.fn'", round(.z_down*1000)/1000

                endif
            endif

            #RECORD FORMANT MODELER STATISTICS
            if formants.predict_formants == 1
                selectObject: "FormantModeler this_model"
                .mod_value = Get model value at time: .fn, .measure_t
                #.mod_value_sigma = Get data point sigma: .fn, .mp

                selectObject: "Table formant_data"
                Set numeric value: .mp, "F'.fn'Pr", round(.mod_value)
            endif

        endfor

        if formants.measure_amplitudes == 1
            selectObject: "Sound 'sound_name$'_part_final_part"
            plusObject: "Ltas 'sound_name$'_part_final_part"
            Remove
        endif

    endfor

    #@logtime


    select Table all_metrics
    #.this_row = Search column: "total_formants", "'.total_formants'"
    .tablerows = Get number of rows
    for .r from 1 to .tablerows
        .tf = Get value: .r, "total_formants"
        .mf = Get value: .r, "max_formant"
        if .tf == .total_formants and .mf == .max_formant
            .this_row = .r
        endif
    endfor

    .mdist = Get value: .this_row, "mdist"
    .sos_geom_mean = Get value: .this_row, "sos_geom_mean"
    .residual_energy6 = Get value: .this_row, "energy_ratio"
    .r2_f1 = Get value: .this_row, "r2_f1"
    .r2_f2 = Get value: .this_row, "r2_f2"
    .r2_f3 = Get value: .this_row, "r2_f3"
    .r2_f4 = Get value: .this_row, "r2_f4"
    .r2_f5 = Get value: .this_row, "r2_f5"

    #.formant_data$ = ""
    .formant_data$ = ",'.total_formants','.max_formant','.mdist:3','.sos_geom_mean:0','.residual_energy6:3','.r2_f1:3','.r2_f2:3','.r2_f3:3','.r2_f4:3','.r2_f5:3'"

    selectObject: "Table formant_data"

    if formants.keep_all == 1
        if formants.total_formants == formants.best_total_formants and formants.max_formant == formants.best_max_formant
            .formant_data$ = .formant_data$ + ",1"
        else
            .formant_data$ = .formant_data$ + ",0"
        endif
        
    endif

    for .fn to formants.output_formants
        for .mp to formants.mps+formants.omps*2
            .fv = Get value: .mp, "F'.fn'"
            .formant_data$ = .formant_data$ + ",'.fv'"
        endfor
    endfor

    if formants.measure_bandwidths == 1
        for .fn to formants.output_formants
            for .mp to formants.mps+formants.omps*2
                .fb = Get value: .mp, "B'.fn'"
                .formant_data$ = .formant_data$ + ",'.fb'"
            endfor
        endfor
    endif


    if formants.measure_amplitudes == 1
        for .fn to formants.output_formants
            for .mp to formants.mps+formants.omps*2
                .fa = Get value: .mp, "A'.fn'"
                .formant_data$ = .formant_data$ + ",'.fa'"
            endfor
        endfor
        for .fn to formants.output_formants
            for .mp to formants.mps+formants.omps*2
                .fp = Get value: .mp, "P'.fn'"
                .formant_data$ = .formant_data$ + ",'.fp'"
            endfor
        endfor
        for .fn to formants.output_formants
            for .mp to formants.mps+formants.omps*2
                .fp = Get value: .mp, "T'.fn'"
                .formant_data$ = .formant_data$ + ",'.fp'"
            endfor
        endfor
    endif

    if formants.predict_formants == 1 
        selectObject: "Table formant_data"
        for .fn to .output_formants
            for .mp to formants.mps+formants.omps*2
                .pred_val = Get value: .mp, "F'.fn'Pr"
                .formant_data$ = .formant_data$ + ",'.pred_val'"
            endfor
        endfor
    endif
    
    fileappend 'outfile$' '.formant_data$'
    
    select Formant final
    plus Table formant_data
    plus FormantModeler this_model
    Remove

endproc

#######################################################################################
# PROCEDURE: formants(max_formant=5500(or 5000),total_formants=5.5,output_formants=3,poles_steps=6,poles0=6,measurements=5,pad=0.03,language=English,overmeasure=0,bandwidths=0,amplitudes=0,curves=0,predictions=0,guide="")
# measure formants. defaults to measuring F1-F3 at 25%, 50%, and 75%
# This was called formantz() through one_script_16dev (until 2/23/20).
# needs to be modified to remove residual arguments
#
# optional arguments: max_formant, total_formants, pad, preemphasis
#
# EXAMPLE: 'formants()' [to measure F1, F2, and F3 at 0%, 25%, 50%, 75%, and 100%]
# EXAMPLE: 'formants(output_formants=5,measurements=11' [to also measure F4 and F5, and to measure at 0%, 10%, 20%, ..., 100%]
# EXAMPLE: 'formants(language=Spanish,bandwidths=1)' [to measure Spanish vowels and to output formant bandwidth measurements]
#######################################################################################

procedure formants (.argString$)

    @parseArgs (.argString$)

    .pad = 0.03        
    .total_formants = 5.5
    .mps = 5
    .output_formants = 3
    .mf_steps = 0
    .mf0 = 5500
    # 4.5, 5, 5.5, or 6 formants
    .poles_steps = 3
    .poles0 = 9
    .language$ = "ral"
    .fit_curves = 0
    .predict_formants = 0
    .overmeasure = 0
    .measure_bandwidths = 0
    .measure_amplitudes = 0
    .keep_all = 0
    .preemphasis = 0

    #MAX FORMANT BANDWIDTH TO USE TO LOOK FOR THE PEAK AMPLITUDE
    .max_fb_for_a = 300
    .guidefile$ = ""
                        
    #if gender$ == "male"
    #    .max_formant = 5000
    #else
        .max_formant = 5500
    #endif

    #timelog$ = outfile$ - ".csv" + "_time.csv"

    for i to parseArgs.n_args
        if parseArgs.var$[i] == "max_formant"
            .max_formant = number(parseArgs.val$[i])
        elif parseArgs.var$[i] == "total_formants"
            .total_formants = number(parseArgs.val$[i])
        elif parseArgs.var$[i] == "output_formants"
            .output_formants = number(parseArgs.val$[i])
        elif parseArgs.var$[i] == "poles_steps"
            .poles_steps = number(parseArgs.val$[i])
        elif parseArgs.var$[i] == "poles0"
            .poles0 = number(parseArgs.val$[i])
        elif parseArgs.var$[i] == "mf_steps"
            .mf_steps = number(parseArgs.val$[i])
        elif parseArgs.var$[i] == "mf0"
            .mf0 = number(parseArgs.val$[i])
        elif parseArgs.var$[i] == "measurements"
            .mps = number(parseArgs.val$[i])
        elif parseArgs.var$[i] == "pad"
            .pad = number(parseArgs.val$[i])
        elif parseArgs.var$[i] == "language"
            .language$ = parseArgs.val$[i]
        elif parseArgs.var$[i] == "overmeasure"
            .overmeasure = number(parseArgs.val$[i])
        elif parseArgs.var$[i] == "bandwidths"
            .measure_bandwidths = number(parseArgs.val$[i])
        elif parseArgs.var$[i] == "amplitudes"
            .measure_amplitudes = number(parseArgs.val$[i])
        elif parseArgs.var$[i] == "curves"
            .fit_curves = number(parseArgs.val$[i])
        elif parseArgs.var$[i] == "predictions"
            .predict_formants = number(parseArgs.val$[i])
        elif parseArgs.var$[i] == "guide"
            .guidefile$ = parseArgs.val$[i]
        elif parseArgs.var$[i] == "keep_all"
            .keep_all = number(parseArgs.val$[i])
        elif parseArgs.var$[i] == "preemphasis"
            .preemphasis = number(parseArgs.val$[i])
        elif parseArgs.var$[i] != ""
            if isHeader == 1
                .unknown_var$ = parseArgs.var$[i]
                printline skipped unknown argument '.unknown_var$'
            endif
        endif
    endfor

    .omps = round((.mps-1) * .overmeasure)

    if isHeader = 1 
        printline formants ('.argString$')

        #printline looking for '.total_formants' formants
        printline looking for formants under '.mf0' and 'mf_steps' up
        printline '.poles_steps' poles steps starting at '.poles0'
        printline measurement points = '.mps'

        if praatVersion <= 6038 or praatVersion==6109
            printline Praat version is 'praatVersion$'. FormantModeler will be given 5 arguments because this is 6.0.38 or earlier or 6.1.09.
        else
            printline Praat version is 'praatVersion$'. FormantModeler will be given 4 arguments because this is 6.0.39 or later.
        endif

        .formantheader$ = ",total_formants,max_formant,mdist,sos,energy,rsq1,rsq2,rsq3,rsq4,rsq5"
        if .keep_all == 1
            .formantheader$ = .formantheader$ + ",best"
        endif

        fileappend 'outfile$' 
        for .fn to .output_formants
            for .mp to .mps+.omps*2
                .mpct = round(100*(.mp-1)/(.mps-1) - 100*.overmeasure)
                .formantheader$ = .formantheader$ + ",F'.fn'_'.mpct'"
            endfor
        endfor

        if .measure_bandwidths == 1
            for .fn to .output_formants
                for .mp to .mps+.omps*2
                    .mpct = round(100*(.mp-1)/(.mps-1) - 100*.overmeasure)
                    .formantheader$ = .formantheader$ + ",B'.fn'_'.mpct'"
                endfor
            endfor
        endif

        if .measure_amplitudes == 1
            for .fn to .output_formants
                for .mp to .mps+.omps*2
                    .mpct = round(100*(.mp-1)/(.mps-1) - 100*.overmeasure)
                    .formantheader$ = .formantheader$ + ",A'.fn'_'.mpct'"
                endfor
            endfor
            for .fn to .output_formants
                for .mp to .mps+.omps*2
                    .mpct = round(100*(.mp-1)/(.mps-1) - 100*.overmeasure)
                    .formantheader$ = .formantheader$ + ",P'.fn'_'.mpct'"
                endfor
            endfor
            for .fn to .output_formants
                for .mp to .mps+.omps*2
                    .mpct = round(100*(.mp-1)/(.mps-1) - 100*.overmeasure)
                    .formantheader$ = .formantheader$ + ",T'.fn'_'.mpct'"
                endfor
            endfor
        endif

        if .fit_curves == 1
            for .fn to .output_formants
                .formantheader$ = .formantheader$ + ",F'.fn'_SD,F'.fn'_constant,F'.fn'_linear,F'.fn'_quadratic,F'.fn'_cubic,F'.fn'_constant_SD,F'.fn'_linear_SD,F'.fn'_quadratic_SD,F'.fn'_cubic_SD"
            endfor
        endif

        if .predict_formants == 1
            for .fn to .output_formants
                for .mp to .mps+.omps*2
                    .mpct = round(100*(.mp-1)/(.mps-1) - 100*.overmeasure)
                    .formantheader$ = .formantheader$ + ",F'.fn'Pr_'.mpct'"
                endfor
            endfor
        endif

        fileappend 'outfile$' '.formantheader$'

        #OPEN THE POPULATION INFORMATION FOR ALL PHONES

        .phones_name$ = .language$+"_prototypes"
        printline '.language$'  
        printline '.phones_name$'.csv
        Read Table from comma-separated file: .phones_name$+".csv"

        Extract rows where column (text): "type", "is equal to", "means"
        Remove column: "type"
        Rename: "phone_means"

        selectObject: "Table "+.phones_name$
        Extract rows where column (text): "type", "is equal to", "matrix"
        Remove column: "type"        
        Rename: "phone_matrices"

        #USE EXISTING FORMANT MEASUREMENT PARAMETERS
        if .guidefile$ != ""

            Read Table from comma-separated file: .guidefile$
            .guidefile_columns = Get number of columns
            Rename: "formant_guide"
            .guidecolumns$ = " token_id total_formants max_formant mdist sos energy "

            for .i from 1 to .guidefile_columns
                .guidefile_column_label$ = Get column label: .guidefile_columns - .i + 1
                if index (.guidecolumns$, .guidefile_column_label$) == 0
                    Remove column: .guidefile_column_label$
                endif
            endfor
            printline Read '.guidefile$' as guide file for formant measurements.
        endif

        #CHOOSE COLUMN NAMES FOR THE DATA TABLE AT THE END
        .formant_data_column_names$ = "mp"
        for .fn to .output_formants
            .formant_data_column_names$ = .formant_data_column_names$+" F'.fn'"
        endfor
        if .measure_bandwidths == 1
            for .fn to .output_formants
                .formant_data_column_names$ = .formant_data_column_names$+" B'.fn'"
            endfor
        endif
        if .measure_amplitudes == 1
            for .fn to .output_formants
                .formant_data_column_names$ = .formant_data_column_names$+" A'.fn'"
            endfor
            #FORMANT PROMINENCE
            for .fn to .output_formants
                .formant_data_column_names$ = .formant_data_column_names$+" P'.fn'"
            endfor
            #TROUGHS
            for .fn to .output_formants
                .formant_data_column_names$ = .formant_data_column_names$+" T'.fn'"
            endfor
        endif
        #POLYNOMIAL CURVE FIT
        if .predict_formants == 1
            for .fn to .output_formants
                .formant_data_column_names$ = .formant_data_column_names$+" F'.fn'Pr"
            endfor
        endif

    elif isComplete == 1
        printline FINISHED  

    else

        #@logtime

        if .measure_amplitudes == 1
            #.ltas_bandwidth = ceiling(sound_samplerate/2048) # changed 2022/12/20
            .ltas_bandwidth = ceiling(sound_samplerate/1024)
        endif

        #.measure_25 = transport.phone_start + transport.duration * 0.25
        #.measure_50 = transport.phone_start + transport.duration * 0.5
        #.measure_75 = transport.phone_start + transport.duration * 0.75

        select Sound 'sound_name$'

        if transport.duration < 0.05 and .pad < 0.05
            .pad = 0.05
        endif

        .overextract_start = transport.phone_start - .overmeasure*transport.duration - .pad
        .overextract_end = transport.phone_end + .overmeasure*transport.duration/2 + .pad
        Extract part... '.overextract_start' '.overextract_end' rectangular 1.0 yes

        if .preemphasis == 1
            Filter (pre-emphasis): 50
            Rename: "'sound_name$'_part_final"
            selectObject: "Sound 'sound_name$'_part"
            Remove
        else
            Rename: "'sound_name$'_part_final"
        endif

        .found_in_guidefile = 0
        if .guidefile$ != ""
            selectObject: "Table formant_guide"
            .token_guide_row = Search column: "token_id", token_id$
            if .token_guide_row > 0
                .total_formants = Get value: .token_guide_row, "total_formants"
                .best_max_formant = Get value: .token_guide_row, "max_formant"
                .best_mdist = Get value: .token_guide_row, "mdist"
                .best_sos_geom_mean = Get value: .token_guide_row, "sos"
                .best_residual_energy6 = Get value: .token_guide_row, "energy"
                .found_in_guidefile = 1
            endif
        endif

        #@logtime

        #.formant_data$ = ""

        if .found_in_guidefile == 1
            #printline found token 'token_id$' in guide file
            .formant_data$ = ",'.total_formants','.best_max_formant','.best_mdist:3','.best_sos_geom_mean:0','.best_residual_energy6:3'"
        else
            #printline did not find token 'token_id$' in guide file
            select Sound 'sound_name$'
            Extract part... 'transport.phone_start'-'.pad' 'transport.phone_end'+'.pad' rectangular 1.0 yes

            if .preemphasis == 1
                Filter (pre-emphasis): 50
                selectObject: "Sound 'sound_name$'_part"
                Remove
                selectObject: "Sound 'sound_name$'_part_preemp"
                Rename: "'sound_name$'_part"                
            endif

            Resample: 16000, 50
            
            ##############################
            # BEGIN FORMANT OPTIMIZATION #
            ##############################

            selectObject: "Table "+.phones_name$
            .prototypes_last_column = Get number of columns
            .protoparams$ = Get column label: 3
            for .colnum from 4 to .prototypes_last_column
                .pp$ = Get column label: .colnum
                .protoparams$ = .protoparams$ + " " + .pp$
            endfor

            .token$ = "candidate"

            .token_columns$ = .protoparams$
            
            # MAKE A TABLE TO STORE FORMANT MEASUREMENT QUALITY INFORMATION
            Create Table with column names: "all_metrics", 0, "total_formants max_formant mdist residual_energy sos_geom_mean validity mdist_ratio sos_geom_mean_ratio r2_f1 r2_f2 r2_f3 r2_f4 r2_f5 energy_ratio validity_ratio"

            # LOOP THROUGH NUMBERS OF POLES, MAKE FORMANT OBJECTS, ASSESS THEM
            for .x from 0 to .poles_steps

                .total_formants = (.poles0 + .x) / 2
                .total_formants_times_ten = .total_formants*10

                for .xx from 0 to .mf_steps
                    
                    #printline '.x' '.xx'

                    .max_formant = .mf0 + .xx*100

                    # CUT FROM HERE
                    select Sound 'sound_name$'_part
                    To Formant (burg)... 0.0 '.total_formants' '.max_formant' 0.025 50
                    Rename: "'.total_formants_times_ten'_'.max_formant'"

                    .int_formants = floor(.total_formants)

                    if praatVersion <= 6038 or praatVersion==6109
                        To FormantModeler: 0, 0, '.int_formants', 3, "Bandwidth"
                    else
                        To FormantModeler: 0, 0, '.int_formants', 3
                    endif

                    .ss1 = Get residual sum of squares: 1
                    .ss2 = Get residual sum of squares: 2
                    .ss3 = Get residual sum of squares: 3

                    .r2_f1 = Get coefficient of determination: 1, 1
                    .r2_f2 = Get coefficient of determination: 2, 2
                    .r2_f3 = Get coefficient of determination: 3, 3         
                    
                    if .int_formants > 3 and .output_formants > 3
                        .ss4 = Get residual sum of squares: 4
                        .r2_f4 = Get coefficient of determination: 4, 4
                    else
                        .ss4 = 0
                        .r2_f4 = 0
                    endif

                    if .int_formants > 4 and .output_formants > 4
                        .ss5 = Get residual sum of squares: 5
                        .r2_f5 = Get coefficient of determination: 5, 5 
                    else
                        .ss5 = 0
                        .r2_f5 = 0
                    endif

                    #CHECK THE COMPLETENESS OF THE HIGHEST MEASURED FORMANT
                    .total_data_points = Get number of data points
                    .valid_data_points = 0
                    for .dp to .total_data_points
                        .data_point_status$ = Get data point status: .int_formants, .dp
                        if .data_point_status$ == "Valid"
                            .valid_data_points = .valid_data_points + 1
                        endif
                    endfor
                    .data_validity = max(.valid_data_points, 0.5) / .total_data_points

                    .sos_geom_mean = sqrt((5*.ss1)^2 + (4*.ss2)^2 + (3*.ss3)^2 + (2*.ss4)^2 + .ss5^2)
                    #HACK
                    if .sos_geom_mean == undefined
                        .sos_geom_mean = 1000000000
                    endif

                    #selectObject: "Formant "+sound_name$+"_part"
                    selectObject: "Formant '.total_formants_times_ten'_'.max_formant'"
                    To LPC: 16000
                    selectObject: "Sound "+sound_name$+"_part_16000"
                    plusObject: "LPC '.total_formants_times_ten'_'.max_formant'"
                    Filter (inverse)
                    Rename: sound_name$+"_part_filtered"
                    .residual_energy = Get energy: 'transport.phone_start', 'transport.phone_end'
                    #printline '.token_columns$'
                    Create Table with column names: .token$, 1, .token_columns$

                    selectObject: "Table "+.phones_name$
                    .prototypes_last_column = Get number of columns
                    for .colnum from 3 to .prototypes_last_column
                        selectObject: "Table "+.phones_name$
                        .param$ = Get column label: .colnum
                        .param_type$ = left$ (.param$, 1)
                        .param_num$ = mid$ (.param$, 2, 1)
                        .param_num = '.param_num$'
                        .sep = index (.param$, "_")
                        .time_pct$ = mid$ (.param$, .sep+1, length (.param$)-.sep)
                        .time_rel = '.time_pct$'/100

                        .measure_time = transport.phone_start + transport.duration * .time_rel

                        selectObject: "Formant '.total_formants_times_ten'_'.max_formant'"
                        if .param_type$ == "F"
                            .measurement_for_prototype = Get value at time... '.param_num' '.measure_time' Hertz Linear
                        elif .param_type$ == "B"
                            .measurement_for_prototype = Get bandwidth at time... '.param_num' '.measure_time' Hertz Linear
                            .measurement_for_prototype = log10(.measurement_for_prototype)
                        else
                            printline unknown parameter: '.param$'
                        endif

                        selectObject: "Table '.token$'"
                        Set numeric value: 1, .param$, .measurement_for_prototype

                    endfor

                    ########################################################
                    #REQUIREMENTS: 
                    # 1. transport.phone$ MUST BE IN THE OPEN MEANS AND MATRICES TABLES
                    # 2. .token$ MUST BE A VECTOR OF MATCHING LENGTH (PROBABLY 12)
                    selectObject: "Table phone_means"
                    .has_phone = Search column: "phone", transport.phone$
                    if .has_phone > 0
                        @mahalanobis (transport.phone$, .token$)
                    else
                        #mahalanobis.dist = undefined
                        mahalanobis.dist = 1
                    endif
                    ########################################################

                    selectObject: "Table all_metrics"
                    Append row
                    .metrics_lastrow = Get number of rows
                    Set numeric value: .metrics_lastrow, "total_formants", .total_formants
                    Set numeric value: .metrics_lastrow, "max_formant", .max_formant
                    Set numeric value: .metrics_lastrow, "mdist", mahalanobis.dist
                    Set numeric value: .metrics_lastrow, "sos_geom_mean", .sos_geom_mean
                    Set numeric value: .metrics_lastrow, "r2_f1", .r2_f1
                    Set numeric value: .metrics_lastrow, "r2_f2", .r2_f2
                    Set numeric value: .metrics_lastrow, "r2_f3", .r2_f3
                    Set numeric value: .metrics_lastrow, "r2_f4", .r2_f4
                    Set numeric value: .metrics_lastrow, "r2_f5", .r2_f5
                    Set numeric value: .metrics_lastrow, "residual_energy", .residual_energy
                    Set numeric value: .metrics_lastrow, "validity", .data_validity

                    # REMOVE OBJECTS WE'RE FINISHED WITH (KEEPING THE FORMANT OBJECTS TO MEASURE LATER)
                    selectObject: "Sound "+sound_name$+"_part_filtered"
                    plusObject: "LPC '.total_formants_times_ten'_'.max_formant'"
                    plus FormantModeler '.total_formants_times_ten'_'.max_formant'_o3
                    plus Table '.token$'
                    Remove

                    .residual_energy6 = .residual_energy*1000000
                endfor
            endfor

            # CHOOSE THE BEST VERSION OF THE FORMANT ANALYSIS
            selectObject: "Table all_metrics"
            .min_mdist = Get minimum: "mdist"
            .min_sos_geom_mean = Get minimum: "sos_geom_mean"
            .min_energy = Get minimum: "residual_energy"
            .max_validity = Get maximum: "validity"

            if interactive_session == 1
                echo 
                printline 'transport.phone$'
                printline Fs'tab$'mdist'tab$'sos_mean'tab$'energy'tab$'validity'tab$'m_ratio'tab$'s_ratio'tab$'e_ratio'tab$'v_ratio'tab$'best'tab$'m'tab$'s'tab$'e'tab$'v
            endif

            .mdist_tolerance = 0.5    
            .mdist_cutoff = 1+.mdist_tolerance

            for i to .metrics_lastrow
                .total_formants_i = Get value: i, "total_formants"
                .mdist_i = Get value: i, "mdist"
                .sos_geom_mean_i = Get value: i, "sos_geom_mean"
                .energy_i = Get value: i, "residual_energy"
                .data_validity_i = Get value: i, "validity"
                .mdist_ratio = .mdist_i/.min_mdist
                .sos_geom_mean_ratio = .sos_geom_mean_i/.min_sos_geom_mean
                .energy_ratio = .energy_i/.min_energy
                .data_validity_ratio = .max_validity / .data_validity_i
                Set numeric value: i, "mdist_ratio", .mdist_ratio
                Set numeric value: i, "sos_geom_mean_ratio", .sos_geom_mean_ratio
                Set numeric value: i, "energy_ratio", .energy_ratio
                Set numeric value: i, "validity_ratio", .data_validity_ratio
            endfor

            selectObject: "Table all_metrics"
            Save as comma-separated file: "all_metrics.csv"

            Extract rows where column (number): "mdist_ratio", "less than", .mdist_cutoff
            Rename: "good_mdist"

            Append column: "mser_geom_mean"
            .good_mdist_lastrow = Get number of rows
            for i to .good_mdist_lastrow
                .sos_geom_mean_ratio = Get value: i, "sos_geom_mean_ratio"
                .energy_ratio = Get value: i, "energy_ratio"
                #.validity_ratio = Get value: i, "validity_ratio"
                .mser_geom_mean_i = sqrt(.mdist_ratio^2 + .sos_geom_mean_ratio^2 + .energy_ratio^2)

                # THE BEST WAS BASED ON:
                #   the ratio of the mdist to min mdist
                #   the ratio of sos to min sos
                #   the ratio of energy to minimum energy
                #   and rsq is not being used

                Set numeric value: i, "mser_geom_mean", .mser_geom_mean_i
            endfor

            # .min_mser_geom_mean = Get minimum: "mser_geom_mean"
            # .best_row = Search column: "mser_geom_mean", "'.min_mser_geom_mean'"

            # 2024/03/04 REMOVING ENERGY AND SOS AND JUST USING MDIST
            .best_row = Search column: "mdist", "'.min_mdist'"

            .best_total_formants = Get value: .best_row, "total_formants"
            .best_max_formant = Get value: .best_row, "max_formant"

            selectObject: "Table all_metrics"
            for i to .metrics_lastrow

                .total_formants_i = Get value: i, "total_formants"
                .max_formant_i = Get value: i, "max_formant"
                .mdist_i = Get value: i, "mdist"
                .sos_geom_mean_i = Get value: i, "sos_geom_mean"
                .energy_i = Get value: i, "residual_energy"
                .data_validity_i = Get value: i, "validity"
                .mdist_ratio = Get value: i, "mdist_ratio"
                .sos_geom_mean_ratio = Get value: i, "sos_geom_mean_ratio"
                .energy_ratio = Get value: i, "energy_ratio"
                .validity_ratio = Get value: i, "validity_ratio"

                .mdist_g$ = ""
                #for j to floor(.mdist_ratio-.mdist_tolerance)
                for j to round(.mdist_ratio)
                    .mdist_g$ = .mdist_g$ + "."
                endfor
                .sos_g$ = ""
                for j to round(.sos_geom_mean_ratio)
                    .sos_g$ = .sos_g$ + "."
                endfor
                .energy_g$ = ""
                for j to round(.energy_ratio)
                    .energy_g$ = .energy_g$ + "."
                endfor
                .validity_g$ = ""
                for j to round(.validity_ratio)
                    .validity_g$ = .validity_g$ + "."
                endfor

                if interactive_session == 1
                    .is_best$ = ""
                    if .mdist_ratio < .mdist_cutoff
                        .is_best$ = .is_best$ + "m"
                        #if .validity_ratio < .validity_cutoff
                        #    .is_best$ = .is_best$ + "v"
                        #else                    
                            .is_best$ = .is_best$ + " "
                        #endif
                    else
                        .is_best$ = .is_best$+"     "
                    endif
                    if .total_formants_i == .best_total_formants and max_formant_i == .best_max_formant
                        .is_best$ = .is_best$ + "*"
                    else
                        .is_best$ = .is_best$ + " "
                    endif
                    .is_best$ = .is_best$ + "   "
                    .energy_i6 = .energy_i*1000000
                    if .energy_i6 < 100
                        .energy_i6$ = "'.energy_i6:0'    "
                    elif .energy_i6 < 1000
                        .energy_i6$ = "'.energy_i6:0'  "
                    else
                        .energy_i6$ = "'.energy_i6:0'"
                    endif
                    printline '.total_formants_i''tab$''.mdist_i:2''tab$''.sos_geom_mean_i:0''tab$''.energy_i6$''tab$''.data_validity_i:3''tab$''.mdist_ratio:3''tab$''.sos_geom_mean_ratio:3''tab$''.energy_ratio:3''tab$''.validity_ratio:3''tab$''.is_best$''tab$''.mdist_g$''tab$''.sos_g$''tab$''.energy_g$''tab$''.validity_g$'
                endif

            endfor

        endif

        #selectObject: "Table "+.phones_name$
        #Remove
        
        #@logtime
            
        if .keep_all == 1
            for .x from 0 to .poles_steps
                .total_formants = (.poles0 + .x) / 2
                for .xx from 0 to .mf_steps
                    .max_formant = .mf0 + .xx*100
                    if .x > 0 or .xx > 0
                        fileappend 'outfile$' 'newline$'
                        fileappend 'outfile$' 'makeMeasurements.base_info$'
                    endif
                    #printline '.x' '.xx'
                    @outputFormantData(.total_formants, .max_formant)

                endfor
            endfor
        else
            @outputFormantData(.best_total_formants, .best_max_formant)
        endif


        # CLEAN UP
        # /home/jimielke/corpora/Raleigh/raleigh_files_test.csv

        select Sound 'sound_name$'_part_final
        Remove

        if .found_in_guidefile != 1
            
            select Sound 'sound_name$'_part
            plus Sound 'sound_name$'_part_16000
            plus Table all_metrics
            plus Table good_mdist
            #plus Table good_mdist_and_validity

            for .x from 0 to .poles_steps
                .total_formants = (.poles0 + .x) / 2
                .total_formants_times_ten = .total_formants*10
                for .xx from 0 to .mf_steps
                    #printline '.x' '.xx'
                    .max_formant = .mf0 + .xx*100
                    plusObject: "Formant '.total_formants_times_ten'_'.max_formant'"
                endfor
            endfor
            Remove
        endif


        if interactive_session == 1
            editor TextGrid 'textgrid_name$'
            Formant settings: '.max_formant', '.best_total_formants', 0.025, 30, 1
            endeditor
        endif

        #@logtime

        #fileappend 'timelog$' 'newline$'

    endif

endproc

#######################################################################################
#                                                                                     #
#                     HIGHLY CUSTOMIZED MEASUREMENT PROCEDURES                        #
#                                                                                     #
#######################################################################################


#######################################################################################
# CUSTOMIZED PROCEDURE: approx_int()
# Calculates various intensity measures of segment relative to following vowel.
# Designed to investigate lenition of voiced approximants in Spanish (cf. Hualde et al. 2011:309-310)
#######################################################################################

procedure approx_int (.argString$)

    @parseArgs (.argString$)
    .vocales$ = "aeiou"

    if isHeader = 1
        printline approx_int ('.argString$')
        fileappend 'outfile$' ,int_min,int_max,int_diff,int_ratio
    elif isComplete = 1
        printline FINISHED
    else
    if index (.vocales$, transport.nextphone$) > 0
        select Sound 'sound_name$'
        Extract part... 'transport.word_start' 'transport.nextword_end' rectangular 1.0 yes
        To Intensity... 100 0 yes
        .int_min = Get minimum... 'transport.phone_start' 'transport.phone_end' Parabolic
        .int_max = Get maximum... 'transport.phone_end' 'transport.nextphone_end' Parabolic
        select Sound 'sound_name$'_part
        plus Intensity 'sound_name$'_part
        Remove

        # Calculate and append
        .int_diff = .int_max - .int_min
        .int_ratio = .int_min / .int_max
        fileappend 'outfile$' ,'.int_min','.int_max','.int_diff','.int_ratio'
    else
        fileappend 'outfile$' ,ERROR,ERROR,ERROR,ERROR
    endif
    endif
endproc

#######################################################################################
# CUSTOMIZED PROCEDURE: moments(start_per, end_per, minHz, maxHz, perc_measure, window_shape)
# measure center of gravity and other spectral moments with arguments for 
# starting and end point exclusion in ms (start_plus, end_plus),
# filtering range (minHz, maxHz), 
# gets whole average plus 25 ms at start, 25 ms in middle, and 25 ms at end, 
# if the segment is at least 30 ms
# Use option d so that you don't get errors about segment being too short
#######################################################################################

procedure moments (.argString$)

# default settings (same as simple cog(), except window_shape )
@parseArgs (.argString$)

    start_plus = 0
    end_plus = 0
    minHz = 1
    maxHz = 44100
    perc_measure = 1
    window_shape$ = "Hanning"

    for i to parseArgs.n_args
        if parseArgs.var$[i] == "start_per"
            start_per = number(parseArgs.val$[i])
        elif parseArgs.var$[i] == "end_per"
            end_per = number(parseArgs.val$[i])
        elif parseArgs.var$[i] == "minHz"
            minHz = number(parseArgs.val$[i])
        elif parseArgs.var$[i] == "maxHz"
            maxHz = number(parseArgs.val$[i])
        elif parseArgs.var$[i] == "perc_measure"
            perc_measure = number(parseArgs.val$[i])
        elif parseArgs.var$[i] == "window_shape"
            window_shape = number(parseArgs.val$[i])
        endif
    endfor 

    if isHeader = 1 
        fileappend 'outfile$' ,cog_avg,sd_avg,skew_avg,kurt_avg,cog_1,sd_1,skew_1,kurt_1,cog_2,sd_2,skew_2,kurt_2,cog_3,sd_3,skew_3,kurt_3
    elif isComplete == 1
        printline FINISHED  
    else
        select Sound 'sound_name$'
        sound_samplerate = Get sampling frequency
        no_points = 1/perc_measure

        # divide up the length of the sound, checking to make sure it's 
        # not going to be under 30 ms
        cog_start = transport.phone_start + (start_plus)
        cog_end = transport.phone_end - (end_plus)
        chunk_dur = cog_end - cog_start
        
        Extract part: 'cog_start', 'cog_end', "Hanning", 1, "yes"
        if minHz > 1 or maxHz < 44100
           Filter (pass Hann band): 'minHz', 'maxHz', 100
        endif

        To Spectrum: "yes"
        cog_avg = Get centre of gravity: 2
        sd_avg = Get standard deviation: 2
        kurt_avg = Get kurtosis: 2
        skew_avg = Get skewness: 2
        Remove
        selectObject: "Sound 'sound_name$'_part"
        Remove
        if minHz > 1 or maxHz < sound_samplerate
            selectObject: "Sound 'sound_name$'_part_band"
            Remove
        endif

        if chunk_dur > 0.03
            cog1_start = (transport.phone_start + start_plus)
            cog1_end = (transport.phone_start + start_plus)+0.025
            cog2_start = (transport.phone_start + (chunk_dur/2)-0.0125)
            cog2_end = (transport.phone_start + (chunk_dur/2)+0.0125)
            cog3_start = (transport.phone_end - end_plus)-0.025
            cog3_end = (transport.phone_end - end_plus)

            select Sound 'sound_name$'
            Extract part: 'cog1_start', 'cog1_end', "Hanning", 1, "yes"
            if minHz > 1 or maxHz < 44100
               Filter (pass Hann band): 'minHz', 'maxHz', 100
            endif
    
            To Spectrum: "yes"
            cog_1 = Get centre of gravity: 2
            sd_1 = Get standard deviation: 2
            kurt_1 = Get kurtosis: 2
            skew_1 = Get skewness: 2
            Remove
            selectObject: "Sound 'sound_name$'_part"
            Remove
            if minHz > 1 or maxHz < sound_samplerate
                selectObject: "Sound 'sound_name$'_part_band"
                Remove
            endif

            select Sound 'sound_name$'
            Extract part: 'cog2_start', 'cog2_end', "Hanning", 1, "yes"
            if minHz > 1 or maxHz < 44100
               Filter (pass Hann band): 'minHz', 'maxHz', 100
            endif
    
            To Spectrum: "yes"
            cog_2 = Get centre of gravity: 2
            sd_2 = Get standard deviation: 2
            kurt_2 = Get kurtosis: 2
            skew_2 = Get skewness: 2
            Remove
            selectObject: "Sound 'sound_name$'_part"
            Remove
            if minHz > 1 or maxHz < sound_samplerate
                selectObject: "Sound 'sound_name$'_part_band"
                Remove
            endif

            select Sound 'sound_name$'
            Extract part: 'cog3_start', 'cog3_end', "Hanning", 1, "yes"
            if minHz > 1 or maxHz < 44100
               Filter (pass Hann band): 'minHz', 'maxHz', 100
            endif
    
            To Spectrum: "yes"
            cog_3 = Get centre of gravity: 2
            sd_3 = Get standard deviation: 2
            kurt_3 = Get kurtosis: 2
            skew_3 = Get skewness: 2
            Remove
            selectObject: "Sound 'sound_name$'_part"
            Remove
            if minHz > 1 or maxHz < sound_samplerate
                selectObject: "Sound 'sound_name$'_part_band"
                Remove
            endif

        else 
            cog_1 = 0
            sd_1 = 0
            kurt_1 = 0
            skew_1 = 0
            cog_2 = 0
            sd_2 = 0
            kurt_2 = 0
            skew_2 = 0
            cog_3 = 0
            sd_3 = 0
            kurt_3 = 0
            skew_3 = 0
        endif

        fileappend 'outfile$' ,'cog_avg:0','sd_avg:0','skew_avg:2','kurt_avg:2','cog_1:0','sd_1:0','skew_1:2','kurt_1:2','cog_2:0','sd_2:0','skew_2:2','kurt_2:2','cog_3:0','sd_3:0','skew_3:2','kurt_3:2'

    endif

endproc

#######################################################################################
# CUSTOMIZED PROCEDURE: getPitch(pad, .do_clips, min_pitch, max_pitch, band_low)
# Get pitch over an entire word, starting with a T (or the rest of any word containing TR from the T)
#
# and output trajectory of pitch results to individual files for each clip. For now, the padding is
# set at 30 ms, because we're interested in looking at pitch onset after a period of voicelessness,
# and we're pretty sure that the T isn't going to be so badly segmented that it is after the onset 
# of the R. The padding should match up with that of the clip that is analyzed in R using MTS.
# It also gets basic intensity information every 8 ms so that it can be decided later 
# (in R) whether the pitch value is a likely candidate, or occurs during a non-vocalic interval
# If MTS hasn't been run yet, optionally use this section to get the clips for analysis? Yes, because
# we only need 30 ms before the marked boundary to get 95% of cases, and with an adjustment to 
# make a preceding {sp} into the corrected phonestart, if it falls between S and T. Then add 20 ms 
# more to ensure enough window for accurate measurements
# 
# optional arguments: do_clips, pad, min_pitch, max_pitch, band_low
#######################################################################################
procedure getPitch (.argString$)

@parseArgs (.argString$)

# default values for pad (Since the start of the word should be definitely ahead of the voicing, 
# we don't need that much, if any, except to make a long enough window to calculate pitch):
    .do_clips = 1
    .pad = 0.05        
    .min_pitch = 75
    .max_pitch = 600
    .band_low = 550

    for i to parseArgs.n_args
        if parseArgs.var$[i] == "pad"
            .pad = number(parseArgs.val$[i])
        elif parseArgs.var$[i] == ".do_clips"
            .do_clips = number(parseArgs.val$[i])
        elif parseArgs.var$[i] == "min_pitch"
            .min_pitch = number(parseArgs.val$[i])
        elif parseArgs.var$[i] == "max_pitch"
            .max_pitch = number(parseArgs.val$[i])
        elif parseArgs.var$[i] == "band_low"
            .band_low = number(parseArgs.val$[i])
        elif parseArgs.var$[i] != ""
            if isHeader == 1
                .unknown_var$ = parseArgs.var$[i]
                printline skipped unknown argument '.unknown_var$'
            endif
        endif
    endfor 

# pitch settings of 75 and 600 gets us a time step of 10 ms, 
# calculated across overlapping 40 ms windows
pitchFilesPath$ = "'writePath$'/pitchfiles"
if isHeader = 1
    fileappend 'outfile$' ,clip_start,clip_end,phonestart_corrected,wordstart,wordend,clip_name,clipPath
	createDirectory: pitchFilesPath$
        if .do_clips=1
        createDirectory: clipPath$
    endif
elif isComplete == 1
        printline FINISHED  
else

    select TextGrid 'textgrid_name$'

    if transport.lastphone2$ == "S"
        if transport.lastphone1$ == "sp"
            phone_start_correct = Get starting point... phone_tier p-1
            .clip_start = round(1000*(phone_start_correct - .pad))/1000
		else 
			phone_start_correct = transport.phone_start
            .clip_start = round(1000*(transport.phone_start - .pad))/1000
        endif
    else
        phone_start_correct = transport.phone_start
            .clip_start = round(1000*(transport.phone_start - .pad))/1000
        endif
    .clip_end = round(1000*(transport.phone_end + .pad +0.25))/1000

        select Sound 'sound_name$'
    Extract part: .clip_start, .clip_end, "rectangular", 1, "yes"
    Rename... t_plus

# In case we want to filter in one step to get rid of mic noise, filter:
        Filter (pass Hann band): '.band_low', 12050, 100
        timestring$ = replace$ ("'.clip_start'", ".", "_", 0)
        if .clip_start == round(.clip_start)
            printline 'timestring$'
            timestring$ = timestring$+"_0"
        endif
        
        .sound_filename$ = "'sound_name$'_'timestring$'_'transport.word$'"
        # default is to write clips, but if you just need to remeasure, use .do_clips=0 as an argument
        if .do_clips = 1
		Write to WAV file... 'clipPath$'/'.sound_filename$'.wav
	endif
	Remove

# get number of bins, as defined by the time step settings for intensity
	timebin_p = (.clip_end - .clip_start) / 0.008
	timebins = round (timebin_p)

# Create a table to put the values
	 tableObject = do("Create Table with column names...", "table", 0, "time pitch intensity")
# Get the pitch and time values
	selectObject: "Sound t_plus"
	To Pitch: 0, .min_pitch, .max_pitch

	for timebin_i from 1 to timebins
		cor_time = .clip_start - 0.008 + 0.008 * timebin_i
		selectObject: "Pitch t_plus"
		pitch_bin = Get frame number from time: cor_time
		f_0 = Get value in frame: round (pitch_bin), "Hertz"
# write to table object
		selectObject(tableObject)
		do("Append row")
	 	thisRow = do("Get number of rows")
		do("Set numeric value...", thisRow, "time", cor_time)
		do("Set numeric value...", timebin_i, "pitch", f_0)
	endfor

# Get intensity measures, to see if any pitch candidates are unlikely
		selectObject: "Sound t_plus"
		To Intensity: 100, 0, "yes"

		for timebin_i from 1 to timebins
			cor_time = .clip_start - 0.008 + 0.008 * timebin_i
			selectObject: "Intensity t_plus"
			amp_bin = Get frame number from time: cor_time
			amp = Get value in frame: round (amp_bin)
# write to table object
			selectObject(tableObject)
    			do("Set numeric value...", timebin_i, "intensity", amp)
		endfor

# write individual tables for each word, naming them so they can be accessed easily
		selectObject(tableObject)
		Save as comma-separated file: "'pitchFilesPath$'/'.sound_filename$'.csv"
		Remove
		selectObject: "Intensity t_plus"
		Remove
		selectObject: "Pitch t_plus"
		Remove
		selectObject: "Sound t_plus"
		Remove

	fileappend 'outfile$' ,'.clip_start','.clip_end','phone_start_correct','transport.word_start','transport.word_end','.sound_filename$','clipPath$'
endif	
endproc	

#######################################################################################
# CUSTOMIZED PROCEDURE: cog_jim()
# measure center of gravity in the style of Jim Michnowicz (measure the middle 60% after filtering 750-11025 Hz)
#######################################################################################

procedure cog_jim (.argString$)

    if isHeader = 1 
        fileappend 'outfile$' ,cog
    elif isComplete == 1
        printline FINISHED  
    else
        select Sound 'sound_name$'
        viscincrement20 = transport.phone_start + transport.duration*0.2
        viscincrement80 = transport.phone_start + transport.duration*0.8
        Extract part... viscincrement20 viscincrement80 rectangular 1.0 yes
        Filter (pass Hann band)... 750 11025 100
        To Spectrum... yes
        .cog = Get centre of gravity... 2
        fileappend 'outfile$' ,'.cog:0'
        plus Sound 'sound_name$'_part
        plus Sound 'sound_name$'_part_band
        Remove
    endif

endproc



#######################################################################################
# CUSTOMIZED PROCEDURE: resegmentSibilant()
# find a sibilant interval around a pre-selected interval 
#
#VARIABLES AVAILABLE TO MEASUREMENT PROCEDURES: 
# - resegmentSibilant.left_bound    the start of the sibilant interval
# - resegmentSibilant.right_bound   the end of the sibilant interval
# - resegmentSibilant.start         the start of the sibilant interval
# - resegmentSibilant.end           the end of the sibilant interval
# - resegmentSibilant.error$        errors related to segmentation
#
# This was used for work on Lyra Magloughlin's dissertation
#######################################################################################

procedure resegmentSibilant (.left_bound, .right_bound, .findBurst)

    #Defaults
    .error$ = ""
    .step_size = 0.005
    .window_size = 0.03
    .band_low = 500
    .band_high = 15000
    .band_smooth = 100
    .cog_threshold = 1500
    .band_diff_on_threshold = 0
    .band_diff_off_threshold = -10
    .low_band_floor = 0
    .low_band_ceiling = 500 
    .high_band_floor = 2000
    .high_band_ceiling = 8000
    .releasemin_threshold = 0.25

    .duration = .right_bound - .left_bound
    .number_of_intervals = .duration/.step_size
    .rounded_num_int = '.number_of_intervals:0'

    .start = -1
    .end = -1
    .last_band_diff = -999

    #CREATE A DATA TABLE FOR THE PICTURE
    Create Table with column names: "spectrum_info", 0, "time cog banddiff banddiffdelta 0-500 500-1k 1k-2k 2k-4k 4k-8k"

    # RESEGMENT THE BURST/ASPIRATION/AFFRICATION, WHICH MAY BE IN THIS SEGMENT AND/OR THE NEXT ONE
    for .k from 0 to .rounded_num_int

        .window_center = '.left_bound' + .k*.step_size
        .window_start = .window_center - .window_size/2
        .window_end = .window_center + .window_size/2

        select Sound 'sound_name$'
        Extract part... '.window_start' '.window_end' rectangular 1.0 yes
        To Spectrum... yes
        .band_diff = Get band energy difference: .low_band_floor, .low_band_ceiling, .high_band_floor, .high_band_ceiling

        #BAND DIFFERENCE VELOCITY
        if .k == 0
            .band_diff_delta = 0
        else
            .band_diff_delta = .band_diff - .last_band_diff
        endif
        .last_band_diff = .band_diff

        .energy_band1 = Get band energy: 0, 500
        .energy_band2 = Get band energy: 500, 1000
        .energy_band3 = Get band energy: 1000, 2000
        .energy_band4 = Get band energy: 2000, 4000
        .energy_band5 = Get band energy: 4000, 8000

        select Sound 'sound_name$'_part
        Filter (pass Hann band): .band_low, .band_high, .band_smooth
        To Spectrum... yes
        .cog = Get centre of gravity... 2

        #ADD DATA TO THE TABLE
        selectObject: "Table spectrum_info"
        Append row
        .lastrow = .k+1
        Set numeric value: .lastrow, "time", .window_center
        Set numeric value: .lastrow, "cog", .cog
        Set numeric value: .lastrow, "banddiff", .band_diff
        Set numeric value: .lastrow, "banddiffdelta", .band_diff_delta
        Set numeric value: .lastrow, "0-500", .energy_band1
        Set numeric value: .lastrow, "500-1k", .energy_band2
        Set numeric value: .lastrow, "1k-2k", .energy_band3
        Set numeric value: .lastrow, "2k-4k", .energy_band4
        Set numeric value: .lastrow, "4k-8k", .energy_band5

        #CLEAN UP OBJECTS CREATED IN THE LOOP
        select Sound 'sound_name$'_part
        plus Sound 'sound_name$'_part_band
        plus Spectrum 'sound_name$'_part_band
        plus Spectrum 'sound_name$'_part
        Remove

    endfor

    #USE VELOCITY TO SELECT SIB START AND END

    selectObject: "Table spectrum_info"
    
    #THIS IS SO .band_diff_max_time IS NOT NEAR THE START OR END OF THE INTERVAL
    #Copy: - copies the Object that was last selected and renames it to what is to the right of the :
    Copy: "spectrum_info_middle"
    .lastrow = Get number of rows
    Remove row: .lastrow
    Remove row: 1

    #THIS IS WHERE THE OLIVE ARROW GETS ITS INFORMATION FROM
    .band_diff_max = Get maximum: "banddiff"
    .band_diff_max_row = Search column: "banddiff", "'.band_diff_max'"
    .band_diff_max_time = Get value... '.band_diff_max_row' time

    #FIND MAXIMUM CENTER OF GRAVITY TOO
    .cog_max = Get maximum: "cog"
    .cog_max_row = Search column: "cog", "'.cog_max'"
    .cog_max_time = Get value... '.cog_max_row' time
    
    selectObject: "Table spectrum_info"
    Extract rows where column (number): "time", "less than or equal to", .band_diff_max_time
    Rename: "spectrum_info_part1"
    .band_diff_delta_max = Get maximum: "banddiffdelta"
    .delta_max_row = Search column: "banddiffdelta", "'.band_diff_delta_max'"
    .delta_max_time = Get value... '.delta_max_row' time
    
    selectObject: "Table spectrum_info"
    Extract rows where column (number): "time", "greater than", .band_diff_max_time      
    Rename: "spectrum_info_part2"
    .band_diff_delta_min = Get minimum: "banddiffdelta"
    .delta_min_row = Search column: "banddiffdelta", "'.band_diff_delta_min'"
    .delta_min_time = Get value... '.delta_min_row' time
    
    #USE WINDOW END
    .start = .delta_max_time + .window_size/2
    .end = .delta_min_time
    
    #USE DEFAULT VALUES IF WE NEVER FOUND THE START OR THE END OF THE SIBILANT INTERVAL
    if .start == -1 and .end == -1
        .error$ = .error$ + "_no-sib-end"
    elif .start > -1 and .end == -1
        .error$ = .error$ + "_sib-end-before-start"
    elif .start == -1 and .end > -1
        .error$ = .error$ + "_no-sib-start"
    endif

    #REFINE THE SEGMENTATION OF THE START OF THE BURST
    #CREATE ANOTHER DATA TABLE FOR THE PICTURE
    Create Table with column names: "burst_info", 0, "time ampratio"

    select Sound 'sound_name$'
    .newboundary = .start

    .releasemin = Get minimum... .start-0.01 .start Sinc70
    .releasemin = max (0, .releasemin)
    
    if .start >= .band_diff_max_time
        .error$ = .error$ + "_sib-start-after-band-diff-max-time"
    endif

    .original_start = .start

    #ONLY DO THIS IF THERE ARE NO ERRORS SO FAR
    if .error$ == "" and .findBurst == 1

        .start_plus = min (.start+0.03, .band_diff_max_time)
        .releasemax = Get maximum... .start .start_plus Sinc70

        #echo '.releasemin' '.releasemax'
        for .step from -1000 to 3000
            .t_new = .start + .step/100000
            select Sound 'sound_name$'
            .thisval = Get value at time... 0 .t_new Sinc70
            .rmsratio = (.thisval-.releasemin)/(.releasemax-.releasemin)

            #ADD DATA TO THE TABLE (FOR THE PICTURE)
            selectObject: "Table burst_info"
            Append row
            .lastrow = .step+1001
            Set numeric value: .lastrow, "time", .t_new
            Set numeric value: .lastrow, "ampratio", .rmsratio

            if .rmsratio > .releasemin_threshold and .newboundary == .start

                if .t_new >= .band_diff_max_time
                    .error$ = .error$ + "_t-new-after-band-diff-max-time"
                endif

                .newboundary = .t_new
                printline '.releasemin:4' '.releasemax:4' '.thisval:4' '.rmsratio:4' '.start:4' '.t_new:4' '.end:4' ['transport.word$']
            endif  
        endfor

        .start = .newboundary
    endif

    #DRAW THE PICTURE IF THIS IS AN INTERACTIVE SESSION
    if interactive_session == 1
        picture_start = .left_bound
        picture_end = .left_bound+.rounded_num_int*.step_size
        @drawSibilantInfo (.left_bound, .right_bound)
    endif

    #CLEAN UP OBJECTS
    selectObject: "Table spectrum_info"
    plusObject: "Table spectrum_info_part1"        
    plusObject: "Table spectrum_info_part2"
    plusObject: "Table spectrum_info_middle"
    plusObject: "Table burst_info"
    Remove

endproc

#######################################################################################
# CUSTOMIZED PROCEDURE: cog_max_plus()
# measure maximum center of gravity across adjacent segments, PLUS OTHER STUFF
# this script incorporates many aspects of B. Smith's new_affricate_script (Nov 2012)
#######################################################################################

procedure cog_max_plus (.argString$)

    if isHeader = 1 
        fileappend 'outfile$' ,left_bound,right_bound,cog_max,sib_start,cog_max_time,sib_end,mid_ctr,mid_slope_lo,maxtime,max_int,rise_time_s,norm_rise,error
    elif isComplete == 1
        printline FINISHED  
    else
        #GIVE DEFAULT VALUES TO ALL OUTPUT VARIABLES
        .left_bound = undefined
        .right_bound = undefined
        .cog_max = undefined
        .cog_max_time = undefined
        #.dip = undefined
        mid_ctr = undefined
        mid_slope_lo = undefined
        maxtime = undefined
        max_int = undefined
        rise_time_s = undefined
        norm_rise = undefined
        error$ = "0"
        
        ##################
        .left_bound = transport.phone_start - 0.025
        if transport.nextphone$ == "R" or transport.nextphone$ == "r"
            .right_bound = transport.nextphone_end + 0.025
        else
            .right_bound = (transport.phone_end+transport.nextphone_end)/2
        endif
        ##################
        @resegmentSibilant (.left_bound, .right_bound, 1)
        ##################
        .left_bound = resegmentSibilant.left_bound
        .right_bound = resegmentSibilant.right_bound
        .sib_start = resegmentSibilant.start
        .sib_end = resegmentSibilant.end
        #.cog_max = resegmentSibilant.cog_max
        #.cog_max_time = resegmentSibilant.cog_max_time
        error$ = error$ + resegmentSibilant.error$
        ##################

        ##########################################################################################
        #NOW MAKING MEASUREMENTS (HAVING ALREADY RESEGMENTED)


        ### FIND .cog_max AGAIN, BECAUSE WE HAVE RESEGMENTED THE SIBILANT INTERVAL

        .step_size = 0.005
        .window_size = 0.03
        .duration = .right_bound - .left_bound
        .number_of_intervals = .duration/.step_size
        .rounded_num_int = '.number_of_intervals:0'
        .band_low = 500
        .band_high = 15000
        .band_smooth = 100

        Create Table with column names: "cog", 0, "time cog"

        for .k from 0 to .rounded_num_int

            .window_center = '.left_bound' + .k*.step_size
            .window_start = .window_center - .window_size/2
            .window_end = .window_center + .window_size/2

            select Sound 'sound_name$'
            Extract part... '.window_start' '.window_end' rectangular 1.0 yes
            Filter (pass Hann band): .band_low, .band_high, .band_smooth
            To Spectrum... yes
            .cog = Get centre of gravity... 2

            selectObject: "Table cog"
            Append row
            .lastrow = .k+1
            Set numeric value: .lastrow, "time", .window_center
            Set numeric value: .lastrow, "cog", .cog

            #CLEAN UP OBJECTS CREATED IN THE LOOP
            select Sound 'sound_name$'_part
            plus Sound 'sound_name$'_part_band
            plus Spectrum 'sound_name$'_part_band
            #plus Spectrum 'sound_name$'_part
            Remove

        endfor

        selectObject: "Table cog"
        .cog_max = Get maximum: "cog"
        .cog_max_row = Search column: "cog", "'.cog_max'"
        .cog_max_time = Get value... '.cog_max_row' time
        Remove

        #TURNING COG_MAX INTO COG_MAX_PLUS HERE
        #FROM B. SMITH (NOV_2012) SCRIPT 

        #WE ARE ONLY DOING THIS IF error$ IS STILL SET TO "0"
        #(MEANING THIS TOKEN IS NOT EXPECTED TO CRASH THE SCRIPT AT THE MEASUREMENT STAGE)
        if error$ == "0"

            if gender$ == "male"
                .max_formant = 5000
                lorange = 3600
                midrange = 6700
            else
                .max_formant = 5500
                lorange = 4500
                midrange = 7400
            endif

            burst = .sib_start
            fe = .sib_end
            vo = fe
            end = .right_bound

            stop_25 = 'burst' + (0.25*('vo' - 'burst'))
            st_25 = 'stop_25' - 0.010
            et_25 = 'stop_25' + 0.010

            burst_20 = 'burst' + 0.020
            burst_10 = 'burst' + 0.010
            burst_40 = 'burst' + 0.040
            fe_20 = 'fe' - 0.020        
            stop_dur = ('vo' - 'burst') * 1000.0
            
            #STILL FROM B. SMITH (NOV_2012)
            #B. Smith says: then select the corresponding sound, pass filter it so that low-frequency microphone noise is 
            #removed, and all the irrelevant (i.e., inaudible) stuff above 22050
            #though, here, I should make a choice (or make two scripts to do it both ways) about low
            #frequency - the 80dB cutoff is because of crappy mic noise, but others cut off at 1000Hz
            #so we'll start with 80 and add another iteration later
                    
            select Sound 'sound_name$'
            Extract part... 'burst' 'fe' rectangular 1.0 yes
            Resample... 22050 50
            Filter (pass Hann band)... 100 11025 100

            #STILL FROM B. SMITH (NOV_2012)
            # Get spectrum from inside word (make sure you have window shape set to hanning in the 
            # advanced spectrogram settings):

            select Sound 'sound_name$'_part_22050_band
            maxtime = Get time of maximum... 'burst' 'fe' Cubic
            frommax = 'maxtime'-0.01
            tomax = 'maxtime'+0.01
        
            #take the length of the entire affricate to get an average measurement over the whole thing

            To Spectrum: "yes"

            avg_ctr_s= Get centre of gravity... 2
            avg_sd_s= Get standard deviation... 2
            avg_skew_s= Get skewness... 2
            avg_kur_s= Get kurtosis... 2
            Rename...  'sound_name$'_burst

            To Ltas (1-to-1)
            avg_slope = Get slope... 0 'lorange' 'midrange' 11025 dB
            avg_slope_hi = Get slope... 'lorange' 'midrange' 'midrange' 11025 dB
            avg_slope_lo = Get slope... 0 'lorange' 'lorange' 'midrange' dB
            avg_slope_all = Get slope... 0 'lorange' 'lorange' 11025 dB
            avg_lo = Get mean... 0 'lorange' dB
            avg_mid = Get mean... 'lorange' 'midrange' dB
            avg_hi = Get mean... 'midrange' 11025 dB
            avg_all = Get mean... 0 11025 dB
            avg_lo_int = 'avg_lo'/'avg_all'
            avg_mid_int = 'avg_mid'/'avg_all'
            avg_hi_int = 'avg_hi'/'avg_all'

            Remove

            select Spectrum 'sound_name$'_burst
            Remove
            
            #take measurements at 20 ms from around the point of highest intensity

            select Sound 'sound_name$'_part_22050_band
            Extract part... 'frommax' 'tomax' rectangular 1.0 yes
            To Spectrum: "yes"

            max_ctr= Get centre of gravity... 2
            max_sd= Get standard deviation... 2
            max_skew= Get skewness... 2
            max_kur= Get kurtosis... 2
            Rename...  'sound_name$'_max

            To Ltas (1-to-1)
            max_slope = Get slope... 0 lorange midrange 11025 dB
            max_slope_hi = Get slope... 'lorange' 'midrange' 'midrange' 11025 dB
            max_slope_lo = Get slope... 0 'lorange' 'lorange' 'midrange' dB
            max_slope_all = Get slope... 0 'lorange' 'lorange' 11025 dB
            max_lo = Get mean... 0 'lorange' dB
            max_mid = Get mean... 'lorange' 'midrange' dB
            max_hi = Get mean... 'midrange' 11025 dB
            max_all = Get mean... 0 11025 dB
            max_lo_int = 'max_lo'/'max_all'
            max_mid_int = 'max_mid'/'max_all'
            max_hi_int = 'max_hi'/'max_all'
            Remove

            select Spectrum 'sound_name$'_max
            plus Sound 'sound_name$'_part_22050_band_part
            Remove
            
            # now around the 25% point

            select Sound 'sound_name$'_part_22050_band
            Extract part... 'st_25' 'et_25' rectangular 1.0 yes         
            To Spectrum: "yes"
                     
            
            st_ctr_s= Get centre of gravity... 2
            st_sd_s= Get standard deviation... 2
            st_skew_s= Get skewness... 2
            st_kur_s= Get kurtosis... 2
            Rename...  'sound_name$'_st
                
            To Ltas (1-to-1)
            st25_slope = Get slope... 0 lorange midrange 11025 dB
            st25_slope_hi = Get slope... 'lorange' 'midrange' 'midrange' 11025 dB
            st25_slope_lo = Get slope... 0 'lorange' 'lorange' 'midrange' dB
            st25_slope_all = Get slope... 0 'lorange' 'lorange' 11025 dB
            st25_lo = Get mean... 0 'lorange' dB
            st25_mid = Get mean... 'lorange' 'midrange' dB
            st25_hi = Get mean... 'midrange' 11025 dB
            st25_all = Get mean... 0 11025 dB
            st25_lo_int = 'st25_lo'/'st25_all'
            st25_mid_int = 'st25_mid'/'st25_all'
            st25_hi_int = 'st25_hi'/'st25_all'
            Remove
                
            select Spectrum 'sound_name$'_st
            plus Sound 'sound_name$'_part_22050_band_part
            Remove

            # then midpoint

            select Sound 'sound_name$'_part_22050_band
            Extract part... 'burst' 'fe' rectangular 1.0 yes            
            To Spectrum: "yes"  
            
            mid_ctr= Get centre of gravity... 2
            mid_sd= Get standard deviation... 2
            mid_skew= Get skewness... 2
            mid_kur= Get kurtosis... 2
            Rename...  'sound_name$'_mid

            To Ltas (1-to-1)
            mid_slope = Get slope... 0 lorange midrange 11025 dB
            mid_slope_hi = Get slope... 'lorange' 'midrange' 'midrange' 11025 dB
            mid_slope_lo = Get slope... 0 'lorange' 'lorange' 'midrange' dB
            mid_slope_all = Get slope... 0 'lorange' 'lorange' 11025 dB
            mid_lo = Get mean... 0 'lorange' dB
            mid_mid = Get mean... 'lorange' 'midrange' dB
            mid_hi = Get mean... 'midrange' 11025 dB
            mid_all = Get mean... 0 11025 dB
            mid_lo_int = 'mid_lo'/'mid_all'
            mid_mid_int = 'mid_mid'/'mid_all'
            mid_hi_int = 'mid_hi'/'mid_all'
            Remove
                
            select Spectrum 'sound_name$'_mid
            plus Sound 'sound_name$'_part_22050_band_part
            Remove
            
            # then burst 20 ms

            select Sound 'sound_name$'_part_22050_band
            Extract part... 'burst' 'burst_20' rectangular 1.0 yes          
            To Spectrum: "yes"

            br20_ctr_s= Get centre of gravity... 2
            br20_sd_s= Get standard deviation... 2
            br20_skew_s= Get skewness... 2
            br20_kur_s= Get kurtosis... 2
            Rename...  'sound_name$'_br

            To Ltas (1-to-1)
            br20_slope = Get slope... 0 lorange midrange 11025 dB
            br20_slope_hi = Get slope... 'lorange' 'midrange' 'midrange' 11025 dB
            br20_slope_lo = Get slope... 0 'lorange' 'lorange' 'midrange' dB
            br20_slope_all = Get slope... 0 'lorange' 'lorange' 11025 dB
            br20_lo = Get mean... 0 'lorange' dB
            br20_mid = Get mean... 'lorange' 'midrange' dB
            br20_hi = Get mean... 'midrange' 11025 dB
            br20_all = Get mean... 0 11025 dB
            br20_lo_int = 'br20_lo'/'br20_all'
            br20_mid_int = 'br20_mid'/'br20_all'
            br20_hi_int = 'br20_hi'/'br20_all'
            Remove
            select Spectrum 'sound_name$'_br
            #select Spectrum 'speaker$'_br
            plus Sound 'sound_name$'_part_22050_band_part
            Remove

            # then burst 10 ms

            select Sound 'sound_name$'_part_22050_band

            Extract part... 'burst' 'burst_10' rectangular 1.0 yes          
            To Spectrum: "yes"

            br10_ctr_s= Get centre of gravity... 2
            br10_sd_s= Get standard deviation... 2
            br10_skew_s= Get skewness... 2
            br10_kur_s= Get kurtosis... 2
            Rename...  'sound_name$'_br10

            To Ltas (1-to-1)
            br10_slope = Get slope... 0 lorange midrange 11025 dB
            br10_slope_hi = Get slope... 'lorange' 'midrange' 'midrange' 11025 dB
            br10_slope_lo = Get slope... 0 'lorange' 'lorange' 'midrange' dB
            br10_slope_all = Get slope... 0 'lorange' 'lorange' 11025 dB
            br10_lo = Get mean... 0 'lorange' dB
            br10_mid = Get mean... 'lorange' 'midrange' dB
            br10_hi = Get mean... 'midrange' 11025 dB
            br10_all = Get mean... 0 11025 dB
            br10_lo_int = 'br10_lo'/'br10_all'
            br10_mid_int = 'br10_mid'/'br10_all'
            br10_hi_int = 'br10_hi'/'br10_all'
            Remove
            select Spectrum 'sound_name$'_br10
            plus Sound 'sound_name$'_part_22050_band_part
            Remove
            
            #still B. Smith
            #ah, yes, don't forget intensity measures

            if fe-burst > 6.4/500 
            
                select Sound 'sound_name$'_part_22050_band
                To Intensity... 500 0 no
                avg_int_s= Get mean... 'burst' 'fe' dB
                burst_int_10= Get mean... 'burst' 'burst_10' dB
                burst_int_20= Get mean... 'burst' 'burst_20' dB
                st25_int_s= Get mean... 'st_25' 'et_25' dB
                last_int_s= Get mean... 'fe_20' 'fe' dB
                maxtime = Get time of maximum... 'burst' 'fe' Cubic
                max_int = Get maximum... 'burst' 'fe' Cubic
                rise_time_s = ('maxtime'-'burst')*1000 
                #rise_time_s is actually in ms
                norm_rise = 'rise_time_s'/'stop_dur'
                Remove
                
            endif
        
            #FYI: 'stop_dur' is calculated above as vo - burst
            
            # clean up
            select Sound 'sound_name$'_part_22050
            plus Sound 'sound_name$'_part
            plus Sound 'sound_name$'_part_22050_band
            Remove
        else
            print  SKIPPING THIS TOKEN: 'error$'
        endif

        fileappend 'outfile$' ,'.left_bound:3','.right_bound:3','.cog_max:0','.sib_start:3','.cog_max_time:3','.sib_end:3','mid_ctr:3','mid_slope_lo:3','maxtime:3','max_int:3','rise_time_s:3','norm_rise:3','error$'
        
        if interactive_session == 1
            editor TextGrid 'textgrid_name$'
            Select... '.sib_start' '.sib_end'
            endeditor
        endif


    endif

endproc
