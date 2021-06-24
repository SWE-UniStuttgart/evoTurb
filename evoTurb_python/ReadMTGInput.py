# -*- coding: utf-8 -*-

"""
ReadMTGInput
function:read variables from the Mann turbulence generator batch file (.bat)
---------------------------------------------------------------------------------------------------
Usage
ConfigParameters = ReadMTGInput(ConfigParameters)
---------------------------------------------------------------------------------------------------
Inputs
ConfigParameters: -dict, configuration parameters 
                   required field: ".SimInitialInputDir": directory of the Mann turbulence generator batch file (.bat)
                   e.g. 'D:/.../.../run.bat'
------------------------------------------------------------------------------------------------------
Outputs
ConfigParameters: -dict, configuration parameters 
------------------------------------------------------------------------------------------------------
Created on 18.06.2021 
Yiyin Chen    (c) University of Stuttgart 
Feng Guo      (c) Flensburg University of Applied Sciences
------------------------------------------------------------------------------------------------------
Modified:

"""

# import libirary
import pathlib
import math

def ReadMTGInput(ConfigParameters):
    
    # check input
    if not pathlib.Path(ConfigParameters['SimInitialInputDir']).is_file() or not pathlib.Path(ConfigParameters['SimInitialInputDir']).suffix == '.bat':
        raise FileNotFoundError('MTG batch file not found! Please define the directory of the batch file of Mann turbulence generator (.bat) in TurbConfig.py')
    
    # read TurbSim input file as a list 
    with open(ConfigParameters['SimInitialInputDir']) as txt:
        MTGInput = txt.read().split()        
      
    # read variables
    
    # alphaEpislon parameter defines spectral tensor
    ConfigParameters['alphaEps']     = float(MTGInput[2])
    
    # Turbulence length scale parameter defines spectral tensor
    ConfigParameters['MannLengthScale']  = float(MTGInput[3]) 
    
    # gamma which defines shear distortion
    ConfigParameters['gamma']        = float(MTGInput[4]) 
    
    # Number of time steps
    ConfigParameters['Nt']           = int(MTGInput[6]) 
    
    # Number of grid points along y [-]
    ConfigParameters['Ny']           = int(MTGInput[7])   
    
    # Number of grid points along z [-]
    ConfigParameters['Nz']           = int(MTGInput[8])
    
    # Grid step in the x axis [m]
    ConfigParameters['dx']           = float(MTGInput[9])  
    
    # Grid Width step [m]
    ConfigParameters['dy']           = float(MTGInput[10])   
    
    # Grid Height step [m]
    ConfigParameters['dz']           = float(MTGInput[11])    
    
    # check the grid size
    if not all([math.floor(math.log2(ConfigParameters['Nt']))==math.log2(ConfigParameters['Nt']),
            math.floor(math.log2(ConfigParameters['Ny']))==math.log2(ConfigParameters['Ny']),
            math.floor(math.log2(ConfigParameters['Nz']))==math.log2(ConfigParameters['Nz'])]):
        raise ValueError('Mann turbulence box requires the grid dimensions to be integer power of 2. Please modify the batch file for MTG.')
   
    return ConfigParameters 