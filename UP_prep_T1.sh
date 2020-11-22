#!/bin/sh

## Preprocessing structural image
# input:
#   - strucural image in $rootdir/$subj/anat
# Steps:
#   - Apply Field of View
#   - Standardise contrast values
#   - Apply FSL SUSAN for non-linear filtering to reduce noise
#   - Extract brain from image

# Hajonides 11/2020

#paths
rootdir=/Users/epsy/Documents/Update_protect
script_path=$rootdir/scripts/preprocessing_pipeline_fmri
subj_path_in=$rootdir/$subj
subj_path_out=$rootdir/$subj

#parameters
subj=$1

#standard processing T1 (modify grep string to locate file)
 echo "We'll process $name_anat"
echo $name_anat

# reduce FOV 
robustfov -v -b 140 \
-i $subj_path_in/anat/$name_anat \
-r $subj_path_out/anat/anat.nii.gz 

#edit: Image values are already standardised. 
3dUnifize \
-prefix $subj_path_out/anat/anat_unifize.nii.gz \
-input $subj_path_out/anat/anat.nii.gz

# susan <input> <brightness threshold> <spatial size> <dimension> <use median> <n_usans> <output>
susan $subj_path_out/anat/anat.nii.gz 25.3259995 2.0 3 1 0 $subj_path_out/anat/anat_susan.nii.gz

# bet image, isolate brain
bet $subj_path_out/anat/anat_susan.nii.gz $subj_path_out/anat/T1_brain.nii.gz -f 0.4 -R
# rename this to "T1" FEAT
cp -r $subj_path_out/anat/anat_susan.nii.gz $subj_path_out/anat/T1.nii.gz
#unzip
gunzip $subj_path_out/anat/T1.nii
gunzip $subj_path_out/anat/T1_brain.nii

