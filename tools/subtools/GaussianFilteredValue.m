function [output]=GaussianFilteredValue(mu,sigma,SingleFrame)
%GAUSSIANFILTEREDVALUE Summary of this function goes here
%Detailed explanation goes here
%mu(1):Horizontal (mu(1)=0 is corresponding to the upper)
%mu(2):Vertical   (mu(2)=0 is corresponding to the left side)
D=zeros(size(SingleFrame));
for index_x=1:size(SingleFrame,2)
    for index_y=1:size(SingleFrame,1)
        D(index_y,index_x)=...
            exp(-((index_x-mu(2)).^2+(index_y-mu(1)).^2)./(2.*(sigma.^2)));
    %exp(-((index_x-mu(2)).^2+(index_y-mu(1)).^2)./(2.*(sigma.^2)))...
            %./(2.*pi.*(sigma.^2));
    end
end

output=sum(D(:).*SingleFrame(:),1);
    
end

