clearvars; close all;
subs = 1:18;

expChoiceData = zeros(6,4,7,length(subs)); % 6 icon probs, 4 pie types, 7 pie prob, pp
subnum = 1;
for currsub = subs
    filename = dir(['participant',num2str(currsub),'_dataExp2*.mat']);
    load (filename.name);

    datatab = table(trialIconsEXP2,cell2mat(trialPiechartTypesEXP2),cell2mat(trialPiechartProbsEXP2),selected_imageEXP2,cell2mat(selected_probabilityEXP2));
    datatab.Properties.VariableNames([2, 3, 5]) = {'PieTypes','PieProb','ChosenProb'};
    piechoice = arrayfun(@(x) strfind(x, 'Pie'), datatab.selected_imageEXP2);
    piechoiceidx = arrayfun(@(x) isempty(cell2mat(x)), piechoice);
    datatab.iconchoice = piechoiceidx;
    pivtab = pivot_table(datatab,{'trialIconsEXP2', 'PieTypes','PieProb'},'iconchoice',@sum);
    pietypes = unique(pivtab.PieTypes);
    pieprobs = unique(pivtab.PieProb);

    datatab2 = table(left_imagesEXP2,cell2mat(left_probabilityEXP2));
    datatab2.Properties.VariableNames(2) = {'IconProb'};
    icontab = pivot_table(datatab2,'left_imagesEXP2','IconProb',@mean);
    icontab = icontab(1:6,:);
    iconNames = icontab.left_imagesEXP2;
    iconProbSet = sort(icontab.mean_of_IconProb);
    
    for curricon = 1:length(iconNames)
        curriconProb = icontab.mean_of_IconProb(curricon);
        curriconProbidx = find(curriconProb==iconProbSet);
        for currpie = 1:length(pietypes)
            ydata = pivtab.sum_of_iconchoice(strcmp(pivtab.trialIconsEXP2,iconNames{curricon})& pivtab.PieTypes==currpie);
            expChoiceData(curriconProbidx,currpie,:,subnum)=ydata;
        end
    end
subnum = subnum+1;
end

save resultsChoiceBehav.mat expChoiceData

% quick plot
avgdata = mean(expChoiceData,4)/5;
figure; aa = 1;
for pietype = 1:4
    choicedata = squeeze(avgdata(:,pietype,:));
    subplot(2,2,aa); plot(pieprobs,choicedata', 'LineWidth',2);
    axis([0 1 0 1]); title (['Pie type ', num2str(pietype)]); xlabel('Prob of winning (Piechart)'); ylabel('Prob of choosing Piechart');
    legend({'1/8','2/8','3/8','5/8','6/8','7/8'}, 'Location','northwest');
    aa = aa+1;
end

% better plot
orange = [200 110 0]/255;
alpha = 1/4:1/8:1;
finalOrange = repmat(orange,[length(alpha),1]);
finalOrange = [finalOrange, alpha'];
figure; aa = 1;
for pietype = 1:4
    xidx = ceil(pietype/2); yidx = mod(pietype+1,2)+1;
    choicedata = expChoiceData(:,pietype,:,:);
    choicedata = choicedata(:)/5;
    pietypes = repmat({'1/8','2/8','3/8','5/8','6/8','7/8'},[1 7*length(subs)])';
    xvals = repmat(repelem(pieprobs,6),[length(subs) 1]);
    gg(xidx,yidx) = gramm('x',xvals,'y',choicedata,'color',pietypes);
    gg(xidx,yidx).stat_summary('geom','line');
end
gg.set_color_options('map',finalOrange);
gg.geom_hline('yintercept',0.5);
gg.axe_property('TickDir','out','YLim',[0 1]);
gg.set_line_options('base_size',3);
gg.set_names('x','S-option prob','y','Prob choosing E-option');
gg.draw();