
library(plyr)
library(zoo)

# CHANGE THIS TO THE ACTUAL SCRIPT PATH
source('~/scripts/phonNCSU/acoustic/formant_functions.r')

##############################################################################################
# READ THE one_script OUTPUT AND ADD THE allophone COLUMN
#
# needs formant frequencies and bandwidths from multiple time points with multiple candidates
#
# sample query:
# praat /phon/scripts/one_script.praat '/phon/nc_transcription/my_files.csv' 'STR 2ND VL VR' 'formants(measurements=21,poles0=8,poles_steps=9,keep_all=1,bandwidths=1)' 'l'
##############################################################################################

# CHANGE THIS TO THE ACTUAL FILE PATH AND NAME
data = read.csv('/home/jimielke/somos_nc/one_script_out_2025Apr21_13h52m39.csv', na.strings='--undefined--')

data$allophone = factor(data$phone)
data$allophone0 = as.factor(gsub('[012]', '', paste(data$allophone)))

##############################################################################################
# GET BARK AND DCT VERSIONS OF FORMANT FREQUENCIES AND SELECTED LOG BANDWIDTHS
##############################################################################################

data = bark_all_formants(data)
data = dct_all_formants(data, formants=1:3, subtype='', coefficients=4, bark=TRUE, measurement_points=seq(20,80,5))
data$log_B1_50 = log(data$B1_50)
data$log_B2_50 = log(data$B2_50)

##############################################################################################
# SELECT THE BEST FORMANT CANDIDATES FOR EACH SPEAKER AND PHONE, THEN OPTIMIZE!
##############################################################################################

candidates = choose_candidates_with_B2_50(data, phone_candidates=seq(4,7.5,0.5), speaker_candidates=seq(4.5,6.5,0.5), 
	phone_col='allophone0', speaker_col='speaker')

data = optimize_within_speaker(data, phone_col='allophone0', candidates$best_bw, candidates$best_by_ph, 
	mcols = c('F1DCT0','F1DCT1','F2DCT0','F2DCT1','log_B1_50','log_B2_50'))

# the rows with new_best_mdist == 1 are the ones that were selected as the best measurements

##############################################################################################
# SAVE THE DATA AND MAKE VOWEL PLOTS
##############################################################################################

save(candidates, file='somos_nc_candidates.RData')
save(data, file='somos_nc_formant_data.RData')

optimized_data = subset(data, new_best_mdist == 1)
save(optimized_data, file='my_optimized_formant_data.RData')

cairo_pdf('somos_nc_all_speakers_2025_04_25.pdf', h=6, w=6, onefile=TRUE)
for (sp in unique(optimized_data$speaker)){
	subdata = subset(optimized_data, speaker==sp & allophone0%in%c('a','e','i','o','u'))

	subdata = trimParameter(subdata, c('F2DCT0', 'F1DCT0'), bywhat='allophone0', sds=2)

	plot.vowels(subdata, 'F2DCT0', 'F1DCT0', group.by='allophone0', main=sp)
}
dev.off()


cairo_pdf('somos_nc_all_speakers_nonshort_vowels_2025_04_25.pdf', h=6, w=6, onefile=TRUE)
for (sp in unique(optimized_data$speaker)){
	subdata = subset(optimized_data, speaker==sp & allophone0%in%c('a','e','i','o','u') & phoneend-phonestart>0.05)

	subdata = trimParameter(subdata, c('F2DCT0', 'F1DCT0'), bywhat='allophone0', sds=2)

	plot.vowels(subdata, 'F2DCT0', 'F1DCT0', group.by='allophone0', main=sp)
}
dev.off()
