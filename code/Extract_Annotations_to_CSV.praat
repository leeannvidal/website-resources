# Script to Extract annotations from Praat Textgrids to CSV file

###### Explanation of the Script ###### 
    # This script extracts various annotations from Praat TextGrids and saves them into a CSV file. The key functionalities include:

    ## Save as CSV: The script saves the results as a CSV file instead of a TXT file.
    ## Tier Name Extraction: It extracts tier names and uses them to extract labels instead of tier numbers.
    ## Diacritics and IPA Conversions: It replaces Spanish diacritics, converts text to IPA, and provides correct phonological context and word class labels.
    ## Formant Extraction: It extracts F1, F2, F3, F4, and F5 formant measurements at 11 equidistant time points.
    ## Additional Annotations: It extracts annotations from tiers to be added to columns in the CSV.
    ## Uppercase to Lowercase Conversion: It converts uppercase letters to lowercase for hostwords.
    ## Duration Calculation: It calculates the duration of segments and their associated hostwords.

###### Notes for Customization ###### 
    ## To use this script, you may need to modify several parts to match your specific needs. Here are the key areas you might need to change:

    ## Directory and File Paths: Update the paths to your sound files, TextGrid files, and the results file.
    ## Formant Analysis Parameters: Adjust the parameters for formant analysis as needed.
    
###### Naming Conventions ###### 
	# This script matches a .wav file to a .TextGrid file based on naming conventions. 
	# If you have .wav files for speakers and multiple TextGrids for each speaker, 
	# ensure the names match. For example, if you have a speaker number 98 from the US, 
	# name your .wav file 90USA.wav and the TextGrid should also start with 90USA. 
	# You can add additional information to the TextGrid file name, such as 90USA_vowels.TextGrid. 
	# Just make sure to include the additional part in the TextGrid file extension field on the form (e.g., _vowels.TextGrid), 
	# and Praat will know to match those files.

###### Usage and Disclaimer ###### 
    # This script is distributed under the GNU General Public License. 
    # You are free to use, modify, and distribute this script as you wish. 
    # However, the author is not responsible for any errors or issues 
    # that may arise from the use of this script. Use it at your own risk.
    # 08.07.2024 Lee-Ann Vidal Covas


###### End of Explanations ######

# Form to collect user input for directories and file names

		# NOTES:                                                                                
		# 1) Remember to add a / or \ (depending on the OS) to the end of all paths. 
		# 2) Because this script converts Arpabet to Unicode IPA, make sure Praat's text writing preferences 
		# are set to UTF-8 before running the script (it is stipulated in the script itself). If you intend to view 
		# the results file in Excel, you will have to open it from within Excel and import it specifying 
		# UTF-8 encoding in order for the characters to display correctly. If reading in R or RStudio, you
		# can read.csv and it will read the IPA symbols correctly.



form Extract LABELS, FORMANTS & DURMS labeled segments in files
	comment Directory. Be sure to include the final "/" or "\" (depending on the OS) to the end of all paths. 
	sentence Sound_directory /path/to/your/soundfiles/
	sentence Sound_file_extension .wav
	sentence TextGrid_directory /path/to/your/textgrids/
	sentence TextGrid_file_extension _YourTextGrid.TextGrid
	sentence resultsfile_(Full_path) /path/to/your/resultsfile.csv
	comment Particulars for formant analysis. 
	positive Time_step_(Formants) 0.01
	integer Maximum_number_of_formants 5
	positive Maximum_formant_(Hz) 5500
	positive Window_length_(s) 0.010
	real Preemphasis_from_(Hz) 50
	endform

Text writing preferences: "UTF-8"

###### Create File Listings and Check Results File ###### 

# Make a listing of all the sound files in a directory:
Create Strings as file list... list 'sound_directory$'*'sound_file_extension$'
numberOfFiles = Get number of strings


# Check if the result file exists:
if fileReadable (resultsfile$)
	pause The file 'resultsfile$' already exists! Do you want to overwrite it?
	filedelete 'resultsfile$'
endif

