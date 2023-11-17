clearvars; close all;
load resultsChoiceBehavNLL.mat % paramEstimates: 1 temperature (b) and 6 midpoints (l) for each participant & pie type
load resultsLE_RL.mat % probwin
load resultsStatedProb.mat % estimProb (% 5 symbols (1 icon + 4 pie), 7 pie prob (6 for icon), pp) estimProbConf

sOptionMidPoints = paramEstimates(2:end,:,:);
eOptionMidPoints = probwin;

yvals = [sOptionMidPoints(:);eOptionMidPoints(:)];
xvals = [repmat(setdiff(1/8:1/8:7/8,1/2),[1 4*size(paramEstimates,3)])';repmat(setdiff(1/8:1/8:7/8,1/2),[1 size(paramEstimates,3)])']; % repmat({'1/8','2/8','3/8','5/8','6/8','7/8'}
conds = [repmat(repelem({'pie1','pie2','pie3','pie4'},6),[1 size(paramEstimates,3)])'; repelem({'icon'},6*size(paramEstimates,3))'];

figure;
f = gramm('x',xvals,'y',yvals,'color',conds);
f.stat_glm();
f.stat_summary('geom',{'point','errorbar'});
f.geom_abline('intercept',0,'slope',1,'style','k--');
f.set_point_options('base_size',12,'markers',{'s'});
f.axe_property('TickDir','out','XLim',[0 1],'YLim',[0 1]);
f.set_names('x','E-option Prob','y','Estimated Prob','Color','Symbol');
f.draw();

yvalsProbEst = estimProb(:)/100;
yvalsConf = estimProbConf(:);
xvals = repmat(repelem(1/8:1/8:7/8,5),[1 size(estimProb,3)])';
conds = repmat({'icon','pie1','pie2','pie3','pie4'},[1 7*size(estimProb,3)])'; 

figure;
g(1,1) = gramm('x',xvals,'y',yvalsProbEst,'color',conds);
g(1,1).stat_glm();
g(1,1).stat_summary('geom',{'point','errorbar'});
g(1,1).set_point_options('base_size',12,'markers',{'s'});
g(1,1).geom_abline('intercept',0,'slope',1,'style','k--');
g(1,1).axe_property('TickDir','out','XLim',[0 1],'YLim',[0 1]);
g(1,1).set_names('x','E-option Prob','y','Estimated Prob','Color','Symbol');

g(1,2) = gramm('x',xvals,'y',yvalsConf,'color',conds);
g(1,2).stat_summary('geom',{'line','point','errorbar'});
g(1,2).set_point_options('base_size',12,'markers',{'s'});
g(1,2).axe_property('TickDir','out','XLim',[0 1],'YLim',[1 5]);
g(1,2).set_names('x','Prob','y','Confidene','Color','Symbol');
g.draw();

% compute and plot slopes
probs1 = setdiff(1/8:1/8:7/8,1/2);
probs2 = 1/8:1/8:7/8;
allslopesEst = zeros(5, size(probwin,2));
allslopesStated = allslopesEst;
for sub = 1:size(probwin,2)
    for currpie = 1:4
        sOptionYvals = sOptionMidPoints(:,currpie,sub);
        p = polyfit(probs1,sOptionYvals,1);
        allslopesEst(currpie,sub) = p(1);
        statedYvals = estimProb(currpie+1,:,sub)/100;
        l = polyfit(probs2,statedYvals,1);
        allslopesStated(currpie,sub) = l(1);
    end
    q = polyfit(probs1, probwin(:,sub),1);
    allslopesEst(5,sub) = q(1);
    statedYvals = estimProb(1,:,sub)/100;
    m = polyfit(probs1,statedYvals([1:3 5:end]),1);
    allslopesStated(5,sub) = m(1);
end

allslopes = [allslopesEst(:);allslopesStated(:)];
xvals = repmat({'pie1','pie2','pie3','pie4','icon'},[1 2*size(probwin,2)]); %, repmat({'pie1St','pie2St','pie3St','pie4St','iconSt'},[1 size(probwin,2)])]';
types = repelem({'Estimated', 'Stated'},5*size(probwin,2));
figure;
h = gramm('x',xvals,'y',allslopes,'color',types);
h.stat_summary('geom',{'line','point','errorbar'});
h.geom_hline('yintercept',1,'style','k--');
h.set_point_options('base_size',12);
h.axe_property('TickDir','out','YLim',[0 1.2]);
h.draw();