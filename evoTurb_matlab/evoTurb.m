%% evoTurb
% script: main script of evoTurb to generate 4D wind fields 

%% Usage
% 0. install TurbSim or Mann turbulence generator
% 1. modify input file of TurbSim (.inp) or Mann turbulence generator (.bat)
% 2. modify #TurbConfig.m#
% 3. run this main script

%% required files
% 1. the executable of TurbSim or Mann turbulence generator
% 2. the input file of TurbSim or Mann turbulence generator

%% Outputs
% 1. the 4D wind field file for the upstream '*_upstream.evo' in binary format
% 2. the corresponding 3D wind field file(s) for the rotor plane 
%    - 'Kaimal':'*_rotor.wnd' 
%    - 'Mann': '*_rotor_u.bin', '*_rotor_v.bin', and '*_rotor_w.bin'

%% Created on 19.11.2020 
% Feng Guo      (c) Flensburg University of Applied Sciences
% Yiyin Chen    (c) University of Stuttgart 

%% Modified
%

%% Main script

clear 
close all
clc    

% add evoTurb_matlab and all the subfolders to the path
addpath(genpath(fileparts(matlab.desktop.editor.getActiveFilename)));
 
%--------- Get Simulation Configuration File -----------
% please modify TurbConfig before running this script
ConfigParameters = TurbConfig(); 

%--------- Run 3D simulations using Mann Turbulence Generator or Turbsim -----------
ConfigParameters = Execute3DSim(ConfigParameters);

%--------- Import 3D wind fields with different seeds --------------
[TurbData3D,ConfigParameters] = Import3DTurb(ConfigParameters);  

%--------- Generate 4D turbulence with 3D wind fields of different seeds --------------
[TurbData4D,ConfigParameters] = Generate4DTurb(ConfigParameters,TurbData3D); 

%--------- Export the 4D wind field to Bladed style binary file --------------
Export4DTurb(ConfigParameters,TurbData4D); 

disp('4D wind field generation finished!')

