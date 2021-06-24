%% ReadMTGInput
% function:read variables from the Mann turbulence generator batch file (.bat)

%% Usage
% ConfigParameters = ReadMTGInput(ConfigParameters)

%% Inputs
%  ConfigParameters: -struct, configuration parameters 
%                    required field: ".SimInitialInputDir": directory of the Mann turbulence generator batch file (.bat)
%                   e.g. 'D:\...\...\run.bat'

%% Outputs
%  ConfigParameters: -struct, configuration parameters 

%% Created on 02.06.2021 
% Yiyin Chen    (c) University of Stuttgart 
% Feng Guo      (c) Flensburg University of Applied Sciences

%% Modified:
%

%% function
function ConfigParameters = ReadMTGInput(ConfigParameters)

%% check input
if ~exist(ConfigParameters.SimInitialInputDir,'file')||~strcmp(ConfigParameters.SimInitialInputDir(end-3:end),'.bat')
    error('MTG batch file not found! Please define the directory of the batch file of Mann turbulence generator (.bat) in TurbConfig.m');
end

%% read TurbSim input file as a cell 
TextCell = regexp(fileread(ConfigParameters.SimInitialInputDir),' ','split');

%% read variables

% alphaEpislon parameter defines spectral tensor
ConfigParameters.alphaEps     = str2double(TextCell{3}); 

% Turbulence length scale parameter defines spectral tensor
ConfigParameters.MannLengthScale  = str2double(TextCell{4}); 

% gamma which defines shear distortion
ConfigParameters.gamma        = str2double(TextCell{5}); 

% Number of time steps
ConfigParameters.Nt           = str2double(TextCell{7}); 

% Number of grid points along y [-]
ConfigParameters.Ny           = str2double(TextCell{8});   

% Number of grid points along z [-]
ConfigParameters.Nz           = str2double(TextCell{9});

% Grid step in the x axis [m]
ConfigParameters.dx           = str2double(TextCell{10});  

% Grid Width step [m]
ConfigParameters.dy           = str2double(TextCell{11});   

% Grid Height step [m]
ConfigParameters.dz           = str2double(TextCell{12});    

% check the grid size
if ~all([floor(log2(ConfigParameters.Nt))==log2(ConfigParameters.Nt),...
        floor(log2(ConfigParameters.Ny))==log2(ConfigParameters.Ny),...
        floor(log2(ConfigParameters.Nz))==log2(ConfigParameters.Nz)])
    error('Mann turbulence box requires the grid dimensions to be integer power of 2. Please modify the batch file for MTG.')
end

