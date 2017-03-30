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

value4plot=[];
for index_filename=1:length(filename)
    load(['results/resultsPositionDecodingByMLE_' filename{index_filename} '.mat'])
    for index_roi=1:length(roi)
        value4plot(index_filename,index_roi,1)=...
            corr(results{index_roi}.true_x,results{index_roi}.predicted_x);
        value4plot(index_filename,index_roi,2)=...
            corr(results{index_roi}.true_y,results{index_roi}.predicted_y);
    end
end


%take the mean across subjects.
%calculate CIs.
mean4plot=[];
CI4plot=[];
for index_roi=1:length(roi)
    for index_HorizontalOrVertical=1:2
        mean4plot(index_roi,index_HorizontalOrVertical)=...
            ifisherz(mean(fisherz(value4plot(:,index_roi,index_HorizontalOrVertical))));
        [dummy1 dummy2 temporal_CI]=ttest(fisherz(value4plot(:,index_roi,index_HorizontalOrVertical)));
        CI4plot(index_roi,index_HorizontalOrVertical,:)=ifisherz(temporal_CI);
    end
end


figure
subplot('Position',[0.15 0.2 0.8 0.6])
hold on
for index_height=1:5
    plot([0 7],[1 1].*(index_height.*0.2),':','Color',[0.5 0.5 0.5],'LineWidth',0.5)
end
for index_HorizontalOrVertical=1:2
    switch index_HorizontalOrVertical
        case 1
            lineColor=[0 0 0];
            lineShift=0;
        case 2
            lineColor=[0.5 0.5 0.5];
            lineShift=0.12;
    end
    handle4legend(index_HorizontalOrVertical)=...
        plot((1:6)+lineShift,mean4plot(:,index_HorizontalOrVertical),...
        '.-','Color',lineColor,'LineWidth',2,'MarkerSize',20);
    for index_roi=1:length(roi)
        plot([1 1].*(index_roi+lineShift),...
            squeeze(CI4plot(index_roi,index_HorizontalOrVertical,:)),...
            'Color',lineColor,'LineWidth',2)
    end
end
hold off
FontSize=14;
ylabel('Decoding accuracy (correlation)','FontSize',FontSize)
set(gca,'XTick',[1:6],'XTickLabel',roi,'FontSize',FontSize)
set(gca,'YTick',[0:0.2:1],'FontSize',FontSize)
xlim([0.5 6.5])
ylim([0 1])
set(gca,'Box','off','TickDir','out','TickLength',[0.03 0.03])
handle4legend=legend(handle4legend,{'Horizontal','Vectical'});
set(handle4legend,'Box','off','Location','SouthWest','FontSize',FontSize)
title('Decoding accuracy with RFM','FontSize',FontSize)
saveas(gcf,'figDecodingAccuracyWithRFM_20170327.pdf','pdf')