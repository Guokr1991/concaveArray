
function [pos, amp] = plus_phantom (N)

%  Place the point scatterers in the phantom

%basic resolution pattern
%x1 = 0.5*[0,1,3,6,10,15]-3.75;
%y1 = [0,0,0,0,0,0];
%z1 = 0.5*[0,1,2,3,4,5]-1.25;

%plus pattern on a 1mm grid
x1=[0];%[0,-1,0,1,0];
y1=[0];%[0,0,0,0,0];
z1=[0];%1,0,0,0,-1];

x=[];y=[];z=[];
ycenter =0;
%place a group at 3 ranges center
for xcenter = -20:5:20
    for zcenter = 45:-5:10
        x = [x, x1+xcenter];
        y = [y, y1+ycenter];
        z = [z, z1+zcenter];
    end
end

npts = length(x);
amp = 100*ones(npts,1);

size(x)
size(z)


r = 50;
%xc=0;
%zc=0;
%outside = ( ((x-xc).^2 + (z-zc).^2) >= r^2);
%amp = amp .* (1-outside'); 

figure(2);plot(x,z,'+');
%  Return the variables
pos = [x' y' z']/1000;




