%% plot data %%

clear all; clc;
addpath DATA/
set(0,'DefaultLineLineWidth',0.5);

stationName = {'EBEM','EPDN','EMFS','EMNR',...
    'EMFO','EPLC','ESLN','ECPN','ESVO'};
m = length(stationName);

Fs = 100; % sampling frequency of 50 Hz
dt = 1/Fs;

figHand1 = figure(1); clf;
set(figHand1,'Position',[10 10 1200 800]);

umax = [];

for i = 1:m
    i
    fileStr = stationName{i} + ".csv";
    u = csvread(fileStr);
    nt = length(u);
    t = 0:dt:(nt-1)*dt;
     
    umax(i) = max(u);
    
    % plot time series
    figure(1); subplot(1,2,1);
    amp = 2e-4;
    h = plot(t,u + amp*(i-1),'k','LineWidth',0.1);
    xlabel('Time (s) since 06:05:00 on 11 February 2014');
    hold on;
    xlim([0 300]);
    set(h.Parent,'XTick',0:30:300);
    set(h.Parent,'YTick',0:amp:amp*(m-1));
    ylim([-amp amp*(m-1)+amp])
    set(h.Parent,'YTickLabel',stationName);
    grid on; box on;
        
    % plot RMS amplitude
    sps = Fs;
    n = length(t);
    win_length = sps*10; % window length % 10 s windows with 90% overlap
    win_overlap = 0.90; % overlap between windows
    win_diff = 1 - win_overlap; % difference between windows
    win_unique = ceil(win_length*win_diff);
    num_win = floor(n/win_unique)-10;
    
    for j = 1:num_win
        idx0(j) = 1 + win_unique*(j-1);
        idx1(j) = idx0(j) + win_length;
        idxc(j) = idx0(j) + ceil(win_length/2);
        tc(j) = t(idxc(j));
        
        u_tmp = u(idx0(j):idx1(j));
        u_rms(j) = rms(u_tmp);
    end
    
    subplot(1,2,2);
    amp = 5e-5;
    h = plot(tc, (u_rms-u_rms(1))+amp*(i-1),'k','LineWidth',1);
    hold on;
    grid on; box on;
    xlabel('Time (s) since 06:05:00 on 11 February 2014');
    xlim([0 300]);
    set(h.Parent,'XTick',0:30:300);
    set(h.Parent,'YTick',0:amp:amp*(m-1));
    ylim([-amp amp*(m-1)+amp])
    set(h.Parent,'YTickLabel',stationName);
    
end

% annotate plots %%
subplot(1,2,1);
text(10,17.2e-4,'(a)','FontSize',20,'FontWeight','Bold');
text(190,17.2e-4,'1 \times 10^{-4} m/s','FontSize',16);
line([290 290],[16.5e-4 17.5e-4],'Color','k','LineWidth',2);
title('Time Series');

subplot(1,2,2);
text(10,(17.2/16*4)*1e-4,'(b)','FontSize',20,'FontWeight','Bold');
text(170,(17.2/16*4)*1e-4,'0.25 \times 10^{-4} m/s','FontSize',16);
line([290 290],[(16.5/16*4)*1e-4 (17.5/16*4)*1e-4],'Color','k','LineWidth',2);
title('RMS Amplitude');

