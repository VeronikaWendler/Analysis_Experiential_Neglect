clearvars; close all;
subs = 1:18;

nll = zeros(length(subs));
parameters = zeros(2,length(subs)); % 1 temperature (b) and alpha for each participant
probwin = zeros(6,length(subs));

options = optimset('Algorithm','interior-point','Display', 'off',...
        'MaxIter', 10000,'MaxFunEval', 10000);

% fmincon params
fmincon_params.init_value = [0, .5, .5];
fmincon_params.lb = [0.001, 0.001, 0.001];
fmincon_params.ub = [100, 1, 1];

subnum = 1;
for currsub = subs
    filename = dir(['participant',num2str(currsub),'_dataExp1*.mat']);
    load (filename.name);

    getNamesAndProbs = [reshape(selectedImagesFromEXP,[6 1]), reshape(string(selectedProbabilitiesFromEXP),[6 1])];
    sortedNamesAndProb = sortrows(getNamesAndProbs,2);

    datatab = table(current_subblogEXP,leftimEXP,rightimEXP,left_OutArrayEXP,right_OutArrayEXP,clicksArray1EXP,outcomeArrayEXP);
    datatab.clicksArray1EXP = 2-datatab.clicksArray1EXP;
    sortedTab = table();
    for block = 1:3
        blockData = datatab(datatab.current_subblogEXP==block,:);
        higherProbInBlock = contains(blockData.leftimEXP,sortedNamesAndProb(4:end,1));
        blockData.choice(higherProbInBlock) = blockData.clicksArray1EXP(higherProbInBlock);
        blockData.choice(~higherProbInBlock) = 3-blockData.clicksArray1EXP(~higherProbInBlock);
        blockData.leftoutcome(higherProbInBlock) = blockData.left_OutArrayEXP(higherProbInBlock)==1;
        blockData.leftoutcome(~higherProbInBlock) = blockData.right_OutArrayEXP(~higherProbInBlock)==1;
        blockData.rightoutcome(higherProbInBlock) = blockData.right_OutArrayEXP(higherProbInBlock)==1;
        blockData.rightoutcome(~higherProbInBlock) = blockData.left_OutArrayEXP(~higherProbInBlock)==1;
        sortedTab = vertcat(sortedTab,blockData);
    end

    % set parameters
    fit_params.cho = sortedTab.choice;
    fit_params.cfcho = 3-sortedTab.choice;
    fit_params.out = sortedTab.leftoutcome;
    fit_params.cfout = sortedTab.rightoutcome;
    fit_params.con = sortedTab.current_subblogEXP;
    fit_params.fit_cf = 1;
    fit_params.ntrials = height(sortedTab);
    fit_params.model = 1;
    fit_params.decision_rule = 1;
    fit_params.q = 0.5;
    fit_params.noptions = 2;
    fit_params.ncond = length(unique(sortedTab.current_subblogEXP));

    [params, ll] = runfit_learning(fit_params, fmincon_params, options);
    parameters(:,subnum) = params(1:2);
    nll(subnum)=ll;

    for block = 1:3
        blockData = sortedTab(sortedTab.current_subblogEXP==block,:);
        pwin = [0.5,0.5];
        for t = 1:height(blockData)
            pwin(1)= pwin(1)+params(2)*(blockData.leftoutcome(t)-pwin(1));
            pwin(2)= pwin(2)+params(2)*(blockData.rightoutcome(t)-pwin(2));
        end
        symNames = unique(blockData.leftimEXP);
        name1idx = find(strcmp(sortedNamesAndProb,symNames{1}));
        name2idx = find(strcmp(sortedNamesAndProb,symNames{2}));
        if name2idx > name1idx
            if pwin(1) > pwin(2)
                probwin(name1idx, subnum) = pwin(2);
                probwin(name2idx, subnum) = pwin(1);
            else
                probwin(name1idx, subnum) = pwin(1);
                probwin(name2idx, subnum) = pwin(2);
            end
        else
            if pwin(1) > pwin(2)
                probwin(name2idx, subnum) = pwin(2);
                probwin(name1idx, subnum) = pwin(1);
            else
                probwin(name2idx, subnum) = pwin(1);
                probwin(name1idx, subnum) = pwin(2);
            end
        end
    end
    subnum = subnum+1;
end
save resultsLE_RL.mat probwin parameters nll

% quick plot
avgmidpoints = mean(probwin,2);
figure; hold on;
line([0,1],[0,1],'LineStyle','--');
plot(str2double(sortedNamesAndProb(:,2)),avgmidpoints);
axis square
hold off;

function [parameters,ll] = runfit_learning(fit_params, fmincon_params, options)
[parameters,l1] = fmincon(@(x) getlpp_learning(x,...
    fit_params.con,...
    fit_params.cho,...
    fit_params.cfcho,...
    fit_params.out,...
    fit_params.cfout,...
    fit_params.q,...
    fit_params.ntrials, fit_params.decision_rule,fit_params.fit_cf),...
    fmincon_params.init_value,...
    [], [], [], [],...
    fmincon_params.lb,...
    fmincon_params.ub,...
    [],options);
ll = l1;
end
