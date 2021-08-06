%% Easy problem

f = @(x)[
    x(1) - x(2) 
    exp(x(1)) - 2*(x(2) + x(3)) - 1
    x(3)^2 - x(2)
    min(x(4),x(4) + x(3)) - exp(x(3))
];

%% Call solver
% Global method, takes long time

opt              = nb_getDefaultOptimset('nb_abcSolve');
opt.maxSolutions = 1;
opt.newtonShare  = .1; % Share of bees using a newton update at each iteration

x = nb_abcSolve.call(f,ones(4,1),ones(4,1)*-4,ones(4,1)*4,opt)

%% Call solver
% Local method (i.e. without using bounds)

opt              = nb_getDefaultOptimset('nb_abcSolve');
opt.maxSolutions = 1;
opt.newtonShare  = 0.1;
opt.local        = true;

x = nb_abcSolve.call(f,ones(4,1),[],[],opt)

%% Using object instead
% Local method (i.e. without using bounds)

opt              = nb_getDefaultOptimset('nb_abcSolve');
opt.maxSolutions = 1;
opt.newtonShare  = 0.1;
opt.local        = true;

solver = nb_abcSolve(f,ones(4,1),[],[],opt);
solve(solver)

%% Another problem
% Which is actually quit difficult...

f = @(x)[min(x(1) + x(2),0.01);x(1).^2-x(2)];

%% Call solver
% Global method, find 2 solution!

opt              = nb_getDefaultOptimset('nb_abcSolve');
opt.maxSolutions = 2;
opt.newtonShare  = .1; % Share of bees using a newton update at each iteration

x = nb_abcSolve.call(f,ones(2,1),ones(2,1)*-3,ones(2,1)*3,opt)

%% Call solver
% Local method (i.e. without using bounds)
% Will get stuck in a vally, try another starting value!

opt              = nb_getDefaultOptimset('nb_abcSolve');
opt.maxSolutions = 1;
opt.newtonShare  = 0.1;
opt.local        = true;

x = nb_abcSolve.call(f,ones(2,1),[],[],opt)

%% Using object instead
% Local method (i.e. without using bounds)
% Will get stuck in a vally, try another starting value!

opt              = nb_getDefaultOptimset('nb_abcSolve');
opt.maxSolutions = 1;
opt.newtonShare  = 0.1;
opt.maxTime      = 30;
opt.local        = true;

solver = nb_abcSolve(f,ones(2,1),[],[],opt);
solve(solver)