# Create a header row for the result file: (remember to edit this as you add or change the analyses! Dont leave any space between the comma and the name as it will add a white space to the value!)
header$ = "SPEAKER,TMIN,PHONO_FORM,PHONO_FORM_INDEX,PHONO_FORM_DURMS,PHONO_CONTEXT, HOSTWORD,HOSTWORD_DURMS,HOSTWORD_INDEX,NTOKENS_WORD,SURF_FORM,POS_SYL,POS_WORD,NSYL_WORD,PREV_SOUND,FOLL_SOUND,SYL_TYPE,WORD_CLASS,STRESS,F1_STEP1,F1_STEP2,F1_STEP3,F1_STEP4,F1_STEP5,F1_STEP6,F1_STEP7,F1_STEP8,F1_STEP9,F1_STEP10,F1_STEP11,F2_STEP1,F2_STEP2,F2_STEP3,F2_STEP4,F2_STEP5,F2_STEP6,F2_STEP7,F2_STEP8,F2_STEP9,F2_STEP10,F2_STEP11,F3_STEP1,F3_STEP2,F3_STEP3,F3_STEP4,F3_STEP5,F3_STEP6,F3_STEP7,F3_STEP8,F3_STEP9,F3_STEP10,F3_STEP11,F4_STEP1,F4_STEP2,F4_STEP3,F4_STEP4,F4_STEP5,F4_STEP6,F4_STEP7,F4_STEP8,F4_STEP9,F4_STEP10,F4_STEP11,F5_STEP1,F5_STEP2,F5_STEP3,F5_STEP4,F5_STEP5,F5_STEP6,F5_STEP7,F5_STEP8,F5_STEP9,F5_STEP10,F5_STEP11'newline$'"
fileappend "'resultsfile$'" 'header$'

###### Process Each Sound File ###### 

