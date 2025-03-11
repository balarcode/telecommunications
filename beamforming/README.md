## Adaptive Beamforming Algorithms for Antenna Arrays

### Introduction

The constrained constant modulus (CCM) criterion can be very useful in circumstances where the signal of interest (SOI) is known beforehand. Under these circumstances, a look-direction constraint can be applied allowing the wireless receiver to quickly subtract out undesirable interference and hone in on the SOI by applying a gain. The CCM criterion is especially powerful in solving this problem due to its simplicity and effectiveness. It simply measures a deviation of the beamformer output from a constant modulus condition and puts a constraint to the array response to the desired signal.

In situations where the SOI is not known prior to detection, a wireless receiver array is said to be "blind". Blind adaptive beamforming is an elegant solution to this problem and can be quickly and easily implemented to extract one signal out of many interfering signals plus noise. However, multiple signals must be extracted and subsequently subtracted before the desired signal is found. The constant modulus algorithm (CMA) constraint for beamforming is a natural fit for this problem because it extracts signals from an array output by exploiting the low modulus fluctuation exhibited by most communications signals.

The work done provides an analysis of the constrained constant modulus algorithm using Auxiliary Vector Filtering (AVF) for the case when a look-direction is already known. An additional analysis of the unconstrained constant modulus algorithm using a Recursive Least Squares (RLS) approach is provided for the case when the SOI is not known.

### Simulation and Results

#### Constrained Constant Modulus Algorithm using Auxiliary Vector Filtering

![Source and Filtered Data](results/figure_ccm_avf_01.png)

![Filter Frequency Response](results/figure_ccm_avf_03.png)

![Absolute Error and SINR](results/figure_ccm_avf_02.png)

#### Unconstrained Constant Modulus Algorithm using Recursive Least Squares Approach

![Source and Filtered Data](results/figure_rls_cma_01.png)

![Filter Frequency Response](results/figure_rls_cma_03.png)

![Absolute Error and SINR](results/figure_rls_cma_02.png)

## Citation

Please note that the technical details made available are for educational purposes only. The repo is not open for collaboration.

If you happen to use the code from this repo, please cite my user name along with link to my profile: https://github.com/balarcode. Thank you!
