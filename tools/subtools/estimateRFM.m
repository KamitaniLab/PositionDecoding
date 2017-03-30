function [ MLE Corr] = estimateRFM(VoxelValue,InputImage,MLE_old)
%ESTIMATERFM Summary of this function goes here
%   Detailed explanation goes here
%

if size(VoxelValue,2)~=1
    error('VoxelValue must be a column vector')
end
if length(InputImage)~=size(VoxelValue,1)
    error('The numbers of fMRI samples and input image samples must be the same.')
end


if var(VoxelValue) < 0.01
    MLE=NaN;
    WeightedAverage=NaN;
    Corr=NaN;
else
    
    %Weighted avarage calculation
    display('set initial values.')
   
    %set initial values for mu and sigma
    FieldSize=size(InputImage{1});
    
    initial_mu=MLE_old.mu;
    initial_sigma=MLE_old.sigma;
    initial_r0=MLE_old.r_0;
    initial_rmax=MLE_old.r_max;
    initial_sigma_noise=MLE_old.sigma_noise;
    initialValues=[initial_mu initial_sigma initial_rmax initial_r0 initial_sigma_noise];
    
    %Construct LogLikelihood function
    %Reference
    %http://staff.aist.go.jp/t.ihara/likelihood.html
    N=length(VoxelValue);
    LogLikelihood=@(mu,sigma,r_max,r_0,sigma_noise)...
        N.*log(1./(sqrt(2.*pi).*sigma_noise))...
        -(1./(2.*(sigma_noise.^2))).*...
        sum((VoxelValue-mu_VoxelValue(mu,sigma,r_max,r_0,InputImage)).^2,1);
    
    %optimization
    display('conduct optimization')
    options.Display='off';
    F=@(x)-LogLikelihood([x(1),x(2)],x(3),x(4),x(5),x(6));
    %[minimizer func_value]=fmincon(F,initialValues,[],[],[],[],...
    %    [0 0 0 0 min(VoxelValue) 0],[FieldSize min(FieldSize) Inf max(VoxelValue) std(VoxelValue)]);
    %[minimizer func_value]=fminunc(F,initialValues,options);
    [minimizer func_value]=fminsearch(F,initialValues,options);
    %[minimizer func_value]=anneal(F,initialValues);
    
    MLE.mu=[minimizer(1);minimizer(2)];
    MLE.sigma=minimizer(3);
    MLE.r_max=minimizer(4);
    MLE.r_0=minimizer(5);
    MLE.sigma_noise=minimizer(6);
    MLE.GaussianFilterImage=...
        makeImageGaussianFilterFromMuSigma(MLE.mu,MLE.sigma,FieldSize);
    
    predictedVoxelValue=mu_VoxelValueFromMLE(MLE,InputImage);
    Corr=corr(predictedVoxelValue,VoxelValue);
    WeightedAverage=NaN;
end



