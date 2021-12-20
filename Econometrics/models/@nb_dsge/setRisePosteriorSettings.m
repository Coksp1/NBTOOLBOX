function obj = setRisePosteriorSettings(obj,varargin)
% Syntax:
%
% obj = setRisePosteriorSettings(obj,varargin)
%
% Description:
%
% Set setting on how to sample from the posterior. 
% 
% Inputs.
%
% - obj : A 1x1 nb_dsge object.
%
% Input:
% 
% - 'burnin'    : The number of draws to burn at the start of the sampling
%                 process.
%
% - 'thin'      : Give 1 to keep every draw, 2 to keep every second draw, 
%                 etc.
%
% - 'algorithm' : Either;
%
%                 > 'mh_sampler' : Uses the mh_sampler function of the RISE
%                                  toolbox
%
%                 > 'rff_sampler' : Uses the rrf_sampler function of the 
%                                   RISE toolbox
% 
% Output:
% 
% obj : The object itself with the options reset.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if numel(obj) > 1
        error([mfilename ':: This method can only be called on a 1x1 nb_dsge object.'])
    end
    
    if nb_isempty(obj.results)
        error([mfilename 'The model is not estimated, and therefore no settings can be reset.'])
    end
    
    % Parse inputs
    default = {'burnin',        [], {@nb_iswholenumber,'&&',@isscalar,'&&',{@ge,1}};...
               'thin',          [], {@nb_iswholenumber,'&&',@isscalar,'&&',{@ge,1}};...
               'algorithm',     [], {{@nb_ismemberi,{'mh_sampler','rrf_sampler'}}}};
    [inputs,message] = nb_parseInputs(mfilename,default,varargin{:});
    if ~isempty(message)
        error(message)
    end
    
    % Assign the settings
    try
        posterior = nb_loadDraws(obj.estOptions.pathToSave);
    catch %#ok<CTCH>
        res       = obj.results;
        posterior = struct('model',options.riseObject,'betaD',nan(size(res.beta,1),size(res.beta,2),0),...
                       'sigmaD',nan(size(res.sigma,1),size(res.sigma,2),0),'type','RISEDSGE',...
                       'burnin',0,'thin',1,'algorithm','mh_sampler');
    end
    
    if ~isempty(inputs.burnin)
        posterior.burnin = inputs.burnin;
    end
    if ~isempty(inputs.thin)
        posterior.thin = inputs.thin;
    end
    if ~isempty(inputs.algorithm)
        posterior.algorithm = inputs.algorithm;
    end
    obj.estOptions.pathToSave = nb_saveDraws(obj.name,posterior);
    
end
