function obj = uncondForecast(obj,nSteps,varargin)
% Syntax:
%
% obj = uncondForecast(obj,nSteps,varargin)
%
% Description:
%
% Produced unconditional point and density forecast of nb_model_generic 
% objects. 
% 
% Input:
% 
% - obj      : A vector of nb_model_generic objects. 
% 
% - nSteps   : Number of forecasting steps. As a 1x1 double. Default is 8.
%
% Optional inputs:
%
% - See the nb_model_generic.forecast method
%
% Output:
%
% - obj    : A vector of nb_model_generic objects. See the property 
%            forecastOutput.
%  
% See also:
% nb_model_generic.forecast
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 2
        nSteps = 6;
    end

    obj = forecast(obj(:),nSteps,varargin{:});

end
