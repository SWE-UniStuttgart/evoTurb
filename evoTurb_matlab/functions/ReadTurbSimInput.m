%% ReadTurbSimInput
% function:read variables from the TurbSim input file (.inp)

%% Usage
% ConfigParameters = ReadTurbSimInput(ConfigParameters)

%% Inputs
%  ConfigParameters: -struct, configuration parameters 
%                    required field: ".SimInitialInputDir": directory of the input file of TurbSim (.inp file),
%                   e.g. 'D:\...\...\TurbSimInputFileTemplate.inp'

%% Outputs
%  ConfigParameters: -struct, configuration parameters 

%% Created on 02.06.2021 
% Yiyin Chen    (c) University of Stuttgart 
% Feng Guo      (c) Flensburg University of Applied Sciences

%% Modified:
%

%% function
function ConfigParameters = ReadTurbSimInput(ConfigParameters)

%% check input
if ~exist(ConfigParameters.SimInitialInputDir,'file')||~strcmp(ConfigParameters.SimInitialInputDir(end-3:end),'.inp')
    error('TurbSim input file not found! Please define the directory of the input file of TurbSim (.inp) in TurbConfig.m');
end

%% read TurbSim input file as a cell 
TextCell = regexp(fileread(ConfigParameters.SimInitialInputDir),'\n','split');

%% read variables
% Number of grid points along z [-]    
line_text = split(TextCell{19});
ConfigParameters.Nz = str2double(line_text{1});
clear line_text 

% Number of grid points along y [-]
line_text = split(TextCell{20});
ConfigParameters.Ny = str2double(line_text{1});
clear line_text 

% Grid height [m]
line_text = split(TextCell{25});
ConfigParameters.Lz = str2double(line_text{1});
clear line_text 

% Grid width [m]
line_text = split(TextCell{26});
ConfigParameters.Ly = str2double(line_text{1});
clear line_text 

% reference wind speed [m/s]    
line_text = split(TextCell{40});
ConfigParameters.Uref = str2double(line_text{1});
clear line_text 

% Height of the reference velocity (URef) [m]
line_text = split(TextCell{39});
ConfigParameters.Href = str2double(line_text{1});
clear line_text 

% Simulation time length in [s]
line_text = split(TextCell{22});
ConfigParameters.Time = str2double(line_text{1});
clear line_text 

% Simulation time step [s]
line_text = split(TextCell{21});
ConfigParameters.dt = str2double(line_text{1});
clear line_text 

% IEC turbulence wind type
line_text = split(TextCell{35});
ConfigParameters.WindType = line_text{1}(2:end-1);
clear line_text 

% IEC turbulence class
line_text = split(TextCell{34});
ConfigParameters.TurbClass = line_text{1}(2:end-1);
clear line_text 

