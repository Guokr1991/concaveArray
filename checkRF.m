
no_lines=129;              %  Number of lines in image
fs = 200e6;

%  Read the data and adjust it in time 
min_sample=0;

Tstart = zeros(no_lines,1);
RF = zeros(8192,no_lines);

for i=1:no_lines

  %  Load the result

  cmd=['load rf_data/rf_ln',num2str(i),'.mat'];
  disp(cmd)
  eval(cmd)
  Tstart(i) = tstart;
  %  Find the envelope
  
  %rf_env=abs(hilbert([zeros(round(tstart*fs-min_sample),1); rf_data]));
    tmp = abs(hilbert([zeros(round(tstart*fs-min_sample),1); rf_data]));
    RF(1:max(size(tmp)),i)=tmp;

end

figure(1);
plot(Tstart);
figure(2);
imagesc(abs(RF));

figure(3)
%  Do logarithmic compression to 50 dB
D=10;
dB_Range=50;
env=RF-min(min(RF));
log_env=20*log10(env(1:D:max(size(env)),:)/max(max(RF)));
log_env=max(0,255/dB_Range*(log_env+dB_Range));
imagesc(log_env);

