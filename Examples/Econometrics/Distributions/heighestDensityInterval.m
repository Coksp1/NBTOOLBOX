%% HDI

dist    = nb_distribution('type','gamma','parameters',{5,2});
r       = random(dist,1000,1);
distEst = nb_distribution.estimate(r);
data    = asData(distEst);
data    = addVariable(data,1,zeros(1000,1),'zero');

dataF       = double(data(distEst.name));
dataX       = double(data('domain'));
intervals   = [0.30,0.5,0.7,0.9];
[rData,lim] = nb_hdi(r,intervals);
patch       = {};
cData       = [  50  125 178
                 78  150 193
                 123 185 212
                 176 220 241]/255;
for ii = size(rData,1)/2:-1:1
    ind1         = dataX < rData(ii*2-1,:);
    ind2         = dataX > rData(ii*2,:);
    ind          = ind1 | ind2;
    newData      = dataF;
    newData(ind) = nan;
    name         = ['dhi_' int2str(intervals(ii)*100)];
    data         = addVariable(data,1,newData,name);
    patch        = [patch,{name,'zero',name,cData(ii,:)}]; %#ok<AGROW>
end

% tb1 = nb_textBox('xData',3.5,'yData',0.01,'string',['CDF(mean) = '  num2str(cdf(dist,mean(dist)))]);
% tb2 = nb_textBox('xData',11,'yData',0.01,'string',['1-CDF(mean) = '  num2str(1 - cdf(dist,mean(dist)))]);
% 
% tb3 = nb_textBox('xData',13,'yData',0.09,'string',['Skewness (normal) = '  num2str(skewness(dist))]);
% tb4 = nb_textBox('xData',13,'yData',0.08,'string',['Skewness (CDF) = '  num2str(skewness(dist,'paulsen'))]);

m1 = mode(distEst);
m2 = median(distEst);
m3 = mean(distEst);

plotter = nb_graph_data(data);
plotter.set('verticalLine',{m1,m2,m3},...
            'verticalLineColor',{[0,0,0],[0.50196,0,0.25098],[0.76471,0.72549,0.58824]},...
            'verticalLineLimit',{[pdf(distEst,m1)-0.0025,pdf(distEst,m1)+0.0025],...
                                 [pdf(distEst,m2)-0.0025,pdf(distEst,m2)+0.0025],...
                                 [pdf(distEst,m3)-0.0025,pdf(distEst,m3)+0.0025]},...
            'verticalLineStyle',{'-','-','-'},...
            'verticalLineWidth',2.5,...
            'fakeLegend',{'Mode',{'type','line','color',[0,0,0]},'Median',{'color',[0.50196,0,0]},'Mean',{'color',[0.76471,0.72549,0.58824]}},...
            'legends',{'','','','','','Mode','Median','Mean'},...
            'patch',patch,...
            'variablesToPLot',{distEst.name},...
            'variableToPlotX','domain',...
            ...'annotation',{tb1,tb2,tb3,tb4},...
            'title','Highest density intervals (Probability intervals)',...
            'xLim',[0,25]);
nb_graphPagesGUI(plotter);

% nb_saveas(gcf,'hdi_skewed','pdf','-noflip')

%% Percentiles

data        = asData(distEst);
data        = addVariable(data,1,zeros(1000,1),'zero');
dataF       = double(data(distEst.name));
dataX       = double(data('domain'));
intervals   = [0.05,0.15,0.25,0.35,0.65,0.75,0.85,0.95]*100;
rData       = prctile(r,intervals)';
patch       = {};
cData       = [  50  125 178
                 78  150 193
                 123 185 212
                 176 220 241]/255;
for ii = 1:size(rData,1)/2
    ind1         = dataX < rData(ii,:);
    ind2         = dataX > rData(end-ii+1,:);
    ind          = ind1 | ind2;
    newData      = dataF;
    newData(ind) = nan;
    name         = ['dhi_' int2str(intervals(ii))];
    data         = addVariable(data,1,newData,name);
    patch        = [patch,{name,'zero',name,cData(end-ii+1,:)}]; %#ok<AGROW>
end

