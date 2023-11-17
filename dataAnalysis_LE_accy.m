clearvars; close all;
subs = 1:18;

perf = zeros(2,3,length(subs)); % accy & rt for each icon-pair per participant

subnum = 1;
for currsub = subs
    filename = dir(['participant',num2str(currsub),'_dataExp1*.mat']);
    load (filename.name);

    getNamesAndProbs = [reshape(selectedImagesFromEXP,[6 1]), reshape(string(selectedProbabilitiesFromEXP),[6 1])];
    sortedNamesAndProb = sortrows(getNamesAndProbs,2);

    datatab = table(current_subblogEXP,leftimEXP,clicksArray1EXP,elapsedTimeEXP);
    datatab.clicksArray1EXP = 2-datatab.clicksArray1EXP;
    for block = 1:3
        blockData = datatab(datatab.current_subblogEXP==block,:);
        higherProbInBlock = contains(blockData.leftimEXP,sortedNamesAndProb(4:end,1));
        blockData.choice(higherProbInBlock) = blockData.clicksArray1EXP(higherProbInBlock);
        blockData.choice(~higherProbInBlock) = 3-blockData.clicksArray1EXP(~higherProbInBlock);
        iconIdx = find(contains(sortedNamesAndProb(:,1),unique(blockData.leftimEXP)));
        perfidx = iconIdx(2)-3;
        perfAccy = mean(mod(blockData.choice,2));
        perfRT = median(blockData.elapsedTimeEXP);
        perf(:,perfidx,subnum)= [perfAccy;perfRT];
    end
    subnum = subnum+1;
end
save resultsLE_perf.mat perf

% quick plot
avgaccy = squeeze(mean(perf(1,:,:),3));
avgrt = squeeze(mean(perf(2,:,:),3));
figure; hold on;
subplot(1,2,1); bar(avgaccy); title('accuracy'); axis([0.5 3.5 0 1]);
subplot(1,2,2); bar(avgrt); title('rt'); axis([0.5 3.5 0 2]);
hold off;

% better plot
xvals = repmat({'1/8-7/8', '2/8-6/8', '3/8-5/8'},[1 length(subs)]);
yvals_acc = perf(1,:,:);
yvals_acc = yvals_acc(:);
yvals_rt = perf(2,:,:);
yvals_rt = yvals_rt(:);
figure;
g(1,1) = gramm('x',xvals, 'y', yvals_acc);
g(1,1).stat_summary('geom',{'point','errorbar'});
g(1,1).geom_hline('yintercept',0.5,'style','k:');
g(1,1).set_names('x','Probability','y','Proportion correct');
g(1,1).axe_property('TickDir','out','YLim',[0 1]);
g(1,2) = gramm('x',xvals, 'y', yvals_rt);
g(1,2).stat_summary('geom',{'point','errorbar'});
g(1,2).set_names('x','Probability','y','Median RT (s)');
g(1,2).axe_property('TickDir','out','YLim',[0 1.2]);
g.set_point_options("base_size",15);
g.draw();