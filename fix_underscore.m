function out = fix_underscore(in)
%
%
%
[s0,s1]=strtok(in,'_');
out = [s0 '\_'];
while (length(s1) > 0),
   [s0,s1]=strtok(s1,'_');
   out = [out s0 '\_'];
end
l=length(out)
out = out(1:l-2);	%strips last two characters
