function fout = calc_point_steeredx( elem_angle, steer_angle, ROC, foc)
%
% This function is specific for rotating the Tx and Rx focus of a concave
% array with ROC radius
% elem_angle is the angular position of the element on the array
% steer+angle is the angle (from normal) it should be steered
%

[np, nl]=size(foc);

fout = zeros(np,3);

srot = makehgtform('yrotate', -steer_angle);  %All are steered the same amount
rot  = makehgtform('yrotate', elem_angle);
for i=1:np
    %steer the line and add ROC
	invec = [0,0,-foc(i),0]';
	outvec = srot * invec;
	
	%add the ROC
	invec = outvec + [0,0,ROC,0]';

	%Now rotate to position on the array  
    outvec = rot * invec;
    fout(i,1) = outvec(1); fout(i,2) = outvec(2); fout(i,3) = outvec(3);
end
