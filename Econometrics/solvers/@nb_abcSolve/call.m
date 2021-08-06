function [x,fval,exitflag] = call(F,init,lb,ub,options,varargin)
% Syntax:
%
% [x,fval,exitflag] = nb_abcSolve.call(F,init,lb,ub,options,varargin)
%
% Description:
%
% Call the artificial bee conlony algorithm to solve a multivariate 
% non-linear system of equations (F(x) = 0). See the documentation of 
% the nb_abcSolve class for more on this algorithm.
% 
% Input:
% 
% - F        : See the dcumentation of the objective property of the 
%              nb_abcSolve class. 
%
% - init     : See the dcumentation of the initialXValue property of the 
%              nb_abcSolve class.
%
% - lb       : See the dcumentation of the lowerBound property of the 
%              nb_abcSolve class.
%
% - ub       : See the dcumentation of the upperBound property of the 
%              nb_abcSolve class.
%
% - options  : See the nb_abcSolve.optimset method for more on this input.
%
% Optional inputs:
%
% - varargin : Optional number of inputs given to the objective when it is
%              called during the solving algorithm.
%
% Output:
% 
% - x        : See the dcumentation of the minXValue property of the 
%              nb_abcSolve class.
%
% - fval     : See the dcumentation of the minFunctionValue property of  
%              the nb_abcSolve class.
%
% - exitflag : See the dcumentation of the exitFlag property of  
%              the nb_abcSolve class.
%
% Examples:
%
% g                    = @(x)-sin(x);
% opt                  = nb_getDefaultOptimset('nb_abcSolve');
% opt.maxSolutions     = 3;
% x                    = nb_abcSolve.call(g,1,-4,4,opt)
% opt.jacobianFunction = @(x)-cos(x);
% x2                   = nb_abcSolve.call(g,1,-4,4,opt)
%
% See also:
% nb_abcSolve.optimset, nb_solve.call, fsolve 
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 5
        options = nb_abcSolve.optimset();
        if nargin < 4
            ub = [];
            if nargin < 3
                lb = [];
            end
        end
    end
    if nargout < 4
        options.doHessian = false;
    end

    obj = nb_abcSolve(F,init,lb,ub,options,varargin{:});
    solve(obj);
    x        = obj.xValue;
    fval     = obj.meritFunctionValue;
    exitflag = obj.exitFlag;
    
end
