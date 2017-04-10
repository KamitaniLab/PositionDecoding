clear all
addpath(genpath('../tools/'));

filename{1}=['Subject1'];
filename{2}=['Subject2'];
filename{3}=['Subject3'];
filename{4}=['Subject4'];
filename{5}=['Subject5'];


for index_filename=1:length(filename)
    load(['../data/' filename{index_filename} '.mat'])
    for index_run2exclude=1:3
        switch index_run2exclude
            case 1
                tag4usedRun='23';
            case 2 
                tag4usedRun='13';
            case 3
                tag4usedRun='12';        
        end
        
        %Pick up the fMRI samples for the training
        voxelData = get_dataset(dataSet,metaData,'VoxelData');
        stimulusPosition_x = get_dataset(dataSet,metaData,'Label (x-coordinate)');
        stimulusPosition_y = get_dataset(dataSet,metaData,'Label (y-coordinate)');
        runNumber = get_dataset(dataSet,metaData,'Run');
        
        voxelData4training=voxelData(runNumber~=index_run2exclude,:);
        stimulusPositionIn60x60matrixSpace=[30.5+(-60/19).*stimulusPosition_y 30.5+(60/19).*stimulusPosition_x];
        stimulusPositionIn60x60matrixSpace=...
            stimulusPositionIn60x60matrixSpace(runNumber~=index_run2exclude,:);
        
         %Prepare stimulus image matrix
        InputImage=[];
        ballRadius=(60./19).*0.5;
        fieldSize=[60 60];
        for index_sample=1:size(stimulusPositionIn60x60matrixSpace,1)
            InputImage{index_sample}=...
                makeImageWithBall(stimulusPositionIn60x60matrixSpace(index_sample,:),ballRadius,fieldSize);
        end
        
        
        %Estimate pRF model parameters by grid search.
        %First, grid search was performed roughly and globally.
        %Then, fine grid search was performed around the above results.
        %Then, one more finer grid search was performed.
        %Then, the final RFM estimation was performed with the above
        %results.
        for index_voxel=1:size(voxelData4training,2)
            
            display(['Processed voxel #:' num2str(index_voxel) ' (' num2str(index_voxel) '/' num2str(size(voxelData4training,2)) ')'])
            
            %set mu values for the grid search.
            muCandidate=[];
            for index_i=0:10:60
                for index_j=0:10:60
                    muCandidate=[muCandidate;index_i index_j];
                end
            end
            %set sigma values for the grid search.
            sigmaCandidate=[1 3 5 10 15 20 30 45 60]';
            
            %Make the search area narrower
            WeightedAverage4currentVoxel=zeros(fieldSize);
            for index_sample=1:size(voxelData4training,1)
                WeightedAverage4currentVoxel=...
                    WeightedAverage4currentVoxel+...
                    voxelData4training(index_sample,index_voxel).*InputImage{index_sample};     
            end
            WeightedAverage4currentVoxel=WeightedAverage4currentVoxel./size(voxelData4training,1);
            threshold=prctile(WeightedAverage4currentVoxel(:),99);
            [temporal_candidate_muI temporal_candidate_muJ]=find(WeightedAverage4currentVoxel > threshold);
            muCandidate=[muCandidate;temporal_candidate_muI temporal_candidate_muJ];
            muCandidate=unique(muCandidate,'rows');
                        
    
            [temporal_MLE temporal_corr]=...
                estimateRFM_roughEstimateForInitialValue...
                (voxelData4training(:,index_voxel),InputImage,...
                muCandidate,sigmaCandidate);
            if isstruct(temporal_MLE)
                %Fine grid search
                muCandidate=[];
                sigmaCandidate=[];
                for index_i=-12:3:12
                    for index_j=-12:3:12
                        muCandidate=[muCandidate;[index_i index_j]+temporal_MLE.mu];
                    end
                end
                sigmaCandidate=[-12:3:12]'+temporal_MLE.sigma;
                sigmaCandidate=sigmaCandidate(sigmaCandidate>0);
                        
                [temporal_MLE temporal_corr]=...
                    estimateRFM_roughEstimateForInitialValue...
                    (voxelData4training(:,index_voxel),InputImage,...
                    muCandidate,sigmaCandidate);
                        
                %Finer grid search
                muCandidate=[];
                sigmaCandidate=[];
                for index_i=-3:1:3
                    for index_j=-3:1:3
                        muCandidate=[muCandidate;[index_i index_j]+temporal_MLE.mu];
                    end
                end
                sigmaCandidate=[-3:1:3]'+temporal_MLE.sigma;
                sigmaCandidate=sigmaCandidate(sigmaCandidate>0);
                        
                [temporal_MLE temporal_corr]=...
                    estimateRFM_roughEstimateForInitialValue...
                    (voxelData4training(:,index_voxel),InputImage,...
                    muCandidate,sigmaCandidate);
                        
                        
                %Final RFM estimation
                [MLE{index_voxel} CorrVoxel(index_voxel)]=...
                    estimateRFM...
                        (voxelData4training(:,index_voxel),InputImage,...
                        temporal_MLE);
                WeightedAverage{index_voxel}=...
                        WeightedAverage4currentVoxel;
            else
                MLE{index_voxel}=NaN;
                WeightedAverage{index_voxel}=NaN;
                CorrVoxel(index_voxel)=NaN;
            end
            save(['RFMparameter/RFMparameter_' filename{index_filename} 'run' tag4usedRun '.mat'],'MLE','CorrVoxel')
        end
        
        
        
        
    end
end
