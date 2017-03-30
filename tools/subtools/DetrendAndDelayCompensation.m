function [processed_label processed_data runNumber] = DetrendAndDelayCompensation(label,data,inds_runs,hemodynamic_delay)
%DETRENDANDDELAYCOMPENSATION Summary of this function goes here
%   Detailed explanation goes here


%inds_runs(1,:): runs' starting points
%inds_runs(2,:): runs' ending points

BP=(inds_runs(:))';
detrended_data=detrend(data,'linear',BP);
%detrended_data=data;

processed_data=[];
processed_label=[];
runNumber=[];
for index_run=1:size(inds_runs,2)
    processed_data=[processed_data;...
        detrended_data((inds_runs(1,index_run)+hemodynamic_delay):inds_runs(2,index_run),:)];
    processed_label=[processed_label;...
        label(inds_runs(1,index_run):(inds_runs(2,index_run)-hemodynamic_delay),:)];
    runNumber=[runNumber;...
        index_run.*ones(length(inds_runs(1,index_run):(inds_runs(2,index_run)-hemodynamic_delay)),1)];
end

