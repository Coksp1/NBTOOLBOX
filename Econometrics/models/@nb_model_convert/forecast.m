function obj = forecast(obj,nSteps,varargin)
% Syntax:
%
% obj = forecast(obj,nSteps,varargin)
%
% Description:
%
% Produced conditional point and density forecast of nb_model_convert 
% objects. First the model stored in the model property is forecast then
% the forecast is converted.
% 
% Input:
% 
% - obj      : A vector of nb_model_convert objects. 
% 
% - nSteps   : See the forecast method of the nb_model_generic class
%
% Optional inputs:
%
% - See the forecast method of the nb_model_generic class
%
% Output:
%
% - obj    : A vector of nb_model_convert objects. 
%  
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    error([mfilename ':: It is not possible to forecast an nb_model_convert object yet. See update instead.'])
    
end
