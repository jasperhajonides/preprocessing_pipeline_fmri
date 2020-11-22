#!/bin/sh

# Further process fMRI data:
#   - register pulvinar mask to fmri data
#   - register Probabilistic atlas to data. 
#   - remove noise by ICA components using FSL FIX
#   - despike data
#   - spatial smoothing in pulvinar
#   - spatial smoothing in basal ganglia
#   - register functional data to standard space
#   - spatial smoothing in visual+parietal masks
#   - run GLM

# input:
#   - functional data in $rootdir/$subj/func/UP_001.feat
#   - FSL FAST basal ganglia mask
#   - probabilistic visual mask atlas $outdir/standard/ProbAtlas_v4/subj_vol_all/maxprob_vol_both.nii.gz
#   - hand classification of ICA components or trained FIX set or it will take an 
#       existing FSL FIX dataset that you can download online (see FSL FIX page)
#   - (pulvinar mask, manually edited: $subj_path_out/mask/highres_subcortex_adjusted.nii.gz)
#   - stimulus timings in $rootdir/behavioural/$subject/*.txt

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

#if pulvinar(+LGN mask) is present
file=$subj_path_out/mask/highres_subcortex_adjusted.nii.gz
if [ -e "$file" ]; then
    echo "Processing Pulvinar masks"
    # isolate subcortical masks 
    applywarp \
    --in=$subj_path_out/mask/highres_subcortex_adjusted.nii.gz \
    --ref=$subj_path_out/func/run-01/UP_001.feat/reg/example_func.nii.gz \
    --premat=$subj_path_out/func/run-01/UP_001.feat/reg/highres2example_func.mat \
    --interp=nn --out=$subj_path_out/mask/example_func_subcortex_adjusted.nii.gz

    fslmaths $subj_path_out/mask/example_func_subcortex_adjusted.nii.gz \
    -uthr 1 $subj_path_out/mask/example_func_pulvinar_adjusted.nii.gz
    fslmaths $subj_path_out/mask/example_func_subcortex_adjusted.nii.gz \
    -thr 2 $subj_path_out/mask/example_func_LGN_adjusted.nii.gz
    
    # include pulvinar processing 
    pulv=true
else
    echo "Skipping pulvinar"
    pulv=false
fi

# # fix visual masks
applywarp \
--in=$outdir/standard/ProbAtlas_v4/subj_vol_all/maxprob_vol_both.nii.gz \
--ref=$subj_path_out/func/run-01/UP_001.feat/reg/example_func.nii.gz \
--premat=$subj_path_out/func/run-01/UP_001.feat/reg/standard2example_func.mat \
--out=$subj_path_out/mask/example_func_Prob_atlas_continuous.nii.gz

applywarp \
--in=$outdir/standard/ProbAtlas_v4/subj_vol_all/maxprob_vol_both.nii.gz \
--ref=$subj_path_out/func/run-01/UP_001.feat/reg/example_func.nii.gz \
--premat=$subj_path_out/func/run-01/UP_001.feat/reg/standard2example_func.mat \
--interp=nn --out=$subj_path_out/mask/example_func_Prob_atlas.nii.gz


for (( r = 1; r < ${#runs[@]}; r++)) do
    run=${runs[$r]}
    mkdir $subj_path_out/func/$run
    run_path=$subj_path_out/func/$run

    # FIX cleanup 
    file=$run_path/UP_001.feat/labels.txt
    if [ -e "$file" ]; then
        echo "hand-clssification exists"
        #apply the noise-signal components marked in the txt file
        # fsl_regfilt -i filtered_func_data -o denoised_data -d filtered_func_data.ica/melodic_mix -f "2,5,9"
        removable_components="$(cd $run_path/UP_001.feat/; tail -n 1 labels.txt  | sed 's/\[/"/g' | sed 's/\]/"/g' | tr -d '[:blank:]')"
        cd $run_path/UP_001.feat/
        echo $removable_components
        fsl_regfilt -i filtered_func_data.nii.gz \
        -o ../regfiltered_func_data.nii.gz \
        -d ./filtered_func_data.ica/melodic_mix \
        -f $removable_components
    elif [-e "$outdir/fix_60runs.Rdata"]; then
        echo "Applying Fix"
        #use marked data to classify noise and signal components
        fix -c $run_path/UP_001.feat $outdir/fix_60runs.Rdata 20
        fix -a $run_path/UP_001.feat/fix4melview....txt -m
    fi

    #remove spikes in data (AFNI)
    export AFNI_3dDespike_NEW=YES 
    3dDespike \
    -nomask \
    -ignore 0 \
    -prefix $run_path/func_data_1_Desp.nii.gz \
    $run_path/regfiltered_func_data.nii.gz
    # remove prev step 
    # rm $run_path/regfiltered_func_data.nii.gz

    if $pulv; then
        #4mm smoothing within subcortical masks 
        #using subject space mask on subject space data to reduce error and out of mask smoothing when selecting voxels
        3dBlurInMask \
        -FWHM 4 \
        -mask $subj_path_out/mask/example_func_pulvinar_adjusted.nii.gz \
        -preserve \
        -prefix $run_path/func_data_2_blur_pulv.nii.gz \
        $run_path/func_data_1_Desp.nii.gz
        # remove prev step 
        rm $run_path/func_data_1_Desp.nii.gz
    fi

    name_in="$(cd $run_path/; ls | grep "func_data_*.nii" | tail -n 1)"
    echo "file name is $name_in" 
    # and basal ganglia
    3dBlurInMask \
    -FWHM 4 \
    -mask $subj_path_out/anat/example_func_basal_ganglia.nii.gz \
    -preserve \
    -prefix $run_path/func_data_4_blur_bg.nii.gz \
    $run_path/$name_in
    # remove prev step 
    rm $run_path/func_data_1_Desp.nii.gz

    #register to standard space to smooth over standard space masks
    flirt \
    -in $run_path/func_data_4_blur_bg.nii.gz \
    -ref $subj_path_out/func/run-01/UP_001.feat/reg/example_func2standard.nii.gz \
    -applyxfm -init $subj_path_out/func/run-01/UP_001.feat/reg/example_func2standard.mat \
    -out $run_path/norm_data_5_flirt.nii.gz

    rm $run_path/norm_data_6_visual_smooth.nii.gz 
    #apply 4mm smoothing within visual mask (R+L)
    3dBlurInMask \
    -FWHM 4 \
    -mask $outdir/standard/ProbAtlas_v4/subj_vol_all/maxprob_vol_both_example_func_dim.nii.gz \
    -preserve \
    -prefix $run_path/norm_data_6_visual_smooth.nii.gz \
    $run_path/norm_data_5_flirt.nii.gz

    #first-level analysis
    nr_images="$(fslhd $run_path/norm_data_6_visual_smooth.nii.gz | grep "dim4" | head -n 1 | tail -c 4)"
    echo "number of images is $nr_images" 

    #FEAT
    #we will include only the GLM from FSL FEAT
    sed -e "s|VOLUMES|${nr_images}|g" \
        -e "s|RUN|${run}|g" \
        -e "s|SUBJECT|${subj}|g" \
        $script_path/fsf_files/stimulus_GLM_localiser_2stim.fsf > $script_path/fsf_files/${subj}_${runs[$r]}_Stim_GLM.fsf
    
    feat $script_path/fsf_files/${subj}_${runs[$r]}_Stim_GLM.fsf

done



