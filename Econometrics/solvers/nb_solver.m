function [x,fVal,exitflag] = nb_solver(solveFunc,fHandle,init,options,varargin)
% Syntax:
%
% x                 = nb_solver(solveFunc,fHandle,init,options)
% [x,fVal,exitflag] = nb_solver(solveFunc,fHandle,init,options,varargin)
%
% Description:
%
% Call a solver function (solveFunc) that can be called like
%
% [x,fVal,exitflag] = solveFunc(fHandle,init,options,varargin{:})
%
% The function should solve the problem F(x) = 0 for x.
% 
% Input:
% 
% - solveFunc : A string with the name or a function_handle of the 
%               function to use to solve the problem
% 
% - fHandle   : A function handle that represents F.
%
% - init      : The initial values of x to be used by the solver.
%
% - options   : A struct with the options to use by the solver. For some
%               optimizers see the optimset function by MATLAB.
%
% Optiona input:
%
% - varargin  : These inputs is passed on to the function fHandle during 
%               the solving of the problem.
%
% Output:
% 
% - x         : The solution of the problem F(x) = 0, as a vector of 
%               double values.
%
% - fVal      : The value of F(x) at the return x.
%
% - exitflag  : The exit flag return by the solver. If only to outputs are
%               returned this exit flag will be interpreded by the
%               nb_interpretExitFlag and an error will be thrown by inside
%               this function.
%
% See also:
% fsolve, nb_getDefaultOptimset, nb_getSolvers
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nb_isOneLineChar(solveFunc)
        solverString = solveFunc;
        solveFunc    = str2func(solveFunc);
    elseif isa(solveFunc,'function_handle')
        solverString = func2str(solveFunc);
    else
        error([mfilename,':: The algorithm input must be a one line char or a function_handle.'])
    end
    if nb_isempty(options)
        if strcmpi(solverString,'fsolve')
            options = optimset(solverString);
        elseif strcmpi(solverString,'csolve')
            options = struct('TolFun',1e-07,'MaxIter',10000);
        end
    else
        if strcmpi(solverString,'csolve')
            if ~isfield(options,'TolFun')
                options.TolFun = 1e-07;
            end
            if ~isfield(options,'MaxIter')
                options.MaxIter = 10000;
            end
        end
    end
    
    switch solverString
        case 'csolve'
            fVal         = nan;
            [x,exitflag] = csolve(fHandle,init,[],options.TolFun,options.MaxIter,varargin{:});
        otherwise
            [x,fVal,exitflag] = solveFunc(fHandle,init,options,varargin{:});
    end
    if nargout < 3
        nb_interpretExitFlag(exitflag,solverString);
    end
    x = x(:);

end
