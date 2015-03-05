function w = hanning(npts)
%
% raised cosine
%
period = npts-1;
w =0.5*abs( 1 - cos(2*pi*[0:npts-1]/period))';

