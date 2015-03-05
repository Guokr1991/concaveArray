function sim_concave_steered(ROC, SteeringMax, folder)
%  Concave array B-mode 
%
%  This script assumes that the field_init procedure has been called
%  Here the field simulation is performed and the data is stored
%  in rf-files; one for each rf-line done. The data must then
%  subsequently be processed to yield the image. 
% author: 
% 	L J Busse, LJB Development, Inc. ljb@ljbdev.com
%
%  Generate the transducer apertures for send and receive


if (nargin < 3); folder = 'rf_data';  end	%folder where data will be stored
if (nargin < 2); SteeringMax = 0; end    	%Max steering angle (degrees)
if (nargin < 1); ROC = 50.; end       		%Radius of curvature mm

close all;
f0=8.e6;                  					%  Transducer center frequency [Hz]
fs=200e6;                					%  Sampling frequency [Hz]
c=1540;                  					%  Speed of sound [m/s]
lambda=c/f0;            				 	%  Wavelength [m]
width=.3/1000.;          					%  Width of element
element_height=5./1000; 					%  Height of element [m]
kerf=.020/1000 ;          					%  Kerf [m]
ROC = ROC/1000;								% convert to meters
ElevFoc = 25./1000;
nlines = 129;           					%Number of lines in the image
Nelem = 256;
TxFnum = 4;
RxFnum = 2;
AperMax = 65;



N_elements=nlines+64;           			%  Number of physical elements
angle_inc = (pi/2)/Nelem; 					%corresponds to Seno's Phase 1 array
index = [-fix(N_elements/2):fix(N_elements/2)];
angle = index*angle_inc;
numArray= length(angle);
sangle = angle(32:32+nlines); 				%steering angles

%This part limits the steering angle
SAMax  = SteeringMax * pi/180;
list = find(abs(sangle) <= SAMax);
sa1 = sign(sangle) * SAMax;
sa1(list) = sangle(list);


focus=[0 0 40]/1000;     %  Fixed focal point [m]

%  Set the sampling frequency
set_sampling(fs);
set_field ('show_times', 5)

tx1 = xdc_concaveArray( numArray, ROC*1000, numArray * angle_inc,5, 0,.28,.3, 2,10)
%figure(5);
show_xdc(tx1);
%pause;
%  Set the impulse response and excitation of the xmit aperture

impulse_response=sin(2*pi*f0*(0:1/fs:2/f0));
impulse_response=impulse_response.*hanning(max(size(impulse_response)))';
xdc_impulse (tx1, impulse_response);

time = -2/f0:1/fs:2/f0;
F0= f0/1.e6;
BW = 0.6*F0;
excitation = stdpul(time*1e6,F0, BW);
%excitation=sin(2*pi*f0*(0:1/fs:2/f0));
figure(3);
plot(time,excitation);
ss= sprintf('F=%fMHz, BW=%f',F0, BW);
xlabel('Time (usec)');
ylabel('Amplitude');
title(ss);
xdc_excitation (tx1, excitation);

%  Generate aperture for reception
%receive_aperture = xdc_linear_array (N_elements, width, element_height, kerf, 1, 10,focus);
rx1 = xdc_concaveArray( numArray, ROC*1000, numArray * angle_inc,5, 0,.28,.3, 2,10)
%rx1 = xdc_rectangles( rect1, cent1, focus);

%  Set the impulse response for the receive aperture
xdc_impulse (rx1, impulse_response);

%   Load the computer phantom
%[pos,amp]=one_point_pht;
%[pos, amp] = simple_point_pht;
[pos,amp]=plus_pht;
%
%if ~exist('pht_data.mat')
%  disp('Scatterer positions should be made by the script mk_pht')
%  disp('before this script can be run')
%  return
%else
%  load pht_data
%  end

%  The different focal zones for transmit and receive
focal_transmit=[10 18 26 36]'/1000;
Nft=max(size(focal_transmit));
focus_times_transmit=([0 14 22 31]'/1000)/1540;	%put halfway between 

focal_receive=[5:2:50]'/1000;
Nfr=max(size(focal_receive));
%focus_times_receive=([0 12.5 17.5 22.5 27.5 32.5 37.5 42.5 47.5]'/1000)/1540;
focus_times_receive = ([ 0 [6:2:48]]'/1000)/1540;


%  Set-up the apodization vectors
RxActive = min(AperMax,round(focal_receive/( width * RxFnum)))
TxActive = min(AperMax,round(focal_transmit/( width * TxFnum)));

RxApo = zeros(AperMax, length(focal_receive));
for i=1:length(focal_receive)
    AperSize = RxActive(i);
    AperHalf = fix(AperSize/2);
    start = 33-AperHalf;
    stop  = 33+AperHalf;
    RxApo(start:stop,i) = hanning(stop-start+1);
end

TxApo = zeros(AperMax, length(focal_transmit));
for i=1:length(focal_transmit)
    AperSize = TxActive(i);
    AperHalf = fix(AperSize/2);
    start = 33-AperHalf;
    stop  = 33+AperHalf;
    TxApo(start:stop,i) = hanning(stop-start+1);
end


% Do imaging line by line
% figure(2);

%If the folder doesn't exist then create it
if exist(folder,'dir')==0;
    qqq= mkdir(folder);
    if qqq ~= 1; return;end
end
        
cmd = ['save ',folder,'/config.mat sa1 angle f0 BW ROC nlines'];
eval(cmd);
for i=1:nlines

  %if ~exist(['rf_data/rf_ln',num2str(i),'.mat'])
    
    cmd=['save ',folder, '/rf_ln',num2str(i),'.mat i'];
    eval(cmd);
    
    disp(['Now making line ',num2str(i)])
  

    % set up apodization so that no nore than 65 elements contribute
    % This should center the active aperture for the current line
    % This should implement expanding Tx and Rx apertures
    TxApodization = zeros(numArray, length(focal_transmit));
    RxApodization = zeros(numArray, length(focal_receive));
    
    TxApodization(i:i+AperMax-1,:) = TxApo;
    RxApodization(i:i+AperMax-1,:) = RxApo;
    
    xdc_apodization (tx1, focus_times_transmit, TxApodization');    
    xdc_apodization (rx1, focus_times_receive,  RxApodization');

    %   Set the focus for this direction
    % This should calculate the focal points for the current line
    theta= angle(33+i-1)
    Fcenter = calc_center(theta,ROC);
    xdc_center_focus(tx1,Fcenter);
    xdc_center_focus(rx1,Fcenter);
   	
    sa = sa1(i);
    TxFoc = calc_point_steeredx( theta, sa, ROC, focal_transmit);
    xdc_focus (tx1,    focus_times_transmit, [TxFoc(:,1), TxFoc(:,2), TxFoc(:,3)]);
    
    RxFoc = calc_point_steeredx( theta, sa, ROC, focal_receive);
    xdc_focus (rx1,    focus_times_receive,  [RxFoc(:,1), RxFoc(:,2), RxFoc(:,3)]);
   
    % Check everything before makeing the calculation
%    show_xdc(tx1);
%    show_xdc(rx1);
    
    %   Calculate the received response
    [rf_data, tstart]=calc_scat(tx1, rx1, pos, amp);

%    tstart

%    if i == 65
%%        figure(1);   
%		plot(rf_data); title(num2str(i));
%        %show_xdc(tx1);
%       pause 
%	end
  
   %  Store the result
    cmd=['save ',folder,'/rf_ln',num2str(i),'.mat rf_data tstart']
    eval(cmd)
   % end

end

%   Free space for apertures
xdc_free (tx1)
xdc_free (rx1)
