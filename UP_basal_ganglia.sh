#!/bin/sh

## Subcortical segmentation using FSL FAST
# extracts subcortical structures.
# input:
#   - T1.nii in $rootdir/$subj/anat

# Hajonides 11/2020


#paths
rootdir=/Users/epsy/Documents/Update_protect
script_path=$rootdir/scripts/preprocessing_pipeline_fmri
subj_path_in=$rootdir/$subj
subj_path_out=$rootdir/$subj 

#parameters
subj=$1

# FSL FIRST - subcortical segmentation
run_first_all -i $subj_path_out/anat/T1.nii -o $subj_path_out/anat/first_segmentation

# create Basal ganglia mask from Caudate, Putamen, Pallidus vertices 
first_utils --meshToVol -m $subj_path_out/anat/first_segmentation-L_Caud_first.vtk -i $subj_path_out/anat/T1.nii -l 1 -o $subj_path_out/anat/L_Caudate  
first_utils --meshToVol -m $subj_path_out/anat/first_segmentation-R_Caud_first.vtk -i $subj_path_out/anat/T1.nii -l 1 -o $subj_path_out/anat/R_Caudate  
first_utils --meshToVol -m $subj_path_out/anat/first_segmentation-L_Pall_first.vtk -i $subj_path_out/anat/T1.nii -l 2 -o $subj_path_out/anat/L_Pallidus  
first_utils --meshToVol -m $subj_path_out/anat/first_segmentation-R_Pall_first.vtk -i $subj_path_out/anat/T1.nii -l 2 -o $subj_path_out/anat/R_Pallidus 
first_utils --meshToVol -m $subj_path_out/anat/first_segmentation-L_Puta_first.vtk -i $subj_path_out/anat/T1.nii -l 3 -o $subj_path_out/anat/L_Putamen 
first_utils --meshToVol -m $subj_path_out/anat/first_segmentation-R_Puta_first.vtk -i $subj_path_out/anat/T1.nii -l 3 -o $subj_path_out/anat/R_Putamen 
fslmaths $subj_path_out/anat/L_Caudate -add $subj_path_out/anat/R_Caudate -bin $subj_path_out/anat/T1_Caudate
fslmaths $subj_path_out/anat/L_Pallidus -add $subj_path_out/anat/R_Pallidus -bin -mul 2 $subj_path_out/anat/T1_Pallidus
fslmaths $subj_path_out/anat/L_Putamen -add $subj_path_out/anat/R_Putamen -bin -mul 3 $subj_path_out/anat/T1_Putamen
fslmaths  $subj_path_out/anat/T1_Pallidus -add $subj_path_out/anat/T1_Putamen -sub 5 -abs -rem 5 -add $subj_path_out/anat/T1_Caudate $subj_path_out/anat/T1_basal_ganglia
# rm $subj_path_out/anat/L_* $subj_path_out/anat/R_* $subj_path_out/anat/T1_C* $subj_path_out/anat/T1_P* #cleanup

# resample first masks to functional data
#first, extract reference image at the start of the run, close to fieldmap collection
name_reference="$(cd $subj_path_in/func/; ls | grep "MB4P2_EEG.nii" | head -n 1)"
fslroi $subj_path_in/func/$name_reference $subj_path_out/func/reference_image.nii.gz 4 1

# from T1 space 1mm voxels to functional space 2mm voxels
3dresample \
-master $subj_path_out/func/reference_image.nii  \
-input $subj_path_out/anat/T1_basal_ganglia.nii.gz \
-prefix $subj_path_out/anat/example_func_basal_ganglia.nii.gz

