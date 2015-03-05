function p = StdPul(t,f,bw)
p=zeros( size(t) );
if (nargin < 2),
   F_0 = 8.0
else 
   F_0 = f
end
if (nargin < 3),
   DeltaF = .6*F_0;
else
   DeltaF = bw;
end

phase = pi;
omega = 2.0 * pi * F_0;
sigmaT = sqrt(2 * log(2.0)) / DeltaF / pi;
p = exp(-(t.^2)/(2. *  sigmaT^2 )) .* sin((omega * t) + phase);



