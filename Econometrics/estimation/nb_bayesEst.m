function [exitflag,beta,fval,H] = nb_bayesEst(init,ub,lb,opt,optimizer,func,priorFunc,varargin)
% Syntax:
%
% [exitflag,beta,fval,H] = nb_bayesEst(init,ub,lb,opt,optimizer,...
%       func,priorFunc,varargin)
%
% Description:
%
% Estimate multiple (related) equations using Bayisian (mode) estimation.
%
% The minimized objective is: func(beta) - priorFunc(beta).
%
% Input:
% 
% - init      : Initial values of the parameters of the model to estimate.
%               As a nParam x 1 double.
%              
% - ub        : Upper bound on the parameters of the model to estimate.
%               As a nParam x 1 or nParam x 1 double. If given as empty  
%               inf is default. Only applies if optimizer is set to 
%               'fmincon' or 'nb_abc'.
%
% - lb        : Lower bound on the parameters of the model to estimate.
%               As a nParam x 1 or nParam x 1 double. If given as empty  
%               -inf is default. Only applies if optimizer is set to 
%               'fmincon' or 'nb_abc'.
%
% - opt       : See the optimset function for more on this input. Default
%               values will be used if it is given as [].
%
% - optimizer : The optimizer to be used; 'fminunc', 'fminsearch', 
%               'fmincon' or 'nb_abc'. 'fmincon' is default.
%
% - func      : A function handle that takes the inputs in the following 
%               order:
%               > The parameter matrix as a (nParam x nEq) x 1 double,
%                 i.e. vec(beta).
%               > The y input.
%               > The x input.
%               > The rest of the optional inputs given to this function 
%                 (varargin)
%
%               The output should be a 1 x 1 double with minus the log 
%               likelihood of the model.
%
% - priorFunc : A function handle that takes the inputs in the following 
%               order:
%               > The parameter matrix as a (nParam x nEq) x 1 double,
%                 i.e. vec(beta).
%
%               The output should be a 1 x 1 double log prior evaluated
%               at the current parameter values.
% 
% Optional input:
%
% - 'NONLCON'   : A function handle that return the values of C(beta) and
%                 Ceq(beta), where C(beta) <= 0 and Ceq(beta) == 0. E.g.
%                 [C,Ceq] = nonlinconstr(beta).
%   
%                 For more see; help nb_abc.constraints
%
% - 'highValue' : The highest possible value for the objective being 
%                 minimized. Default is 1000000. 
%
% - varargin    : The rest will be given as optional inputs to the func 
%                 input.
% 
% Output: 
% 
% - exitflag   : The reason for exiting the minimization. Positive numbers
%                and 0 means success, otherwise failure.
%
% - beta       : A nxvar x neq matrix with the estimated 
%                parameters.
%
% - residual   : Residual from the estimated equation. As an 
%                nobs x neq matrix. 
%
% - H          : Hessian matrix at the mode of the objective function.
%                As a 
%
% See also
% nb_midasFunc
%
% Written by Kenneth S. Paulsen
 
% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Get linear constraints
    [NONLCON,varargin]   = nb_parseOneOptional('NONLCON',[],varargin{:});
    [highValue,varargin] = nb_parseOneOptional('highValue',1000000,varargin{:});
    if ~isempty(NONLCON)
        if ~any(strcmpi(optimizer,{'fmincon','nb_abc'}))
            error([mfilename ':: You need to use the ''fmincon'' or ''nb_abc'' optimizers, if you add non-linear constraints (''NONLCON'' input).'])
        end
    else
        NONLCON = [];
    end

    if isempty(opt)
        if strcmpi(optimizer,'nb_abc')
            opt = nb_getDefaultOptimset('nb_abc');
        else
            opt             = optimset(optimizer);
            opt.Display     = 'off';
            opt.MaxFunEvals = 2000;
            opt.MaxIter     = 500;
            opt.TolFun      = sqrt(eps);
            opt.TolX        = sqrt(eps);
            opt.LargeScale  = 'off';
        end
    end
    
    % Bounds
    init = init(:);
    N    = size(init,1);
    if isempty(ub)
        ub = inf(N,1);
    end
    if isempty(lb)  
        lb = -inf(N,1); 
    end
    
    % Get objective to minimize
    objective = @(beta)calculateLogPosterior(beta,func,priorFunc,highValue,varargin);
    
    % Do the estimation for each equation separate
    if strcmpi(optimizer,'fminunc')
        [beta,fval,exitflag,~,~,H] = fminunc(objective,init,opt);
    elseif strcmpi(optimizer,'fminsearch')
        [beta,fval,exitflag] = fminsearch(objective,init,opt);
        H             = nb_hessian(objective,beta);
    elseif strcmpi(optimizer,'nb_abc')
        [beta,fval,exitflag,H] = nb_abc.call(fh,init,lb,ub,opt,NONLCON);
    else
        [beta,fval,exitflag,~,~,~,H] = fmincon(objective,init,[],[],[],[],lb,ub,NONLCON,opt);
    end

end

%==========================================================================
function fVal = calculateLogPosterior(beta,func,priorFunc,highValue,inputs)
% Calculate the log posterior

    logLik   = func(beta,inputs{:});
    logPrior = priorFunc(beta);
    fVal     = logLik - logPrior;
    if fVal > highValue
        fVal = highValue;
    end
    
end
