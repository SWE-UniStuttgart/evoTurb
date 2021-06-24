# -*- coding: utf-8 -*-
"""
Export4DTurb
function: export 4D turbulence into binary file
--------------------------------------------------------------------------
Usage
Export4DTurb(ConfigParameters,TurbData4D)
---------------------------------------------------------------------------
Inputs
ConfigParameters: -dict, configuration parameters, output of the function #Generate4D.py#
TurbData4D: -dict, 4D wind data, output of the function #Generate4D.py#
            three fields __['U'], __['V'], and __['W'] storing the three wind components
            each field is a 4D array with size of (Nz,Ny,Nt,Nplanes)
----------------------------------------------------------------------------
Outputs
1. a binary file of 4D wind fields (.evo) 
  dimension: 1 = time, 2 = u,v,w, 3 = Ny, 4 = Nz, 5 = unfrozen planes
2. the corresponding 3D wind field file(s) for the rotor plane 
   - 'Kaimal':'*_rotor.wnd' 
   - 'Mann': '*_rotor_u.bin', '*_rotor_v.bin', and '*_rotor_w.bin'
-----------------------------------------------------------------------------
Created on 22.06.2021 
Yiyin Chen    (c) University of Stuttgart 
Feng Guo      (c) Flensburg University of Applied Sciences
-------------------------------------------------------------------------------
Modified

"""

# import libirary
import shutil
import os
import numpy as np

def Export4DTurb(ConfigParameters,TurbData4D):

    if ConfigParameters['TurbModel']=='Kaimal':
        # copy the 3D wind field for the rotor plane
        shutil.copyfile(os.path.join(ConfigParameters['saveDir_3D'],ConfigParameters['SimulationName3D'][0]+'.wnd'),\
            os.path.join(ConfigParameters['saveDir_4D'],ConfigParameters['SimulationName3D'][0]+'_rotor.wnd'))    
    elif ConfigParameters['TurbModel']=='Mann':
        # copy the 3D wind field for the rotor plane
        shutil.copyfile(os.path.join(ConfigParameters['saveDir_3D'],ConfigParameters['SimulationName3D'][0]+'_u.bin'),\
            os.path.join(ConfigParameters['saveDir_4D'],ConfigParameters['SimulationName3D'][0]+'_rotor_u.bin'))     
        shutil.copyfile(os.path.join(ConfigParameters['saveDir_3D'],ConfigParameters['SimulationName3D'][0]+'_v.bin'),\
            os.path.join(ConfigParameters['saveDir_4D'],ConfigParameters['SimulationName3D'][0]+'_rotor_v.bin'))  
        shutil.copyfile(os.path.join(ConfigParameters['saveDir_3D'],ConfigParameters['SimulationName3D'][0]+'_w.bin'),\
            os.path.join(ConfigParameters['saveDir_4D'],ConfigParameters['SimulationName3D'][0]+'_rotor_w.bin'))  
        # offset and scale parameters for binary files
        ConfigParameters['binary_Offset'] = np.zeros((3,1))
        ConfigParameters['binary_Scale'] = ConfigParameters['gamma']/1000*np.ones((3,1))

           
    # apply binary scale and offset 
    ubin  = np.int16((TurbData4D['U']-ConfigParameters['binary_Offset'][0])/ConfigParameters['binary_Scale'][0])
    vbin  = np.int16((TurbData4D['V']-ConfigParameters['binary_Offset'][1])/ConfigParameters['binary_Scale'][1])
    wbin  = np.int16((TurbData4D['W']-ConfigParameters['binary_Offset'][2])/ConfigParameters['binary_Scale'][2])
    
    # export the unfrozen planes except the turbine plane
    data2export = np.stack((ubin[:,:,:,1:],vbin[:,:,:,1:],wbin[:,:,:,1:]),axis=4)    
    data2export = np.transpose(data2export,(2,4,1,0,3))    
    
    print('Exporting 4D wind field as binary files...')
            
    fid = os.path.join(ConfigParameters['saveDir_4D'],ConfigParameters['SimulationName4D']+'_upstream.evo')
    with open(fid,'wb') as f2write:
        # write the head line with the number of unfrozen planes
        # write the x positions of unfrozen planes
        array2write = np.append(ConfigParameters['Nplanes']-1, ConfigParameters['Xpos'][1:])
        np.array(np.int16(array2write)).tofile(f2write)
        # write 4D wind field
        np.array(np.reshape(data2export,(-1,1),order="F")).tofile(f2write) 
        
    print('Binary file exported!')










