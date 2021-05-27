% Generate 4D turbulence using Turbsim or Mann Turbulence Generator
% 
% 
% Usage: change the parameters in 'TurbConfig.m' to get desired turbulence
% 
% 
% Input: not required, just chang parameters in 'TurbConfig.m'
% 
% 
% 
% Output: a 4D turbulence file written as binary file;
%         the x position of the turbulence is firstly written,
%         then the u v w components are written. The turbsim style scaling
%         and offset is used to reduce the size of the binary data, check
%         'readBLgrid.m' for detail.
% 
% 
% Modified:
% 
% 
% ToDo: In clude Mann model
% 
% Created:  Feng Guo 19-Nov 2020


% Code:


clear all
close all
clc
    
 
%--------- Get Simulation Configuration File -----------
[ConfigParameters, ErrorSat, ErrorMessage]                    = TurbConfig();


%--------- Run 3D simulation by Mann Turbulence Generator or Turbsim -----------
[SimulationNames3D,ConfigParameters, ErrorSat, ErrorMessage]  = ExecuteSim(ConfigParameters);


%--------- Read in 3D turbulence with different seeds --------------
[TurbData3D, ConfigParameters,ErrorSat, ErrorMessage]         = ReadInTurb(ConfigParameters,SimulationNames3D);  

%--------- Generate 4D turbulence with 3D turb of different seeds --------------
[TurbData4D, ErrorSat, ErrorMessage]                          = Generate4DTurb(ConfigParameters,TurbData3D) ; 

%--------- Write 4D turb to Bladed style binary file --------------
[ErrorSat, ErrorMessage]                                      = Write4DTurb(ConfigParameters,TurbData4D) ; 

