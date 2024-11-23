function [fval,sol] = likelihood(par,estStruct)
% Syntax:
%
% [fval,sol] = nb_dsge.likelihood(par,estStruct)
%
% Description:
%
% Evaluate minus the log likelihood.
% 
% Input:
% 
% - See the method nb_model_generic.objective for descrption of inputs.
% 
% Output:
% 
% - fval : Value of minus the log likelihood at the given parameters.
%
% - sol  : A struct with the solution of the model. See output from 
%          nb_dsge.stateSpace, 
%
% See also:
% nb_dsge.objective, nb_dsge.stateSpace, nb_dsge.stateSpaceBreakPoint,
% nb_dsge.stateSpaceTVP, nb_kalmanLikelihoodMissingDSGE, 
% nb_kalmanLikelihoodBreakPointDSGE, nb_kalmanLikelihoodTVPDSGE
% nb_kalmanLikelihoodUnivariateStochasticTrendDSGE
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Calculate minus the log likelihood
    if estStruct.filterType == 1
        sol = nb_dsge.stateSpace(par,estStruct);
        if strcmpi(estStruct.options.kf_method,'normal')
            fval = nb_kalmanLikelihoodMissingDSGE(par,@(x)unwrapSolution(x,sol),estStruct.y); 
        elseif strcmpi(estStruct.options.kf_method,'diffuse')
            fval = nb_kalmanLikelihoodDiffuseDSGE(par,@(x)unwrapDiffuseSolution(x,sol),estStruct.y);
        else % Univariate filter
            fval = nb_kalmanLikelihoodUnivariateDSGE(par,@(x)unwrapDiffuseSolution(x,sol),estStruct.y);
        end
    elseif estStruct.filterType == 2 % Break-points
        sol = nb_dsge.stateSpaceBreakPoint(par,estStruct);
        if strcmpi(estStruct.options.kf_method,'normal')
            fval = nb_kalmanLikelihoodBreakPointDSGE(par,@(x)unwrapSolution(x,sol),estStruct.y);
        elseif strcmpi(estStruct.options.kf_method,'diffuse')
            fval = nb_kalmanLikelihoodDiffuseBreakPointDSGE(par,@(x)unwrapDiffuseSolution(x,sol),estStruct.y);
        else % Univariate filter
            fval = nb_kalmanLikelihoodUnivariateBreakPointDSGE(par,@(x)unwrapDiffuseSolution(x,sol),estStruct.y);
        end
    elseif estStruct.filterType == 4 % Stochastic trend
        sol = []; % Should return the iterative solution!
        if strcmpi(estStruct.options.kf_method,'diffuse')
            fval = nb_kalmanLikelihoodDiffuseStochasticTrendDSGE(par,estStruct);
        else % Univariate filter
            fval = nb_kalmanLikelihoodUnivariateStochasticTrendDSGE(par,estStruct);
        end
    else % Observed time-varying parameters
        sol = nb_dsge.stateSpaceTVP(par,estStruct);
        if strcmpi(estStruct.options.kf_method,'normal')
            fval = nb_kalmanLikelihoodTVPDSGE(par,@(x)unwrapSolution(x,sol),estStruct.y);
        elseif strcmpi(estStruct.options.kf_method,'diffuse')
            fval = nb_kalmanLikelihoodDiffuseTVPDSGE(par,@(x)unwrapDiffuseSolution(x,sol),estStruct.y);
        else % Univariate filter
            fval = nb_kalmanLikelihoodUnivariateTVPDSGE(par,@(x)unwrapDiffuseSolution(x,sol),estStruct.y);
        end
    end
    
end

%==========================================================================
function [H,A,C,x,P,options,err] = unwrapSolution(~,sol)
% First input is just a dummy input (just to make it possible to call it
% with the par input in nb_kalmanLikelihoodMissingDSGE etc.)

    err = sol.err;
    if ~isempty(err)
        H       = [];
        A       = [];
        C       = [];
        x       = [];
        P       = [];
        options = [];
        return
    end

    H       = sol.H;
    A       = sol.A;
    C       = sol.C;
    x       = sol.x;
    P       = sol.P;
    options = sol.options;

end

%==========================================================================
function [H,A,C,x,P,Pinf,options,err] = unwrapDiffuseSolution(~,sol)
% First input is just a dummy input (just to make it possible to call it
% with the par input in nb_kalmanLikelihoodMissingDSGE etc.)

    err = sol.err;
    if ~isempty(err)
        H       = [];
        A       = [];
        C       = [];
        x       = [];
        P       = [];
        Pinf    = [];
        options = [];
        return
    end

    H       = sol.H;
    A       = sol.A;
    C       = sol.C;
    x       = sol.x;
    P       = sol.P;
    Pinf    = sol.Pinf;
    options = sol.options;

end
