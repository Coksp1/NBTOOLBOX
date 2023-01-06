function obj = forecast(obj,nSteps,varargin)
% Syntax:
%
% obj = forecast(obj,nSteps,varargin)
%
% Description:
%
% Produced conditional point and density forecast of nb_model_group 
% objects. Use the combineForecast method to produce the combined density
% or point forecast.
% 
% Input:
% 
% - obj      : A vector of nb_model_group objects. 
% 
% - nSteps   : See the forecast method of the nb_model_generic class
%
% Optional inputs:
%
% - See the forecast method of the nb_model_generic class
%
% Output:
%
% - obj    : A vector of nb_model_group objects. See the property 
%            forecastOutput of each model stored in the models property
%            of the nb_model_group object.
%  
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    obj = obj(:);
    for ii = 1:size(obj,1)
        
        valid               = obj(ii).valid;
        models              = obj(ii).models;
        indMGroup           = cellfun(@(x)isa(x,'nb_model_group'),models);
        modelGroups         = models(indMGroup);
        modelsGeneric       = models(~indMGroup);
        models(indMGroup)   = nb_obj2cell(forecast([modelGroups{:}],nSteps,varargin{:}));
        [modelsG,validG]    = forecast([modelsGeneric{:}],nSteps,varargin{:});
        models(~indMGroup)  = nb_obj2cell(modelsG);
        valid(~indMGroup)   = validG;
        obj(ii).models      = models;
        obj(ii).valid       = valid;
        
    end
    
end