# Open each sound file in the directory:
for ifile to numberOfFiles
	filename$ = Get string... ifile
	Read from file... 'sound_directory$''filename$'

	# get the name of the sound object:
	soundname$ = selected$ ("Sound", 1)

	# Look for a TextGrid by the same name plus the extension:
	gridfile$ = "'textGrid_directory$''soundname$''textGrid_file_extension$'"

    ###### Check and Read TextGrid File ###### 
	
	# if a TextGrid exists, open it and do the analysis:
	if fileReadable (gridfile$)
		Read from file... 'gridfile$'
		Rename... 'soundname$'

        ###### Perform Formant Analysis ###### 

		# formant analysis
		select Sound 'soundname$'
		To Formant (burg)... time_step maximum_number_of_formants maximum_formant window_length preemphasis_from

		select TextGrid 'soundname$'

        ### ###### Extract Tier Names ###### 

		nTiers = Get number of tiers
		for tier to nTiers
		tierName$ = Get tier name: tier

		if tierName$ = "Host__Word"
			word_tier = tier

		elsif tierName$ = "num_tokens_per_host_word"
			ntok_word = tier

		elsif tierName$ = "Phonological"
			phono_tier = tier

		elsif tierName$ = "Phonological_Context"
			phono_context_tier = tier

		elsif tierName$ = "Surface_Form"
			sf_tier = tier

		elsif tierName$ = "POS_IN_SYLL"
			pos_syl_tier = tier

		elsif tierName$ = "POW"
			pow_tier = tier

		elsif tierName$ = "Num_of_Syllables"
			num_syl_tier = tier

		elsif tierName$ = "Previous_Sound"
			prev_tier = tier

		elsif tierName$ = "Following_Sound"
			follow_tier = tier

		elsif tierName$ = "Syllable_Type"
			syllable_type_tier = tier

		elsif tierName$ = "Word_Class"
			word_class_tier = tier

		elsif tierName$ = "Syllable_Stress"
			stress_tier = tier

		endif
		endfor
			
		numberOfIntervals = Get number of intervals... 

        ###### Analyze Each Interval ###### 

		# Pass through all intervals in the designated tier, and if they have a label, do the analysis:
		for interval to numberOfIntervals
		label_phono$ = Get label of interval... phono_tier interval
		if label_phono$ <> ""

        ###### Calculate Interval Durations and 11 equidistant steps to extract formants from  ###### 

		# duration:
		token_start = Get starting point... phono_tier interval
		token_end = Get end point... phono_tier interval
		token_durms = (token_end - token_start)*1000
		token_start2 = token_start + (5/1000)
		token_end2 = token_end - (5/1000)
		token_step2 = token_start2 + (token_end2 - token_start2)*0.1
		token_step3 = token_start2 + (token_end2 - token_start2)*0.2
		token_step4 = token_start2 + (token_end2 - token_start2)*0.3
		token_step5 = token_start2 + (token_end2 - token_start2)*0.4
		token_midpoint = (token_start + token_end) / 2
		token_step7 = token_start2 + (token_end2 - token_start2)*0.6
		token_step8 = token_start2 + (token_end2 - token_start2)*0.7
		token_step9 = token_start2 + (token_end2 - token_start2)*0.8
		token_step10 = token_start2 + (token_end2 - token_start2)*0.9

        ###### Match Intervals in Other Tiers ###### 

		# get the matching interval (at the midpoint) in the word tier
		word_interval = Get interval at time... word_tier token_midpoint
		# get label of interval in the word tier
		label_word$ = Get label of interval... word_tier word_interval
			if label_word$ = ""
					label_word$ = "EMPTY"
			endif
		word_start = Get starting point... word_tier word_interval
		word_end = Get end point... word_tier word_interval
		word_durms = (word_end - word_start)*1000

		# get the matching interval (at the midpoint) in the PHONO_CONTEXT tier
		context_interval = Get interval at time... phono_context_tier token_midpoint
		# get label of interval in the PHONO_CONTEXT tier
		label_context$ = Get label of interval... phono_context_tier context_interval
			if label_context$ = ""
					label_context$ = "EMPTY"
			endif

		# get the matching interval (at the midpoint) in the NTOKENS_WORD tier
		ntokensword_interval = Get interval at time... ntok_word token_midpoint
		# get label of interval in the NTOKENS_WORD tier
		label_ntokensword$ = Get label of interval... ntok_word ntokensword_interval
			if label_ntokensword$ = ""
					label_ntokensword$ = "EMPTY"
			endif
		
		# get the matching interval (at the midpoint) in the SURF_FORM tier
		sf_interval = Get interval at time... sf_tier token_midpoint
		# get label of interval in the SURF_FORM tier
		label_sf$ = Get label of interval... sf_tier sf_interval
			if label_sf$ = ""
					label_sf$ = "EMPTY"
			endif
		
		# get the matching interval (at the midpoint) in the POS_SYL tier
		pos_interval = Get interval at time... pos_syl_tier token_midpoint
		# get label of interval in the POS_SYL tier
		label_pos$ = Get label of interval... pos_syl_tier pos_interval
			if label_pos$ = ""
					label_pos$ = "EMPTY"
			endif
		
		# get the matching interval (at the midpoint) in the POS_WORD tier
		pos_word_interval = Get interval at time... pow_tier token_midpoint
		# get label of interval in the POS_WORD tier
		label_pos_word$ = Get label of interval... pow_tier pos_word_interval
			if label_pos_word$ = ""
					label_pos_word$ = "EMPTY"
			endif
		
		# get the matching interval (at the midpoint) in the NSYL_WORD tier
		nsyl_interval = Get interval at time... num_syl_tier token_midpoint
		# get label of interval in the NSYL_WORD tier
		label_nsyl$ = Get label of interval... num_syl_tier nsyl_interval
			if label_nsyl$ = ""
					label_nsyl$ = "EMPTY"
			endif
		
		# get the matching interval (at the midpoint) in the PREV_SOUND tier
		prev_interval = Get interval at time... prev_tier token_midpoint
		# get label of interval in the PREV_SOUND tier
		label_prev$ = Get label of interval... prev_tier prev_interval
			if label_prev$ = ""
					label_prev$ = "EMPTY"
			endif
		
		# get the matching interval (at the midpoint) in the FOLL_SOUND tier
		following_interval = Get interval at time... follow_tier token_midpoint
		# get label of interval in the FOLL_SOUND tier
		label_following$ = Get label of interval... follow_tier following_interval
			if label_following$ = ""
					label_following$ = "EMPTY"
			endif
		
		# get the matching interval (at the midpoint) in the SYL_TYPE tier
		syltype_interval = Get interval at time... syllable_type_tier token_midpoint
		# get label of interval in the SYL_TYPE tier
		label_syltype$ = Get label of interval... syllable_type_tier syltype_interval
			if label_syltype$ = "1"
			    label_syltype$ = "open"
			elif label_syltype$ = "2"
			    label_syltype$ = "closed"
			elif label_syltype$ = ""
			    label_syltype$ = "EMPTY"
			else
			    # If the label is anything else, it remains unchanged
			endif
		
		# get the matching interval (at the midpoint) in the WORD_CLASS tier
		wordclass_interval = Get interval at time... word_class_tier token_midpoint
		# get label of interval in the WORD_CLASS tier
		label_wordclass$ = Get label of interval... word_class_tier wordclass_interval
			if label_wordclass$ = ""
					label_wordclass$ = "EMPTY"
			endif
		
		# get the matching interval (at the midpoint) in the STRESS tier
		stress_interval = Get interval at time... stress_tier token_midpoint
		# get label of interval in the STRESS tier
		label_stress$ = Get label of interval... stress_tier stress_interval
			if label_stress$ = "1"
			    label_stress$ = "stressed"
			elif label_stress$ = "2"
			    label_stress$ = "unstressed"
			elif label_stress$ = ""
			    label_stress$ = "EMPTY"
			else
			    # If the label is anything else, it remains unchanged
			endif

        ###### Extract Formants ###### 

		# formant extraction
		select Formant 'soundname$'

		# F1
		f1_step1 = Get value at time... 1 token_start2 Hertz Linear
		f1_step2 = Get value at time... 1 token_step2 Hertz Linear
		f1_step3 = Get value at time... 1 token_step3 Hertz Linear
		f1_step4 = Get value at time... 1 token_step4 Hertz Linear
		f1_step5 = Get value at time... 1 token_step5 Hertz Linear
		f1_midpoint = Get value at time... 1 token_midpoint Hertz Linear
		f1_step7 = Get value at time... 1 token_step7 Hertz Linear
		f1_step8 = Get value at time... 1 token_step8 Hertz Linear
		f1_step9 = Get value at time... 1 token_step9 Hertz Linear
		f1_step10 = Get value at time... 1 token_step10 Hertz Linear
		f1_step11 = Get value at time... 1 token_end2 Hertz Linear

		# F2
		f2_step1 = Get value at time... 2 token_start2 Hertz Linear
		f2_step2 = Get value at time... 2 token_step2 Hertz Linear
		f2_step3 = Get value at time... 2 token_step3 Hertz Linear
		f2_step4 = Get value at time... 2 token_step4 Hertz Linear
		f2_step5 = Get value at time... 2 token_step5 Hertz Linear
		f2_midpoint = Get value at time... 2 token_midpoint Hertz Linear
		f2_step7 = Get value at time... 2 token_step7 Hertz Linear
		f2_step8 = Get value at time... 2 token_step8 Hertz Linear
		f2_step9 = Get value at time... 2 token_step9 Hertz Linear
		f2_step10 = Get value at time... 2 token_step10 Hertz Linear
		f2_step11 = Get value at time... 2 token_end2 Hertz Linear

		# F3
		f3_step1 = Get value at time... 3 token_start2 Hertz Linear
		f3_step2 = Get value at time... 3 token_step2 Hertz Linear
		f3_step3 = Get value at time... 3 token_step3 Hertz Linear
		f3_step4 = Get value at time... 3 token_step4 Hertz Linear
		f3_step5 = Get value at time... 3 token_step5 Hertz Linear
		f3_midpoint = Get value at time... 3 token_midpoint Hertz Linear
		f3_step7 = Get value at time... 3 token_step7 Hertz Linear
		f3_step8 = Get value at time... 3 token_step8 Hertz Linear
		f3_step9 = Get value at time... 3 token_step9 Hertz Linear
		f3_step10 = Get value at time... 3 token_step10 Hertz Linear
		f3_step11 = Get value at time... 3 token_end2 Hertz Linear

		# F4
		f4_step1 = Get value at time... 4 token_start2 Hertz Linear
		f4_step2 = Get value at time... 4 token_step2 Hertz Linear
		f4_step3 = Get value at time... 4 token_step3 Hertz Linear
		f4_step4 = Get value at time... 4 token_step4 Hertz Linear
		f4_step5 = Get value at time... 4 token_step5 Hertz Linear
		f4_midpoint = Get value at time... 4 token_midpoint Hertz Linear
		f4_step7 = Get value at time... 4 token_step7 Hertz Linear
		f4_step8 = Get value at time... 4 token_step8 Hertz Linear
		f4_step9 = Get value at time... 4 token_step9 Hertz Linear
		f4_step10 = Get value at time... 4 token_step10 Hertz Linear
		f4_step11 = Get value at time... 4 token_end2 Hertz Linear

		# F5
		f5_step1 = Get value at time... 5 token_start2 Hertz Linear
		f5_step2 = Get value at time... 5 token_step2 Hertz Linear
		f5_step3 = Get value at time... 5 token_step3 Hertz Linear
		f5_step4 = Get value at time... 5 token_step4 Hertz Linear
		f5_step5 = Get value at time... 5 token_step5 Hertz Linear
		f5_midpoint = Get value at time... 5 token_midpoint Hertz Linear
		f5_step7 = Get value at time... 5 token_step7 Hertz Linear
		f5_step8 = Get value at time... 5 token_step8 Hertz Linear
		f5_step9 = Get value at time... 5 token_step9 Hertz Linear
		f5_step10 = Get value at time... 5 token_step10 Hertz Linear
		f5_step11 = Get value at time... 5 token_end2 Hertz Linear


        ###### Convert Text and Replace Diacritics ###### 


		# Call procedures to convert text and replace diacritics

		# To change diacritics in other tiers, simply replace the tier name after "Call ReplaceAccents"
		label_word$ = replace_regex$ (label_word$, "[A-Z]", "\L&", 0)
		call ReplaceAccents label_word$
		call ConvertTextIPA label_phono$
		call ConvertTextIPA label_sf$
		call ReplacePhonoContext label_context$
		call ReplaceWordClass label_wordclass$
		call ReplacePrevFollSounds label_prev$
		call ReplacePrevFollSounds label_following$


        ###### Procedures ###### 


		#PROCEDURE TO REPLACE DIACRITICS/ACCENTS WITH LOWERCASE vowel
		procedure ReplaceAccents diacritic$
		'diacritic$' = replace_regex$ ('diacritic$', "Á", "a", 0)
		'diacritic$' = replace_regex$ ('diacritic$', "É", "e", 0)
		'diacritic$' = replace_regex$ ('diacritic$', "Í", "i", 0)
		'diacritic$' = replace_regex$ ('diacritic$', "Ó", "o", 0)
		'diacritic$' = replace_regex$ ('diacritic$', "Ú", "u", 0)
		'diacritic$' = replace_regex$ ('diacritic$', "Ü", "u", 0)
		'diacritic$' = replace_regex$ ('diacritic$', "á", "a", 0)
		'diacritic$' = replace_regex$ ('diacritic$', "é", "e", 0)
		'diacritic$' = replace_regex$ ('diacritic$', "í", "i", 0)
		'diacritic$' = replace_regex$ ('diacritic$', "ó", "o", 0)
		'diacritic$' = replace_regex$ ('diacritic$', "ú", "u", 0)
		'diacritic$' = replace_regex$ ('diacritic$', "ü", "u", 0)
		endproc

		procedure ReplacePrevFollSounds ipa$
		'ipa$' = replace_regex$ ('ipa$', "NA", "pause", 0)
		'ipa$' = replace_regex$ ('ipa$', "l2", "ɫ", 0)
		'ipa$' = replace_regex$ ('ipa$', "ɡ$", "g", 0)
		'ipa$' = replace_regex$ ('ipa$', "d2", "ð", 0)
		'ipa$' = replace_regex$ ('ipa$', "ng", "ŋ", 0)
		'ipa$' = replace_regex$ ('ipa$', "g2", "ɣ", 0)
		'ipa$' = replace_regex$ ('ipa$', "ɡ2", "ɣ", 0)
		'ipa$' = replace_regex$ ('ipa$', "b2", "β", 0)
		'ipa$' = replace_regex$ ('ipa$', "r2", "ɹ", 0)
		'ipa$' = replace_regex$ ('ipa$', "0l$", "l", 0) 
		endproc

		procedure ConvertTextIPA ipa$
		'ipa$' = replace_regex$ ('ipa$', "dx", "ɾ", 0)
		'ipa$' = replace_regex$ ('ipa$', "\?", "ʔ", 0)
		'ipa$' = replace_regex$ ('ipa$', "dark-l", "ɫ", 0)
		endproc

		procedure ReplacePhonoContext context$
		'context$' = replace_regex$ ('context$', "la$", "V___V", 0)
		'context$' = replace_regex$ ('context$', "la1", "V___V", 0)
		'context$' = replace_regex$ ('context$', "la2", "V___V", 0)
		'context$' = replace_regex$ ('context$', "lb1", "#___", 0)
		'context$' = replace_regex$ ('context$', "lb2", "Cσ___", 0)
		'context$' = replace_regex$ ('context$', "lc1", "[σC___V", 0)
		'context$' = replace_regex$ ('context$', "lc2", "C[σC___", 0)
		'context$' = replace_regex$ ('context$', "lc3", "V[σC___", 0)
		'context$' = replace_regex$ ('context$', "lc4", "V___#V", 0)
		'context$' = replace_regex$ ('context$', "ld1", "V___C", 0)
		'context$' = replace_regex$ ('context$', "ld2", "V___#C", 0)
		'context$' = replace_regex$ ('context$', "ld3", "V___##", 0)
		'context$' = replace_regex$ ('context$', "a$", "V___V", 0)
		'context$' = replace_regex$ ('context$', "a1", "V___V", 0)
		'context$' = replace_regex$ ('context$', "a2", "V___V", 0)
		'context$' = replace_regex$ ('context$', "b1", "#___", 0)
		'context$' = replace_regex$ ('context$', "b2", "Cσ___", 0)
		'context$' = replace_regex$ ('context$', "c1", "[σC___V", 0)
		'context$' = replace_regex$ ('context$', "c2", "C[σC___", 0)
		'context$' = replace_regex$ ('context$', "c3", "V[σC___", 0)
		'context$' = replace_regex$ ('context$', "c4", "V___#V", 0)
		'context$' = replace_regex$ ('context$', "d1", "V___C", 0)
		'context$' = replace_regex$ ('context$', "d2", "V___#C", 0)
		'context$' = replace_regex$ ('context$', "d3", "V___##", 0)
		endproc

		procedure ReplaceWordClass wordclass$
		'wordclass$' = replace_regex$ ('wordclass$', "1c", "noun_common", 0)
		'wordclass$' = replace_regex$ ('wordclass$', "1$", "noun_common", 0)
		'wordclass$' = replace_regex$ ('wordclass$', "1p", "noun_proper", 0)
		'wordclass$' = replace_regex$ ('wordclass$', "2i$", "verb_infinitive", 0)
		'wordclass$' = replace_regex$ ('wordclass$', "2c$", "verb_conjugated", 0)
		'wordclass$' = replace_regex$ ('wordclass$', "2p", "verb_participle", 0)
		'wordclass$' = replace_regex$ ('wordclass$', "2t", "verb_participle", 0)
		'wordclass$' = replace_regex$ ('wordclass$', "2g", "verb_gerund", 0)
		'wordclass$' = replace_regex$ ('wordclass$', "2iP", "verb_infinitive_pronoun", 0)
		'wordclass$' = replace_regex$ ('wordclass$', "2cP", "verb_conjugated_pronoun", 0)
		'wordclass$' = replace_regex$ ('wordclass$', "3", "determiner", 0)
		'wordclass$' = replace_regex$ ('wordclass$', "4", "adjective", 0)
		'wordclass$' = replace_regex$ ('wordclass$', "5", "adverb", 0)
		'wordclass$' = replace_regex$ ('wordclass$', "6", "pronoun", 0)
		'wordclass$' = replace_regex$ ('wordclass$', "7", "preposition", 0)
		'wordclass$' = replace_regex$ ('wordclass$', "8", "conjunction", 0)
		'wordclass$' = replace_regex$ ('wordclass$', "9", "other", 0)
		endproc

        ###### Save Results to CSV ###### 

		# Save result to text file: (remember to edit this if you add or change the analyses! Dont leave any space between the comma and the name as it will add a white space to the value!)
		resultline$ = "'soundname$','token_start','label_phono$','interval','token_durms','label_context$','label_word$','word_durms','word_interval','label_ntokensword$','label_sf$','label_pos$','label_pos_word$','label_nsyl$','label_prev$','label_following$','label_syltype$','label_wordclass$','label_stress$','f1_step1','f1_step2','f1_step3','f1_step4','f1_step5','f1_midpoint','f1_step7','f1_step8','f1_step9','f1_step10','f1_step11','f2_step1','f2_step2','f2_step3','f2_step4','f2_step5','f2_midpoint','f2_step7','f2_step8','f2_step9','f2_step10','f2_step11','f3_step1','f3_step2','f3_step3','f3_step4','f3_step5','f3_midpoint','f3_step7','f3_step8','f3_step9','f3_step10','f3_step11','f4_step1','f4_step2','f4_step3','f4_step4','f4_step5','f4_midpoint','f4_step7','f4_step8','f4_step9','f4_step10','f4_step11','f5_step1','f5_step2','f5_step3','f5_step4','f5_step5','f5_midpoint','f5_step7','f5_step8','f5_step9','f5_step10','f5_step11''newline$'"
		fileappend "'resultsfile$'" 'resultline$'

		# select the TextGrid so we can iterate to the next interval:
		select TextGrid 'soundname$'
		endif
		endfor
		# Remove the TextGrid, Formant, and Pitch objects
		select TextGrid 'soundname$'
		Remove
		select Formant 'soundname$'
		Remove
	endif
	# Remove the Sound object
	select Sound 'soundname$'
	Remove
	# and go on with the next sound file!
	select Strings list
endfor

###### Cleanup ###### 

# When everything is done, remove the list of sound file paths:
select all
Remove
writeInfoLine: "Done."