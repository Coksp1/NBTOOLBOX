function obj = setPrior(obj,prior)
% Syntax:
%
% obj = setPrior(obj,prior)
%
% Description:
%
% Set priors of a vector of nb_fmdyn objects. The prior input must either
% be a struct or nb_struct with same size as obj or have size 1.
% 
% The provided struct will be added to the property options as the field
% prior. 
%
% See nb_fmdyn.priorTemplate for the format of the struct.
%
% Input:
% 
% - obj   : A vector of nb_fmdyn objects
%
% - prior : A struct or nb_struct with either matching numel of obj or size 
%           1. If size is 1 all models gets the same prior settings.
% 
% Output:
% 
% - obj   : A vector of nb_fmdyn objects with the priors set.
%
% See also:
% nb_fmdyn.priorTemplate
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nb_isempty(prior)
        return
    end

    if isa(prior,'nb_struct')
        prior = get(prior); % Convert to struct
    end
    prior = prior(:);
    obj   = obj(:);
    nobj  = size(obj,1);
    if numel(prior) == 1

        for ii = 1:nobj
            obj(ii).options.estim_method = prior.method;
            prior                        = rmfield(prior,'method');
            obj(ii).options.prior        = prior;
        end

    elseif numel(prior) == nobj

        for ii = 1:nobj
            priorThis                    = prior(ii);
            obj(ii).options.estim_method = priorThis.method;
            priorThis                    = rmfield(priorThis,'method');
            obj(ii).options.prior        = priorThis;
        end

    else
        error([mfilename ':: The prior input does not match the number of models in the vector of nb_fmdyn models.'])
    end

end
