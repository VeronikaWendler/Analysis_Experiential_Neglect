clearvars; close all;
subs = 1:18;

estimProb = nan(5,7,length(subs)); % 5 symbols (1 icon + 4 pie), 7 pie prob (6 for icon), pp
estimProbConf = estimProb;

subnum = 1;
for currsub = subs
    filename = dir(['participant',num2str(currsub),'_SliderResponsesEXP_*.mat']);
    load (filename.name);

    datatab = table(selectedImageNamesArrayEXP,cell2mat(sliderResponsesArrayEXP),confidenceLevelsArrayEXP);
    datatab.Properties.VariableNames(2) = {'SliderResp'};
    probesttab = pivot_table(datatab,'selectedImageNamesArrayEXP','SliderResp',@mean);
    conftab = pivot_table(datatab,'selectedImageNamesArrayEXP','confidenceLevelsArrayEXP',@mean);

    filename = dir(['participant',num2str(currsub),'_dataExp1*.mat']);
    load (filename.name);
    getNamesAndProbs = [reshape(selectedImagesFromEXP,[6 1]), reshape(string(selectedProbabilitiesFromEXP),[6 1])];
    sortedNamesAndProb = sortrows(getNamesAndProbs,2);

    curricons = conftab.selectedImageNamesArrayEXP(1:6);
    for icn = 1:6
        iconidx = find(contains(sortedNamesAndProb(:,1),curricons{icn}));
        if iconidx>3
            iconidx = iconidx+1;
        end
        estimProb(1,iconidx,subnum) = probesttab.mean_of_SliderResp(icn);
        estimProbConf(1,iconidx,subnum) = conftab.mean_of_confidenceLevelsArrayEXP(icn);
    end
    pieonlytabProbEst = probesttab(7:end,:);
    pieonlytabConf = conftab(7:end,:);

    for pie = 1:height(pieonlytabProbEst)
        pietype = str2double(pieonlytabProbEst.selectedImageNamesArrayEXP{pie}(4));
        pieidx = str2double(pieonlytabProbEst.selectedImageNamesArrayEXP{pie}(5));
        estimProb(pietype+1,pieidx,subnum) = pieonlytabProbEst.mean_of_SliderResp(pie);
        estimProbConf(pietype+1,pieidx,subnum) = pieonlytabConf.mean_of_confidenceLevelsArrayEXP(pie);
    end

subnum = subnum+1;
end

save resultsStatedProb.mat estimProb estimProbConf

