function [obj,valid] = estimate(obj,varargin)
% Syntax:
%
% obj         = estimate(obj,varargin)
% [obj,valid] = estimate(obj,varargin)
%
% Description:
%
% Estimate the model(s) represented by nb_model_estimate object(s).
% 
% Input:
%
% - obj        : A vector of nb_model_generic objects.
%
% - 'parallel' : Use this string as one of the optional inputs to run the
%                estimation in parallel.
%
% - 'cores'    : The number of cores to open, as an integer. Default
%                is to open max number of cores available. Only an 
%                option if 'parallel' is given. 
%
% - 'remove'   : Give 'remove' to remove the models that return errors from
%                the obj output. This input is not stored to the 
%                forecastOutput property of the objects. 
%
% - 'waitbar'  : Use this string to give a waitbar during estimation. I.e.
%                when looping over models. If 'parallel' is used this
%                option is not supported!
%
% - 'write'    : Use this option to write errors to a file instead of 
%                throwing the error.
%
% Optional input:
% 
% - varargin : See the the set method.
% 
% Output:
% 
% - obj   : A vector of nb_model_generic objects, where the 
%           estimation results are stored in the property
%           results.
%
% - valid : A logical with size nObj x 1. true at location ii if 
%           estimation of model ii succeded, otherwise false.  If
%           'write' is not used an error will be thrown instead, so
%           in this case this output will be true for all models.
%
% See also:
% nb_model_generic, solve
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    [inputs,others] = nb_model_estimate.parseOptional(varargin{:});
     
    % Interpret option inputs
    obj  = set(obj,others{:});
    obj  = obj(:);
    nobj = numel(obj);
    if nobj == 0
        return
    end

    % Set up the estimators
    names  = getModelNamesLocal(obj);
    estOpt = cell(1,nobj);
    for ii = 1:nobj
        if isfield(obj(ii).options,'data') && isempty(obj(ii).options.data) && ~isa(obj,'nb_manualCalculator')
            error([mfilename ':: You must assign some data to the model ' names{ii} ' to be able to estimate it!'])
        end
        estOpt(ii) = getEstimationOptions(obj(ii));
    end

    % Estimate the model(s)
    [res,estOpt] = nb_model_estimate.loopEstimate(estOpt,names,inputs);
    
    % Assign objects
    for ii = 1:nobj
        % The wrapUpEstimation method may have been overloaded by
        % subclasses of the nb_model_estimate class
        obj(ii) = wrapUpEstimation(obj(ii),res{ii},estOpt{ii});
    end

    % Remove estimated objects that failed
    valid = ~cellfun(@isempty,res)';
    if inputs.remove && inputs.write
        obj = obj(valid);
    end

end

function names = getModelNamesLocal(obj)

    siz   = size(obj);
    obj   = obj(:);
    names = arrayfun(@getName,obj,'uniformOutput',false);
    ind   = find(cellfun(@isempty,names))';
    if ~isempty(ind)
        for ii = ind
            names{ii} = ['Model' int2str(ii)];
        end
    end
    names = reshape(names,siz);
    
end
