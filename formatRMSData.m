%% Plot data %%
%
% Load station meta data and plot

set(0,'DefaultAxesFontSize',16);
clear all; clc;
addpath DATA/

%% Load meta data %%

T = readtable('seismicStationMetaData.csv');
staName = table2array(T(:,1));
m = length(staName);
easting = table2array(T(:,2))*1000;
northing = table2array(T(:,3))*1000;
elev = table2array(T(:,4))*1000;
calib1 = table2array(T(:,5));
calib2 = table2array(T(:,6));
ac_calib = calib1./calib2;

save('metaData.mat','staName','easting','northing','elev','ac_calib');


%% Root-mean-square amplitude %%
RMS = [];
%n = length(t); 

figure(3); clf;

Fs = 100; % samples per second (100 Hz)
sps = Fs;
dt = 1/Fs;
win_length = sps*1*10; % window length % 10 s windows with 90% overlap
win_overlap = 0.90; % overlap between windows
win_diff = 1 - win_overlap; % difference between windows
win_unique = ceil(win_length*win_diff);

U_RMS = [];
u_rms = [];
tc = [];

for j = 1:m
    fileStr = staName{j} + ".csv";
    u = csvread(fileStr);
    nt = length(u);
    t = 0:dt:(nt-1)*dt;
    num_win = floor(nt/win_unique)-10;
        
    for i = 1:num_win
        idx0(i) = 1 + win_unique*(i-1);
        idx1(i) = idx0(i) + win_length;
        idxc(i) = idx0(i) + ceil(win_length/2);
        tc(i) = t(idxc(i));
        
        u_tmp = u(idx0(i):idx1(i));
        u_rms(i) = rms(u_tmp);
    end
    U_RMS(:,j) = u_rms;
end

for i = 1:m
    subplot(3,3,i);
    plot(tc, U_RMS(:,i));
    hold on;
end

save('RMS.mat','U_RMS','tc','win_length','win_overlap');

   
    