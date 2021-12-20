function obj = uncondForecast(obj,nSteps,varargin)
% Syntax:
%
% obj = uncondForecast(obj,nSteps,varargin)
%
% Description:
%
% Produced unconditional point and density forecast of nb_model_convert 
% objects.
% 
% Input:
% 
% - obj      : A vector of nb_model_convert objects. 
% 
% - nSteps   : See the uncondForecast method of the nb_model_generic class
%
% Optional inputs:
%
% - See the uncondForecast method of the nb_model_generic class
%
% Output:
%
% - obj    : A vector of nb_model_convert objects. 
%  
% See also:
% nb_model_convert.forecast
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj = forecast(obj,nSteps,varargin{:});
    
end
