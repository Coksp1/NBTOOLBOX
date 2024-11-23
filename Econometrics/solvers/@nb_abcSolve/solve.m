function solve(obj,varargin)
% Syntax:
%
% solve(obj)
% solve(obj,varargin)
%
% Description:
%
% Run solving of the given problem.
% 
% Input:
% 
% - obj : An object of class nb_abcSolve.
%
% Optional input:
%
% - varargin : Given to the nb_abcSolve.set method.
% 
% Output:
% 
% The provided object of class nb_abcSolve has been updated the following 
% properties;
% > xValue
% > meritFunctionValue
% > exitFlag
%
% See also:
% nb_abcSolve.call
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

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
    doSolving(obj);
    if obj.useParallel
        nb_closePool(ret);
    end
    
end
