function obj = sample(obj,varargin)
% Syntax:
%
% obj = sample(obj,varargin)
%
% Description:
%
% Sample from the posterior distribution using some type of 
% sampling algorithm.
% 
% Caution: Be aware that the 'draws' options only decides the number of
%          draws used to produce error bands of IRF, forecast etc., while  
%          the the 'draws' field of the 'sampler_options' options sets the
%          number of the sampler itself. The draws to keep are randomly 
%          selected out of the sampled draws!
%
% Caution: If you use an external sampler, you can use the 
%          nb_model_generic.assignPosteriorDraws method to assign this
%          to the object. Be caution to not assign too many draws, as
%          you may run out of memory (i.e. don't assing 1 000 000 draws)!
%
% Caution: To manually inspect the posterior draws use 
%          nb_model_generic.loadPosterior, and see the field output. This
%          is the output from the sampler function specified.
%
% Input:
%
% - obj      : An object of class nb_model_sampling.
%
% Optional input:
% 
% - varargin : Optional input pairs given to the set method. See
%              nb_model_estimate.set. I.e. these input can be used to
%              set fields of the options property. Most relevant is 
%              'sampler_options'
%             
% Output:
% 
% - obj      : An object of class nb_model_sampling.
%
% See also:
% nb_model_estimate.estimate, nb_model_generic.assignPosteriorDraws,
% nb_model_generic.checkPosteriors, nb_model_generic.plotPosteriors,
% nb_model_sampling.geweke, nb_model_sampling.gelmanRubin
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if numel(obj) > 1
        error([mfilename ':: This method only handles scalar ' class(obj) '.'])
    end
    if ~isa(obj,'nb_model_estimate')
        error([mfilename ':: The obj input must inherit the nb_model_estimate interface.'])
    end
    obj = set(obj,varargin{:});
    
    if ~isfield(obj.estOptions,'pathToSave')
        error([mfilename ':: No bayesian estimation has been done. Cannot proceed.'])
    end
    
    if obj.options.draws > obj.options.sampler_options.draws
        error([mfilename ':: The ''draws'' option must be less than or equal the ''sampler_options.draws'' option!'])
    end
    
    % Produce the posterior draws
    posterior            = nb_loadDraws(obj.estOptions.pathToSave); 
    posterior.output     = struct(); % Trigger re-sampling from scratch!
    lb                   = posterior.options.lb;
    ub                   = posterior.options.ub;
    posterior.options    = obj.options.sampler_options;
    posterior.options.lb = lb;
    posterior.options.ub = ub;
    sampleFunc           = str2func([obj.estOptions.estimator,'.sampler']); % E.g. nb_statespaceEstimator.sampler
    [~,~,posterior]      = sampleFunc(posterior,obj.options.draws);
    
    % Save posterior draws and save path to object
    estOptions            = obj.estOptions;
    estOptions.pathToSave = nb_saveDraws(obj.name,posterior);
    obj                   = setEstOptions(obj,estOptions);
    
end
