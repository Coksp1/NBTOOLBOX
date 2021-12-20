function [paramD,success,solvingFailed,objAcc] = monteCarloFiltering(obj,varargin)
% Syntax:
%
% paramD                                = monteCarloFiltering(obj,varargin)
% [paramD,success,solvingFailed,objAcc] = monteCarloFiltering(obj,varargin)
%
% Description:
%
% Draws parameter values from a compact space, which is spesified with some
% lower and upper bounds. For each draws the model is tried to be solved,
% if success the behavior of the model is tested and if that is a success
% that model is returned.
%
% The draws are made using the function nb_monteCarloSim.
%
% Input:
% 
% - obj          : A scalar nb_model_generic object. 
%
% Optional input:
%
% - 'draws'      : The number of draws from the compact set to be tested. 
%
% - 'func'       : A function_handle or a string with the name of a
%                  function. The function should take one input, and that
%                  input is assumed to be an object of class
%                  nb_model_generic. The (only) output must be either true
%                  or false. Return true if the model fit a certain
%                  criteria.
%
% - 'parallel'   : Give true to run the MCF in parallel.
%
% - 'parameters' : A 1 x N cellstr with the parameter names to be drawn
%                  from. Must be part of model.
%
% - 'lowerBound' : A 1 x N double with the lower bound on the parameters of
%                  interest.
% 
% - 'upperBound' : A 1 x N double with the upper bound on the parameters of
%                  interest.
%
% - 'waitbar'    : true or false. Default is true.
%
% Output:
% 
% - paramD        : The draws made from the parameter space. As a draws x N
%                   double. Use paramD(success,:) to get the accepted
%                   draws.
% 
% - success       : A 1 x N logical. An element is true if the model where
%                   solved and the test function returned true.
%
% - solvingFailed : A 1 x N logical. An element is true if the model could
%                   not be solved.
%
% - objAcc        : A 1 x nAcc vector of nb_model_generic objects 
%                   representing the accepted models.
%
% See also:
% function_handle, nb_model_generic.solve, 
% nb_model_generic.assignParameters
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if numel(obj) > 1
        error([mfilename ':: This method only handle a scalar nb_model_generic object'])
    end

    if ~issolved(obj)
        error([mfilename ':: All the models must be solved to do monte carlo filtering (just to be certain that the model has a solution!)'])
    end

    % Parse the arguments
    %--------------------------------------------------------------
    suppMethods = {'latin','sobol','halton'};
    default = {'draws',          10000,   {@nb_isScalarInteger,'||',{@gt,0}};...
               'func',           [],      {{@isa,'function_handle'},'||',@nb_isOneLineChar};...
               'lowerBound',     [],      {@isnumeric,'||',@isvector};...
               'method',         'latin', {@nb_ismemberi,suppMethods};...
               'parallel',       false,   {@islogical,'||',@isnumeric};...
               'parameters',     {},      {@iscellstr};...
               'upperBound',     [],      {@isnumeric,'||',@isvector};...
               'waitbar',        true,    @nb_isScalarLogical};
           
    [inputs,message] = nb_parseInputs(mfilename,default,varargin{:});
    if ~isempty(message)
        error(message)
    end
    
    % Check the inputs
    if isempty(inputs.func)
        error([mfilename ':: You need to provide the func input.'])
    end
    if isempty(inputs.func)
        error([mfilename ':: You need to provide the parameters input.'])
    end
    if ischar(inputs.func)
        inputs.func = str2func(inputs.func);
    end
    param = obj.parameters.name;
    test  = ismember(inputs.parameters,param);
    if any(~test)
        error([mfilename ':: The following parameters are not part of the model; ' toString(inputs.parameters(~test))])
    end
    
    if length(inputs.lowerBound) ~= length(inputs.parameters)
        error([mfilename ':: The ''lowerBound'' input must have the same length as the ''parameters'' input.'])
    end
    if length(inputs.upperBound) ~= length(inputs.parameters)
        error([mfilename ':: The ''upperBound'' input must have the same length as the ''parameters'' input.'])
    end
    
    if any(~isfinite(inputs.lowerBound))
        error([mfilename ':: All the lower bounds on the parameters must be finite!'])
    end
    if any(~isfinite(inputs.upperBound))
        error([mfilename ':: All the upper bounds on the parameters must be finite!'])
    end
    if any(inputs.upperBound - inputs.lowerBound <= 0)
        error([mfilename ':: Some of the lower bounds are greater than or equal to the upper bounds!'])
    end
    
    % Draw from the compact parameter space
    paramD = nb_monteCarloSim(inputs.draws,inputs.lowerBound,inputs.upperBound,inputs.method);
    
    % Do the monte carlo filtering
    returnAcc     = nargout > 3;
    success       = true(1,inputs.draws);
    solvingFailed = false(1,inputs.draws);
    if inputs.parallel
    
        ret  = nb_openPool();
        par  = inputs.parameters;
        func = inputs.func;
        parfor ii = 1:inputs.draws

            % Assign parameters and solve
            objTest = assignParameters(obj,'param',par,'value',paramD(ii,:));
            try
                objTest = solve(objTest);
            catch 
                solvingFailed(ii) = true;
                success(ii)       = false;
                continue
            end

            % Test the criteria
            success(ii) = feval(func,objTest);

        end
        
        % Resolve the accepted models
        paramAcc = paramD(success,:);
        if returnAcc
            nAcc   = sum(success);
            objAcc = obj(ones(1,draws),:);
            parfor ii = 1:nAcc
                objAcc(ii) = assignParameters(obj,'param',par,'value',paramAcc(ii,:));
                objAcc(ii) = solve(objAcc(ii));
            end
        end
        nb_closePool(ret);
        
    else
        
        if returnAcc
            objAcc = obj(1:0);
        end
        
        % Initialize waitbar
        if inputs.waitbar
            notify           = nb_when2Notify(inputs.draws);
            h                = nb_waitbar5([],'MCF',true);
            h.text1          = 'Working...';
            h.maxIterations1 = inputs.draws;
        end
        
        obj = set(obj,'silent',true);
        for ii = 1:inputs.draws

            % Assign parameters and solve
            objTest = assignParameters(obj,'param',inputs.parameters,'value',paramD(ii,:));
            try
                objTest = solve(objTest);
            catch 
                solvingFailed(ii) = true;
                success(ii)       = false;
                continue
            end

            % Test the criteria
            success(ii) = inputs.func(objTest);

            % Append to accepted models
            if success(ii) && returnAcc
                objAcc = [objAcc,objTest];  %#ok<AGROW>
            end
            
            % Update status
            if inputs.waitbar
                if rem(ii,notify) == 0
                    h.status1 = ii;
                end
            end
            
        end
        
        delete(h);
        
    end
    
end
