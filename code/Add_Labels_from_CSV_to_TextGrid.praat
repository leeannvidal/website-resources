#Script to add labels from csv file to intervals on textgrid

    ### ------------- Explanation of the Script ------------- 
        # Goals of this script
          # Add correct values to TextGrids using a CSV file 
          
          # HOW?
          
            # For each interval in the phono_tier, get the label of the word in the word_tier
            # Then look at the CSV
            # Check if word (COLUMN NAME "HOSTWORD") & phone (COLUMN NAME "PHONO_FORM") match the labels in Textgrid interval, THEN
            # If they match get the values in the same row for the columns "NSYL_PER_WORD", "WORD_CLASS", and "STRESS"
            # If there IS a value, get the value and label the respective interval in the respective tiers: num_syl_tier, word_class_tier, stress_tier
            # If the row is empty, label the interval with the label CODE

    ### ------------- Notes for Customization ------------- 
        ## To use this script, you may need to modify several parts to match your specific needs. 
        ## Here are the key areas you might need to change:

        ### Pathnames: Change the pathnames for input directories and files accordingly.
        ### Column Names: Change the column names based on your csv file accordingly.
        ### Tier Names: Change the tier names based on your Textgrid accordingly.

        ### ------------- Usage and Disclaimer ------------- 
            # This script is distributed under the GNU General Public License. 
            # You are free to use, modify, and distribute this script as you wish. 
            # However, the author is not responsible for any errors or issues 
            # that may arise from the use of this script. Use it at your own risk.
            ## 07.30.2024 Lee-Ann Vidal Covas

####################################################

# Form to collect user input for directories and file names
        # NOTES:                                                                                
        # 1) Change the dummy pathnames to your pathname
        # 2) Remember to add a / or \ (depending on the OS) to the end of all paths. 

form Add relevant words to additional tier 
    comment Give the directory of the CSV file and TextGrids:
    sentence inputDir /path/to/your/textgrids/
    comment Give the name of the input CSV file with relevant words:
    word inputTable /path/to/your/csvfile.csv
endform

# Create a new directory to save updated TextGrids
createDirectory: "'inputDir$'/Updated"

# Remove any objects open in the object window
select all
numberOfSelectedObjects = numberOfSelected ()
if numberOfSelectedObjects > 0
     Remove
endif

# Clear info window
clearinfo

# Load the CSV file
Read Table from comma-separated file... 'inputTable$'
Rename... table

# find TextGrid files in the specified folder
Create Strings as file list... list 'inputDir$'/*.textgrid
#Create Strings as file list... list 'inputDir$'/*.TextGrid
numberOfFiles = Get number of strings

#appendInfoLine: numberOfFiles

# Loop through each TextGrid file
for ifile to numberOfFiles
   select Strings list
   textgridFile$ = Get string... ifile
   Read from file... 'inputDir$''textgridFile$'
   Rename... textgrid

    # Get tier names and assign them to variables
        nTiers = Get number of tiers
            for tier to nTiers
                tierName$ = Get tier name: tier

                if tierName$ = "Host__Word"
                    word_tier = tier
                elsif tierName$ = "Phonological"
                    phono_tier = tier
                elsif tierName$ = "Num_of_Syllables"
                    num_syl_tier = tier
                elsif tierName$ = "Word_Class"
                    word_class_tier = tier
                elsif tierName$ = "Syllable_Stress"
                    stress_tier = tier
                endif
            endfor

    # go through each interval in tier where the words are located
    numberOfIntervals = Get number of intervals... phono_tier
        appendInfoLine: numberOfIntervals

    ### ------------- Iterate Through Intervals and Compute Midpoints ------------- 

    for each_interval from 1 to numberOfIntervals
            select TextGrid textgrid
              label_phono$ = Get label of interval... phono_tier each_interval
              if label_phono$ <> ""
                    interval_start = Get starting point... phono_tier each_interval
                    interval_end = Get end point... phono_tier each_interval
                    interval_midpoint = (interval_start + interval_end) / 2

                ### ------------- Matching Intervals in Other Tiers ------------- 

                # get the matching interval (at the midpoint) in the word tier
                    word_interval = Get interval at time... word_tier interval_midpoint
                    # get label of interval in the word tier
                    label_word$ = Get label of interval... word_tier word_interval

                  # get the matching interval (at the midpoint) in the NSYL_WORD tier
                    nsyl_interval = Get interval at time... num_syl_tier interval_midpoint
                    # get label of interval in the NSYL_WORD tier
                    label_nsyl$ = Get label of interval... num_syl_tier nsyl_interval

                # get the matching interval (at the midpoint) in the WORD_CLASS tier
                    wordclass_interval = Get interval at time... word_class_tier interval_midpoint
                    # get label of interval in the WORD_CLASS tier
                    label_wordclass$ = Get label of interval... word_class_tier wordclass_interval
                    
                  # get the matching interval (at the midpoint) in the STRESS tier
                    stress_interval = Get interval at time... stress_tier interval_midpoint
                    # get label of interval in the STRESS tier
                    label_stress$ = Get label of interval... stress_tier stress_interval

                    # Append info for debugging
                                # appendInfoLine: "TEXTGRID LABELS: " + "PHONO: " + label_phono$ + "WORD: " + label_word$ + "NSYL: " + label_nsyl$ + "WORD CLASS: " + label_wordclass$ + "STRESS: " + label_stress$

            select Table table

            # get number of rows in table (csv)
            numRows = Get number of rows

            for i to numRows
                        # Retrieve values from the CSV for each row (you can add or delete rows based on need)

                        word$ = Table_table$[i, "HOSTWORD"]
                        phone$ = Table_table$[i, "PHONO_FORM"]
                        #numberOfSyllables$ = Table_table$[i, "NSYL_WORD"]
                        #wordCategory$ = Table_table$[i, "WORD_CLASS"]
                        #stress$ = Table_table$[i, "STRESS"]

                         # Append info for debugging
                                #appendInfoLine: "CVS LABELS!" + "PHONO: " + phone$ + "WORD: " + word$ + "NSYL: " + numberOfSyllables$ + "WORD CLASS: " + wordCategory$ + "STRESS: " + stress$

                # Check if word and phone match the labels
                        if word$ = label_word$ & phone$ = label_phono$
                            numberOfSyllables$ = Get value: i, "NSYL_WORD"
                            wordCategory$ = Get value: i, "WORD_CLASS"
                            stress$ = Get value: i, "STRESS"

                        # Append info for debugging

                            #appendInfoLine: "BOTH" + "PHONO: " + label_phono$ + "WORD: " + label_word$ + "NSYL: " + numberOfSyllables$ + "WORD CLASS: " + wordCategory$ + "STRESS: " + stress$
                        
                          #Set the interval labels

                          select TextGrid textgrid

                          if numberOfSyllables$ <> ""
                            Set interval text... num_syl_tier nsyl_interval 'numberOfSyllables$'
                          else
                            Set interval text... num_syl_tier nsyl_interval CODE
                          endif


                          if wordCategory$ <> ""
                            Set interval text... word_class_tier wordclass_interval 'wordCategory$'
                          else
                            Set interval text... word_class_tier wordclass_interval CODE
                          endif

                          if stress$ <> ""
                            Set interval text... stress_tier stress_interval 'stress$'
                          else 
                            Set interval text... stress_tier stress_interval CODE
                          endif
                        
                        endif
            endfor
            endif

            
    endfor

    # Save modified textgrid
    select TextGrid textgrid
    Save as text file... 'inputDir$'Updated/'textgridFile$'
    appendInfoLine: "updated 'textgridFile$'"

endfor

# Remove all objects
select all
Remove