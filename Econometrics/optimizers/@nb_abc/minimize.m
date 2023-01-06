function minimize(obj,varargin)
% Syntax:
%
% minimize(obj)
% minimize(obj,varargin)
%
% Description:
%
% Run minimization on the given objective.
% 
% Input:
% 
% - obj : An object of class nb_abc.
%
% Optional input:
%
% - varargin : Given to the nb_abc.set method.
% 
% Output:
% 
% The provided object of class nb_abc has been updated the following 
% properties;
% > minXValue
% > minFunctionValue
% > exitFlag
% > hessian
%
% See also:
% nb_abc.call
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Set optional inputs.
    obj = set(obj,varargin{:});
    
    if obj.useParallel
        ret = nb_openPool(obj.numWorkers);
    end

    % Test all options
    testOptions(obj);
    
    % Initialize the bees
    initialize(obj);
    
    % Do minimization
    doMinimization(obj);
    
    % Estimate Hessian at the found point
    if obj.doHessian
        obj.hessian = nb_hessian(@(x)obj.objective(x),obj.minXValue);
    end
    
    if obj.useParallel
        nb_closePool(ret);
    end
    
end
