# preprocessing_pipeline_fmri
During (f)MRI brain scans, it is common practice to collect a high-resolution scan of the brain (±5 minutes) and multiple lower contrast functional scans that can be completed in 500-2000ms while the subject is performing a task in the scanner. This script ensures all scans are alligned by means of linear and non-linear translations, ICA-based noise components are rejected, brain regions of interest are selected, spatial smoothing is applied where necessary, time courses are de-noised, and general linear models are applied to locate regions of the brain that respond to task-based events. 


This pipeline utilises a combination of function from:
* *FSL*; M.W. Woolrich, S. Jbabdi, B. Patenaude, M. Chappell, S. Makni, T. Behrens, C. Beckmann, M. Jenkinson, S.M. Smith. Bayesian analysis of neuroimaging data in FSL. NeuroImage, 45:S173-86, 2009
* *AFNI* Cox, R. W. (1996). AFNI: software for analysis and visualization of functional magnetic resonance neuroimages. Computers and Biomedical research, 29(3), 162-173.
And atlasses:
* Wang, L., Mruczek, R. E., Arcaro, M. J., & Kastner, S. (2015). Probabilistic maps of visual topography in human cortex. Cerebral cortex, 25(10), 3911-3931.
* Morel, A., Magnin, M., & Jeanmonod, D. (1997). Multiarchitectonic and stereotactic atlas of the human thalamus. Journal of Comparative Neurology, 387(4), 588-630.
* Zhang, Y. and Brady, M. and Smith, S. Segmentation of brain MR images through a hidden Markov random field model and the expectation-maximization algorithm. IEEE Trans Med Imag, 20(1):45-57, 2001.

