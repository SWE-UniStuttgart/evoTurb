%% Execute3DSim
% function: Run 3D simulations by calling Mann Turbulence Generator or Turbsim 

%% Usage
% ConfigParameters =  Execute3DSim(ConfigParameters)

%% Inputs
%  ConfigParameters: -struct, configuration parameters, output of the function #TurbConfig.m#

%% Outputs
%  ConfigParameters: -struct, configuration parameters 
%  3D wind fields saved in ConfigParameters.saveDir_3D

%% Created on 19.11.2020 
% Feng Guo      (c) Flensburg University of Applied Sciences
% Yiyin Chen    (c) University of Stuttgart 

%% Modified
%

%% function
function  ConfigParameters =  Execute3DSim(ConfigParameters)

SimulationNames3D               = cell(length(ConfigParameters.Seeds),1); % cell structure saving the names of 3D wind fields

% call Turbsim to generate 3D wind fields
if strcmp(ConfigParameters.TurbModel,'Kaimal')
    
    % loop over to execute TurbSim
    for i = 1:ConfigParameters.Nplanes
        
        clear TextCell line_text char_idx old_seed thisTurbSimInput fileID flag
        
        % name the current 3D wind field, replace comma with d
        SimulationNames3D{i} = strrep(['Kaimal_',ConfigParameters.WindType,...
            '_URef',num2str(ConfigParameters.Uref),...
            '_',ConfigParameters.TurbClass,...
            '_Ly',num2str(ConfigParameters.Ly),...
            '_Lz',num2str(ConfigParameters.Lz),...
            '_Ny',num2str(ConfigParameters.Ny),...
            '_Nz',num2str(ConfigParameters.Nz),...
            '_H',num2str(ConfigParameters.Href),...
            '_T',num2str(ConfigParameters.Time),...
            '_dt',num2str(ConfigParameters.dt),...
            '_Seed',num2str(ConfigParameters.Seeds(i))],'.','d');
        
        % check if 3D wind field exists
        if ~exist(fullfile(ConfigParameters.saveDir_3D,[SimulationNames3D{i},'.wnd']),'file')
                                  
            TextCell = regexp(fileread(ConfigParameters.SimInitialInputDir),'\n','split');
            
            % modify the random seed in the input file of TurbSim 
            line_text = TextCell{5};
            char_idx = strfind(line_text,'RandSeed1');
            old_seed = line_text(~isspace(line_text(1:char_idx-1)));
            TextCell{5} = strrep(line_text,old_seed,num2str((ConfigParameters.Seeds(i))));
            
            % Check and set the flag of ScaleIEC as 0 because the scaling will
            % distort the complex Fourier coefficients 
            clear line_text char_idx flag
            line_text = TextCell{16};
            char_idx = strfind(line_text,'ScaleIEC');                
            flag = line_text(~isspace(line_text(1:char_idx-1)));
            if ~strcmp(flag,'0')
                TextCell{16} = strrep(line_text,flag,'0');
                warning('ScaleIEC is set 0, otherwise it causes errors in the 4D wind field generation.')
            end
            
            % Check and set the flag of the vertical mean flow (uptilt) angle 
            % and the Horizontal mean flow (skew) angle as 0
            % because the current evoTurb does not support it            
            clear line_text char_idx flag
            line_text = TextCell{27};
            char_idx = strfind(line_text,'VFlowAng');                
            flag = line_text(~isspace(line_text(1:char_idx-1)));
            if ~strcmp(flag,'0')
                TextCell{27} = strrep(line_text,flag,'0');
                warning('VFlowAng is set 0, otherwise it will cause errors in the 4D wind field generation.')
            end
            
            clear line_text char_idx flag
            line_text = TextCell{28};
            char_idx = strfind(line_text,'HFlowAng');                
            flag = line_text(~isspace(line_text(1:char_idx-1)));
            if ~strcmp(flag,'0')
                TextCell{28} = strrep(line_text,flag,'0');
                warning('HFlowAng is set 0, otherwise it will cause errors in the 4D wind field generation.')
            end
                        
            % save the modified input file 
            thisTurbSimInput = fullfile(ConfigParameters.saveDir_SimInputFiles,[SimulationNames3D{i},'.inp']);
            fileID = fopen(thisTurbSimInput,'w');
            fprintf(fileID,'%s\n',TextCell{:});
            fclose(fileID);
        
            % call TurbSim exe if the 3D wind fields do not exist
            disp(['Generating ',SimulationNames3D{i}])
            dos([ConfigParameters.exeDir,' ',thisTurbSimInput]);
            
            % Move .wnd and .sum files to 3DTurb_Kaimal
            movefile(fullfile(ConfigParameters.saveDir_SimInputFiles,[SimulationNames3D{i},'.wnd']),fullfile(ConfigParameters.saveDir_3D,[SimulationNames3D{i},'.wnd']))
            movefile(fullfile(ConfigParameters.saveDir_SimInputFiles,[SimulationNames3D{i},'.sum']),fullfile(ConfigParameters.saveDir_3D,[SimulationNames3D{i},'.sum']))

        else
            disp(['3D wind field exists: ',SimulationNames3D{i}])
        end
              
    end
    
