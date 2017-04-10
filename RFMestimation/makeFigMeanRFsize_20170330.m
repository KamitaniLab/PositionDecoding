clear all
addpath(genpath('../tools/'));

filename{1}=['Subject1'];
filename{2}=['Subject2'];
filename{3}=['Subject3'];
filename{4}=['Subject4'];
filename{5}=['Subject5'];

roi{1}='V1';
roi{2}='V2';
roi{3}='V3';
roi{4}='V4';
roi{5}='LOC';
roi{6}='FFA';

meanRFsize=[];% a matrix would include mean RF sizes (6 rois x 5 subjects)
for index_filename=1:length(filename)
    %load fMRI data
    load(['../data/' filename{index_filename} '.mat'])
    
    temporal_RFsize4thisSubject=cell(6,1);
    
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
            %Pick up the voxel numbers for each ROI
            usedVoxelNumber = get_metadata(metaData, roi{index_roi});
            usedVoxelNumber=find(usedVoxelNumber);
            
            
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
            
            
          
           %pool the RF sizes
           for index_usedVoxelNumer=1:length(usedVoxelNumber)
                temporal_RFsize4thisSubject{index_roi}=...
                    [temporal_RFsize4thisSubject{index_roi};MLE{usedVoxelNumber(index_usedVoxelNumer)}.sigma.*(19/60)];
           end
            
            
            
        end
        
        
    end
    
    %take the mean for each ROI
    for index_roi=1:length(roi)
        meanRFsize(index_roi,index_filename)=mean(temporal_RFsize4thisSubject{index_roi});
    end
end

figure
subplot('Position',[0.15 0.2 0.8 0.6])
FontSize=14;
Color{1}=[1 0 0];
Color{2}=[0 0 1];
Color{3}=[0 0.8 0];
Color{4}=[0 1 1];
Color{5}=[1 0 1];

hold on
for index_height=1:8
    plot([0 7],[1 1].*(index_height.*0.5),':','Color',[0.5 0.5 0.5],'LineWidth',0.5)
end
%plot the results for each subject.
for index_filename=1:length(filename)
    handle4legend(index_filename)=...
        plot(1:6,meanRFsize(:,index_filename),'Color',Color{index_filename},'LineWidth',1);
end
%plot the results averaged across subjects.
handle4legend(length(filename)+1)=...
        plot(1:6,mean(meanRFsize,2),'Color',[0 0 0],'LineWidth',2);
hold off

ylabel('RF size (degree)','FontSize',FontSize)
set(gca,'XTick',[1:6],'XTickLabel',roi,'FontSize',FontSize)
set(gca,'YTick',[0:0.5:3.5],'FontSize',FontSize)
xlim([0.5 6.5])
ylim([0 3.5])
set(gca,'Box','off','TickDir','out','TickLength',[0.03 0.03])
handle4legend=legend(handle4legend,{'S1','S2','S3','S4','S5','Mean'});
set(handle4legend,'Box','off','Location','SouthEast','FontSize',FontSize)
saveas(gcf,'figMeanRFsize_20170330.pdf','pdf')

