%% Text

opt           = optimset('fminsearch');
displayer     = nb_optimizerDisplayer('notifyStep',2,'type','text');
opt.OutputFcn = getOutputFunction(displayer);
f             = @(x)x^2;
[maxX,fVal,e] = fminsearch(f,100,opt);

%% Command window

opt           = optimset('fminsearch');
displayer     = nb_optimizerDisplayer('notifyStep',2);
opt.OutputFcn = getOutputFunction(displayer);
f             = @(x)x^2;
[maxX,fVal,e] = fminsearch(f,100,opt);

%% Graph

opt           = optimset('fminsearch');
displayer     = nb_optimizerDisplayer('notifyStep',2,'type','graph');
opt.OutputFcn = getOutputFunction(displayer);
f             = @(x)x^2;
[maxX,fVal,e] = fminsearch(f,100,opt);

%% Text and graph

opt           = optimset('fminsearch');
displayer     = nb_optimizerDisplayer('notifyStep',2,'type','textgraph');
opt.OutputFcn = getOutputFunction(displayer);
f             = @(x)x^2;
[maxX,fVal,e] = fminsearch(f,100,opt);

%% Text

opt           = optimset('fminsearch');
displayer     = nb_optimizerDisplayer('notifyStep',2,'type','text');
opt.OutputFcn = getOutputFunction(displayer);
f             = @(x)x(1)^2 + x(2)^2;
[maxX,fVal,e] = fminsearch(f,[100,20],opt);

%% Command window

opt           = optimset('fminsearch');
displayer     = nb_optimizerDisplayer('notifyStep',2);
opt.OutputFcn = getOutputFunction(displayer);
f             = @(x)x(1)^2 + x(2)^2;
[maxX,fVal,e] = fminsearch(f,[100,20],opt);

%% Graph

opt           = optimset('fminsearch');
displayer     = nb_optimizerDisplayer('notifyStep',2,'type','graph',...
                                      'storeMax',10);
opt.OutputFcn = getOutputFunction(displayer);
f             = @(x)x(1)^2 + x(2)^2;
[maxX,fVal,e] = fminsearch(f,[100,20],opt);

%% Text and graph

opt           = optimset('fminsearch');
displayer     = nb_optimizerDisplayer('notifyStep',2,'type','textgraph');
opt.OutputFcn = getOutputFunction(displayer);
f             = @(x)x(1)^2 + x(2)^2;
[maxX,fVal,e] = fminsearch(f,[100,20],opt);

%% Text (fmincon)

opt           = optimset('fmincon');
opt.Display   = 'off';
displayer     = nb_optimizerDisplayer(...
                    'notifyStep',1,...
                    'names',{'alpha','beta'},...
                    'type','Text');
opt.OutputFcn = getOutputFunction(displayer);
f             = @(x)x(1)^2 + x(2)^2;
[maxX,fVal,e] = fmincon(f,[100,20],[],[],[],[],[],[],[],opt);

%% Text (fsolve)

opt           = optimset('fsolve');
opt.Display   = 'off';
displayer     = nb_optimizerDisplayer(...
                    'notifyStep',1,...
                    'names',{'alpha','beta'},...
                    'type','Text');
opt.OutputFcn = getOutputFunction(displayer);
f             = @(x)x(1)^2 + x(2)^2;
[x,fVal,e]    = fsolve(f,[100,20],opt);
