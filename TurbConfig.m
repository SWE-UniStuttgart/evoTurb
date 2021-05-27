% This function returns turbulence configuration, change the parameters
% to get desired results
% 
% Usage: change the parameters to desired
% 
% 
% Input: not required
% 
% 
% 
% Output: [ConfigParameters, ErrorSat, ErrorMessage]
%         ConfigParameters: a struct contains all configuration parameters
%         ErrorSat: 1 for error detected, 0 for no error
%         ErrorMessage: the error message, written as string
% 
% 
% Modified:
% 
% 
% ToDo: 
% 
% Created: Feng Guo 19-Nov 2020 Flensburg University of Applied Sciences


function  [ConfigParameters, ErrorSat, ErrorMessage] = TurbConfig()

    %# Common parameters defined

    ConfigParameters.Uref            = 16;            %#Hub height mean wind speed [m/s]
    ConfigParameters.Ny              = 5;            % #Number of grid points along y [-]
    ConfigParameters.Nz              = 5;            %Number of grid points along z [-] 
    ConfigParameters.Nlongi          = 3;             %#Number of unfrozen planes along x [-]
    ConfigParameters.Xvec            = [0,50,100];     %#A vector includes the interested yz planes along x
    ConfigParameters.Seeds           = [1,3,7];        %#Seeds for each simulated yz plane along x
    ConfigParameters.Model           = 'Kaimal';         %#Tuebulence model name: Kaimal or Mann
    ConfigParameters.Time            = 3600;            %#Simulation time length in [s]
    ConfigParameters.dt              = 0.25 ;          %#Simulation time step [s]
    ConfigParameters.a_x             = 2 ;             %#Longitudinal cohernece decay constant 1  
    ConfigParameters.b_x             = 0 ;             %#Longitudinal cohernece decay constant 2 


    
    
    

    % Model Specific Parameters IEC Kaimal, used for Turbsim
    if ConfigParameters.Model == 'Kaimal'     
       ConfigParameters.Ly          = 136  ;       %GridWidth      - Grid Width [m]
       ConfigParameters.Lz          = 136  ;      %GridHeight     - Grid Height [m]  this referes to the rotor swept area with zero at hub 
       ConfigParameters.Class       = 'A'   ;      %IEC turbulence class  IEC-61400
       ConfigParameters.TurbModel   = 'NTM'   ;      %IEC turbulence model NTM or ETM
       ConfigParameters.fileDir     = 'D:\evoTurb\UnfreezeTurb_matlab\TurbSim\';   % executable directory  
       ConfigParameters.exeName     = 'TurbSim_x64.exe' ;  % executable directory  
       ConfigParameters.dx          = ConfigParameters.Uref *ConfigParameters.dt;         %Grid step length in x direction [m]
       ConfigParameters.saveDir     = 'D:\evoTurb\UnfreezeTurb_matlab\TurbResults\';         %# 3D turb save directory
       ConfigParameters.InputFileName  = 'TurbSimInputFileTemplate.inp' ;  % input file name for turbsim 
       
       

    % Model Specific Parameters Mann, used for Mann turbulence generator
    elseif ConfigParameters.Model == 'Mann'   
%        ConfigParameters.dy           = 4            #GridWidth      - Grid step Width  [m]
%        ConfigParameters.dz           = 4            #GridHeight     - Grid step Height [m]
%        ConfigParameters.alphaEps     = 0.11         #alphaEpislon parameter defines spectral tensor
%        ConfigParameters.LengthScale  = 61           #Turbulence length scale parameter defines spectral tensor
%        ConfigParameters.gamma        = 3.2          #gamma defines shear distortion
%        ConfigParameters.HighComp     = 'false'      #High frequency compensation flag, check Mann's manual for detail
%        ConfigParameters.Ly           = ConfigParameters.dy *ConfigParameters.Ny           #Grid Width [m]
%        ConfigParameters.Lz           = ConfigParameters.dz *ConfigParameters.Nz           #Grid Height [m]  this referes to the rotor swept area with zero at hub        
%        ConfigParameters.dx           = ConfigParameters.Uref *ConfigParameters.dt         #Grid step length in x direction [m]
%        Nx                              = ConfigParameters.Time /ConfigParameters.dt         #Number of grid points along x [-]  this is different from Nlongi
%        ConfigParameters.Nx           = 2**(math.ceil(math.log(Nx,2)))        #Grid total length in x direction [m] must be 2^n n is integer             
%        ConfigParameters.fileDir      = os.getcwd()+'\\MannTurb\\'            # executable directory  
%        ConfigParameters.exeName      = 'mann_turb_x64.exe'                   # executable directory  
%        ConfigParameters.saveDir      = os.getcwd()+'\\TurbResults\\'         # 3D turb save directory
%         
    else
      ErrorSat = 1 ;
      ErrorMessage = 'Turbulence model undefined!';
      error(ErrorMessage)
    end   


    %# Continue with other common parameters that are derived
    ConfigParameters.Fs              = 1/ConfigParameters.dt;   %# Sampling freq
    ConfigParameters.Fn              = ConfigParameters.Fs /2;  %# Nyquist freq
    ConfigParameters.Nx              = ConfigParameters.Time /ConfigParameters.dt;         %#Number of grid points along x [-]
    ConfigParameters.x               = 0:ConfigParameters.dx:ConfigParameters.Nx *ConfigParameters.dx-ConfigParameters.dx;    % vector along x direction for Kaimal turb box
    ConfigParameters.t               = ConfigParameters.x /ConfigParameters.Uref;       % time vector
    ConfigParameters.df              = 1/(ConfigParameters.t(end)+ConfigParameters.dt );                       % frequency step
    ConfigParameters.f               = ConfigParameters.df:ConfigParameters.df:ConfigParameters.Fn;  %frequency bector
    
    %# The longitudinal coherence function
    a_x                                = ConfigParameters.a_x; 
    b_x                                = ConfigParameters.b_x; 
    f                                  = ConfigParameters.f; 
    Uref                               = ConfigParameters.Uref;
    ConfigParameters.kappa_x           = a_x/2*((f./Uref).^2+(b_x)^2).^0.5;
 
    


%########### check error #########################
       
     %#Number of grid planes along x should be equals to the length of Seeds 
     %#This seed must not be repectitive, otherwise the longitudinal coherence
     %# could not be correctlly build     
     if length(ConfigParameters.Seeds ) ~= ConfigParameters.Nlongi  || length(ConfigParameters.Xvec ) ~= ConfigParameters.Nlongi
         ErrorSat = 1;
         ErrorMessage = 'Number of planes along x should be equals to the length of Seeds!';
         error(ErrorMessage)
         
     elseif length(unique(ConfigParameters.Seeds )) ~= ConfigParameters.Nlongi
         ErrorSat = 1 ;
         ErrorMessage = 'The seeds must not be repetitive!';
         error(ErrorMessage)         
     else
         ErrorSat = 0;
         ErrorMessage = 'No error detected!';
     end
    
end
