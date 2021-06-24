# -*- coding: utf-8 -*-

"""
readBLgrid
function: read in the Turbsim '.wnd' binary wind field data
------------------------------------------------------------------------------------
This code is translated from the matlab version.
copyright: TurbSim (c) NREL
source: https://github.com/old-NWTC/TurbSim/blob/master/CertTest/readBLgrid.m
--------------------------------------------------------------------------------------
Usage
velocity, y, z, nz, ny, dz, dy, dt, zHub, z1, SummVars,Scale,Offset = readBLgrid(FileName)
------------------------------------------------------------------------------------------
Inputs
FileName       - string, the name of the file to open (.wnd extension is optional)
-----------------------------------------------------------------------------------------
Outputs
velocity      - 4-D vector: time, velocity component, iy, iz 
y             - 1-D vector: horizontal locations y(iy)
z             - 1-D vector: vertical locations z(iz)
nz, ny        - scalars: number of points in the vertical/horizontal
                direction of the grid
dz, dy, dt    - scalars: distance between two points in the vertical [m]/
                horizontal [m]/time [s] dimension
zHub           - hub height [m]
z1             - vertical location of bottom of grid [m above ground level]
SumVars        - variables from the summary file (zHub, Clockwise, UBAR, TI_u, TI_v, TI_w)
Scale          - a scale factor to write out binary data
Offset         - an offset to write out binary data
--------------------------------------------------------------------------------------------
Created on 18.06.2021 
Feng Guo      (c) Flensburg University of Applied Sciences
Yiyin Chen    (c) University of Stuttgart 
"""

# import libirary
import numpy as np
import os


