%script to generate a lot of data and images
% author: 
% 	L J Busse, LJB Development, Inc. ljb@ljbdev.com
%

ROC = 50;
nlines = 129;

tic;
for SteeringMax = 0:2:2
    folder = sprintf('rf_sa_%d',SteeringMax);
    sim_concave_steered(ROC, SteeringMax, folder);
    make_concavey_steered(folder,nlines)
end
toc