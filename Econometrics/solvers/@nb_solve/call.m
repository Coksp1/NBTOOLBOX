function [x,fval,exitflag,JAC] = call(F,init,options,JF,varargin)
% Syntax:
%
% [x,fval,exitflag,JAC] = nb_solve.call(F,init,options,JF,varargin)
%
% Description:
%
% Call the nb_solve class to solve the F(x) = problem. See the 
% documentation of the nb_abc class for more on this algorithm.
% 
% Input:
% 
% - F           : See the dcumentation of the F property of the nb_solve 
%                 class. Must be given. 
%
% - init        : See the dcumentation of the init property of the 
%                 nb_solve class. Must be given.
%
% - options     : See the nb_solve.optimset method for more on this input.
%                 Can be empty.
%
% - JF          : See the dcumentation of the JF property of the nb_solve 
%                 class. Can be empty. 
% 
% Optional inputs:
%
% - varargin : Optional number of inputs given to the F (and JF)  
%              function(s) when it is called during the solution 
%              algorithm.
%
% Output:
% 
% - x        : See the dcumentation of the minXValue property of the 
%              nb_abc class.
%
% - fval     : See the dcumentation of the minFunctionValue property of  
%              the nb_abc class.
%
% - exitflag : See the dcumentation of the exitFlag property of  
%              the nb_abc class.
%
% - JAC      : Jacobian at last iteration.
%
% Examples:
%
% g  = @(x)x^2;
% x1 = nb_solve.call(g,1)
% x2 = nb_solve.call(g,-3)
%
% See also:
% nb_solve.optimset, fsolve
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 4
        JF = [];
        if nargin < 3
            options = nb_solve.optimset();
        end
    end
    
    obj = nb_solve(F,init,options,JF,varargin{:});
    solve(obj);
    
    x        = obj.x;
    fval     = obj.fVal;
    exitflag = obj.exitFlag;
    JAC      = obj.jacobian;

end