% call Mann turbulence generator to generate 3D wind fields
elseif strcmp(ConfigParameters.TurbModel,'Mann') % baustelle
    
     % loop over to execute Mann Turb generator
     for i = 1:ConfigParameters.Nplanes
         
         clear TextCell thisBatch fileID 
         
        % name the current 3D wind field, replace comma with d
        SimulationNames3D{i} = strrep(['Mann_alphaEps',num2str(ConfigParameters.alphaEps),...
            '_L',num2str(ConfigParameters.MannLengthScale),...
            '_gamma',num2str(ConfigParameters.gamma),...
            '_Nx',num2str(ConfigParameters.Nt),...
            '_Ny',num2str(ConfigParameters.Ny),...
            '_Nz',num2str(ConfigParameters.Nz),...
            '_dx',num2str(ConfigParameters.dx),...
            '_dy',num2str(ConfigParameters.dy),...
            '_dz',num2str(ConfigParameters.dz),...
            '_Seed',num2str(ConfigParameters.Seeds(i))],'.','d');       
        
        % check if 3D wind field exists
        if ~all([exist(fullfile(ConfigParameters.saveDir_3D,[SimulationNames3D{i},'_u.bin']),'file'),...
                exist(fullfile(ConfigParameters.saveDir_3D,[SimulationNames3D{i},'_v.bin']),'file'),...
                exist(fullfile(ConfigParameters.saveDir_3D,[SimulationNames3D{i},'_w.bin']),'file')])
            
            % modify the input files for MTG           
            TextCell = regexp(fileread(ConfigParameters.SimInitialInputDir),' ','split');
            TextCell{1} = ConfigParameters.exeDir; % first input: the directory of the .exe file
            TextCell{2} = fullfile(ConfigParameters.saveDir_3D,SimulationNames3D{i}); % second input: the directory of the .bin files
            TextCell{6} = num2str(ConfigParameters.Seeds(i)); % modify the random seed in the input file of MTG 
            
            % save the modified input file 
            thisBatch = fullfile(ConfigParameters.saveDir_SimInputFiles,[SimulationNames3D{i},'.bat']);
            fileID = fopen(thisBatch,'w');
            fprintf(fileID,'%s ',TextCell{:});
            fclose(fileID);
        
            % call batch file to run MTG if the 3D wind fields do not exist
            disp(['Generating ',SimulationNames3D{i}])
            dos(thisBatch);          

        else
            disp(['3D wind field exists: ',SimulationNames3D{i}])
        end
        
     end
            
end

% name the 4D wind field ending with the first and the last random seed
ConfigParameters.SimulationName4D  = [SimulationNames3D{1},'_',num2str(ConfigParameters.Seeds(end))];
% save the names of the 3D wind fields
ConfigParameters.SimulationName3D  = SimulationNames3D;
