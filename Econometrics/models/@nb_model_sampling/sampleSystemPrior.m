function obj = sampleSystemPrior(obj,varargin)
% Syntax:
%
% obj = sampleSystemPrior(obj,varargin)
%
% Description:
%
% Sample from the system prior distribution using some type of 
% sampling algorithm, i.e. get the prior distribution of the parameters
% given the system priors.
%
% Input:
%
% - obj     : An object of class nb_model_sampling.
%
% Optional input:
% 
% - varargin : Optional input pairs given to the set method. See
%              nb_model_estimate.set. I.e. these input can be used to
%              set fields of the options property. Most relevant is 
%              'sample_options'
%             
% Output:
% 
% - obj      : An object of class nb_model_sampling.
%
% See also:
% nb_model_estimate.estimate, nb_model_generic.assignPosteriorDraws,
% nb_dsge.systemPriorObjective
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if numel(obj) > 1
        error([mfilename ':: This method only handles scalar ' class(obj) '.'])
    end
    if ~isa(obj,'nb_model_estimate')
        error([mfilename ':: The obj input must inherit the nb_model_estimate interface.'])
    end
    obj = set(obj,varargin{:});
    
    if not(isfield(obj.options,'prior') && isfield(obj.options,'systemPrior'))
        error([mfilename ':: The model does not support system priors.'])
    end
    if isempty(obj.options.systemPrior)
        error([mfilename ':: You must select some system priors! See setSystemPrior or use set(obj,''systemPrior'',yourPriorFunc)'])
    end    
    
    % Get objective
    estOptions          = getEstimationOptions(obj); 
    getObjectiveFunc    = str2func([class(obj) '.getObjectiveForEstimation']);
    [~,estStruct,lb,ub] = getObjectiveFunc(estOptions{1},true);
    sysPriorObjective   = str2func([class(obj) '.systemPriorObjective']);
    objective           = @(x)sysPriorObjective(x,estStruct);
    
    % Get initial value
    prior = obj.options.prior;
    if isempty(prior)
        error([mfilename ':: You must select some priors on the parameters as well as system priors! See setPrior'])
    end
    betaPrior = cell2mat(prior(:,2));
    
    % Set the lower and upper bound
    samplerOpt    = obj.options.sampler_options;
    samplerOpt.ub = ub;
    samplerOpt.lb = lb;
    
    % Get a initial value on the covariance matrix of the parameters
    Hessian   = nb_hessian(@(x)-objective(x),betaPrior);
    omega     = Hessian\eye(size(Hessian,1));
    stdEstPar = sqrt(diag(omega));
    if any(~isreal(stdEstPar))
        if obj.options.covrepair
            omega = nb_covrepair(omega,false);
        else
            warning([mfilename ':: Covariance of system prior at the initial value where not real...'])
        end
    end
    
    % Do the sampling
    if ischar(samplerOpt.sampler)
        samplerFunc = str2func(samplerOpt.sampler);
    elseif isa(posterior.options.sampler,'function_handle')
        samplerFunc = samplerOpt.sampler;
    else
        error([mfilename 'The ''sampler'' field of the ''sampler_options'' option must be ',...
                         'either a string with the name of the function or a function_handle.'])
    end
    output = samplerFunc(objective,betaPrior',omega,samplerOpt);
    
    % Save updated priors draws and save path to object
    obj.systemPriorPath = nb_saveDraws([obj.name '_system'],output);
    
end
