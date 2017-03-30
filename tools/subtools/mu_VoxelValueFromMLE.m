function [output]=mu_VoxelValueFromMLE(MLE,InputImage)
%MU_VOXELVALUE Summary of this function goes here
%   Detailed explanation goes here
for index_frame=1:length(InputImage)
    Energy=sum(InputImage{index_frame}(:).*MLE.GaussianFilterImage(:));
    output(index_frame,1)=MLE.r_0+MLE.r_max.*Energy;
end
end

