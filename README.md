# evoTurb --- 4D wind field generator

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.5028595.svg)](https://doi.org/10.5281/zenodo.5028595)

## 1 Introduction

The evoTurb aims to generate 4D wind fields by constraining multiple independent 3D wind fields generated using `TurbSim` or `Mann turbulence generator (MTG)` with the user-defined longitudinal coherence. 

The evoTurb is available both in Matlab and Python. If you are a Matlab user, please download `evoTurb_matlab`. If you are a Python user, please download `evoTurb_python`. If you don't have TurbSim or MTG, please download `3D wind field generator` and unzip it before running the scripts.

## 2 Methodology

The 4D wind field simulation method is extended from the Veers method of 3D stochastic wind field simulation introduced in [1]. The coherence between any two points in space is assumed to be the multiplication of the lateral-vertical coherence and the longitudinal coherence. For more details regarding the methodology of 4D wind field simulation, please refer to our publication [2].

The evoTurb will first call TurbSim or MTG depending on users' choice to generate 3D wind fields. Then, it will read the 3D wind fields and compute the complex Fourier coefficients. Next, it will multiply the complex Fourier coefficients with the factorization of the longitudinal coherence matrix to constitute the complex Fourier coefficients for the 4D wind field. After that, iFFT is applied to obtain the time series data of wind speed. Finally, two binary files will be exported as results: one is the turbulent wind field on the rotor plane (identified with `_rotor`, same extension as the 3D wind fields) and the other is the upstream wind field (identified with `_upstream` with extension of `.evo`). 

The longitudinal coherence is acquired from the user-defined wind evolution model. The evoTurb supports the following wind evolution models (the wind evolution model is defined by users in the configuration function `TurbConfig`):
- `Exp-UserDefined`: uses the wind evolution model (Eq.4) in [3]. Users are supposed to define the wind evolution model parameters by themselves.
- `Exp-Simley`: uses the wind evolution model (Eq.7) in [3]. The parameterization model is acquired from LES simulations.
- `Kristensen`: uses the wind evolution model (Eq.20) and G-function (Eq.29) in [4]. This model is based on physical assumption.    
- `Exp-GPR`: uses the wind evolution model (Eq.6) and the Gaussian process regression (GPR) models case 15 for a and case 17 for b (Table5) in [5]. The GPR models are trained with measurement data from an onshore flat site (see `acknowledgement`). Due to the limitation of the training data, it is not recommended to use the GPR models for the cases where the separations between the unfrozen planes exceed 109 m. The python version does not support this option.

## 3 Usage

### Software requirements

- The `evoTurb_matlab` obtains best performance in `Matlab 2020b` and is compatible with `Matlab 2018b`. It might also be compatible with lower versions of Matlab but no garantee.
- The `evoTurb_python` requires `Python 3.7`.
- The evoTurb requires either `TurbSim` or `Mann turbulence generator (MTG)`. If you have them installed, please modify the corresponding directories in the configuration function of evoTurb. If you don't have any of them, please download `3D wind field generator` which contains both TurbSim and MTG. The TurbSim executable and the input file `TurbSimInputFileTemplate.inp` are included in the folder `evoTurb\3D wind field generator\TurbSim`. The MTG executable, dll file, and the batch file `run.bat` are included in the folder `evoTurb\3D wind field generator\MannTurb`. 

The TurbSim source code can be found in: https://github.com/OpenFAST/openfast/tree/main/vs-build/TurbSim. 

The Mann turbulence generator is accessible from: https://www.hawc2.dk/download/pre-processing-tools

### General workflow

To use evoTurb, please follow the following steps:
1. Modify the input file for TurbSim `TurbSimInputFileTemplate.inp` or MTG `run.bat` following their instructions. No need to adjust the random seed because this will be defined in the configuration function. 
2. Modify the configuration function: `TurbConfig(.m/.py)`
3. Run the main script: `evoTurb(.m/.py)`

After running the main script, three folders will be created if they don't already exist: 
- `3DTurb_(model name)` to store the 3D wind fields 
- `InputFiles_(model name)` to store the corresponding input files for TurbSim or MTG
- `4DTurb_(model name)` to store the 4D wind fields

### Run test case

A test case is provided to verify this turbulence unfreezing method. This is only available for the matlab version. 

All the relevant files are included in the folder `evoTurb_matlab\example`. The configuration function `CohTestConfig.m` and the input files  `TurbSimInputFileCohTest.inp` and `MannTurbInputFileCohTest.bat` have already been set up for the test case specifically. So, there is no need to adjust these files.

To run the test case, execute the `TestCoherence.m`. This script will generate 8 independent 4D turbulent wind fields and estimate the coherence from the simulated data. Then, the estimated y-z plane coherence will be compared with the analytical coherence according to turbulence model (IEC Kaimal or IEC Mann). Also, the estimated longitudinal coherence will be compared with the user-defined one that is used to simulate the evolving turbulence.

## 4 References

[1] Veers, P. S. (1988). Three-Dimensional Wind Simulation (No. SAND88-0152 UC-261). Albuquerque, New Mexico. 

[2] Chen, Y., Guo, F., Schlipf, D., and Cheng, P. W.: Four-dimensional wind field generation for the aeroelastic simulation of wind turbines with lidars, Wind Energ. Sci., 7, 539–558, https://doi.org/10.5194/wes-7-539-2022, 2022. 

[3] Simley, E., & Pao, L. Y. (2015). A longitudinal spatial coherence model for wind evolution based on large-eddy simulation. In 2015 American Control Conference (ACC) (pp. 3708–3714). IEEE. https://doi.org/10.1109/ACC.2015.7171906

[4] Kristensen, L. (1979). On longitudinal spectral coherence. Boundary-Layer Meteorology, 16(2), 145–153. https://doi.org/10.1007/BF02350508

[5] Chen, Y., Schlipf, D., & Cheng, P. W. (2021). Parameterization of wind evolution using lidar. Wind Energy Science, 6(1), 61–91. https://doi.org/10.5194/wes-6-61-2021

## 5 Code development and maintenance

</a></div><div itemscope itemtype="https://schema.org/Person"><a itemprop="sameAs" content="https://orcid.org/0000-0002-1343-0654" href="https://orcid.org/0000-0002-1343-0654" target="orcid.widget" rel="me noopener noreferrer" style="vertical-align:top;"><img src="https://orcid.org/sites/default/files/images/orcid_16x16.png" style="width:1em;margin-right:.5em;" alt="ORCID iD icon">Yiyin Chen</a></div>

[Stuttgart Wind Energy (SWE), University of Stuttgart](https://www.ifb.uni-stuttgart.de/en/institute/team/Chen-00003/)

contact: chen@ifb.uni-stuttgart.de

</a></div><div itemscope itemtype="https://schema.org/Person"><a itemprop="sameAs" content="https://orcid.org/0000-0003-3275-6243" href="https://orcid.org/0000-0003-3275-6243" target="orcid.widget" rel="me noopener noreferrer" style="vertical-align:top;"><img src="https://orcid.org/sites/default/files/images/orcid_16x16.png" style="width:1em;margin-right:.5em;" alt="ORCID iD icon">Feng Guo</a></div>

[Wind Energy Technology Institute, Flensburg University of Applied Sciences](https://hs-flensburg.de/hochschule/personen/guo)

contact: feng.guo@hs-flensburg.de

## 6 Acknowledgement
The Gaussian process regression models for the wind evolution model parameters (the option „Exp-GPR“ in the matlab version) were trained with the measurement data acquired from the project Lidar complex (grant no. 0325519A) funded by the German Federal Ministry for Economic Affairs and Energy (BMWi). This project was aimed at the development of lidar technologies for detecting wind field structures with regard to optimising wind energy use in mountainous-complex terrain. For more details, please refer to:
- https://www.ifb.uni-stuttgart.de/en/research/windenergy/projects/lidar_complex/
- https://www.windfors.de/en/projects/lidar-complex/

## 7 Financial support

This research has received partial funding from: 
- the Joint Graduate Research Training Group Windy Cities, supported by the Baden-Württemberg Ministry of Science, Research and Arts.
- the European Union’s Horizon 2020 research and innovation program under the Marie Skłodowska-Curie Grant Agreement No. 858358 (LIKE—Lidar Knowledge Europe). See https://www.msca-like.eu/ for more details about the LIKE project.

## 8 Citing this code

Chen, Y., & Guo, F. (2021). evoTurb (Version v1.0.0) [Computer software]. https://doi.org/10.5281/zenodo.5028595

