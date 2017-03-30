function [ MLE Corr] = estimateRFM_roughEstimateForInitialValue(VoxelValue,InputImage,muCandidate,sigmaCandidate)
%ESTIMATERFM Summary of this function goes here
%   Detailed explanation goes here
%

if size(VoxelValue,2)~=1
    error('VoxelValue must be a column vector')
end
if length(InputImage)~=size(VoxelValue,1)
    error('The numbers of fMRI samples and input image samples must be the same.')
end
FieldSize=size(InputImage{1});

if var(VoxelValue) < 0.01
    MLE=NaN;
    WeightedAverage=NaN;
    Corr=NaN;
else
    
    
    display('Grid search for estimating mu and sigma')
    candidatesIn3Dspace=[];
    for index_mu=1:size(muCandidate,1)
        for index_sigma=1:length(sigmaCandidate)
            candidatesIn3Dspace=...
                [candidatesIn3Dspace;...
                muCandidate(index_mu,1) muCandidate(index_mu,2) sigmaCandidate(index_sigma)];
        end
    end
    
    C=[];
    for index_candidatesIn3Dspace=1:size(candidatesIn3Dspace,1)
        FilteredValue=...
            mu_VoxelValue(...
            candidatesIn3Dspace(index_candidatesIn3Dspace,[1 2]),...
            candidatesIn3Dspace(index_candidatesIn3Dspace,3),1,0,InputImage);
        C(index_candidatesIn3Dspace)=corr(FilteredValue,VoxelValue);
    end
    [dummy I]=max(C);
    MLE.mu=[candidatesIn3Dspace(I,[1 2])];
    MLE.sigma=candidatesIn3Dspace(I,3);
  
    
    
    display('The other 3 parameter fitting after mu & sigma estimation')
    FilteredValue=...
            mu_VoxelValue(MLE.mu,MLE.sigma,1,0,InputImage);
    [B]=regress(VoxelValue,[FilteredValue ones(length(FilteredValue),1)]);
    MLE.r_0=B(2);
    MLE.r_max=B(1);
    MLE.sigma_noise=sqrt(mean((VoxelValue-(MLE.r_0+(MLE.r_max).*FilteredValue)).^2));
    MLE.GaussianFilterImage=...
        makeImageGaussianFilterFromMuSigma(MLE.mu,MLE.sigma,FieldSize);
    
    predictedVoxelValue=mu_VoxelValueFromMLE(MLE,InputImage);
    Corr=corr(predictedVoxelValue,VoxelValue);
    
end



