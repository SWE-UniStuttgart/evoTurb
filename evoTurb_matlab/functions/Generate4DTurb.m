%% Generate4DTurb
% function: Generate 4D wind fields from 3D wind fields generated with TurbSim or MTG

%% Usage
% [TurbData4D, ErrorSat, ErrorMessage]= Generate4DTurb(ConfigParameters,TurbData3D) 

%% Inputs
%  ConfigParameters: -struct, configuration parameters, output of the function #Import3DTurb.m#
%  TurbData3D: -struct, independent 3D turbulence data at differnt y-z planes, output of the function #Import3DTurb.m#
%              three fields *.U, *.V, and *.W storing the three wind components
%              each field is a 4D array with size of [Nz,Ny,Nt,Nplanes]

%% Outputs
%  TurbData4D: -struct, 4D wind data
%              three fields *.U, *.V, and *.W storing the three wind components
%              each field is a 4D array with size of [Nz,Ny,Nt,Nplanes]

%% Created on 19.11.2020 
% Feng Guo      (c) Flensburg University of Applied Sciences
% Yiyin Chen    (c) University of Stuttgart 

%% Modified:
%

%% function
function  [TurbData4D,ConfigParameters] = Generate4DTurb(ConfigParameters,TurbData3D) 
    
Nt       = ConfigParameters.Nt ;
Ny       = ConfigParameters.Ny ;
Nz       = ConfigParameters.Nz ;  
Nplanes  = ConfigParameters.Nplanes;
nf = length(ConfigParameters.f); % number of frequency

% calculate longitudinal coherence for the u component
[Cohx_u,ConfigParameters] = CalcCohx(ConfigParameters);        
% Cholesky decomposition
Hx_u = nan(Nplanes,Nplanes,nf);
for i = 1:nf
    Hx_u(:,:,i) = chol(Cohx_u(:,:,i),'lower');
end

disp('Turbulence unfreezing started...')

% Get the mean value of the u component
U_yz_mean = mean(TurbData3D.U,3); 
% fluctuation of the u component 
u_yz = TurbData3D.U-U_yz_mean;              
% two sided Fourier coefficient u 
FC_yz_u_2side = fft(reshape(permute(u_yz,[4,1,2,3]),[Nplanes*Ny*Nz,Nt]),[],2);      
% one sided Fourier coefficient u   
FC_yz_u_1side = reshape(FC_yz_u_2side(:,1:nf),[Nplanes,Ny*Nz,nf]);

% introduce the longitudinal coherence in the 3D wind fields
if exist('pagemtimes','builtin') % this function was introduced in R2020b  
    FC_xyz_u = pagemtimes(Hx_u,real(FC_yz_u_1side))+pagemtimes(Hx_u,imag(FC_yz_u_1side))*1i;         
else        
    FC_xyz_u = nan(Nplanes,Ny*Nz,nf);
    for i = 1:nf
        FC_xyz_u(:,:,i) = Hx_u(:,:,i)*real(FC_yz_u_1side(:,:,i))+Hx_u(:,:,i)*imag(FC_yz_u_1side(:,:,i))*1i;
    end
end

% apply iFFT
u_xyz = ifft(reshape(FC_xyz_u,[Nplanes*Ny*Nz,nf]),Nt,2,'Symmetric');        
% add the mean value
U_xyz = permute(reshape(u_xyz,[Nplanes,Nz,Ny,Nt]),[2 3 4 1])+U_yz_mean;

% For MTG, the same coherence will also applied to the w component to keep
% the coherence betwenn u and w component unchanged.
if strcmp(ConfigParameters.TurbModel,'Mann')  
                 
    % two sided Fourier coefficient u 
    FC_yz_w_2side = fft(reshape(permute(TurbData3D.W,[4,1,2,3]),[Nplanes*Ny*Nz,Nt]),[],2);      
    % one sided Fourier coefficient u   
    FC_yz_w_1side = reshape(FC_yz_w_2side(:,1:nf),[Nplanes,Ny*Nz,nf]);

    % introduce the longitudinal coherence in the 3D wind fields
    if exist('pagemtimes','builtin') % this function was introduced in R2020b  
        FC_xyz_w = pagemtimes(Hx_u,real(FC_yz_w_1side))+pagemtimes(Hx_u,imag(FC_yz_w_1side))*1i;         
    else        
        FC_xyz_w = nan(Nplanes,Ny*Nz,nf);
        for i = 1:nf
            FC_xyz_w(:,:,i) = Hx_u(:,:,i)*real(FC_yz_w_1side(:,:,i))+Hx_u(:,:,i)*imag(FC_yz_w_1side(:,:,i))*1i;
        end
    end

    % apply iFFT
    w_xyz = ifft(reshape(FC_xyz_w,[Nplanes*Ny*Nz,nf]),Nt,2,'Symmetric');        
    % add the mean value
    W_xyz = permute(reshape(w_xyz,[Nplanes,Nz,Ny,Nt]),[2 3 4 1]);
    
else
    W_xyz = TurbData3D.W;

end

% output structure for the 4D wind field
TurbData4D = struct('U',U_xyz,'V',TurbData3D.V,'W',W_xyz);
    
disp('4D turbulence simulation finished!')
        
end
    


 
        

