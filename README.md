# evoTurb --- 4D wind field generator

## 1 Introduction

The evoTurb aims to generate 4D wind fields by constraining multiple independent 3D wind fields generated using the TurbSim or the Mann turbulence generator with the user-defined longitudinal coherence. The evoTurb is 

### 1.1 Methodology

The 4D wind field simulation method is extended from the Veer’s method of 3D stochastic wind field simulation [1]. The coherence between any two points in space is assumed to be the multiplication of the lateral-vertical coherence and the longitudinal coherence.

The evoTurb will first call TurbSim or Mann turbulence generator depending to users' choice to generate 3D wind fields. 

### 1.2 Supported wind evolution models

The evoTurb supports the following wind evolution models (the wind evolution model is defined by users in TurbConfig):

1. 'Exp-UserDefined': uses the wind evolution model (Eq.4) in [1]. Users are supposed to define the wind evolution model parameters by themselves.

2. 'Exp-Simley': uses the wind evolution model (Eq.7) in [1]. The parameterization model is acquired from LES simulations.

3. 'Kristensen' uses the wind evolution model (Eq.20) and G-function (Eq.29) in [2]. This model is based on physical assumption.
    
4. 'Exp-GPR': uses the wind evolution model (Eq.6) and the GPR models case 15 for a and case 17 for b (Table5) in [3]. The GPR models are trained with measurement data from an onshore flat site (see acknowledgement). Due to the limitation of the training data, it is not recommended to use the GPR models for the cases where the separations between the unfrozen planes exceed 109 m. The python version does not support this option.

## 2 Usage

### 2.1 General approach

1. modify the input file for TurbSim (.inp) or Mann turbulence generator (.bat)
2. modify the configuration function: TurbConfig(.m/.py)
3. run the main script: evoTurb(.m/.py)

### 2.2 Run test case
A test case is provided to....

## 3 Development environments

Matlab version: 2019b
Python version: 3.7

## 4 References

[1] Simley, E., & Pao, L. Y. (2015). A longitudinal spatial coherence model for wind evolution based on large-eddy simulation. In 2015 American Control Conference (ACC) (pp. 3708–3714). IEEE. https://doi.org/10.1109/ACC.2015.7171906

[2] Kristensen, L. (1979). On longitudinal spectral coherence. Boundary-Layer Meteorology, 16(2), 145–153. https://doi.org/10.1007/BF02350508

[3] Chen, Y., Schlipf, D., & Cheng, P. W. (2021). Parameterization of wind evolution using lidar. Wind Energy Science, 6(1), 61–91. https://doi.org/10.5194/wes-6-61-2021

## 5 Acknowledgement
The Gaussian process regression models for the wind evolution model parameters (the option „Exp-GPR“ in the matlab version) were trained with the measurement data acquired from the project Lidar complex (grant no. 0325519A) funded by the German Federal Ministry for Economic Affairs and Energy (BMWi). This project was aimed at the development of lidar technologies for detecting wind field structures with regard to optimising wind energy use in mountainous-complex terrain. For more details, please refer to:

https://www.ifb.uni-stuttgart.de/en/research/windenergy/projects/lidar_complex/

https://www.windfors.de/en/projects/lidar-complex/

## 6 Code development and maintenance

</a></div><div itemscope itemtype="https://schema.org/Person"><a itemprop="sameAs" content="https://orcid.org/0000-0002-1343-0654" href="https://orcid.org/0000-0002-1343-0654" target="orcid.widget" rel="me noopener noreferrer" style="vertical-align:top;"><img src="https://orcid.org/sites/default/files/images/orcid_16x16.png" style="width:1em;margin-right:.5em;" alt="ORCID iD icon">Yiyin Chen</a></div>

[Stuttgart Wind Energy (SWE), University of Stuttgart](https://www.ifb.uni-stuttgart.de/en/institute/team/Chen-00003/)

contact: chen@ifb.uni-stuttgart.de

</a></div><div itemscope itemtype="https://schema.org/Person"><a itemprop="sameAs" content="https://orcid.org/0000-0003-3275-6243" href="https://orcid.org/0000-0003-3275-6243" target="orcid.widget" rel="me noopener noreferrer" style="vertical-align:top;"><img src="https://orcid.org/sites/default/files/images/orcid_16x16.png" style="width:1em;margin-right:.5em;" alt="ORCID iD icon">Feng Guo</a></div>

[Wind Energy Technology Institute, Flensburg University of Applied Sciences](https://hs-flensburg.de/hochschule/personen/guo)

contact: feng.guo@hs-flensburg.de

## 7 Citing
