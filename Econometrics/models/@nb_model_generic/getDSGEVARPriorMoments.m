function [GammaYY,GammaXX,GammaXY] = getDSGEVARPriorMoments(obj,dsgeVAR,varargin)
% Syntax:
%
% [GammaYY,GammaXX,GammaXY] = getDSGEVARPriorMoments(obj,dsgeVAR)
% [GammaYY,GammaXX,GammaXY] = getDSGEVARPriorMoments(obj,dsgeVAR,varargin)
%
% Description:
%
% Get DSGE-VAR prior matrices. See the prior struct returned by
% nb_var.priorTemplate('dsge').
% 
% Input:
% 
% - obj     : An object of class nb_model_generic.
%
% - dsgeVar : A nb_var object set up with options for estimation of a
%             DSGE-VAR. 
%
% Optional input:
%
% - 'maxIter' : Maximum number of iterations to solve the lyapunov 
%               equation. Needed to calculate the covariance matrix 
%               of the model.
%
% - 'tol'     : The tolerance level when solving the lyapunov equation. 
%               Needed to calculate the covariance matrix of the model.
% 
% Output:
% 
% Let N be number of dependent variables, L the number of lags of the VAR, 
% and C is equal to 1 if a constant is inlcuded. otherwise 0.
%
% - GammaYY : A N x N double with the nonstandardized sample moments of 
%             the left-hand variables of the VAR.
%
% - GammaXX : A (C + N*L) x (C + N*L) double with the nonstandardized 
%             sample moments of the right-hand variables of the VAR.
%
% - GammaXY : A (C + N*L) x N double with the nonstandardized sample 
%             moments between the right-hand variables and the left-hand
%             variables of the VAR.
%
% See also:
% nb_var, nb_var.priorTemplate
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if ~isscalar(obj)
        error('The obj input must be a scalar.')
    end
    if ~issolved(obj)
        error('The obj input must be solved.')
    end
    if ~isfield(obj.solution,'A')
        error('The obj input must be a dynamic model!')
    end
    if isfield(obj.options,'time_trend')
        if obj.options.time_trend 
            error('The obj input cannot have a time-trend!')
        end
    end
    
    % Get optional inputs
    default = {'tol',          eps,             @(x)nb_isScalarNumber(x,0);...
               'maxIter',      1000,            @(x)nb_isScalarInteger(x,0)
    };
    [inputs,message] = nb_parseInputs(mfilename,default,varargin{:});
    if ~isempty(message)
        error(message)
    end
    
    % Get exogenous
    numExo = dsgeVAR.exogenous.number;
    if numExo > 0
        error('It is not yet supported to have exogenous variables in the DSGE-VAR model.')
    end
    if dsgeVAR.options.constant && isa(obj,'nb_dsge')
        ss = getSteadyState(obj,dsgeVAR.dependent.name);
        ss = vertcat(ss{:,2});
    else
        ss = zeros(dsgeVAR.dependent.number,1);
    end
    
    % Get exogenous mean and variances
    c = theoreticalMoments(obj,'stacked',true,'nLags',dsgeVAR.options.nLags,...
        'type','covariance','tol',inputs.tol,'maxIter',inputs.maxIter,...
        'vars',dsgeVAR.dependent.name);
    c = double(c);
 
    % Build the theoretical covariance between Y and X
    constant = dsgeVAR.options.constant;
    numDep   = dsgeVAR.dependent.number;
    GammaXY  = c(numDep+1:end,1:numDep);
    if constant
        GammaXY = [zeros(1,numDep);GammaXY];
    end
    
    % Build the theoretical covariance between X and X
    GammaXX = c(numDep+1:end,numDep+1:end);
    if constant
        % Add one row and one column to GXX
        GammaXX = [[1,kron(ones(1,dsgeVAR.options.nLags),ss')];
            kron(ones(dsgeVAR.options.nLags,1),ss),GammaXX ];
    end

    % Build the theoretical covariance between Y and Y
    GammaYY = c(1:numDep,1:numDep);

end
