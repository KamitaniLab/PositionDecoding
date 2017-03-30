function [ Image ] = makeImageGaussianFilterFromMuSigma(mu,sigma,FieldSize)
%MAKEIMAGEGAUSSIANFILTER Summary of this function goes here
%   Detailed explanation goes here
%
%
%
I=([1:FieldSize(1)]')*ones(1,FieldSize(2));
J=ones(FieldSize(1),1)*[1:FieldSize(2)];

Image=...
    exp(-((J-mu(2)).^2+(I-mu(1)).^2)./(2.*(sigma.^2)));

end

