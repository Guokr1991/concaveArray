function make_concavey_steered(folder,nlines)
%  Make the image interpolation for the polar scan
%
%  Version 1.0, 17/2-99 JAJ
%  Version 1.1, 16/8-2007 JAJ
%    Small changes in compression
% author: 
% L J Busse, LJB Development, Inc. ljb@ljbdev.com
%  LJB This version uses only matlabs functions for interpolation
%  LJB this version is meant for concave arrays
%  LJB this version uses steering angles from config file
%

if (nargin < 2); nlines = 129;end
if (nargin < 1); folder = 'rf_data';end

cmd=['load ',folder,'/config.mat']
eval(cmd);

%  Set initial parameters
D=10;       %  Sampling frequency decimation factor
fs=200e6; %  Sampling frequency  [Hz]
c=1540;     %  Speed of sound [m]
%ROC = 50/1000;   %radius of the concave array

Nelem = 256;
N_elements=nlines+64;           %  Number of physical elements
angle_inc = (pi/2)/Nelem; %corresponds to Seno's Phase 1 array
index = [-fix(N_elements/2):fix(N_elements/2)];
angle = index*angle_inc;
numArray= length(angle);

theta= angle(32+[1:nlines]);
no_lines=nlines;                  %  Number of lines in image

%  Read the data and adjust it in time 

min_sample=0;
for i=1:no_lines

  %  Load the result

  cmd=['load ',folder,'/rf_ln',num2str(i),'.mat']
  eval(cmd)
  
  %  Find the envelope
  
  rf_env=abs(hilbert([zeros(round(tstart*fs-min_sample),1); rf_data]));
  env(1:max(size(rf_env)),i)=rf_env;
end
%cmd=['load ',folder,'/desc.mat']
%eval(cmd)

fs=fs/D;

%  Do logarithmic compression to 50 dB
env=env-min(min(env));

% convert to dB and downsample
log_env=20*log10(env(1:D:max(size(env)),:)/max(max(env)));


Nz=512;                         % Size of image in pixels
Nx=512;                         % Size of image in pixels

[npts,nrays]=size(log_env)

%define the output grid
start_depth=.001;   % Depth for start of image in meters
image_size=0.040;   % Size of image in meters
dx = image_size/Nx;
dz = image_size/Nz;
dt = 1/fs;

%output grid (rectangular coordinates)
x=[-image_size/2:dx:image_size/2];
y=[ROC:-dz:ROC-image_size];

[xo,yo]=meshgrid(x, y); %output grid


%input grid (polar coordinates)
%numArray= max(size(angle));

xi = zeros(npts,nrays);
yi = zeros(npts,nrays);



range = -c*[0:npts-1]*dt/2;
for i=1:nlines
    %steer the line
    rangex = range * sin( sa1(i));
    rangey = ROC + range * cos( sa1(i));
    
    %rotate it into position
    %theta= angle(32+i);
    rot = makehgtform('zrotate', theta(i));
    for j=1:npts
        in = [rangex(j), rangey(j), 0, 0]';
        out = rot * in;
        xi(j,i) = out(1);
        yi(j,i) = out(2);
    end
end
    

% does interpolation here
log_env(1:3,:) = 0; %Fill in some points at the beginning of each line so array is visible
tmp = griddata(xi,yi,log_env,xo,yo,'cubic');

%imagesc(x*100,y*100,tmp);
f=1
for dB_Range = 40:5:80
    figure(f); f=f+1;
    
    imagesc(x*100,y*100,tmp,[-dB_Range,0]);
    colormap(gray(256));
    axis xy
    axis([-2,2,1.,5.0]);
    axis square
    colorbar;

%    set(gca,'FontSize',14)
    xlabel('Lateral distance [cm]')
    ylabel('Axial distance [cm]')

    sss= sprintf('%s: %2d dB', folder,dB_Range);
%title({fix_underscore(sss);desc});
    title(fix_underscore(sss));
    scommand=sprintf('print -djpeg %s/ca_8-4.8_dB%d.jpg',folder,dB_Range);
    eval(scommand);
end