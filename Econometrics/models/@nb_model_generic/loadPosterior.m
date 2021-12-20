function posterior = loadPosterior(obj)
% Syntax:
%
% posterior = loadPosterior(obj)
%
% Description:
%
% Load posterior of the estimated model. Bayesian models only!
%
% Input:
%
% - obj       : An object of class nb_model_generic.
%             
% Output:
% 
% - posterior : A struct with the posterior output (The format will depend
%               on the sampling method used).
%
% See also:
% nb_model_estimate.estimate, nb_model_generic.assignPosteriorDraws,
% nb_model_sampling.sample
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if numel(obj) > 1
        error([mfilename ':: This method only handles scalar ' class(obj) '.'])
    end
    if ~isfield(obj.estOptions,'pathToSave')
        error([mfilename ':: No bayesian estimation has been done. Cannot proceed.'])
    end
    posterior = nb_loadDraws(obj.estOptions.pathToSave); 

end
