#!/bin/sh

# This script calls scripts for fMRI data preprocessing 
# Hajonides 11/2020


#paths
rootdir=/Users/epsy/Documents/Update_protect
script_path=$rootdir/scripts/preprocessing_pipeline_fmri

# subjects and runs to loop over
subjects=(sub-02) 
runs=(unprocessed run-01 run-02 run-03 run-04 run-05 run-06 run-07 run-08)


#loop over subjects
for ((s = 0; s < ${#subjects[@]}; s++ )) do 
    #define subject specific variables
    subj=${subjects[$s]}
    
    #preprocessing, taking the data from the scanner and doing basic preprocessing on functional, anatomical, and fieldmap.
    source  $script_path/UP_prep_T1.sh $subj

    #registration functional data
    source $script_path/UP_registration.sh $subj $runs

    # #(sub)cortical mask prep
    source $script_path/UP_basal_ganglia.sh $subj
    source $script_path/UP_pulvinar.sh $subj

    # Task specific preprocessing
    # - delineated pulvinar + LGN masks
    # - either FIX trained or hand classified txt file
    # - event timings in ./behavioural/SUBJECT/....txt in three column format. 
    source $script_path/UP_task_specific.sh $subj $runs

    # higher level
    source $script_path/UP_higher_level.sh $subj $runs

done