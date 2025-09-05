# Script to create new tiers

	### ------------- Explanation of the Script ------------- 

		## This script is designed to create new tiers in Praat, a software used for speech analysis. 
		## The script performs the following tasks:

			# Check and Create Tiers: It first checks if certain tiers exist. 
				### If a tier doesn't exist, the script duplicates a specified tier and assigns a new name to it.
			# Update Tier Numbers: It updates the numbers associated with all the tiers.
			# Empty Text in Tiers: The script clears any text in the intervals of certain tiers.
			# Duplicate Additional Tiers: It duplicates additional tiers based on specific criteria.
				### The script checks for the existence of several other tiers like "POW", "Num_of_Syllables", etc.
				### If these tiers do not exist, it duplicates the relevant existing tier and assigns a new name to it.
			# Utility Function: It includes a function to get the tier names and update variables accordingly.

	### ------------- Notes for Customization ------------- 
		## To use this script, you may need to modify several parts to match your specific needs. 
		## Here are the key areas you might need to change:

		### Tier Names: Since your tiers will have different names, update the tier names in the script accordingly.
		### New Tier Position: Adjust the newduplicatetier variable if your tier structure requires a different starting position.
		### Additional Tiers: Add or remove the duplication of tiers based on your requirements.

		### ------------- Usage and Disclaimer ------------- 
			# This script is distributed under the GNU General Public License. 
			# You are free to use, modify, and distribute this script as you wish. 
			# However, the author is not responsible for any errors or issues 
			# that may arise from the use of this script. Use it at your own risk.
			## 07.30.2024 Lee-Ann Vidal Covas

	# Below is the script with additional annotations for customization:

# If necessary, add tiers 
	## Note, the function (procedure) being called is at the end of the script.
call GetTier Phonological_Context phono_context_tier


# Initialize new tier position
newduplicatetier = phono_context_tier + 2
#change to +1 if phono tier doesnt exist
# Adjust newduplicatetier as needed based on your tier structure

# Check and create new tiers
	#### The code for the duplicate tiers takes the following arguments
		#### Duplicate tier: name_of_tier_to_be_copied	position_of_new_tier	name_of_new_tier

# Check and create Phonological tier
	call GetTier Phonological phono_tier
	if phono_tier = 0
		Duplicate tier... phono_context_tier	newduplicatetier	Phonological
		newduplicatetier = newduplicatetier + 1
	endif

# Check and create Surface_Form tier
	call GetTier Surface_Form sf_tier
	if sf_tier = 0
		Duplicate tier... phono_context_tier	newduplicatetier	Surface_Form
		newduplicatetier = newduplicatetier + 1
	endif

# Check and create POS_IN_SYLL tier
call GetTier POS_IN_SYLL pos_syl_tier
		if pos_syl_tier = 0
		Duplicate tier... phono_context_tier	newduplicatetier	POS_IN_SYLL
		newduplicatetier = newduplicatetier + 1
		endif




# Update all tier numbers:
call GetTier Host__Word word_tier
call GetTier num_tokens_per_host_word ntok_word
call GetTier Phonological_Context phono_context_tier
call GetTier Phonological phono_tier
call GetTier Surface_Form sf_tier
call GetTier POS_IN_SYLL pos_syl_tier



# Empty text in tiers

# Clear text in Surface_Form tier
numberOfIntervals = Get number of intervals... sf_tier
	for interval to numberOfIntervals
		label_sf$ = Get label of interval... sf_tier interval 
		if label_sf$ <> ""
		Set interval text... sf_tier interval
		endif
	endfor

# Clear text in POS_IN_SYLL tier
 numberOfIntervals = Get number of intervals... pos_syl_tier
	for interval to numberOfIntervals
		label_pos$ = Get label of interval... pos_syl_tier interval 
		if label_pos$ <> ""
		Set interval text... pos_syl_tier interval
		endif
	endfor

	# ------------- Duplicate rest of tiers based on a different tier -------------
	
	### You can duplicate an already labelled tier (useful if you're using the values to recode into something else later)
	### OR you can duplicate an empty tier so that you can annotate them in Praat later 

			# Check to see if a tier exists and duplicate it if it doesnt

			call GetTier POW pow_tier
			if pow_tier = 0
				Duplicate tier... phono_context_tier	newduplicatetier	POW
				newduplicatetier = newduplicatetier + 1
			endif

			call GetTier Num_of_Syllables num_syl_tier
			if num_syl_tier = 0
				Duplicate tier... pos_syl_tier	newduplicatetier	Num_of_Syllables
				newduplicatetier = newduplicatetier + 1
			endif

			call GetTier Previous_Sound prev_tier
			if prev_tier = 0
				Duplicate tier... pos_syl_tier	newduplicatetier	Previous_Sound
				newduplicatetier = newduplicatetier + 1
			endif

			call GetTier Following_Sound follow_tier
			if follow_tier = 0
				Duplicate tier... pos_syl_tier	newduplicatetier	Following_Sound
				newduplicatetier = newduplicatetier + 1
			endif

			call GetTier Syllable_Type syllable_type_tier
			if syllable_type_tier = 0
				Duplicate tier... phono_context_tier	newduplicatetier	Syllable_Type
				newduplicatetier = newduplicatetier + 1
			endif

			call GetTier Word_Class word_class_tier
			if word_class_tier = 0
				Duplicate tier... pos_syl_tier	newduplicatetier	Word_Class
				newduplicatetier = newduplicatetier + 1
			endif

			call GetTier Syllable_Stress stress_tier
			if stress_tier = 0
				Duplicate tier... pos_syl_tier	newduplicatetier	Syllable_Stress
				newduplicatetier = newduplicatetier + 1
			endif



#------------- Function to get the tier names -------------

procedure GetTier name$ variable$
	numberOfTiers = Get number of tiers
	itier = 1
	repeat
		tier$ = Get tier name... itier
		itier = itier + 1
	until tier$ = name$ or itier > numberOfTiers
	if tier$ <> name$
		'variable$' = 0
	else
		'variable$' = itier - 1
	endif
	
endproc
