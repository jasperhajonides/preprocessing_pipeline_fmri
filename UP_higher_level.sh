#!/bin/sh

# Higher level GLM combining different FEAT GLM outputs at a subject level.

# input:   
# input:
#   - FSL FEAT GLM output as $rootdir/$subj/func/xxxx.feat
#   - empty translation matrices that can be added to the $rootdir/$subj/func/xxxx.feat/reg folder. 
# Hajonides 11/2020

#parameters
subj=$1
runs=$1


#paths
rootdir=/Users/epsy/Documents/Update_protect
script_path=$rootdir/scripts/preprocessing_pipeline_fmri
subj_path_in=$rootdir/$subj
subj_path_out=$rootdir/$subj

# FSL will try to transform the data to standard space using the registration files.
# we have already completed this transformation so we will provide empty matrices.  
for (( r = 1; r < ${#runs[@]}; r++)) do
    run=${runs[$r]}
    echo "Copy reg files $run."
    cp -r $rootdir/standard/reg_standard $subj_path_in/func/$run/GLM_001.feat/reg
    cp -r $subj_path_in/func/$run/UP_001.feat/reg/highres.nii.gz $subj_path_in/func/$run/GLM_001.feat/reg/highres.nii.gz
done

# ## higher level FEAT
echo "Running higher level FEAT"
sed -e "s|SUBJECT|$subj|g" \
$script_path/higher_level_template_stimpres.fsf > $script_path/fsf_files/${subj}_higher_level_stimpres.fsf
echo "higher level fsf created."
feat $script_path/fsf_files/${subj}_higher_level_stimpres.fsf