def readBLgrid(FileName):
    
    length    = len(FileName);                          # avoid using len 
    ending    = FileName[length-4:length]
    
    if '.wnd' in ending:
        FileName = FileName[0:length-4]
    
    #-------------------------------------------------------------
    
    #initialize variables
    fileFmt  = 'int16';
    ConvFact = 1.0;          #results in meters and seconds
    
    str_i      = ['HUB HEIGHT','CLOCKWISE','UBAR','TI(U','TI(V','TI(W']  #MUST be in UPPER case
    numVars    = len(str_i )   
    SummVars   = np.zeros((numVars, 1))
    
    #-----------------------------------------
    #READ THE HEADER OF THE BINARY FILE 
    #----------------------------------------- 
    
    if not os.path.isfile(FileName + '.wnd'):  
       print( 'Wind file could not be opened, check whether it is in the directory' )
    
    fid_wnd =open(FileName + '.wnd' , 'rb')
    #with open(FileName + '.wnd' , 'rb') as fid_wnd:    
    nffc   = np.fromfile(fid_wnd,dtype=np.int16,count = 1)
    if  nffc != -99:    # old or new bladed styles
        dz      = np.fromfile(fid_wnd,dtype=np.int16,count = 1)               # delta z in mm
        dy      = np.fromfile(fid_wnd,dtype=np.int16,count = 1)               # delta y in mm
        dx      = np.fromfile(fid_wnd,dtype=np.int16,count = 1)               # delta x (actually t in this case) in mm
        nt      = np.fromfile(fid_wnd,dtype=np.int16,count = 1)               # half number of time steps
        MFFWS   = np.fromfile(fid_wnd,dtype=np.int16,count = 1)              #10 times mean FF wind speed, should be equal to MWS
        notused = np.fromfile(fid_wnd,dtype=np.int16,count = 5)              # unnecessary lines
        nz      = np.fromfile(fid_wnd,dtype=np.int16,count = 1)               # 1000 times number of points in vertical direction, max 32
        ny      = np.fromfile(fid_wnd,dtype=np.int16,count = 1)               # 1000 times the number of points in horizontal direction, max 32
        notused = np.fromfile(fid_wnd,dtype=np.int16,count = 3*(-int(nffc)-1))
    
            # convert the integers to real numbers 
        nffc     = -nffc;
        dz       = 0.001*ConvFact*dz
        dy       = 0.001*ConvFact*dy
        dx       = 0.001*ConvFact*dx
        MFFWS    = 0.1*ConvFact*MFFWS
        nz       = np.fix( nz % pow(2,16) / 1000 )                # the mod 2^16 is a work around for somewhat larger grids
        ny       = np.fix( ny % pow(2,16) / 1000 )                # the mod 2^16 is a work around for somewhat larger grids
            
    else: #THE NEWER-STYLE AERODYN WIND FILE
        fc       = np.fromfile(fid_wnd,dtype=np.int16,count = 1)               # should be 4 to allow turbulence intensity to be stored in the header
    
        nffc     = np.fromfile(fid_wnd,dtype=np.int32,count = 1)               # number of components (should be 3)
        lat      = np.fromfile(fid_wnd,dtype=np.float32,count = 1)            # latitude (deg)
        z0       = np.fromfile(fid_wnd,dtype=np.float32,count = 1)             # Roughness length (m)
        zOffset  = np.fromfile(fid_wnd,dtype=np.float32,count = 1)             # Reference height (m) = Z(1) + GridHeight / 2.0
        TI_U     = np.fromfile(fid_wnd,dtype=np.float32,count = 1)            # Turbulence Intensity of u component (%)
        TI_V     = np.fromfile(fid_wnd,dtype=np.float32,count = 1)             # Turbulence Intensity of v component (%)
        TI_W     = np.fromfile(fid_wnd,dtype=np.float32,count = 1)             # Turbulence Intensity of w component (%)
    
        dz       = np.fromfile(fid_wnd,dtype=np.float32,count = 1)             # delta z in m 
        dy       = np.fromfile(fid_wnd,dtype=np.float32,count = 1)            # delta y in m
        dx       = np.fromfile(fid_wnd,dtype=np.float32,count = 1)           # delta x in m           
        nt       = np.fromfile(fid_wnd,dtype=np.int32,count = 1)            # half the number of time steps
        MFFWS    = np.fromfile(fid_wnd,dtype=np.float32,count = 1)             # mean full-field wind speed
    
        notused  = np.fromfile(fid_wnd,dtype=np.float32,count = 3)           # unused variables (for BLADED)
        notused  = np.fromfile(fid_wnd,dtype=np.int32,count = 2)              # unused variables (for BLADED)
        nz       = np.fromfile(fid_wnd,dtype=np.int32,count = 1)              # number of points in vertical direction
        ny       = np.fromfile(fid_wnd,dtype=np.int32,count = 1)             # number of points in horizontal direction
        notused  = np.fromfile(fid_wnd,dtype=np.int32,count = 3*(int(nffc)-1))     # unused variables (for BLADED)                
    
    #SummVars{numVars-3} = MFFWS;
    #SummVars{numVars-2} = TI_U;
    #SummVars{numVars-1} = TI_V;
    #SummVars{numVars}   = TI_W;
    SummVars[2] =  MFFWS
    SummVars[3] =  TI_U
    SummVars[4] =  TI_V
    SummVars[5] =  TI_W
    
    
    nt     = max([nt*2,1])
    dt     = dx/MFFWS
                    
    #-----------------------------------------
    #READ THE SUMMARY FILE FOR SCALING FACTORS
    #-----------------------------------------                   
    print('Reading the summary file....')    
     
    indx     = SummVars
    
    if not os.path.isfile(FileName + '.sum'):  
       print( 'Summary file could not be opened, check whether it is in the directory' );
    
    
    # loop to read in summary file  
    with open(FileName + '.sum' , 'r') as fid_sum:
            while  any(indx == 0):   #MFFWS and the TIs should not be zero
                line  = fid_sum.readline()
                #file_lines = fid_sum.readlines()
                if not isinstance(line, str):
                    # We reached the end of the file
                    print('Reached the end of summary file without all necessary data.');            
                    break
                
                line  = line.upper();
                if '=' in line :
                    findx = line.find("=")+1   #first index
                else:
                    findx = 1
                
                if line.isspace():
                    lindx = 0
                else:
                    lindx = len(line)-1           #last  index
    
                
                #matches = [line for line in file_lines ] #first index
                #findx   = file_lines.index(matches[0])+1
                #if not findx:
                #    findx = 1;
                    
               # lindx = len(line);               
            
                i = 1;
                while (i <= numVars):
                    if indx[i-1]==0:
                       k = line.find(str_i[i-1]);                
                       if  k>=0:              # we found a string we're looking for                
                           indx[i-1] = k;
                           k=line.find('%');
                           if k>=0:
                              lindx = max(findx,k-1)
                           tmp = line[findx:lindx].lstrip().split(' ')[0]   # take the first string, ignore the white space in the begining
                    
                           try:
                               SummVars[i-1] = float(tmp)
                               break;
                           except:
                                  if tmp == 'T':
                                     SummVars[i-1] = 1;
                                  else:
                                     SummVars[i-1] = -1;  #use this for false instead of zero.
    
                    i = i + 1   # in while loop
     
    ## read the rest of the file to get the grid height offset, if it's there
    
            ZGoffset = 0.0   # we are still in the fid open loop
    
            while True:
                line  = fid_sum.readline()
                if not isinstance(line, str):
                    break;
            
                line  = line.upper()
                findx = line.find('HEIGHT OFFSET')
                if findx>=0:
                    lindx = len(line)
                    findx = line.find('=')+1
                    ZGoffset = float(line[findx:lindx].lstrip().split(' ')[0]) #z grid offset
                    break;
    
    # now the fid_sum is closed 
    
    
    
    #-----------------------------------------
    #READ THE GRID DATA FROM THE BINARY FILE
    #-----------------------------------------                   
    print('Reading and scaling the grid data...')
    
    # nffc     = 3;
    nv       = nffc*ny*nz;               # the size of one time step
    Scale    = 0.00001*SummVars[2]*SummVars[3:6]
    Offset   = np.zeros((3, 1))
    Offset[0]   = SummVars[2]
    Offset[1]   = 0
    Offset[2]   = 0
    
    
    
    velocity = np.zeros((int(nt),int(nffc),int(ny),int(nz)))
    
    if SummVars[1] > 0:        #clockwise rotation
        #flip the y direction....
        #let's change the dimension of velocity so that it's 4-d instead of 3-d   
        y_ix = list(range(int(ny),0,-1))
    else:
        y_ix = list(range(0,int(ny)+1,1))
    
    
    # [v cnt] = fread( fid_wnd, nv, fileFmt );
    # if cnt < nv
    #     error(['Could not read entire file: at grid record ' num2str( (it-1)*nv+cnt2 ) ' of ' num2str(nrecs)]);
    # end
    # disp('Scaling the grid data...');
    
    
    for it in range(1,int(nt)+1):
        
        v       = np.fromfile(fid_wnd,dtype=np.int16,count = int(nv))
        cnt     = len(v)
        if cnt < nv:
            print('Could not read entire file: at grid record '+ int( (it-1)*nv+cnt )+' of '+int(nv*nt))
        
        cnt2 = 1;
        for iz in range(1,int(nz)+1):
            for iy in range(int(y_ix[0]),int(y_ix[-1])-1,-1):
                for k in range(1,int(nffc)+1):
                    velocity[it-1,k-1,iy-1,iz-1] = v[cnt2-1]*Scale[k-1] + Offset[k-1]
                    cnt2 = cnt2 + 1;
                    
    
    
    #close the file io
    fid_wnd.close()
    
    y    = range(0,int(ny))*dy - dy*(ny-1)/2
    zHub = SummVars[0];
    z1   = zHub - ZGoffset - dz*(nz-1)/2  #this is the bottom of the grid
    z    = range(0,int(ny))*dz + z1;
    
    print('Finished.');

    return velocity, y, z, nz, ny, dz, dy, dt, zHub, z1, SummVars,Scale,Offset