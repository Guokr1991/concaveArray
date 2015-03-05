function fout = calc_center( angle, ROC)
%
% 


rot = makeyrotform(angle);
invec = [0, 0, ROC, 0]';
outvec = rot*invec;
fout = outvec(1:3)';
