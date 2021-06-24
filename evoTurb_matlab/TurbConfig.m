%% TurbConfig
% function: 4D wind field configurations

%% Usage
% ConfigParameters = TurbConfig()
% Please modify the user-defined configurations in TurbConfig.

%% Inputs
%  No input variables required 

%% Outputs
%  ConfigParameters: -struct, configuration parameters 

%% Created on 19.11.2020 
% Feng Guo      (c) Flensburg University of Applied Sciences
% Yiyin Chen    (c) University of Stuttgart 

%% Modified:
%

%% function
function  ConfigParameters = TurbConfig()

%% ---  Please modify the following user-defined configurations for the turbulence model ---------------------

%Turbulence model name: 'Kaimal' or 'Mann'. Please modify the configurations for the selected turbulence simulation tool!    
% ConfigParameters.TurbModel       = 'Kaimal';     % for TurbSim
ConfigParameters.TurbModel       = 'Mann';         % for Mann turbulence generator

% directory of TurbSim or Mann turbulence generator, e.g. '..\..\TurbSim_x64.exe' or '..\..\mann_turb_x64.exe' 
% ConfigParameters.exeDir     = 'D:\evoTurb_matlab\TurbSim\TurbSim_x64.exe';
ConfigParameters.exeDir     = 'D:\evoTurb_matlab\MannTurb\mann_turb_x64.exe';

% directory of the input file of TurbSim (.inp) or Mann turbulence generator (batch file)
% ConfigParameters.SimInitialInputDir  = 'D:\evoTurb_matlab\TurbSim\TurbSimInputFileTemplate.inp';     
ConfigParameters.SimInitialInputDir  = 'D:\evoTurb_matlab\MannTurb\run.bat';   

% reference wind speed [m/s]. 
% This value is only used for Mann model. Uref for Kaimal is read from the input file of TurbSim
ConfigParameters.Uref = 16;

% the x positions of the unfrozen planes perpendicular to x axis  
ConfigParameters.Xpos            = [0,50,100];     % 0 = turbine plane must be present

% Define different random seeds for each simulated yz plane along x if you want to reproduce specific wind fields. 
% The size must be identical to ConfigParameters.Xpos.
% Or you may leave it empty, then the random seeds will be generated later.
ConfigParameters.Seeds           = [11,12,13];       

% Define directory to save results. New folders will be created in this directory. 
% Or you may leave it empty, then the new folders will be created in the current folder 
ConfigParameters.saveDir     = 'D:\test';    

%% ---- Please modify the following user-defined configurations for the wind evolution model ---------------------------------------------------

% wind evolution models: 'Exp-UserDefined', 'Exp-Simley', 'Exp-GPR', 'Kristensen'
% 1.'Exp-UserDefined' uses the wind evolution model (Eq.4) with user-defined parameters 
%   and 'Exp-Simley' uses the wind evolution model (Eq.7) in
        % Simley, E., & Pao, L. Y. (2015). 
        % A longitudinal spatial coherence model for wind evolution based on large-eddy simulation. 
        % In 2015 American Control Conference (ACC) (pp. 3708–3714). IEEE. 
        % https://doi.org/10.1109/ACC.2015.7171906
%    This model is acquired from LES simulations.

% 2.'Kristensen' uses the wind evolution model (Eq.20) and G-function (Eq.29) in
        % Kristensen, L. (1979). 
        % On longitudinal spectral coherence. 
        % Boundary-Layer Meteorology, 16(2), 145–153. 
        % https://doi.org/10.1007/BF02350508
%    This model is based on physical deduction.
    
% 3.'Exp-GPR' uses the wind evolution model (Eq.6) and 
%    the GPR models case 15 for a and case 17 for b (Table5) in
        % Chen, Y., Schlipf, D., & Cheng, P. W. (2021). 
        % Parameterization of wind evolution using lidar. 
        % Wind Energy Science, 6(1), 61–91. 
        % https://doi.org/10.5194/wes-6-61-2021
%    The GPR models are trained with measurement data from an onshore flat site.
%    Due to the limitation of the training data, it is not recommended to 
%    use the GPR models for the cases where the separations between the unfrozen planes exceed 109 m.

ConfigParameters.EvoModel        = 'Exp-Simley'; % 'Exp-UserDefined', 'Exp-Simley', 'Exp-GPR', 'Kristensen'     

% define wind evolution parameters for the model 'Exp-UserDefined'
% equation => cohx = exp(-a.*sqrt((f.*dx./U).^2+(b.*dx).^2))
if strcmp(ConfigParameters.EvoModel,'Exp-UserDefined')
    ConfigParameters.evo_a             = 1 ;            % Longitudinal coherence decay parameter  
    ConfigParameters.evo_b             = 0 ;            % Longitudinal coherence decay offset parameter
end
% In other options, the wind evolution parameters will be calculated according to the wind statistics

