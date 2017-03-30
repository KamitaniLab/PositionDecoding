function [output]=mu_VoxelValue(mu,sigma,r_max,r_0,InputImage)
%MU_VOXELVALUE Summary of this function goes here
%   Detailed explanation goes here
for index_frame=1:length(InputImage)
    output(index_frame,1)=r_0+r_max.*GaussianFilteredValue(mu,sigma,InputImage{index_frame});
end
end

