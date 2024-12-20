function obj = uncondForecast(obj,nSteps,varargin)
% Syntax:
%
% obj = uncondForecast(obj,nSteps,varargin)
%
% Description:
%
% Produced unconditional point and density forecast of nb_model_group 
% objects. Use the combineForecast method to produce the combined density
% or point forecast.
% 
% Input:
% 
% - obj      : A vector of nb_model_group objects. 
% 
% - nSteps   : See the uncondForecast method of the nb_model_generic class
%
% Optional inputs:
%
% - See the uncondForecast method of the nb_model_generic class
%
% Output:
%
% - obj    : A vector of nb_model_group objects. See the property 
%            forecastOutput of each model stored in the models property
%            of the nb_model_group object.
%  
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    obj = forecast(obj,nSteps,varargin{:});
    
end
