
X = nb_monteCarloSim(100,[0,0],[2.5,1],'latin');
f = figure;
a = axes('parent',f);
scatter(X(:,1),X(:,2),'parent',a);
set(a,'xlim',[0,2.5],'yLim',[0,1])

XS = nb_monteCarloSim(100,[0,0],[2.5,1],'sobol');
f  = figure;
a  = axes('parent',f);
scatter(XS(:,1),XS(:,2),'parent',a);

XH = nb_monteCarloSim(100,[0,0],[2.5,1],'halton');
f  = figure;
a  = axes('parent',f);
scatter(XH(:,1),XH(:,2),'parent',a);
