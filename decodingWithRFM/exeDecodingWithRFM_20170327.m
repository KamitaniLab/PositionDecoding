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
            voxelData = get_dataset(dataSet,metaData,'VoxelData');
            usedVoxelNumber = get_metadata(metaData, roi{index_roi});
            usedVoxelNumber=find(usedVoxelNumber);
            stimulusPosition_x = get_dataset(dataSet,metaData,'Label (x-coordinate)');
            stimulusPosition_y = get_dataset(dataSet,metaData,'Label (y-coordinate)');
            runNumber = get_dataset(dataSet,metaData,'Run');
            
            %Pick up the fMRI samples from the test run.
            voxelData=voxelData(runNumber==index_run4test,:);
            stimulusPosition_x=stimulusPosition_x(runNumber==index_run4test,:);
            stimulusPosition_y=stimulusPosition_y(runNumber==index_run4test,:);
            
            
            %Load the RFM parameters
            load(['..//RFMestimation/RFMparameter/' ...
                'RFMparameter_' filename{index_filename} 'run' runNumber4training '.mat'])
            
            %Voxel selection by RFM fitness
            I=find(all([...
                0.2 < CorrVoxel' ...
                CorrVoxel' < 1.0],2));
            usedVoxelNumber=intersect(usedVoxelNumber,I);
                  
            %Voxel selection by removing the voxels whose RF centers are
            %outside the stimulus field.
            mu=[];
            for index_voxel=1:length(MLE)
                if isstruct(MLE{index_voxel})
                    mu(index_voxel,:)=[(MLE{index_voxel}.mu-30.5).*(19/60)];
                else
                    mu(index_voxel,:)=[NaN NaN];
                end
            end
            mu(:,1)=-mu(:,1);
            I=find(all([...
                -3.8 < mu(:,1) ...
                mu(:,1) < 3.8 ...
                -3.8 < mu(:,2) ...
                mu(:,2) < 3.8],2));
            usedVoxelNumber=intersect(usedVoxelNumber,I);
            
            
            %Exclude trials where no stimulus was presented.
            I=find(any(isnan([stimulusPosition_x stimulusPosition_y]),2));
            voxelData(I,:)=[];
            stimulusPosition_x(I,:)=[];
            stimulusPosition_y(I,:)=[];
        
            %Decodeing analysis
            
            %Set the positions for which we will calculate the likelihood.
            candidatesOfBallPositions=[];
            for index_i=21:40  
                for index_j=21:40
                    candidatesOfBallPositions=[candidatesOfBallPositions;index_i index_j];
                end
            end
            fieldSize=[60 60];
            radius=(60./19).*0.5;
            %position decoding by MLE.
            predicted=...
               PredictBallPosition(voxelData(:,usedVoxelNumber),...
                MLE(usedVoxelNumber),radius,fieldSize,candidatesOfBallPositions);
            
            
            %store the decoding results.
            %Here, the decoded positions from the above function are
            %expressed by the positions in the 60 x 60-image matrix space.
            %store the values after transforming them into the the
            %xy-coordinates.
            results{index_roi}.true_x=[results{index_roi}.true_x;stimulusPosition_x];
            results{index_roi}.true_y=[results{index_roi}.true_y;stimulusPosition_y];
            results{index_roi}.predicted_x=[results{index_roi}.predicted_x;(predicted(:,2)-30.5).*(+19/60)];
            results{index_roi}.predicted_y=[results{index_roi}.predicted_y;(predicted(:,1)-30.5).*(-19/60)];
           
                
            
            
            
        end
        
        
    end
    save(['results/resultsPositionDecodingByMLE_' filename{index_filename} '.mat'],'results')
end

