clear all
addpath(genpath('../tools/'));

filename{1}=['TH130109'];
filename{2}=['RA121222'];
filename{3}=['YH130109'];
filename{4}=['RO140926'];
filename{5}=['SC150326'];

roi{1}='V1';
roi{2}='V2';
roi{3}='V3';
roi{4}='V4';
roi{5}='LOC';
roi{6}='FFA';

for index_filename=1:length(filename)
    %load fMRI data
    load(['../data/' filename{index_filename} '.mat'])
    %make a variable to store results
    results=cell(length(roi),1);
    for index_roi=1:length(results)
        results{index_roi}.true_x=[];
        results{index_roi}.true_y=[];
        results{index_roi}.predicted_x=[];
        results{index_roi}.predicted_y=[];
    end
    
    for index_run4test=1:3
        switch index_run4test
            case 1
                runNumber4training='23';
            case 2 
                runNumber4training='13';
            case 3
                runNumber4training='12';        
        end
        
        
        
        for index_roi=1:length(roi)
            %Pick up the voxel data 
            voxelData = get_dataset(dataSet,metaData,roi{index_roi});
            stimulusPosition_x = get_dataset(dataSet,metaData,'Label (x-coordinate)');
            stimulusPosition_y = get_dataset(dataSet,metaData,'Label (y-coordinate)');
            runNumber = get_dataset(dataSet,metaData,'Run');
            
            %exclude trials where no stimulus were presented.
            I=find(any(isnan([stimulusPosition_x stimulusPosition_y]),2));
            voxelData(I,:)=[];
            stimulusPosition_x(I,:)=[];
            stimulusPosition_y(I,:)=[];
            runNumber(I,:)=[];
                
            %position decoding by kSVR.
            param.svmoption='-s 3 -t 2 -p 0';
            predicted_x=...
               traintest_SVR(...
               voxelData(runNumber~=index_run4test,:),stimulusPosition_x(runNumber~=index_run4test,:),...
               voxelData(runNumber==index_run4test,:),stimulusPosition_x(runNumber==index_run4test,:),param);
            predicted_y=...
               traintest_SVR(...
               voxelData(runNumber~=index_run4test,:),stimulusPosition_y(runNumber~=index_run4test,:),...
               voxelData(runNumber==index_run4test,:),stimulusPosition_y(runNumber==index_run4test,:),param);
           
            
            %store the decoding results
            results{index_roi}.true_x=[results{index_roi}.true_x;stimulusPosition_x(runNumber==index_run4test,:)];
            results{index_roi}.true_y=[results{index_roi}.true_y;stimulusPosition_y(runNumber==index_run4test,:)];
            results{index_roi}.predicted_x=[results{index_roi}.predicted_x;predicted_x];
            results{index_roi}.predicted_y=[results{index_roi}.predicted_y;predicted_y];
      

        end
        
        
    end
    save(['results/resultsPositionDecodingBySVR_' filename{index_filename} '.mat'],'results')
end