% tb1 = nb_textBox('xData',3.5,'yData',0.01,'string',['CDF(mean) = '  num2str(cdf(dist,mean(dist)))]);
% tb2 = nb_textBox('xData',11,'yData',0.01,'string',['1-CDF(mean) = '  num2str(1 - cdf(dist,mean(dist)))]);
% 
% tb3 = nb_textBox('xData',13,'yData',0.09,'string',['Skewness (normal) = '  num2str(skewness(dist))]);
% tb4 = nb_textBox('xData',13,'yData',0.08,'string',['Skewness (CDF) = '  num2str(skewness(dist,'paulsen'))]);

m1 = mode(distEst);
m2 = median(distEst);
m3 = mean(distEst);

plotter = nb_graph_data(data);
plotter.set('verticalLine',{mode(distEst),median(distEst),mean(distEst)},...
            'verticalLineColor',{[0,0,0],[0.50196,0,0.25098],[0.76471,0.72549,0.58824]},...
            'verticalLineLimit',{[pdf(distEst,m1)-0.0025,pdf(distEst,m1)+0.0025],...
                                 [pdf(distEst,m2)-0.0025,pdf(distEst,m2)+0.0025],...
                                 [pdf(distEst,m3)-0.0025,pdf(distEst,m3)+0.0025]},...
            'verticalLineStyle',{'-','-','-'},...
            'verticalLineWidth',2.5,...
            'fakeLegend',{'Mode',{'type','line','color',[0,0,0]},'Median',{'color',[0.50196,0,0]},'Mean',{'color',[0.76471,0.72549,0.58824]}},...
            'legends',{'','','','','','Mode','Median','Mean'},...
            'patch',patch,...
            'variablesToPLot',{distEst.name},...
            'variableToPlotX','domain',...
            ...'annotation',{tb1,tb2,tb3,tb4},...
            'title','Percentiles',...
            'xLim',[0,25]);
nb_graphPagesGUI(plotter);

% nb_saveas(gcf,'perc_skewed','pdf','-noflip')

%% HDI (Bimodal)

dist    = nb_distribution('type','beta','parameters',{0.5,0.5});
r       = random(dist,1000,1);
distEst = nb_distribution.estimate(r);
data    = asData(distEst);
data    = addVariable(data,1,zeros(1000,1),'zero');

dataF       = double(data(distEst.name));
dataX       = double(data('domain'));
intervals   = [0.3,0.5,0.7,0.9];
[rData,lim] = nb_hdi(r,intervals);
patch       = {};
cData       = [  50  125 178
                 50  125 178
                 78  150 193
                 78  150 193
                 123 185 212
                 123 185 212
                 176 220 241]/255;
for ii = length(lim)/2:-1:1
    ind1         = dataX < rData(ii*2-1,:);
    ind2         = dataX > rData(ii*2,:);
    ind          = ind1 | ind2;
    newData      = dataF;
    newData(ind) = nan;
    name         = lim{ii*2};
    data         = addVariable(data,1,newData,name);
    patch        = [patch,{name,'zero',name,cData(ii,:)}]; %#ok<AGROW>
end

% tb1 = nb_textBox('xData',3.5,'yData',0.01,'string',['CDF(mean) = '  num2str(cdf(dist,mean(dist)))]);
% tb2 = nb_textBox('xData',11,'yData',0.01,'string',['1-CDF(mean) = '  num2str(1 - cdf(dist,mean(dist)))]);
% 
% tb3 = nb_textBox('xData',13,'yData',0.09,'string',['Skewness (normal) = '  num2str(skewness(dist))]);
% tb4 = nb_textBox('xData',13,'yData',0.08,'string',['Skewness (CDF) = '  num2str(skewness(dist,'paulsen'))]);

m1 = mode(distEst);
m2 = median(distEst);
m3 = mean(distEst);

plotter = nb_graph_data(data);
plotter.set('verticalLine',{mode(distEst),median(distEst),mean(distEst)},...
            'verticalLineColor',{[0,0,0],[0.50196,0,0.25098],[0.76471,0.72549,0.58824]},...
            'verticalLineLimit',{[pdf(distEst,m1)-0.025,pdf(distEst,m1)+0.025],...
                                 [pdf(distEst,m2)-0.025,pdf(distEst,m2)+0.025],...
                                 [pdf(distEst,m3)-0.025,pdf(distEst,m3)+0.025]},...
            'verticalLineStyle',{'-','-','-'},...
            'verticalLineWidth',2.5,...
            'fakeLegend',{'Mode',{'type','line','color',[0,0,0]},'Median',{'color',[0.50196,0,0]},'Mean',{'color',[0.76471,0.72549,0.58824]}},...
            'legends',{'','','','','','','','','Mode','Median','Mean'},...
            'patch',patch,...
            'variablesToPLot',{distEst.name},...
            'variableToPlotX','domain',...
            ...'annotation',{tb1,tb2,tb3,tb4},...
            'title','Highest density intervals (Probability intervals)',...
            'xLim',[-0.35,1.35]);
