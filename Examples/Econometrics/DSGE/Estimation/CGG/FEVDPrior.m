function logSystemPrior = FEVDPrior(parser,solution)
% Syntax:
%
% logSystemPrior = FEVDPrior(parser,solution)
%
% Description:
%
% File adding system prior on FEVD.
%
% Input:
%
% - parser   : The parser property of the nb_dsge class.
%
% - solution : The solution property of the nb_dsge class.
%
% See also:
% nb_dsge.help, nb_dsge.set
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Options
    prior.horizon    = [1,1];
    prior.res        = {'e','eta'};
    prior.endo       = {'y','pie'};
    prior.numPriors  = size(prior.horizon,2);
    prior.priorFuncs = {
        @(x)log(nb_distribution.normal_pdf(x,0.7,0.05))
        @(x)log(nb_distribution.normal_pdf(x,0.7,0.05))
    };

    % Construct some options needed to call nb_varDecomp
    options.estimType  = ''; 
    inputs.perc        = [];
    inputs.method      = '';
    inputs.foundReplic = [];
    inputs.replic      = 1;
    inputs.horizon     = unique(prior.horizon)';
    inputs.shocks      = unique(prior.res);
    inputs.variables   = unique(prior.endo);
    results            = struct(); 
    solution.endo      = parser.endogenous;
    solution.res       = parser.exogenous;
    solution.class     = 'nb_dsge';
    
    % Do the variance decomposition
    decomp = nb_varDecomp(solution,options,results,inputs);

    % Fetch the observations to be evaluated
    x = zeros(prior.numPriors,1); % Values to evaluate the priors at
    for ii = 1:prior.numPriors
        locRes  = strcmpi(prior.res{ii},inputs.shocks);
        locEndo = strcmpi(prior.endo{ii},inputs.variables);
        x(ii)   = decomp(prior.horizon(ii),locRes,locEndo);
    end
    
    % Evaluate the log prior distribution at the current IRFs
    logSystemPrior = 0;
    logPriorDens   = prior.priorFuncs;
    for ii = 1:prior.numPriors
        logSystemPrior = logSystemPrior + logPriorDens{ii}(x(ii));
    end
    if ~isfinite(logSystemPrior)
        logSystemPrior = -1e10;
    end
    
end
