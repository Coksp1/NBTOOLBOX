function obj = setPrior(obj,prior)
% Syntax:
%
% obj = setPrior(obj,prior)
%
% Description:
%
% Set priors of a vector of nb_arima objects. The prior input must either
% be a struct or nb_struct with same size as obj or have size 1.
% 
% The provided struct will be added to the property options as the field
% prior. 
%
% See nb_arima.priorTemplate for the format of the struct.
%
% Caution : The algorithm field of the option property will
%           automatically be set to 'bayesian'.
%
% Input:
% 
% - obj   : A vector of nb_arima objects
%
% - prior : A struct or nb_struct with either matching numel of obj or size 
%           1. If size is 1 all models gets the same prior settings.
% 
% Output:
% 
% - obj   : A vector of nb_arima objects with the priors set.
%
% See also:
% nb_arima.priorTemplate
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
            obj(ii).options.prior     = prior;
            obj(ii).options.algorithm = 'bayesian';
        end

    elseif numel(prior) == nobj

        for ii = 1:nobj
            obj(ii).options.prior     = prior(ii);
            obj(ii).options.algorithm = 'bayesian';
        end

    else
        error('The prior input does not match the number of models in the vector of nb_arima models.')
    end

end
