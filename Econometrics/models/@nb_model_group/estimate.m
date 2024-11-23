function obj = estimate(obj,varargin)
% Syntax:
%
% obj = estimate(obj,varargin)
%
% Description:
%
% Estimate the model(s) represented by nb_model_group object(s).
% 
% Input:
%
% - obj : A vector of nb_model_group objects.
%
% Optional input:
% 
% - varargin : See the the estimate method of the nb_model_generic 
%              class.
% 
% Output:
% 
% - obj : A vector of nb_model_group objects, where the estimation 
%         results are stored in the property results.
%
% See also:
% nb_model_generic
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    obj = obj(:);
    for ii = 1:size(obj,1)
        
        valid               = obj(ii).valid;
        models              = obj(ii).models;
        indMGroup           = cellfun(@(x)isa(x,'nb_model_group'),models);
        modelGroups         = models(indMGroup);
        modelsGeneric       = models(~indMGroup);
        models(indMGroup)   = nb_obj2cell(estimate([modelGroups{:}],varargin{:}));
        [modelsG,validG]    = estimate([modelsGeneric{:}],varargin{:});
        models(~indMGroup)  = nb_obj2cell(modelsG);
        valid(~indMGroup)   = validG;
        obj(ii).models      = models;
        obj(ii).valid       = valid;
        
    end

end
