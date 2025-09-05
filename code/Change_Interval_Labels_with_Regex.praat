 ## Script to change interval labels using regex

  ### ------------- Explanation of the Script ------------- 

    ## This script is designed to change the labels of intervals in 
      ### Praat tiers using regular expressions (regex). 
    ## It performs the following tasks:

      # Identify Tiers: The script identifies and assigns numbers to various 
        ### tiers such as "Host__Word", "Phonological", "Surface_Form", etc.
      # Define Regex Patterns: Various regex patterns are defined for different 
        ### label types such as "word_initial", "word_internal", "pos_onset", etc.
      #Change Interval Labels: The script loops through each interval in the 
        ### "Phonological" tier and applies the regex patterns to change 
        ### the labels in the specified tiers.

  ### ------------- Notes for Customization ------------- 

    ## To use this script, you may need to modify several parts to match your specific needs. 
    ## Here are the key areas you might need to change:

    ### Tier Names: Since your tiers will have different names, update the tier names in the script accordingly.
    ### Regex Patterns: Adjust the regex patterns according to the specific labeling criteria of your project.
    ### Label Changes: Modify the label text that is set in the intervals based on your requirements.

    ### ------------- Usage and Disclaimer ------------- 
      # This script is distributed under the GNU General Public License. 
      # You are free to use, modify, and distribute this script as you wish. 
      # However, the author is not responsible for any errors or issues 
      # that may arise from the use of this script. Use it at your own risk.
      ## 07.30.2024 Lee-Ann Vidal Covas

  # Below is the script with additional annotations for customization:

#Change interval labels using phono context tier 
    #Get tier names
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
      
    numberOfIntervals = Get number of intervals... phono_tier

# Define regex patterns for different label types

      #Position in Word
      word_initial$ = "^(lb1|lc1|b1|c1)$"
      word_internal$ = "^(la|lb2|lc2|lc3|ld1|a|a1|a2|b2|c2|c3|d1)$"
      word_final$ = "^(lc4|ld2|ld3|c4|d2|d3|ld?|d?)$"

      #Syllable Position
      pos_onset$ = "^(la|a1|a2|a|lb1|lb2|lc1|lc2|lc3|b1|b2|c1|c2|c3)$"
      pos_coda$ = "^(lc4|ld1|ld2|ld3|c4|d1|d2|d3)$"

      #Syllable Type
      syl_type_closed$ = "^(lc4|ld1|ld2|ld3|c4|d1|d2|d3|ld?|d?)$"
      syl_type_code$ = "^(la|la1|lc1|a|a1|a2|c1|lb1|lb2|lc2|lc3|b1|b2|c2|c3)$"
      word_open$ = "[l|L|r|R][aeiouáéíóú]$"
      word_closed$ = "[l|L|r|R][aeiouáéíóú][^aeiouáéíóú]$"

      #Phono
      flap$ = "^(a1|c1|c2|c3|c4|d1|d2|d3|d?)$"
      trill$ = "^(a2|b1|b2)"
      lateral$ = "^(la|lb1|lb2|lc1|lc2|lc3|lc4|ld1|ld2|ld3|ld?)$"

### ------------- Iterate Through Intervals and Compute Midpoints ------------- 

for each_interval from 1 to numberOfIntervals
  label_phono$ = Get label of interval... phono_tier each_interval
  if label_phono$ <> ""
    token_start = Get starting point... phono_tier each_interval
    token_end = Get end point... phono_tier each_interval
    token_midpoint = (token_start + token_end) / 2

    ### ------------- Matching Intervals in Other Tiers ------------- 

    # get the matching interval (at the midpoint) in the word tier
        word_interval = Get interval at time... word_tier token_midpoint
        # get label of interval in the word tier
        label_word$ = Get label of interval... word_tier word_interval
        word_start = Get starting point... word_tier word_interval
        word_end = Get end point... word_tier word_interval
        word_durms = (word_end - word_start)*1000

    # get the matching interval (at the midpoint) in the PREV_SOUND tier
        prev_interval = Get interval at time... prev_tier token_midpoint
        # get label of interval in the PREV_SOUND tier
        label_prev$ = Get label of interval... prev_tier prev_interval
        if label_prev$ = ""
          Set interval text... prev_tier each_interval CODEEE
        endif

        # get the matching interval (at the midpoint) in the FOLL_SOUND tier
        following_interval = Get interval at time... follow_tier token_midpoint
        # get label of interval in the FOLL_SOUND tier
        label_following$ = Get label of interval... follow_tier following_interval
        if label_following$ = ""
          Set interval text... follow_tier each_interval CODEEE
        endif 

    # get the matching interval (at the midpoint) in the PHONO_CONTEXT tier
        context_interval = Get interval at time... phono_context_tier token_midpoint
        # get label of interval in the PHONO_CONTEXT tier
        label_context$ = Get label of interval... phono_context_tier context_interval

    # get the matching interval (at the midpoint) in the POS_SYL tier
        pos_interval = Get interval at time... pos_syl_tier token_midpoint
        # get label of interval in the POS_SYL tier
        label_pos$ = Get label of interval... pos_syl_tier pos_interval

    # get the matching interval (at the midpoint) in the POS_WORD tier
          pos_word_interval = Get interval at time... pow_tier token_midpoint
          # get label of interval in the POS_WORD tier
          label_pos_word$ = Get label of interval... pow_tier pos_word_interval

    # get the matching interval (at the midpoint) in the SYL_TYPE tier
        syltype_interval = Get interval at time... syllable_type_tier token_midpoint
        # get label of interval in the SYL_TYPE tier
        label_syltype$ = Get label of interval... syllable_type_tier syltype_interval

        
        ### ------------- Change Labels Based on Regex Patterns defined above-------------

          #  Change Phono labels 
          if index_regex(label_context$, flap$)
            Set interval text... phono_tier each_interval ɾ
          elsif index_regex(label_context$, trill$)
            Set interval text... phono_tier each_interval r
          elsif index_regex(label_context$, lateral$)
            Set interval text... phono_tier each_interval l
          #elsif index_regex(label_context$, phono_code$)
           # Set interval text... phono_tier each_interval CODEEE
          endif

          #  Change PIS labels 
          if index_regex(label_context$, pos_onset$)
            Set interval text... pos_syl_tier each_interval onset
          elsif index_regex(label_context$, pos_coda$)
            Set interval text... pos_syl_tier each_interval coda
          else
            Set interval text... pos_syl_tier each_interval CODEEE
          endif

           #  Change POW labels 
          if index_regex(label_context$, word_initial$)
            label_pos_word$ = "initial"
            Set interval text... pow_tier each_interval initial
          elsif index_regex(label_context$, word_internal$)
            label_pos_word$ = "internal"
            Set interval text... pow_tier each_interval internal
          elsif index_regex(label_context$, word_final$)
            label_pos_word$ = "final"
            Set interval text... pow_tier each_interval final
          endif

          #  Change SYL_TYPE labels 
          if index_regex(label_context$, syl_type_closed$)
            Set interval text... syllable_type_tier each_interval closed
          elsif index_regex(label_context$, syl_type_code$)
            if index_regex(label_word$, word_open$)
              Set interval text... syllable_type_tier each_interval open
            elsif index_regex(label_word$, word_closed$)
              Set interval text... syllable_type_tier each_interval closed
              else 
              Set interval text... syllable_type_tier each_interval CODEEE
            endif
          endif


  endif
endfor