% If you pick other wind evolution models except 'Exp-UserDefined' when using Mann model
% please adjust the following variables for calculating the wind evolution model parameters
if ~strcmp(ConfigParameters.EvoModel,'Exp-UserDefined')&&strcmp(ConfigParameters.TurbModel,'Mann')
    ConfigParameters.sigma_u            = 3;            % standard deviation of u component [m/s] 
    ConfigParameters.sigma_v            = 2;            % standard deviation of v component [m/s] 
    ConfigParameters.sigma_w            = 2;            % standard deviation of w component [m/s] 
    ConfigParameters.L_u                = 340;          % integral length scale of u component [m] 
end

% ------ End of the user-defined configurations ---------------------------

%% obtain derived parameters 

if strcmp(ConfigParameters.TurbModel,'Kaimal')     

    % read variables from the TurbSim input file
    ConfigParameters = ReadTurbSimInput(ConfigParameters);

    % Number of time steps [-]
    ConfigParameters.Nt = ConfigParameters.Time./ConfigParameters.dt;         
    % Grid step length in x direction [m] in 3D wind fields corresponding to time steps    
    ConfigParameters.dx = ConfigParameters.Uref*ConfigParameters.dt;         


% Model Specific Parameters Mann, used for Mann turbulence generator
elseif strcmp(ConfigParameters.TurbModel,'Mann')   

    % read variables from the MTG input file 
    ConfigParameters = ReadMTGInput(ConfigParameters);

    % time steps
    ConfigParameters.dt = ConfigParameters.dx/ConfigParameters.Uref;
    %Grid Width [m]
    ConfigParameters.Ly           = ConfigParameters.dy.*ConfigParameters.Ny; 
    %Grid Height [m]  this referes to the rotor swept area with zero at hub                  
    ConfigParameters.Lz           = ConfigParameters.dz.*ConfigParameters.Nz;                        

else
    error('Turbulence model undefined! Please define either Kaimal or Mann as turbulence model in the TurbConfig.m')
end     

ConfigParameters.Nplanes         = numel(ConfigParameters.Xpos);             % Number of unfrozen planes perpendicular to x axis [-]

ConfigParameters.Fs              = 1/ConfigParameters.dt;   %# Sampling freq
ConfigParameters.Fn              = ConfigParameters.Fs/2;  %# Nyquist freq

ConfigParameters.x               = 0:ConfigParameters.dx:ConfigParameters.Nt*ConfigParameters.dx-ConfigParameters.dx;    % vector along x direction of 3D wind fields 
ConfigParameters.t               = ConfigParameters.x./ConfigParameters.Uref;       % time vector
ConfigParameters.df              = 1/(ConfigParameters.t(end)+ConfigParameters.dt );                       % frequency step
ConfigParameters.f               = ConfigParameters.df:ConfigParameters.df:ConfigParameters.Fn;  %frequency vector

% generate random seeds if not given
if  isempty(ConfigParameters.Seeds)
    ConfigParameters.Seeds = randperm(2147483647,ConfigParameters.Nplanes);
end

% directory for saving the input files and the generated 3D and 4D wind fields
if isempty(ConfigParameters.saveDir)
    ConfigParameters.saveDir_3D = fullfile(cd,['3DTurb_',ConfigParameters.TurbModel]);
    ConfigParameters.saveDir_4D = fullfile(cd,['4DTurb_',ConfigParameters.TurbModel]);
    ConfigParameters.saveDir_SimInputFiles = fullfile(cd,['InputFiles_',ConfigParameters.TurbModel]);
else
    ConfigParameters.saveDir_3D = fullfile(ConfigParameters.saveDir,['3DTurb_',ConfigParameters.TurbModel]);
    ConfigParameters.saveDir_4D = fullfile(ConfigParameters.saveDir,['4DTurb_',ConfigParameters.TurbModel]);
    ConfigParameters.saveDir_SimInputFiles = fullfile(ConfigParameters.saveDir,['InputFiles_',ConfigParameters.TurbModel]);
end   

if ~exist(ConfigParameters.saveDir_3D,'dir')
    mkdir(ConfigParameters.saveDir_3D)
end
    
if ~exist(ConfigParameters.saveDir_4D,'dir')
    mkdir(ConfigParameters.saveDir_4D)
end   

if ~exist(ConfigParameters.saveDir_SimInputFiles,'dir')
    mkdir(ConfigParameters.saveDir_SimInputFiles)
end  

% ---------------------------- check errors ---------------------------

% check if Xpos contains 0 = turbine plane
if ~ismember(0,ConfigParameters.Xpos)
    error('The x position must contain 0 to represent the turbine plane.')  
end

%Number of grid planes along x should be equals to the length of Seeds 
%This seed must not be repectitive, otherwise the longitudinal coherence
%could not be correctlly build     
if length(unique(ConfigParameters.Seeds )) ~= ConfigParameters.Nplanes
    error('The number of unfrozen planes should be equals to the length of Seeds. The seeds must not be repetitive!')         
end

% check wind evolution models
if ~contains(ConfigParameters.EvoModel,{'Exp-UserDefined','Exp-Simley','Exp-GPR','Kristensen'})
    error('Wind evolution model undefined! Please choose one of the following wind evolution models in the TurbConfig: Exp-UserDefined, Exp-Simley, Exp-GPR, Kristensen.')
end

 % --------------------------------------------------------------------
end
