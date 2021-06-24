# -*- coding: utf-8 -*-
"""
Generate4DTurb
function: Generate 4D wind fields from 3D wind fields generated with TurbSim or MTG
--------------------------------------------------------------------------------------
Usage
TurbData4D, ConfigParameters = Generate4DTurb(ConfigParameters,TurbData3D) 
------------------------------------------------------------------------------------
Inputs
ConfigParameters: -dict, configuration parameters, output of the function #Import3DTurb.py#
TurbData3D: -dict, independent 3D turbulence data at differnt y-z planes, output of the function #Import3DTurb.py#
            three fields __['U'], __['V'], and __['W'] storing the three wind components
            each field is a 4D array with size of (Nz,Ny,Nt,Nplanes)
-----------------------------------------------------------------------------------
Outputs
TurbData4D: -dict, 4D wind data
            three fields *.U, *.V, and *.W storing the three wind components
            each field is a 4D array with size of (Nz,Ny,Nt,Nplanes)
------------------------------------------------------------------------------------
Created on 19.11.2020 
Feng Guo      (c) Flensburg University of Applied Sciences
Yiyin Chen    (c) University of Stuttgart 
-------------------------------------------------------------------------------------
Modified

"""

# import libirary
import numpy as np
from CalcCohx import CalcCohx


def Generate4DTurb(ConfigParameters,TurbData3D):

    Nt       = int(ConfigParameters['Nt'])
    Ny       = ConfigParameters['Ny'] 
    Nz       = ConfigParameters['Nz']   
    Nplanes  = ConfigParameters['Nplanes']
    nf = len(ConfigParameters['f']) # number of frequency
    
    # calculate longitudinal coherence for the u component
    Cohx_u,ConfigParameters = CalcCohx(ConfigParameters) 
       
    # Cholesky decomposition
    Hx_u = np.empty((Nplanes,Nplanes,nf))
    Hx_u[:] = np.NaN
    
    for i in range(nf):
        Hx_u[:,:,i] = np.linalg.cholesky(Cohx_u[:,:,i])
    
    print('Turbulence unfreezing started...')
    
    # Get the mean value of the u component
    U_yz_mean = np.mean(TurbData3D['U'],axis=2,keepdims=True) 
    # fluctuation of the u component 
    u_yz = TurbData3D['U']-U_yz_mean              
    # two sided Fourier coefficient u 
    FC_yz_u_2side = np.fft.fft(np.reshape(np.transpose(u_yz,(3,0,1,2)),(Nplanes*Ny*Nz,Nt), order="F"),axis=1)       
    # one sided Fourier coefficient u   
    FC_yz_u_1side = np.reshape(FC_yz_u_2side[:,0:nf],(Nplanes,Ny*Nz,nf),order="F")
    
    # introduce the longitudinal coherence in the 3D wind fields        
    FC_xyz_u = np.empty((Nplanes,Ny*Nz,nf),dtype=complex)
    FC_xyz_u[:] = np.NaN
    for i in range(nf):
        FC_xyz_u[:,:,i] = Hx_u[:,:,i]@FC_yz_u_1side[:,:,i]
    
    # apply iFFT 
    u_xyz = np.fft.irfft(np.reshape(FC_xyz_u,(Nplanes*Ny*Nz,nf),order="F"),n=2*nf,axis=1)       
    # add the mean value
    U_xyz = np.transpose(np.reshape(u_xyz,(Nplanes,Nz,Ny,Nt),order="F"),(1,2,3,0)) + U_yz_mean
    
    # For MTG, the same coherence will also applied to the w component to keep
    # the coherence betwenn u and w component unchanged.
    if ConfigParameters['TurbModel'] == 'Mann':  
                     
        # two sided Fourier coefficient u 
        FC_yz_w_2side = np.fft.fft(np.reshape(np.transpose(TurbData3D['W'],(3,0,1,2)),(Nplanes*Ny*Nz,Nt), order="F"),axis=1)      
        # one sided Fourier coefficient u   
        FC_yz_w_1side = np.reshape(FC_yz_w_2side[:,0:nf],(Nplanes,Ny*Nz,nf), order="F")
    
        # introduce the longitudinal coherence in the 3D wind fields  
        FC_xyz_w = np.empty((Nplanes,Ny*Nz,nf),dtype=complex)
        FC_xyz_w[:] = np.NaN   
        for i in range(nf):
            FC_xyz_w[:,:,i] = Hx_u[:,:,i]@FC_yz_w_1side[:,:,i] 
            
        # apply iFFT 
        w_xyz = np.fft.irfft(np.reshape(FC_xyz_w,(Nplanes*Ny*Nz,nf),order="F"),n=2*nf,axis=1)       
        # add the mean value
        W_xyz = np.transpose(np.reshape(w_xyz,(Nplanes,Nz,Ny,Nt),order="F"),(1,2,3,0))
        
    else:
        W_xyz = TurbData3D['W']   
    
    # output structure for the 4D wind field
    TurbData4D = {"U": U_xyz,"V": TurbData3D['V'],"W" :W_xyz}
        
    print('4D turbulence simulation finished!')
    return TurbData4D,ConfigParameters
    
