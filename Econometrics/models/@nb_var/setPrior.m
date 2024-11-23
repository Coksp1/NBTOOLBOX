function obj = setPrior(obj,prior)
% Syntax:
%
% obj = setPrior(obj,prior)
%
% Description:
%
% Set priors of a vector of nb_var objects. The prior input must either
% be a struct or nb_struct with same size as obj or have size 1.
% 
% The provided struct will be added to the property options as the field
% prior. 
%
% See nb_var.priorTemplate for the format of the struct.
%
% Caution : The estim_method field of the option property will
%           automatically be set to 'bvar'.
%
% Caution : Not yet supported for the subclass nb_favar!
%
% Input:
% 
% - obj   : A vector of nb_var objects
%
% - prior : A struct or nb_struct with either matching numel of obj or size 
%           1. If size is 1 all models gets the same prior settings.
% 
% Output:
% 
% - obj   : A vector of nb_var objects with the priors set.
%
% See also:
% nb_var.priorTemplate
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

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
            obj(ii).options.prior = prior;
            if strcmpi(prior.type,'kkse')
                obj(ii).options.estim_method = 'tvpmfsv';
            else
                obj(ii).options.estim_method = 'bVar';
            end
        end

    elseif numel(prior) == nobj

        for ii = 1:nobj
            obj(ii).options.prior = prior(ii);
            if strcmpi(prior(ii).type,'kkse')
                obj(ii).options.estim_method = 'tvpmfsv';
            else
                obj(ii).options.estim_method = 'bVar';
            end
        end

    else
        error([mfilename ':: The prior input does not match the number of models in the vector of nb_var models.'])
    end

end
