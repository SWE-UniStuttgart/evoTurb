# -*- coding: utf-8 -*-
"""
Execute3DSim
function: Run 3D simulations by calling Mann Turbulence Generator or Turbsim 
-------------------------------------------------------------------------------------------
Usage
ConfigParameters =  Execute3DSim(ConfigParameters)
-------------------------------------------------------------------------------------------
Inputs
ConfigParameters: -dict, configuration parameters, output of the function #TurbConfig.py#
---------------------------------------------------------------------------------------------
Outputs
ConfigParameters: -dict, configuration parameters 
3D wind fields saved in ConfigParameters['saveDir_3D']
---------------------------------------------------------------------------------------------
Created on 19.11.2020 
Feng Guo      (c) Flensburg University of Applied Sciences
Yiyin Chen    (c) University of Stuttgart 
-------------------------------------------------------------------------------------------
Modified

"""

# import libirary
import os
import subprocess
import shutil


def Execute3DSim(ConfigParameters):

    SimulationNames3D               = list(range(ConfigParameters['Nplanes']))
    
    if ConfigParameters['TurbModel'] == 'Kaimal': 
    
        # loop over to execute TurbSim
        for i in range(ConfigParameters['Nplanes']):
         
            # name the current 3D wind field, replace comma with d
            SimulationNames3D[i] = 'Kaimal_'+ConfigParameters['WindType']+\
                                    '_URef'+'{0:g}'.format(ConfigParameters['Uref']).replace('.','d')+\
                                    '_'+ConfigParameters['TurbClass']+\
                                    '_Ly'+'{0:g}'.format(ConfigParameters['Ly']).replace('.','d')+\
                                    '_Lz'+'{0:g}'.format(ConfigParameters['Lz']).replace('.','d')+\
                                    '_Ny'+'{0:g}'.format(ConfigParameters['Ny'])+\
                                    '_Nz'+'{0:g}'.format(ConfigParameters['Nz'])+\
                                    '_H'+'{0:g}'.format(ConfigParameters['Href']).replace('.','d')+\
                                    '_T'+'{0:g}'.format(ConfigParameters['Time']).replace('.','d')+\
                                    '_dt'+'{0:g}'.format(ConfigParameters['dt']).replace('.','d')+\
                                    '_Seed'+'{0:g}'.format(ConfigParameters['Seeds'][i])
            
            # check if 3D wind field exists
            if not os.path.isfile(os.path.join(ConfigParameters['saveDir_3D'],SimulationNames3D[i]+'.wnd')):
              
                with open(ConfigParameters['SimInitialInputDir']) as f2read:
                    TurbSimInput = f2read.readlines()                
                
                # modify the random seed in the input file of TurbSim 
                line_text = TurbSimInput[4]
                old_seed = line_text.split()[0]
                TurbSimInput[4] = line_text.replace(old_seed,str(ConfigParameters['Seeds'][i]))
                del line_text,old_seed                                    
                
                # Check and set the flag of ScaleIEC as 0 because the scaling will
                # distort the complex Fourier coefficients 
                line_text = TurbSimInput[15]
                flag = line_text.split()[0]
                if flag != '0':
                    TurbSimInput[15] = line_text.replace(flag,'0')
                    print('ScaleIEC is set 0, otherwise it causes errors in the 4D wind field generation.')
                del line_text,flag
                  
                # Check and set the flag of the vertical mean flow (uptilt) angle 
                # and the Horizontal mean flow (skew) angle as 0
                # because the current evoTurb does not support it      
                line_text = TurbSimInput[26]
                flag = line_text.split()[0]
                if flag != '0':
                    TurbSimInput[26] = line_text.replace(flag,'0')
                    print('VFlowAng is set 0, otherwise it will cause errors in the 4D wind field generation.')
                del line_text,flag
                
                line_text = TurbSimInput[27]
                flag = line_text.split()[0]
                if flag != '0':
                    TurbSimInput[27] = line_text.replace(flag,'0')
                    print('HFlowAng is set 0, otherwise it will cause errors in the 4D wind field generation.') 
                del line_text,flag
                
                # save the modified input file 
                thisTurbSimInput = os.path.join(ConfigParameters['saveDir_SimInputFiles'],SimulationNames3D[i]+'.inp')
                with open(thisTurbSimInput,'w') as f2write:
                    f2write.writelines(TurbSimInput)
                
                # call TurbSim exe if the 3D wind fields do not exist
                print('Generating '+SimulationNames3D[i])
                subprocess.run(ConfigParameters['exeDir']+' '+thisTurbSimInput)   #bug!!                  
                
                # Move .wnd and .sum files to 3DTurb_Kaimal
                shutil.move(os.path.join(ConfigParameters['saveDir_SimInputFiles'],SimulationNames3D[i]+'.wnd'),\
                            os.path.join(ConfigParameters['saveDir_3D'],SimulationNames3D[i]+'.wnd'))
                shutil.move(os.path.join(ConfigParameters['saveDir_SimInputFiles'],SimulationNames3D[i]+'.sum'),\
                            os.path.join(ConfigParameters['saveDir_3D'],SimulationNames3D[i]+'.sum'))
                    
                del TurbSimInput,thisTurbSimInput,f2read,f2write
            
            else:                        
                print('3D wind field exists: '+SimulationNames3D[i])
       
    elif ConfigParameters['TurbModel'] == 'Mann':   
     
        ## loop over to execute Mann Turb generator
        for i in range(ConfigParameters['Nplanes']):
             
            SimulationNames3D[i] = 'Mann_alphaEps'+'{0:g}'.format(ConfigParameters['alphaEps']).replace('.','d')+\
                                    '_L'+'{0:g}'.format(ConfigParameters['MannLengthScale']).replace('.','d')+\
                                    '_gamma'+'{0:g}'.format(ConfigParameters['gamma']).replace('.','d')+\
                                    '_Nx'+'{0:g}'.format(ConfigParameters['Nt']).replace('.','d')+\
                                    '_Ny'+'{0:g}'.format(ConfigParameters['Ny']).replace('.','d')+\
                                    '_Nz'+'{0:g}'.format(ConfigParameters['Nz']).replace('.','d')+\
                                    '_dx'+'{0:g}'.format(ConfigParameters['dx']).replace('.','d')+\
                                    '_dy'+'{0:g}'.format(ConfigParameters['dy']).replace('.','d')+\
                                    '_dz'+'{0:g}'.format(ConfigParameters['dz']).replace('.','d')+\
                                    '_Seed'+'{0:g}'.format(ConfigParameters['Seeds'][i])
                                    
            # check if 3D wind field exists
            if not all([os.path.isfile(os.path.join(ConfigParameters['saveDir_3D'],SimulationNames3D[i]+'_u.bin')),\
                        os.path.isfile(os.path.join(ConfigParameters['saveDir_3D'],SimulationNames3D[i]+'_v.bin')),\
                        os.path.isfile(os.path.join(ConfigParameters['saveDir_3D'],SimulationNames3D[i]+'_w.bin'))]):     
            
                # modify the input files for MTG           
                with open(ConfigParameters['SimInitialInputDir']) as f2read:
                    MTGInput = f2read.read().split()  
                
                MTGInput[0] = ConfigParameters['exeDir'] # first input: the directory of the .exe file
                MTGInput[1] = os.path.join(ConfigParameters['saveDir_3D'],SimulationNames3D[i]) # second input: the directory of the .bin files
                MTGInput[5] = str(ConfigParameters['Seeds'][i]) # modify the random seed in the input file of MTG 
                MTGInput = " ".join(MTGInput)
                
                # save the modified input file 
                thisBatch = os.path.join(ConfigParameters['saveDir_SimInputFiles'],SimulationNames3D[i]+'.bat')
                with open(thisBatch,'w') as f2write:
                    f2write.write(MTGInput)
                
                # call batch file to run MTG if the 3D wind fields do not exist
                print('Generating '+SimulationNames3D[i])
                subprocess.run(thisBatch)     
                
                del MTGInput,f2read,f2write
            
            else:                        
                print('3D wind field exists: '+SimulationNames3D[i])
        
    # name the 4D wind field ending with the first and the last random seed
    ConfigParameters['SimulationName4D']  = SimulationNames3D[0]+'_'+str(ConfigParameters['Seeds'][-1])
    # save the names of the 3D wind fields
    ConfigParameters['SimulationName3D']  = SimulationNames3D  
      
    return ConfigParameters      