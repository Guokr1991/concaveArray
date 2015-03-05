function fout = calc_point( angle, ROC, foc)
%
% This function is specific for rotating the Tx and Rx focus of a concave
% array with ROC radius
%
[np, nl]=size(foc);

fout = zeros(np,3);

rot = makeyrotform(angle);

for i=1:np
    invec = [0, 0, ROC - foc(i), 0]';
    outvec = rot * invec;
    fout(i,1) = outvec(1); fout(i,2) = outvec(2); fout(i,3) = outvec(3);
end
