#!/bin/sh

# Run FSL FEAT registration
# input:
#   -functional runs as .nii images in $rootdir/$subj/func
#   -structural image as T1.nii and T1_brain.nii in $rootdir/$subj/anat

# Hajonides 11/2020


#parameters
subj=$1
runs=$1

#paths
rootdir=/Users/epsy/Documents/Update_protect
outdir=$rootdir
script_path=$rootdir/scripts/mri
subj_path_in=$rootdir/$subj
subj_path_out=$outdir/$subj


for (( r = 1; r < ${#runs[@]}; r++)) do
    echo "$r"
    #define run specific variables
    run=${runs[$r]}
    mkdir $subj_path_out/func/$run
    run_path=$subj_path_out/func/$run
    nii_name="$(ls $subj_path_in/func/* | grep "run" | head -n ${r} | tail -n 1)"
    nr_images="$(fslhd $nii_name | grep "dim4" | head -n 1 | tail -c 4)"
    echo "number of images is $nr_images" 

    if [[ ${runs[$r]} == "run-01" ]]; then
        # reference image is fifth image of first run. 
        rm $rootdir/$subj/func/reference_image*
        fslroi $rootdir/$subj/func/run01.nii $rootdir/$subj/func/reference_image 5 1 
        gunzip $rootdir/$subj/func/reference_image.nii.gz
    fi

    #FEAT
    #we will include motion correction, no smoothing, high pass filter (100), MELODIC, no fieldmap correction
    sed -e "s|VOLUMES|${nr_images}|g"  \
    -e "s|RUN|${run}|g" \
    -e "s|SUBJECT|${subj}|g" \
    -e "s|NAME|${nii_name}|g" \
    $script_path/fsf_files/feat_pipeline_preprocessing_003.fsf > $script_path/fsf_files/${subj}_${runs[$r]}_design_prepFeat.fsf
          
    feat $script_path/fsf_files/${subj}_${runs[$r]}_design_prepFeat.fsf
            

done


    






