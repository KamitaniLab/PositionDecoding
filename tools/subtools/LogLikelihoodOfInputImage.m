function [ output ] = LogLikelihoodOfInputImage(VoxelValue,MLE,InputImage)
%LOGLIKELIHOODOFINPUTIMAGE Summary of this function goes here
%   Detailed explanation goes here

if size(VoxelValue,1)~=1
    error('VoxelValue must be 1 by D')
end
if ~iscell(InputImage)
    InputImage_copied=InputImage;
    InputImage=[];
    InputImage{1}=InputImage_copied;
end
num_used_voxel=0;
used_voxel=[];

for index_voxel=1:length(MLE)
    if ~isstruct(MLE{index_voxel})
        
    else
        num_used_voxel=num_used_voxel+1;
        used_voxel=[used_voxel num_used_voxel];
        %mufMRIsignal(:,num_used_voxel)=...
        %    mu_VoxelValue(MLE{index_voxel}.mu,MLE{index_voxel}.sigma,...
        %    MLE{index_voxel}.r_max,MLE{index_voxel}.r_0,InputImage);
        mufMRIsignal(:,num_used_voxel)=...
            mu_VoxelValueFromMLE(MLE{index_voxel},InputImage);
        sigma_noise(1,num_used_voxel)=MLE{index_voxel}.sigma_noise;
    end
end

for index_sample=1:length(InputImage)
    output(index_sample,1)=...
        sum(...
        log(1./(sqrt(2.*pi).*sigma_noise))...
        -(((VoxelValue(1,:)-mufMRIsignal(index_sample,:)).^2)./(2.*(sigma_noise.^2)))...
        ,2);
end
