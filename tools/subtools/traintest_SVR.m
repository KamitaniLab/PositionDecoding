function [predicted_label true_label param] = traintest_SVR(feature4training,label4training,feature4test,label4test,param)
%TRAINTEST_SVR Summary of this function goes here
%   Detailed explanation goes here

if ~isfield(param,'svmoption')
    param.svmoption='-s 3 -t 0 -p 0';
end
if ~isfield(param,'zscore4label')
    param.zscore4label=1;
end
if ~isfield(param,'zscore4feature')
    param.zscore4feature=1;
end
if ~isfield(param,'numFeatures')
    param.numFeatures=size(feature4training,2);
end


if param.zscore4feature
    [feature4training mu sigma]=zscore(feature4training);
    feature4test=(feature4test-ones(size(feature4test,1),1)*mu)./(ones(size(feature4test,1),1)*sigma);
end

if param.zscore4label
    [label4training mu4label sigma4label]=zscore(label4training);
end
if param.numFeatures~=size(feature4training,2);
    C=corr(label4training,feature4training);
    [dummy I]=sort(abs(C),'descend');
    feature4training=feature4training(:,I(1:param.numFeatures));
    feature4test=feature4test(:,I(1:param.numFeatures));
end
model=svmtrain(label4training,feature4training,param.svmoption);
predicted_label=svmpredict(label4test,feature4test,model);
true_label=label4test;

if param.zscore4label
    predicted_label=(predicted_label.*sigma4label)+mu4label;
end

