# -*- coding: utf-8 -*-
"""
ReadTurbSimInput
function:read variables from the TurbSim input file (.inp)
--------------------------------------------------------------------------
Usage
ConfigParameters = ReadTurbSimInput(ConfigParameters)
----------------------------------------------------------------------------
Inputs
ConfigParameters: -dict, configuration parameters 
                   required field: ".SimInitialInputDir": directory of the input file of TurbSim (.inp file),
                  e.g. 'D:/.../.../TurbSimInputFileTemplate.inp'
---------------------------------------------------------------------------------
Outputs
ConfigParameters: -dict, configuration parameters 
---------------------------------------------------------------------------------
Created on 20.06.2021 
Yiyin Chen    (c) University of Stuttgart 
Feng Guo      (c) Flensburg University of Applied Sciences
--------------------------------------------------------------------------------
Modified:

"""

# import libirary
import pathlib

def ReadTurbSimInput(ConfigParameters):
    
    # check input
    if not pathlib.Path(ConfigParameters['SimInitialInputDir']).is_file() or not pathlib.Path(ConfigParameters['SimInitialInputDir']).suffix == '.inp':
        raise FileNotFoundError('TurbSim input file not found! Please define the directory of the input file of TurbSim (.inp) in TurbConfig.py')
    
    # read TurbSim input file as a list 
    with open(ConfigParameters['SimInitialInputDir']) as txt:
        TurbSimInput = txt.readlines() 
   
    ## read variables
    
    # Number of grid points along z [-]           
    ConfigParameters['Nz'] = int(TurbSimInput[18].split()[0])
    
    # Number of grid points along y [-]
    ConfigParameters['Ny'] = int(TurbSimInput[19].split()[0])
    
    # Grid height [m]
    ConfigParameters['Lz'] = float(TurbSimInput[24].split()[0])
    
    # Grid width [m]
    ConfigParameters['Ly'] = float(TurbSimInput[25].split()[0])
    
    # reference wind speed [m/s]    
    ConfigParameters['Uref'] = float(TurbSimInput[39].split()[0])
    
    # Height of the reference velocity (URef) [m]
    ConfigParameters['Href'] = float(TurbSimInput[38].split()[0])
    
    # Simulation time length in [s]
    ConfigParameters['Time'] = float(TurbSimInput[21].split()[0])
   
    # Simulation time step [s]
    ConfigParameters['dt'] = float(TurbSimInput[20].split()[0])
    
    # IEC turbulence wind type
    ConfigParameters['WindType'] = TurbSimInput[34].split()[0][1:-1]
       
    # IEC turbulence class
    ConfigParameters['TurbClass'] = TurbSimInput[33].split()[0][1:-1]
    
    return ConfigParameters 