nb_graphPagesGUI(plotter);

% nb_saveas(gcf,'hdi_bimodal','pdf','-noflip')

%% Percentiles (Bimodal)

data        = asData(distEst);
data        = addVariable(data,1,zeros(1000,1),'zero');
dataF       = double(data(distEst.name));
dataX       = double(data('domain'));
intervals   = [0.05,0.15,0.25,0.35,0.65,0.75,0.85,0.95]*100;
rData       = prctile(r,intervals)';
patch       = {};
cData       = [  50  125 178
                 78  150 193
                 123 185 212
                 176 220 241]/255;
for ii = 1:size(rData,1)/2
    ind1         = dataX < rData(ii,:);
    ind2         = dataX > rData(end-ii+1,:);
    ind          = ind1 | ind2;
    newData      = dataF;
    newData(ind) = nan;
    name         = ['dhi_' int2str(intervals(ii))];
    data         = addVariable(data,1,newData,name);
    patch        = [patch,{name,'zero',name,cData(end-ii+1,:)}]; %#ok<AGROW>
end

% tb1 = nb_textBox('xData',3.5,'yData',0.01,'string',['CDF(mean) = '  num2str(cdf(dist,mean(dist)))]);
% tb2 = nb_textBox('xData',11,'yData',0.01,'string',['1-CDF(mean) = '  num2str(1 - cdf(dist,mean(dist)))]);
% 
% tb3 = nb_textBox('xData',13,'yData',0.09,'string',['Skewness (normal) = '  num2str(skewness(dist))]);
% tb4 = nb_textBox('xData',13,'yData',0.08,'string',['Skewness (CDF) = '  num2str(skewness(dist,'paulsen'))]);

m1 = mode(distEst);
m2 = median(distEst);
m3 = mean(distEst);

plotter = nb_graph_data(data);
plotter.set('verticalLine',{mode(distEst),median(distEst),mean(distEst)},...
            'verticalLineColor',{[0,0,0],[0.50196,0,0.25098],[0.76471,0.72549,0.58824]},...
            'verticalLineLimit',{[pdf(distEst,m1)-0.025,pdf(distEst,m1)+0.025],...
                                 [pdf(distEst,m2)-0.025,pdf(distEst,m2)+0.025],...
                                 [pdf(distEst,m3)-0.025,pdf(distEst,m3)+0.025]},...
            'verticalLineStyle',{'-','-','-'},...
            'verticalLineWidth',2.5,...
            'fakeLegend',{'Mode',{'type','line','color',[0,0,0]},'Median',{'color',[0.50196,0,0]},'Mean',{'color',[0.76471,0.72549,0.58824]}},...
            'legends',{'','','','','','Mode','Median','Mean'},...
            'patch',patch,...
            'variablesToPLot',{distEst.name},...
            'variableToPlotX','domain',...
            ...'annotation',{tb1,tb2,tb3,tb4},...
            'title','Percentiles',...
            'xLim',[-0.35,1.35]);
nb_graphPagesGUI(plotter);

% nb_saveas(gcf,'perc_bimodal','pdf','-noflip')

%% Plot fan chart

nb_clearall

r = randn(10,100000);
nb_fanChart([1:10]',r);
nb_fanChart([1:10]',r,'method','hdi');

r = nb_distribution.beta_rand(10,100000,0.5,0.5);
nb_fanChart([1:10]',r);
nb_fanChart([1:10]',r,'method','hdi');

%% Plot fan chart (ts)

dist  = nb_distribution('type','beta','parameters',{0.5,0.5});
data  = nb_ts.rand('2000Q1',10,{'Var1'},10000,dist);
dataM = window(mean(data),'','','',1);

plotter = nb_graph_ts(dataM);
plotter.set('fanDatasets',data,'fanMethod','hdi');

nb_graphPagesGUI(plotter);

