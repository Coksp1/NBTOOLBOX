%% Test from high frequency to low

% Generate monthly data
data = nb_ts.simulate('1990M1',100,{'Var1','Var2'},1,[0.6,0.1;0.1,0.7],ones(2,1),[],40);

m  = nb_var(...
    'constant',         0,...
    'data',             data,...
    'dependent',        data.variables,...
    'recursive_estim',  0);

m = estimate(m);
m = solve(m);
m = forecast(m,36);
p = plotForecast(m);
nb_graphSubPlotGUI(p);

% From month to quarter
mq = nb_model_convert(m,'freq',4,'method','average','name','test');
pq = plotForecast(mq);
nb_graphSubPlotGUI(pq);

% From month to year
my = nb_model_convert(m,'freq',1,'method','average','name','test');
py = plotForecast(my);
nb_graphSubPlotGUI(py);

%% Test from high frequency to low (recursive)

% Generate monthly data
data = nb_ts.simulate('1990M1',100,{'Var1','Var2'},1,[0.6,0.1;0.1,0.7],ones(2,1),[],40);

m  = nb_var(...
    'constant',                     0,...
    'data',                         data,...
    'dependent',                    data.variables,...
    'recursive_estim',              1,...
    'recursive_estim_start_date',   '1994M1');

m = estimate(m);
m = solve(m);
m = forecast(m,36,'fcstEval','se');
p = plotForecast(m,'hairyplot');
nb_graphSubPlotGUI(p);

% From month to quarter
mq = nb_model_convert(m,'freq',4,'method','average','name','test');
pq = plotForecast(mq,'hairyplot');
nb_graphSubPlotGUI(pq);

% From month to year
my = nb_model_convert(m,'freq',1,'method','average','name','test');
py = plotForecast(my,'hairyplot');
nb_graphSubPlotGUI(py);

%% Test from high frequency to low
% Missing data

% Generate monthly data with one missing observation for 'Var1'
data        = nb_ts.simulate('1990M1',100,{'Var1','Var2'},1,[0.6,0.1;0.1,0.7],ones(2,1),[],40);
data(end,1) = nan;

m  = nb_var(...
    'constant',         0,...
    'data',             data,...
    'dependent',        data.variables,...
    'recursive_estim',  0,...
    'missingMethod',    'forecast');

m = estimate(m);
m = solve(m);
m = forecast(m,36);
p = plotForecast(m);
nb_graphSubPlotGUI(p);

% From month to quarter
mq = nb_model_convert(m,'freq',4,'method','average','name','test');
pq = plotForecast(mq);
nb_graphSubPlotGUI(pq);

% From month to year
my = nb_model_convert(m,'freq',1,'method','average','name','test');
py = plotForecast(my);
nb_graphSubPlotGUI(py);

%% Test from high frequency to low (recursive)
% Missing data

% Generate monthly data with one missing observation for 'Var1'
data        = nb_ts.simulate('1990M1',100,{'Var1','Var2'},1,[0.6,0.1;0.1,0.7],ones(2,1),[],40);
data(end,1) = nan;

m  = nb_var(...
    'constant',                     0,...
    'data',                         data,...
    'dependent',                    data.variables,...
    'recursive_estim',              1,...
    'recursive_estim_start_date',   '1994M1',...
    'missingMethod',                'forecast');

m = estimate(m);
m = solve(m);
m = forecast(m,36,'fcstEval','se');
p = plotForecast(m,'hairyplot');
nb_graphSubPlotGUI(p);

% From month to quarter
mq = nb_model_convert(m,'freq',4,'method','average','name','test');
pq = plotForecast(mq,'hairyplot');
nb_graphSubPlotGUI(pq);

% From month to year
my = nb_model_convert(m,'freq',1,'method','average','name','test');
py = plotForecast(my,'hairyplot');
nb_graphSubPlotGUI(py);

%% Test from low frequency to high

% Generate yearly data
data = nb_ts.simulate('1990',50,{'Var1','Var2'},1,[0.6,0.1;0.1,0.7],ones(2,1),[],40);

m  = nb_var(...
    'constant',         0,...
    'data',             data,...
    'dependent',        data.variables,...
    'recursive_estim',  0);

m = estimate(m);
m = solve(m);
m = forecast(m,3);
p = plotForecast(m);
nb_graphSubPlotGUI(p);

% From year to quarter
mq = nb_model_convert(m,'freq',4,'method','linear','name','test');
pq = plotForecast(mq);
nb_graphSubPlotGUI(pq);

% From year to month
mm = nb_model_convert(m,'freq',12,'method','linear','name','test');
pm = plotForecast(mm);
nb_graphSubPlotGUI(pm);

%% Test from low frequency to high (recursive)

% Generate yearly data
data = nb_ts.simulate('1990',50,{'Var1','Var2'},1,[0.6,0.1;0.1,0.7],ones(2,1),[],40);

m  = nb_var(...
    'constant',                     0,...
    'data',                         data,...
    'dependent',                    data.variables,...
    'recursive_estim',              1,...
    'recursive_estim_start_date',   '2021');

m = estimate(m);
m = solve(m);
m = forecast(m,3,'fcstEval','se');
p = plotForecast(m,'hairyplot');
nb_graphSubPlotGUI(p);

% From year to quarter
mq = nb_model_convert(m,'freq',4,'method','linear','name','test');
pq = plotForecast(mq,'hairyplot');
nb_graphSubPlotGUI(pq);

% From year to month
mm = nb_model_convert(m,'freq',12,'method','linear','name','test');
pm = plotForecast(mm,'hairyplot');
nb_graphSubPlotGUI(pm);

%% Test from low frequency to high
% Missing data

% Generate yearly data with one missing observation at the end for 'Var1'
data        = nb_ts.simulate('1990',50,{'Var1','Var2'},1,[0.6,0.1;0.1,0.7],ones(2,1),[],40);
data(end,1) = nan;

m  = nb_var(...
    'constant',         0,...
    'data',             data,...
    'dependent',        data.variables,...
    'recursive_estim',  0,...
    'missingMethod',    'forecast');

m = estimate(m);
m = solve(m);
m = forecast(m,3);
p = plotForecast(m);
nb_graphSubPlotGUI(p);

% From year to quarter
mq = nb_model_convert(m,'freq',4,'method','linear','name','test');
pq = plotForecast(mq);
nb_graphSubPlotGUI(pq);

% From year to month
mm = nb_model_convert(m,'freq',12,'method','linear','name','test');
pm = plotForecast(mm);
nb_graphSubPlotGUI(pm);

%% Test from low frequency to high (recursive)
% Missing data

% Generate yearly data with one missing observation at the end for 'Var1'
data        = nb_ts.simulate('1990',50,{'Var1','Var2'},1,[0.6,0.1;0.1,0.7],ones(2,1),[],40);
data(end,1) = nan;

m  = nb_var(...
    'constant',                     0,...
    'data',                         data,...
    'dependent',                    data.variables,...
    'recursive_estim',              1,...
    'recursive_estim_start_date',   '2021',...
    'missingMethod',                'forecast');

m = estimate(m);
m = solve(m);
m = forecast(m,3,'fcstEval','se');
p = plotForecast(m,'hairyplot');
nb_graphSubPlotGUI(p);

% From year to quarter
mq = nb_model_convert(m,'freq',4,'method','linear','name','test');
pq = plotForecast(mq,'hairyplot');
nb_graphSubPlotGUI(pq);

% From year to month
mm = nb_model_convert(m,'freq',12,'method','linear','name','test');
pm = plotForecast(mm,'hairyplot');
nb_graphSubPlotGUI(pm);
