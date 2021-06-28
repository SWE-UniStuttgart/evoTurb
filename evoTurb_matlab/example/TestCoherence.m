% This scritp calculate the ensample mean coherence to verify the 4D turbulence simulation method,
% it is tested for a fixed configuration with: Nt or Nx = 16384, Ny = 8, and Nz = 8; the authors have precalculated the theorectical 
% coherence for Mann turbulence model with Delta y = 32m, and Delta z =0; to calculate the coherence, please refer to thefollowing references:
% [1] E. Cheynet. (2020, April 29). Matlab implementation of the uniform shear model (Version v1.7). Zenodo. http://doi.org/10.5281/zenodo.3776105 
% [2] Mann, J. (1994). The spatial structure of neutral atmospheric surface-layer turbulence. Journal of fluid mechanics, 273, 141-168.

%% Created on 17.06.2021 
% Feng Guo      (c) Flensburg University of Applied Sciences
% Yiyin Chen    (c) University of Stuttgart 

%% Modified:
%

%% Main script:

clear 
close all
clc    


%--------- add parent path--------
addpath('..\')

%--------- Initial set up --------
nSamples         = 8;
rng(1); 


%--------- Get Simulation Configuration File -----------
%The test is only for the folowing configuration!
ConfigParameters         = CohTestConfig(); 
ConfigParameters.Nt      = 16384;
ConfigParameters.Ny      = 8;
ConfigParameters.Nz      = 8;
Dz                       = 4;   % the grid step lengh in z
Dy                       = 4;   % the grid step lengh in y
ConfigParameters.L_u     = 8.1*42; %integral length scale
   
% for spectral estimation
nFFT                    = 4096; 
nDataPerBlock           = 1024; % 
vWindow                 = rectwin(nDataPerBlock);
noverlap                = 1; % almost no overlap; 
Fs                      = ConfigParameters.Fs;


% specify size
PSD_1_1_1   = nan(nSamples,nFFT/2+1);
PSD_1_1_2   = nan(nSamples,nFFT/2+1);
PSD_1_1_3   = nan(nSamples,nFFT/2+1);
PSD_v_1_1_3 = nan(nSamples,nFFT/2+1);
PSD_w_1_1_3 = nan(nSamples,nFFT/2+1);
PSD_1_4_1   = nan(nSamples,nFFT/2+1);
PSD_1_8_1   = nan(nSamples,nFFT/2+1);
    
CPSD_1_1_1_to_1_1_2  = nan(nSamples,nFFT/2+1);
CPSD_1_1_1_to_1_1_3  = nan(nSamples,nFFT/2+1);
CPSD_1_1_2_to_1_1_3  = nan(nSamples,nFFT/2+1);
CPSD_1_1_1_to_1_4_1  = nan(nSamples,nFFT/2+1);
CPSD_1_1_1_to_1_8_1  = nan(nSamples,nFFT/2+1);
CPSD_1_4_1_to_1_1_2  = nan(nSamples,nFFT/2+1);
CPSD_1_4_1_to_1_1_3  = nan(nSamples,nFFT/2+1);
CPSD_1_8_1_to_1_1_2  = nan(nSamples,nFFT/2+1);
CPSD_1_8_1_to_1_1_3  = nan(nSamples,nFFT/2+1);
CPSD_1_1_3_to_w_1_1_3= nan(nSamples,nFFT/2+1);

% loop over samples

for i = 1:1:nSamples
    
    seed_new      = randi([1 1000],1,3);  % seeds for random number generator
    
    while ismember(seed_new,ConfigParameters.Seeds)             % if the new seed repeat, generate new group
        seed_new      = randi([1 1000],1,3);  % seeds for random number generator
    end
    ConfigParameters.Seeds          = seed_new;
    
    
    %--------- Run 3D simulations using Mann Turbulence Generator or Turbsim -----------
    ConfigParameters = Execute3DSim(ConfigParameters);
    
    %--------- Import 3D wind fields with different seeds --------------
    [TurbData3D,ConfigParameters] = Import3DTurb(ConfigParameters);
    
    %--------- Generate 4D turbulence with 3D wind fields of different seeds --------------
    [TurbData4D,ConfigParameters] = Generate4DTurb(ConfigParameters,TurbData3D);
    
    % the dimentions in TurbData4D: Nz,Ny,Nt,Nplanes
    U_1_1_1  = squeeze(TurbData4D.U(1,1,:,1));    %U_1_1_1, U at first row first column and first plane
    U_1_1_2  = squeeze(TurbData4D.U(1,1,:,2));
    U_1_1_3  = squeeze(TurbData4D.U(1,1,:,3));
    U_1_4_1  = squeeze(TurbData4D.U(1,4,:,1));
    U_1_8_1  = squeeze(TurbData4D.U(1,8,:,1));
    
    V_1_1_3  = squeeze(TurbData4D.V(1,1,:,3));
    W_1_1_3  = squeeze(TurbData4D.W(1,1,:,3));
        
    
    [PSD_1_1_1(i,:),f_est]    = cpsd(detrend(U_1_1_1),detrend(U_1_1_1),vWindow,noverlap,nFFT,Fs);
    PSD_1_1_2(i,:)            = cpsd(detrend(U_1_1_2),detrend(U_1_1_2),vWindow,noverlap,nFFT,Fs);
    PSD_1_1_3(i,:)            = cpsd(detrend(U_1_1_3),detrend(U_1_1_3),vWindow,noverlap,nFFT,Fs);
    PSD_1_4_1(i,:)            = cpsd(detrend(U_1_4_1),detrend(U_1_4_1),vWindow,noverlap,nFFT,Fs);
    PSD_1_8_1(i,:)            = cpsd(detrend(U_1_8_1),detrend(U_1_8_1),vWindow,noverlap,nFFT,Fs);
    PSD_v_1_1_3(i,:)          = cpsd(detrend(V_1_1_3),detrend(V_1_1_3),vWindow,noverlap,nFFT,Fs);
    PSD_w_1_1_3(i,:)          = cpsd(detrend(W_1_1_3),detrend(W_1_1_3),vWindow,noverlap,nFFT,Fs);
    
    CPSD_1_1_1_to_1_1_2(i,:)  = cpsd(detrend(U_1_1_1),detrend(U_1_1_2),vWindow,noverlap,nFFT,Fs);
    CPSD_1_1_1_to_1_1_3(i,:)  = cpsd(detrend(U_1_1_1),detrend(U_1_1_3),vWindow,noverlap,nFFT,Fs);
    CPSD_1_1_2_to_1_1_3(i,:)  = cpsd(detrend(U_1_1_2),detrend(U_1_1_3),vWindow,noverlap,nFFT,Fs);
    CPSD_1_1_1_to_1_4_1(i,:)  = cpsd(detrend(U_1_1_1),detrend(U_1_4_1),vWindow,noverlap,nFFT,Fs);
    CPSD_1_1_1_to_1_8_1(i,:)  = cpsd(detrend(U_1_1_1),detrend(U_1_8_1),vWindow,noverlap,nFFT,Fs);
    CPSD_1_4_1_to_1_1_2(i,:)  = cpsd(detrend(U_1_4_1),detrend(U_1_1_2),vWindow,noverlap,nFFT,Fs);
    CPSD_1_4_1_to_1_1_3(i,:)  = cpsd(detrend(U_1_4_1),detrend(U_1_1_3),vWindow,noverlap,nFFT,Fs);
    CPSD_1_8_1_to_1_1_2(i,:)  = cpsd(detrend(U_1_8_1),detrend(U_1_1_2),vWindow,noverlap,nFFT,Fs);
    CPSD_1_8_1_to_1_1_3(i,:)  = cpsd(detrend(U_1_8_1),detrend(U_1_1_3),vWindow,noverlap,nFFT,Fs);
    CPSD_1_1_3_to_w_1_1_3(i,:)= cpsd(detrend(U_1_1_3),detrend(W_1_1_3),vWindow,noverlap,nFFT,Fs);
end



% calculate analytical longitudinal coherence
[Cohx_u,ConfigParameters] = CalcCohx(ConfigParameters); 
x_coh1                    = interp1(ConfigParameters.f,squeeze(Cohx_u(1,2,:)),f_est,'linear','extrap');  % theorectical coherence Dx =50m
x_coh2                    = interp1(ConfigParameters.f,squeeze(Cohx_u(1,3,:)),f_est,'linear','extrap');  % theorectical coherence Dx =100m





%% plot
set(groot,'defaultTextInterpreter','latex')
set(groot,'defaultAxesTickLabelInterpreter','latex')
set(groot,'defaultLegendInterpreter','latex')
set(groot,'defaultFigureColor','w')
set(groot,'defaultTextFontSize',10)
set(groot,'defaultAxesFontSize',10)
set(groot,'defaultLineLineWidth',1.2)

figure('units','normalized','outerposition',[0 0 1 1])
subplot(2,2,1)
hold on; grid on; box on;
plot(f_est,abs(mean(CPSD_1_1_1_to_1_1_2,1).^2)./mean(PSD_1_1_1,1)./mean(PSD_1_1_2,1),'-.','color',[0 0.4470 0.7410]);
plot(f_est,abs(mean(CPSD_1_1_1_to_1_1_3,1).^2)./mean(PSD_1_1_1,1)./mean(PSD_1_1_3,1),'-.','color',[0.8500 0.3250 0.0980]);
% plot(f_est,abs(mean(CPSD_1_1_2_to_1_1_3,1).^2)./mean(PSD_1_1_2,1)./mean(PSD_1_1_3,1));
plot(f_est,x_coh1.^2,'color',[0 0.4470 0.7410])
plot(f_est,x_coh2.^2,'color',[0.8500 0.3250 0.0980])
legend('estimated: Dx = 50 m','estimated: Dx = 100 m','theoretical: Dx = 50 m','theoretical: Dx = 100 m','Location','northeast')
set(gca,'Xscale','log')
xlabel('frequency [Hz]')
ylabel('magnitude coherence [-]')

subplot(2,2,2)
hold on; grid on; box on;
plot(f_est,abs(mean(CPSD_1_1_1_to_1_4_1,1).^2)./mean(PSD_1_1_1,1)./mean(PSD_1_4_1,1),'-.','color',[0 0.4470 0.7410]);
plot(f_est,abs(mean(CPSD_1_1_1_to_1_8_1,1).^2)./mean(PSD_1_1_1,1)./mean(PSD_1_8_1,1),'-.','color',[0.8500 0.3250 0.0980]);
if strcmp(ConfigParameters.TurbModel,'Kaimal')   
    yz_coh1      = exp(-12*Dy*4*((f_est/ConfigParameters.Uref).^2+(0.12/ConfigParameters.L_u).^2).^0.5);
    yz_coh2      = exp(-12*Dy*8*((f_est/ConfigParameters.Uref).^2+(0.12/ConfigParameters.L_u).^2).^0.5);
    plot(f_est,yz_coh1.^2,'color',[0 0.4470 0.7410]);
    plot(f_est,yz_coh2.^2,'color',[0.8500 0.3250 0.0980]);
    set(gca,'Xscale','log')
    xlabel('frequency [Hz]')
    ylabel('magnitude coherence [-]')
    title('Dz = 0')
    legend('estimated: Dy = 16 m','estimated: Dy = 32 m','theoretical: Dy = 16 m','theoretical: Dy = 32 m','Location','northeast')
else
    load('example\MannCoh.mat') 
    yz_coh1          = interp1(k_coh/2/pi*ConfigParameters.Uref,coh_1,f_est,'linear','extrap');
    yz_coh2          = interp1(k_coh/2/pi*ConfigParameters.Uref,coh_2,f_est,'linear','extrap');
    plot(f_est,yz_coh1.^2,'color',[0 0.4470 0.7410]);
    plot(f_est,yz_coh2.^2,'color',[0.8500 0.3250 0.0980]);
    set(gca,'Xscale','log')
    xlabel('frequency [Hz]')
    ylabel('magnitude coherence [-]')
    title('Dz = 0')
    legend('estimated: Dy = 12 m','estimated: Dy = 28 m','theoretical: Dy = 12 m','theoretical: Dy = 28 m','Location','northeast')
end    

subplot(2,2,3)
hold on; grid on; box on;
plot(f_est,abs(mean(CPSD_1_4_1_to_1_1_2,1).^2)./mean(PSD_1_4_1,1)./mean(PSD_1_1_2,1),'-.','color',[0 0.4470 0.7410]);
plot(f_est,abs(mean(CPSD_1_4_1_to_1_1_3,1).^2)./mean(PSD_1_4_1,1)./mean(PSD_1_1_3,1),'-.','color',[0.8500 0.3250 0.0980]);
plot(f_est,abs(mean(CPSD_1_8_1_to_1_1_2,1).^2)./mean(PSD_1_8_1,1)./mean(PSD_1_1_2,1),'-.','color',[0.4660 0.6740 0.1880]);
plot(f_est,abs(mean(CPSD_1_8_1_to_1_1_3,1).^2)./mean(PSD_1_8_1,1)./mean(PSD_1_1_3,1),'-.','color',[0.3010 0.7450 0.9330]);
plot(f_est,(x_coh1.*yz_coh1).^2,'color',[0 0.4470 0.7410])
plot(f_est,(x_coh2.*yz_coh1).^2,'color',[0.8500 0.3250 0.0980])
plot(f_est,(x_coh1.*yz_coh2).^2,'color',[0.4660 0.6740 0.1880])
plot(f_est,(x_coh2.*yz_coh2).^2,'color',[0.3010 0.7450 0.9330])
set(gca,'Xscale','log')
xlabel('frequency [Hz]')
ylabel('magnitude coherence [-]')
title('Dz = 0')
if strcmp(ConfigParameters.TurbModel,'Kaimal')  
   legend('estimated: Dx = 50 m, Dy = 16 m','estimated: Dx = 100 m, Dy = 16 m',...
          'estimated: Dx = 50 m, Dy = 32 m','estimated: Dx = 100 m, Dy = 32 m',...
          'theoretical: Dx = 50 m, Dy = 16 m','theoretical: Dx = 100 m, Dy = 16 m',...
          'theoretical: Dx = 50 m, Dy = 32 m','theoretical: Dx = 100 m, Dy = 32 m','Location','northeast')
else
   legend('estimated: Dx = 50 m, Dy = 12 m','estimated: Dx = 100 m, Dy = 12 m',...
          'estimated: Dx = 50 m, Dy = 28 m','estimated: Dx = 100 m, Dy = 28 m',...
          'theoretical: Dx = 50 m, Dy = 12 m','theoretical: Dx = 100 m, Dy = 12 m',...
          'theoretical: Dx = 50 m, Dy = 28 m','theoretical: Dx = 100 m, Dy = 28 m','Location','northeast')
end

subplot(2,2,4)
hold on; grid on; box on;
plot(f_est,f_est'.*mean(PSD_1_1_3,1));
plot(f_est,f_est'.*mean(PSD_v_1_1_3,1));
plot(f_est,f_est'.*mean(PSD_w_1_1_3,1));
plot(f_est,f_est'.*mean(real(CPSD_1_1_3_to_w_1_1_3),1));
set(gca,'Xscale','log')
xlabel('frequency [Hz]')
ylabel('$f\cdot$spectra [(m/s)$^2$]')
legend('u','v','w','uw','Location','northeast')


