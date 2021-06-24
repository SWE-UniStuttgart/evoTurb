%% Import3DTurb
% function: import the brnary files of the 3D simulations in matlab

%% Usage
% [TurbData3D, ConfigParameters] =  Import3DTurb(ConfigParameters)

%% Inputs
%  ConfigParameters: -struct, configuration parameters, output of the function #ExecuteSim.m#
%  binary files of 3D wind fields generated using TurbSim or MTG

%% Outputs
%  TurbData3D: -struct, independent 3D turbulence data at differnt yz planes
%              three fields *.U, *.V, and *.W storing the three wind components
%              each field is a 4D array with size of [Nz,Ny,Nt,Nplanes]
%  ConfigParameters: -struct, configuration parameters 

%% Created on 19.11.2020 
% Feng Guo      (c) Flensburg University of Applied Sciences
% Yiyin Chen    (c) University of Stuttgart 

%% Modified
%

%% function
function   [TurbData3D,ConfigParameters] = Import3DTurb(ConfigParameters) 

% preallocate 4D array to save u, v, and w components, 
% size: [Nz,Ny,Nt,Nplanes]
U = nan(ConfigParameters.Nz,ConfigParameters.Ny,ConfigParameters.Nt,ConfigParameters.Nplanes);   
V = nan(ConfigParameters.Nz,ConfigParameters.Ny,ConfigParameters.Nt,ConfigParameters.Nplanes); 
W = nan(ConfigParameters.Nz,ConfigParameters.Ny,ConfigParameters.Nt,ConfigParameters.Nplanes); 

% read TurbSim .wnd files
if strcmp(ConfigParameters.TurbModel,'Kaimal')      

     for i = 1:ConfigParameters.Nplanes
        
         clear wndName velocity Scale Offset 
         % u v w binary file name           
         wndName   = fullfile(ConfigParameters.saveDir_3D,[ConfigParameters.SimulationName3D{i},'.wnd']);

         % read .wnd in matlab
         [velocity, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~,Scale,Offset] = readBLgrid(wndName);
         U(:,:,:,i)           = permute(squeeze(velocity(:,1,:,:)),[3 2 1]);   
         V(:,:,:,i)           = permute(squeeze(velocity(:,2,:,:)),[3 2 1]);   
         W(:,:,:,i)           = permute(squeeze(velocity(:,3,:,:)),[3 2 1]);   

         if i == 1   % set the offset and Scale factor based on the first yz plane
            ConfigParameters.binary_Scale            = Scale;
            ConfigParameters.binary_Offset           = Offset;
         end

     end


% read MTG .bin files
elseif strcmp(ConfigParameters.TurbModel,'Mann')  %baustelle

    nx = ConfigParameters.Nt;
    ny = ConfigParameters.Ny;
    nz = ConfigParameters.Nz;

    for i = 1:ConfigParameters.Nplanes        
        
        clear this_u this_v this_w
        
        % Read *_u.bin in matlab
        clear bin_file fileID 
        bin_file = fullfile(ConfigParameters.saveDir_3D,[ConfigParameters.SimulationName3D{i},'_u.bin']);
        fileID = fopen(bin_file);
        this_u = reshape(fread(fileID,'real*4'),[nz ny nx]);
        this_u = flip(this_u,3);
        this_u = flip(this_u,2);          % flip to change the propagation direction
        U(:,:,:,i) = this_u;
        fclose(fileID);
        
        % Read *_v.bin in matlab
        clear bin_file fileID 
        bin_file = fullfile(ConfigParameters.saveDir_3D,[ConfigParameters.SimulationName3D{i},'_v.bin']);
        fileID = fopen(bin_file);
        this_v = reshape(fread(fileID,'real*4'),[nz ny nx]);
        this_v = flip(this_v,3);
        this_v = flip(this_v,2);          % flip to change the propagation direction
        V(:,:,:,i) = this_v;
        fclose(fileID);
        
        % Read *_w.bin in matlab
        clear bin_file fileID 
        bin_file = fullfile(ConfigParameters.saveDir_3D,[ConfigParameters.SimulationName3D{i},'_w.bin']);
        fileID = fopen(bin_file);
        this_w = reshape(fread(fileID,'real*4'),[nz ny nx]);
        this_w = flip(this_w,3);
        this_w = flip(this_w,2);          % flip to change the propagation direction
        W(:,:,:,i) = this_w;
        fclose(fileID);
        
    end

end

TurbData3D = struct('U',U,'V',V,'W',W);

end


