function [Alead,A0,Alag,B] = simulateStructuralMatricesStatic(parser,options,solution,results)
% Syntax:
%
% [Alead,A0,Alag,B] = nb_dsge.simulateStructuralMatricesStatic(parser,
%                           options,solution,results)
%
% Description:
%
% Private static of the nb_dsge class. 
% 
% See also:
% nb_dsge.simulateStructuralMatrices
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Draw parameters
    draws    = options.uncertain_draws;
    simParam = random(parser.parameterDistribution,draws)';
    indU     = parser.parametersIsUncertain;

    % Take derivative w.r.t to the variables for different draws
    paramSim = results.beta(:,ones(1,draws));
    nEndo    = length(parser.endogenous);
    nExo     = length(parser.exogenous);
    nEqs     = size(parser.equations,1);
    Alead    = nan(nEqs,nEndo,draws);
    A0       = nan(nEqs,nEndo,draws);
    Alag     = nan(nEqs,nEndo,draws);
    B        = nan(nEqs,nExo,draws);
    for ii = 1:draws
        paramSim(indU,ii) = simParam(:,ii);
        solution          = nb_dsge.derivativeNB(parser,solution,paramSim(:,ii));
        [Alead(:,:,ii),A0(:,:,ii),Alag(:,:,ii),B(:,:,ii)] = nb_dsge.jacobian2StructuralMatricesNB(solution.jacobian,parser);
    end
    
end
