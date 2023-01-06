function [A,B,C,ss,p,err] = updateSolution(options,results,xu,p,tt)
% Syntax:
%
% [A,B,C,ss,p,err] = nb_dsge.updateSolution(options,results,xu,p,tt)
%
% Description:
%
% Resolve the model when dealing with stochastic trend. 
%
% See also:
% nb_kalmanSmootherUnivariateStochasticTrendDSGE,
% nb_kalmanLikelihoodUnivariateStochasticTrendDSGE,
% nb_kalmanSmootherDiffuseStochasticTrendDSGE,
% nb_kalmanLikelihoodDiffuseStochasticTrendDSGE
% 
% Written by Kenneth Sæterhagen Paulsen 

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    results.beta       = p;
    [A,B,C,~,ss,p,err] = nb_dsge.solveOneIteration(options,results,xu);
    if nargout < 6
        if ~isempty(err)
            error('nb_dsge:updateSolution:couldNotSolve',...
                  [mfilename ':: Failed at period ' int2str(tt) '. Error:: ' err])
        end
    end
            
end
