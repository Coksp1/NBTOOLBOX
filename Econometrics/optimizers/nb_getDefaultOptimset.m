function opt = nb_getDefaultOptimset(opt,funcName)
% Syntax:
%
% opt = nb_getDefaultOptimset(funcName)
% opt = nb_getDefaultOptimset(opt,funcName)
%
% Description:
%
% If the opt input isempty or a struct without any fields, then this 
% method will return the default setting for the optimizer/solver used.
%
% I.e. for the MATLAB functions 'fmincon','fminunc','fminsearch' and 
% 'fsolve' this amount to calling optimset with the name of the function
% a the only input.
% 
% If this function don't recognize the function given by funcName, it will
% just return the opt input as it is (except that it will add the 'Display'
% 'OutputFcn' fields if not already added). 
%
% Input:
% 
% - opt      : A struct (with or without fields) or any other empty object.
% 
% - funcName : Name of the estimator/optimizer/solver to be used.
%
% Output:
% 
% - opt      : A struct with the options used by the estimator/optimizer/
%              solver.
%
% See also:
% optimset, nb_abc.optimset, nb_solve.optimset, nb_abcSolve.optimset,
% nb_lasso.optimset, nb_randomForest.optimset
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if ischar(opt)
        funcName = opt;
        opt      = struct();
    end

    if nb_isempty(opt)
        if strcmpi(funcName,'fsolve')
            opt             = optimset(funcName);
            opt.MaxIter     = 10000;
            opt.MaxFunEvals = inf;
            opt.Display     = 'iter';
            opt.TolFun      = 1e-07;
            opt.TolX        = 1e-10;
            opt.OutputFcn   = [];
        elseif strcmpi(funcName,'csolve')
            opt = struct('TolFun',1e-07,'MaxIter',10000);
        elseif any(strcmpi(funcName,{'fmincon','fminunc','fminsearch','fsolve'}))
            opt = optimset(funcName);
        elseif strcmpi(funcName,'bee_gate')
            opt = struct('MaxNodes',20,'MaxIter',inf,'MaxTime',60*60*5,'MaxFunEvals',inf,'OutputFcn',[]);
        elseif strcmpi(funcName,'nb_pso')
            opt = pso.optimset('Display','iter','MaxTime',60*60*5,'ConstrBoundary','reflect'); 
        elseif strcmpi(funcName,'nb_abc')
            opt = nb_abc.optimset;
        elseif strcmpi(funcName,'nb_abcSolve')
            opt = nb_abcSolve.optimset;        
        elseif strcmpi(funcName,'nb_solve')
            opt = nb_solve.optimset;    
        elseif strcmpi(funcName,'csminwel')
            opt = struct('TolFun',1.0000e-06,'MaxIter',inf);
        elseif strcmpi(funcName,'nb_lasso')
            opt = nb_lasso.optimset;  
        elseif strcmpi(funcName,'nb_randomForest')
            opt = nb_randomForest.optimset;    
        end
    end
    
    if ~any(strcmpi(funcName,{'nb_lasso','nb_randomForest'}))
        if ~isfield(opt,'OutputFcn')
            opt.OutputFcn = [];
        end
        if ~isfield(opt,'Display')
            if ~isfield(opt,'display')
                opt.Display = 'iter';
            end
        end
    end

end
