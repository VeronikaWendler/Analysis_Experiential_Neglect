clearvars; close all;
subs = 1:18;

nll = zeros(4,length(subs));
paramEstimates = nan(6+1,4,length(subs)); % 1 temperature (b) and 6 midpoints (l) for each participant & pie type
options = optimset('Algorithm','interior-point','Display', 'off',...
    'MaxIter', 10000,'MaxFunEval', 10000);

subnum = 1;
for currsub = subs
    filename = dir(['participant',num2str(currsub),'_dataExp2*.mat']);
    load (filename.name);

    datatab = table(trialIconsEXP2,cell2mat(trialPiechartTypesEXP2),cell2mat(trialPiechartProbsEXP2),selected_imageEXP2,cell2mat(selected_probabilityEXP2));
    datatab.Properties.VariableNames([2, 3, 5]) = {'PieTypes','PieProb','ChosenProb'};
    piechoice = arrayfun(@(x) strfind(x, 'Pie'), datatab.selected_imageEXP2);
    datatab.iconChoice = arrayfun(@(x) isempty(cell2mat(x)), piechoice);
    iconNames = table2array(unique(datatab(:,1)));
    pietypes = table2array(unique(datatab(:,2)));
    pieprobs = table2array(unique(datatab(:,3)));

    datatab2 = table(left_imagesEXP2,cell2mat(left_probabilityEXP2));
    datatab2.Properties.VariableNames(2) = {'IconProb'};
    icontab = pivot_table(datatab2,'left_imagesEXP2','IconProb',@mean);
    icontab = icontab(1:6,:);
    iconProbSet = sort(icontab.mean_of_IconProb);

    for currpie = 1:length(pietypes)
        yvals = zeros(length(iconNames),length(pieprobs)*5); xvals = yvals; % 5 trials per pie probability
        for curricon = 1:length(iconNames)
            curriconProb = icontab.mean_of_IconProb(curricon);
            curriconProbidx = find(curriconProb==iconProbSet);
            yvals(curriconProbidx,:) = double(datatab.iconChoice(strcmp(datatab.trialIconsEXP2,iconNames{curricon})&datatab.PieTypes==currpie));
            xvals(curriconProbidx,:) = datatab.PieProb(strcmp(datatab.trialIconsEXP2,iconNames{curricon})&datatab.PieTypes==currpie);
        end
        [params, nll(currpie, subnum)] = fmincon(@(x) mle(x, xvals, yvals),...
            [1, ones(1, length(iconNames)) .* .5], [], [], [], [],[0.01, zeros(1, length(iconNames))],[inf, ones(1, length(iconNames))],[],options);
        paramEstimates(:, currpie, subnum) = params;
    end
    subnum = subnum+1;
end

save resultsChoiceBehavNLL.mat paramEstimates pieprobs nll

% quick plot
avgmidpoints = mean(paramEstimates(2:end,:,:),3);
figure; hold on;
line([0,1],[0,1],'LineStyle','--');
plot(iconProbSet,avgmidpoints);
hold off;

function nll = mle(x, X, Y)
% options = optimset('Display','off');
temp = x(1);
midpoints = x(2:end);
ll = 0;
for ii = 1:size(Y, 1)
    yhat = logfun(X(ii,:), midpoints(ii), temp);
    ll = ll + (1/numel(yhat)) * sum(log(yhat) .* Y(ii,:) + log(1-yhat).*(1-Y(ii,:)));
end
nll = -ll;
end

function p = logfun(x, midpoint, temp)
p = 1./(1+exp(temp.*(x-midpoint)));
end
