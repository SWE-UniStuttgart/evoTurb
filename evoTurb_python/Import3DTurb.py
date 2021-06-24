# -*- coding: utf-8 -*-
"""
Import3DTurb
function: import the binary files of the 3D simulations in python
--------------------------------------------------------------------------
Usage
TurbData3D, ConfigParameters =  Import3DTurb(ConfigParameters)
------------------------------------------------------------------------------
Inputs
ConfigParameters: -dict, configuration parameters, output of the function #ExecuteSim.py#
                  binary files of 3D wind fields generated using TurbSim or MTG
-----------------------------------------------------------------------------------------
Outputs
TurbData3D: -dict, independent 3D turbulence data at differnt yz planes
            three fields __['U'], __['V'], and __['W'] storing the three wind components
            each field is a 4D array with size of (Nz,Ny,Nt,Nplanes)
ConfigParameters: -dict, configuration parameters 
----------------------------------------------------------------------------------
Created on 19.11.2020 
Feng Guo      (c) Flensburg University of Applied Sciences
Yiyin Chen    (c) University of Stuttgart 
--------------------------------------------------------------------------------
Modified

"""

# import libirary
import numpy as np
import os
from readBLgrid import readBLgrid

def Import3DTurb(ConfigParameters):
    
    # preallocate 4D array to save u, v, and w components, 
    # size: (Nz,Ny,Nt,Nplanes)
    U = np.empty((ConfigParameters['Nz'],ConfigParameters['Ny'],int(ConfigParameters['Nt']),ConfigParameters['Nplanes']))   
    V = np.empty((ConfigParameters['Nz'],ConfigParameters['Ny'],int(ConfigParameters['Nt']),ConfigParameters['Nplanes']))  
    W = np.empty((ConfigParameters['Nz'],ConfigParameters['Ny'],int(ConfigParameters['Nt']),ConfigParameters['Nplanes']))  
    U[:] = np.NaN
    V[:] = np.NaN
    W[:] = np.NaN
    
    # read TurbSim .wnd files
    if ConfigParameters['TurbModel'] == 'Kaimal':  
        
         for i in range(ConfigParameters['Nplanes']):
       
             # u v w binary file name           
             wndName   = os.path.join(ConfigParameters['saveDir_3D'],ConfigParameters['SimulationName3D'][i]+'.wnd')
    
             # read .wnd in python
             velocity,_,_,_,_,_,_,_,_,_,_,Scale,Offset = readBLgrid(wndName)
             U[:,:,:,i]           = np.transpose(np.squeeze(velocity[:,0,:,:]),(2,1,0))  
             V[:,:,:,i]           = np.transpose(np.squeeze(velocity[:,1,:,:]),(2,1,0))   
             W[:,:,:,i]           = np.transpose(np.squeeze(velocity[:,2,:,:]),(2,1,0))     
             
             if i == 0:   # set the offset and Scale factor based on the first yz plane
                 ConfigParameters['binary_Scale']            = Scale;
                 ConfigParameters['binary_Offset']           = Offset;
                
             del wndName,velocity,Scale,Offset 
       
    # read MTG .bin files
    elif ConfigParameters['TurbModel'] == 'Mann':  
         
         Nx                              = ConfigParameters['Nt'] 
         Ny                              = ConfigParameters['Ny'] 
         Nz                              = ConfigParameters['Nz'] 
  
         for i in range(ConfigParameters['Nplanes']):
                                                          
             # u v w binary file name           
             u_file = os.path.join(ConfigParameters['saveDir_3D'],ConfigParameters['SimulationName3D'][i]+'_u.bin')
             v_file = os.path.join(ConfigParameters['saveDir_3D'],ConfigParameters['SimulationName3D'][i]+'_v.bin')
             w_file = os.path.join(ConfigParameters['saveDir_3D'],ConfigParameters['SimulationName3D'][i]+'_w.bin')
             
             # read u v w binary and adjust the storage dimention
             with open(u_file, 'rb') as fid:    
                   dataRaw          = np.fromfile(fid,dtype=np.float32)
                   dataRaw          = np.reshape(dataRaw, (Nz,Ny,Nx), order="F")
                   # flip to change the propagation direction
                   dataRaw          = np.flip(dataRaw,2) 
                   dataRaw          = np.flip(dataRaw,1)
                   U[:,:,:,i]       = dataRaw
             del fid,dataRaw

             with open(v_file, 'rb') as fid:    
                   dataRaw          = np.fromfile(fid,dtype=np.float32)
                   dataRaw          = np.reshape(dataRaw, (Nz,Ny,Nx), order="F")
                   # flip to change the propagation direction
                   dataRaw          = np.flip(dataRaw,2)
                   dataRaw          = np.flip(dataRaw,1)
                   V[:,:,:,i]       = dataRaw
             del fid,dataRaw                   
                   
             with open(w_file, 'rb') as fid:    
                   dataRaw          = np.fromfile(fid,dtype=np.float32)
                   dataRaw          = np.reshape(dataRaw, (Nz,Ny,Nx), order="F")
                   # flip to change the propagation direction
                   dataRaw          = np.flip(dataRaw,2)
                   dataRaw          = np.flip(dataRaw,1)
                   W[:,:,:,i]       = dataRaw
             del fid,dataRaw 
             
             del u_file,v_file,w_file
                   
    TurbData3D = {"U": U, "V": V, "W": W}
    
    return TurbData3D,ConfigParameters