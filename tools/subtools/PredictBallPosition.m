function [ predicted ] = PredictBallPosition(VoxelValue,MLE,radius,FieldSize,CandidateCenters)
%PREDICTBALLPOSITION Summary of this function goes here
%   Detailed explanation goes here


InputImage=[];
for index_CandidateCenters=1:size(CandidateCenters,1)
    InputImage{index_CandidateCenters}=...
        makeImageWithBall(CandidateCenters(index_CandidateCenters,:),radius,FieldSize);
end




for index_sample=1:size(VoxelValue,1)
    display(['Current processed fMRI sample:' num2str(index_sample) '/' num2str(size(VoxelValue,1))])
    %for index_voxel=1:length(MLE)
        %predicted_VoxelValue(:,index_voxel)=mu_VoxelValue(...
        %    MLE{index_voxel}.mu,MLE{index_voxel}.sigma,...
        %    MLE{index_voxel}.r_max,MLE{index_voxel}.r_0,InputImage);
    %end
    L=LogLikelihoodOfInputImage(VoxelValue(index_sample,:),MLE,InputImage);
    %L=corr(VoxelValue(index_sample,:)',predicted_VoxelValue');
    [dummy I]=max(L);
    predicted(index_sample,:)=CandidateCenters(I,:);
end
end

