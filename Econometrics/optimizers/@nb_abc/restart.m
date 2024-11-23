function [x,fval,exitflag,hessian] = restart(obj)
% Syntax:
%
% [x,fval,exitflag,hessian] = restart(obj)
%
% Description:
%
% Call the artificial bee conlony algorithm. See the documentation of 
% the nb_abc class for more on this algorithm.
% 
% Input:
% 
% - obj      : A nb_abc object that has been stopped or saved.
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
% - hessian  : See the dcumentation of the hessian property of  
%              the nb_abc class.
%
% See also:
% nb_abc.call
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if obj.useParallel
        ret = nb_openPool(obj.numWorkers);
    end

    % Restart reporting
    resForDisplay = struct('iteration',obj.iterations,'fval',obj.minFunctionValue);
    update(obj.displayer,obj.minXValue,resForDisplay,'init');
    
    % Do minimization
    doMinimization(obj);
    
    % Estimate Hessian at the found point
    if obj.doHessian
        obj.hessian = nb_hessian(@(x)obj.objective(x),obj.minXValue);
    end
    
    if obj.useParallel
        nb_closePool(ret);
    end
    
    % Return
    x        = obj.minXValue;
    fval     = obj.minFunctionValue;
    exitflag = obj.exitFlag;
    if nargout > 3
        hessian = obj.hessian;
    end
    
end
