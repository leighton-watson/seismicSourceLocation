%% source location 2D %%
%
% use amplitude information to constrain the source location searching over
% 2D domain with sources constrained to the topography

tic

set(0,'DefaultAxesFontSize',16);
clear all; clc;
cmap = get(gca,'ColorOrder');
addpath DATA/

%% Load data %%

load metaData.mat
load Etna_DEM.mat
load RMS.mat

STA = [easting, northing, elev];
m = length(STA);

b = 1; % exponent (b=0.5 for surface waves, b=1 for body waves)

%% Plot time series and DEM to isolate search region and time

tidx1 = 1;
tidx2 = length(tc);

lat1 = 4.174e6;
lat2 = 4.181e6;
long1 = 4.98e5;
long2 = 5.05e5;

x = X(1,:);
y = Y(:,1);

xidx1 = find(x >= long1,1,'first');
xidx2 = find(x >= long2,1,'first');

yidx1 = find(y >= lat1,1,'first');
yidx2 = find(y >= lat2,1,'first');

%% Iterate over all points on DEM to calculate R2 %%

dx_skip = 5; % space points to skip
dt_skip = 2; % time points to skip

tvec = tidx1:dt_skip:tidx2; % time vector
xvec = xidx1:dx_skip:xidx2; % x vector
yvec = yidx1:dx_skip:yidx2; % y vector

nt = length(tvec); % length of time vector
nx = length(xvec); % length of x vector
ny = length(yvec); % length of y vector

R2 = zeros(nx,ny,nt);


for k = 1:nt
    disp("Percentage complete = " + num2str(k/nt*100) + "%");
    k_idx = tvec(k);
    A = U_RMS(k_idx,:)';
    
    for i = 1:ny
        for j = 1:nx
            i_idx = yvec(i);
            j_idx = xvec(j);
            
            src = [X(i_idx,j_idx),Y(i_idx,j_idx),C(i_idx,j_idx)];
            r = ((src(1)-STA(:,1)).^2 + (src(2)-STA(:,2)).^2 + (src(3)-STA(:,3)).^2).^(1/2);
            
            % linear model with slope b
            xx = log(r);
            yy = log(A);
            m = -b; % gradient of linear fit
            c = mean(yy - m*xx);
                        
            % linear regression on both slope and intercept
            XX = [ones(length(xx),1) xx];
            c = XX\yy;
            yy_fit = [c'*XX']';
                                    
            yy_resid = yy - yy_fit;
            ss_resid = sum(yy_resid.^2);
            ss_total = (length(yy)-1)*var(yy);
            rsq = 1 - ss_resid/ss_total;
            R2(i,j,k) = rsq;
            
         end
    end
    
end


%% Calculate source location %%

Rmax = zeros(nt,1);
XR = [];
YR = [];
RR = [];

for k = 1:nt
    disp("Percentage complete = " + num2str(k/nt*100) + "%");
    k_idx = tvec(k);
    
    Rmax(k) = max(max(R2(:,:,k)));
    count = 1;
    for i = 1:ny
        for j = 1:nx
            i_idx = yvec(i);
            j_idx = xvec(j);
            
            Rtest = R2(i,j,k);
            if Rtest > 0.99*Rmax(k)
                XR(count,k) = X(i_idx,j_idx);
                YR(count,k) = Y(i_idx,j_idx);
                RR(count,k) = Rtest;
                count = count + 1;
            end
            
        end
    end
end

%% calculate mean coordinates and r value
tplot = [];
xplot = [];
yplot = [];
rplot = [];
for k = 1:nt
    k
    tplot(k) = tc(tvec(k));
    xtmp = nonzeros(XR(:,k));
    xplot(k) = mean(xtmp);

    ytmp = nonzeros(YR(:,k));
    yplot(k) = mean(ytmp);
    
    rtmp = nonzeros(RR(:,k));
    rplot(k) = mean(rtmp);
end

xcrater = 500351;
ycrater = 4177740;
figure(2); 
subplot(2,1,1);
plot(tplot,xplot-xcrater); hold on;
ylabel('Easting (m)');

subplot(2,1,2);
plot(tplot,yplot-ycrater); hold on;
ylabel('Northing (m)');

total_time = toc;

