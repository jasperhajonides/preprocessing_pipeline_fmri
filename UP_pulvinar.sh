#!/bin/sh

## Register mask of pulvinar and LGN to structural data
# Warning: after registration, manual editing of the pulvinar mask is required. 
# input:
#   - FSL FEAT output in $rootdir/$subj/func/UP_001.feat
#   - Pulvinar mask from atlas $outdir/standard/MorelAtlasMNI152/Pulvinar_1mm_MNI.nii.gz

# Hajonides 11/2020

#parameters
subj=$1

#paths
rootdir=/Users/epsy/Documents/Update_protect
outdir=$rootdir
script_path=$rootdir/scripts/mri
subj_path_in=$rootdir/$subj
subj_path_out=$outdir/$subj


file=$outdir/standard/MorelAtlasMNI152/Pulvinar_1mm_MNI.nii.gz
if [ -e "$file" ]; then
    echo "Combining Morel Atlas Pulvinar and LGN volumes"

    fslmaths $outdir/standard/MorelAtlasMNI152/left-vols-1mm/PuA.nii.gz \
    -add $outdir/standard/MorelAtlasMNI152/left-vols-1mm/Pul.nii.gz \
    -add $outdir/standard/MorelAtlasMNI152/left-vols-1mm/PuL.nii.gz \
    -add $outdir/standard/MorelAtlasMNI152/left-vols-1mm/PuM.nii.gz \
    -add $outdir/standard/MorelAtlasMNI152/left-vols-1mm/PuA.nii.gz \
    $outdir/standard/MorelAtlasMNI152/Left_Pulivnar_1mm_MNI.nii.gz

    fslmaths $outdir/standard/MorelAtlasMNI152/right-vols-1mm/PuA.nii.gz \
    -add $outdir/standard/MorelAtlasMNI152/right-vols-1mm/Pul.nii.gz \
    -add $outdir/standard/MorelAtlasMNI152/right-vols-1mm/PuL.nii.gz \
    -add $outdir/standard/MorelAtlasMNI152/right-vols-1mm/PuM.nii.gz \
    -add $outdir/standard/MorelAtlasMNI152/right-vols-1mm/PuA.nii.gz \
    $outdir/standard/MorelAtlasMNI152/Right_Pulivnar_1mm_MNI.nii.gz

    fslmaths $outdir/standard/MorelAtlasMNI152/Right_Pulivnar_1mm_MNI.nii.gz \
    -add $outdir/standard/MorelAtlasMNI152/Left_Pulivnar_1mm_MNI.nii.gz -bin \
    $outdir/standard/MorelAtlasMNI152/Pulvinar_1mm_MNI.nii.gz

    #LGN for bonus
    fslmaths $outdir/standard/MorelAtlasMNI152/left-vols-1mm/LGNmc.nii.gz \
    -add $outdir/standard/MorelAtlasMNI152/left-vols-1mm/LGNpc.nii.gz \
    $outdir/standard/MorelAtlasMNI152/Left_LGN_1mm_MNI.nii.gz

    fslmaths $outdir/standard/MorelAtlasMNI152/right-vols-1mm/LGNmc.nii.gz \
    -add $outdir/standard/MorelAtlasMNI152/right-vols-1mm/LGNpc.nii.gz \
    $outdir/standard/MorelAtlasMNI152/Right_LGN_1mm_MNI.nii.gz

    fslmaths $outdir/standard/MorelAtlasMNI152/Right_LGN_1mm_MNI.nii.gz \
    -add $outdir/standard/MorelAtlasMNI152/Left_LGN_1mm_MNI.nii.gz -bin \
    $outdir/standard/MorelAtlasMNI152/LGN_1mm_MNI.nii.gz
fi

echo "registering std -> example func and transform pulvinar."

run_path=$subj_path_out/func/run-01

# highres -> example func
flirt -in $run_path/UP_001.feat/reg/highres.nii.gz \
-ref $run_path/UP_001.feat/reg/example_func.nii.gz \
-omat $run_path/UP_001.feat/reg/highres2example_func.mat \
-out $run_path/UP_001.feat/reg/highres2example_func

fnirt --in=$run_path/UP_001.feat/reg/standard \
--ref=$run_path/UP_001.feat/reg/highres \
--iout=$run_path/UP_001.feat/reg/standard2highres

applywarp \
--in=$outdir/standard/MorelAtlasMNI152/Pulvinar_1mm_MNI.nii.gz \
--ref=$run_path/UP_001.feat/reg/highres.nii.gz \
--warp=$run_path/UP_001.feat/reg/standard2example_funcwarp \
--premat=$run_path/UP_001.feat/reg/standard2example_func.mat \
--out=$outdir/standard/MorelAtlasMNI152/Pulvinar_1mm_example_func.nii.gz

# use the above registration information to register the pulvinar from std to highres. 
# After manually marking this ROI we use the highres2example_func to get the mask in functional space. 
flirt \
-in $outdir/standard/MorelAtlasMNI152/Pulvinar_1mm_MNI.nii.gz \
-ref $run_path/UP_001.feat/reg/highres.nii.gz \
-applyxfm -init $run_path/UP_001.feat/reg/standard2highres.mat \
-interp nearestneighbour -out $run_path/UP_001.feat/reg/highres_pulvinar.nii.gz


