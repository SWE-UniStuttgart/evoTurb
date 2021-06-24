%% Export4DTurb
% function: export 4D turbulence into binary file

%% Usage
% Export4DTurb(ConfigParameters,TurbData4D)

%% Inputs
%  ConfigParameters: -struct, configuration parameters, output of the function #Generate4D.m#
%  TurbData4D: -struct, 4D wind data, output of the function #Generate4D.m#
%              three fields *.U, *.V, and *.W storing the three wind components
%              each field is a 4D array with size of [Nz,Ny,Nt,Nplanes]

%% Outputs
% 1. a binary file of 4D wind fields (.evo) 
%   dimension: 1 = time, 2 = u,v,w, 3 = Ny, 4 = Nz, 5 = unfrozen planes
% 2. the corresponding 3D wind field file(s) for the rotor plane 
%    - 'Kaimal':'*_rotor.wnd' 
%    - 'Mann': '*_rotor_u.bin', '*_rotor_v.bin', and '*_rotor_w.bin'

%% Created on 19.11.2020 
% Feng Guo      (c) Flensburg University of Applied Sciences
% Yiyin Chen    (c) University of Stuttgart 

%% Modified:
%

%% function
function Export4DTurb(ConfigParameters,TurbData4D)

if strcmp(ConfigParameters.TurbModel,'Kaimal')
    % copy the 3D wind field for the rotor plane
    copyfile(fullfile(ConfigParameters.saveDir_3D,[ConfigParameters.SimulationName3D{1},'.wnd']),...
        fullfile(ConfigParameters.saveDir_4D,[ConfigParameters.SimulationName3D{1},'_rotor.wnd']))    
elseif strcmp(ConfigParameters.TurbModel,'Mann')
    % copy the 3D wind field for the rotor plane
    copyfile(fullfile(ConfigParameters.saveDir_3D,[ConfigParameters.SimulationName3D{1},'_u.bin']),...
        fullfile(ConfigParameters.saveDir_4D,[ConfigParameters.SimulationName3D{1},'_rotor_u.bin']))     
    copyfile(fullfile(ConfigParameters.saveDir_3D,[ConfigParameters.SimulationName3D{1},'_v.bin']),...
        fullfile(ConfigParameters.saveDir_4D,[ConfigParameters.SimulationName3D{1},'_rotor_v.bin']))  
    copyfile(fullfile(ConfigParameters.saveDir_3D,[ConfigParameters.SimulationName3D{1},'_w.bin']),...
        fullfile(ConfigParameters.saveDir_4D,[ConfigParameters.SimulationName3D{1},'_rotor_w.bin']))  
    % offset and scale parameters for binary files
    ConfigParameters.binary_Offset = [0,0,0];
    ConfigParameters.binary_Scale = ConfigParameters.gamma/1000*ones(3,1);
end
       
% apply binary scale and offset 
ubin  = int16((TurbData4D.U-ConfigParameters.binary_Offset(1))./ConfigParameters.binary_Scale(1));
vbin  = int16((TurbData4D.V-ConfigParameters.binary_Offset(2))./ConfigParameters.binary_Scale(2));
wbin  = int16((TurbData4D.W-ConfigParameters.binary_Offset(3))./ConfigParameters.binary_Scale(3));

% export the unfrozen planes except the turbine plane
data2export = cat(5,ubin(:,:,:,2:end),vbin(:,:,:,2:end),wbin(:,:,:,2:end));    
data2export = permute(data2export,[3 5 2 1 4]);    

disp('Exporting 4D wind field as binary files...')
fid = fopen(fullfile(ConfigParameters.saveDir_4D,[ConfigParameters.SimulationName4D,'_upstream.evo']),'w');    
fwrite(fid,int16(ConfigParameters.Nplanes-1),'int16');     % write the head line with the number of unfrozen planes
fwrite(fid,int16(ConfigParameters.Xpos(2:end)),'int16');   % write the x positions of unfrozen planes        
fwrite(fid,data2export(:),'int16');        
fclose('all');
disp('Binary file exported!')

end






