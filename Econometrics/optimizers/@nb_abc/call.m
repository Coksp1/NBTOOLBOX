function [x,fval,exitflag,hessian] = call(fh,init,lb,ub,options,constraints,varargin)
% Syntax:
%
% [x,fval,exitflag,hessian] = nb_abc.call(fh,init,lb,ub,options,constraints,varargin)
%
% Description:
%
% Call the artificial bee conlony algorithm. See the documentation of 
% the nb_abc class for more on this algorithm.
% 
% Input:
% 
% - fh          : See the documentation of the objective property of the 
%                 nb_abc class. 
%
% - init        : See the documentation of the initialXValue property of the 
%                 nb_abc class.
%
% - lb          : See the documentation of the lowerBound property of the 
%                 nb_abc class.
%
% - ub          : See the documentation of the upperBound property of the 
%                 nb_abc class.
%
% - options     : See the nb_abc.optimset method for more on this input.
% 
% - constraints : See the documentation of the constraints property of the 
%                 nb_abc class.
%
% Optional inputs:
%
% - varargin : Optional number of inputs given to the objective when it is
%              called during the minimization algorithm.
%
% Output:
% 
% - x        : See the documentation of the minXValue property of the 
%              nb_abc class.
%
% - fval     : See the documentation of the minFunctionValue property of  
%              the nb_abc class.
%
% - exitflag : See the documentation of the exitFlag property of  
%              the nb_abc class.
%
% - hessian  : See the documentation of the hessian property of  
%              the nb_abc class.
%
% Examples:
%
% g  = @(x)-sin(x);
% x3 = nb_abc.call(g,-3,-4,4)
%
% See also:
% nb_abc.optimset, fmincon, fminunc, fminsearch, bee_gate
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 6 
        constraints = [];
        if nargin < 5
            options = nb_abc.optimset();
            if nargin < 4
                ub = [];
                if nargin < 3
                    lb = [];
                end
            end
        end
    end
    
    if nargout < 4
        options.doHessian = false;
    end

    obj = nb_abc(fh,init,lb,ub,options,constraints,varargin{:});
    minimize(obj);
    
    x        = obj.minXValue;
    fval     = obj.minFunctionValue;
    exitflag = obj.exitFlag;
    if nargout > 3
        hessian  = obj.hessian;
    end
    
end
