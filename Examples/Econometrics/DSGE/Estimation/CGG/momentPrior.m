function logSystemPrior = momentPrior(parser,solution)
% Syntax:
%
% logSystemPrior = momentPrior(parser,solution)
%
% Description:
%
% File adding system prior on second order moments.
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
    vars = {'y'};

    % Get current solution
    A     = solution.A;
    C     = solution.C;
    nEndo = size(A,1);
    
    % Calculate moments
    [~,c]      = nb_calculateMoments(A,zeros(nEndo,0),C,eye(nEndo),[],[],0,'covariance');
    endo       = parser.endogenous;
    [~,locV]   = ismember(vars,endo); 
    moments    = c(locV,locV);
     
    % Evaluate priors
    logSystemPrior = 0;
    logSystemPrior = logSystemPrior + log(nb_distribution.normal_pdf(moments(1),0.005,0.001)); % y
    if ~isfinite(logSystemPrior)
        logSystemPrior = -1e10;
    end
    
end
