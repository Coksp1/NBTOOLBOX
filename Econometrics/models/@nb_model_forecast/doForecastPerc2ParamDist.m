function [obj,dist] = doForecastPerc2ParamDist(obj,distribution,draws,varargin)
% Syntax:
%
% [obj,dist] = doForecastPerc2ParamDist(obj,distribution,draws,varargin)
%
% Description:
%
% Calculates a parameterized density from percentiles using a matching 
% percentiles estimator, and then simulate draws from this distribution. 
% See the nb_distribution.perc2ParamDist function.
% 
% Input:
% 
% - obj          : A nb_model_forecast object. 
% 
% - distribution : The distribution you want to estimate based on the
%                  percentiles. You must have at least as many percentiles
%                  as there are parameters!
%
% - draws        : Number of draws to make from the estimated 
%                  distributions.
%
% Optional input:
%
% - 'optimizer' : See doc of the optimizer input to the nb_callOptimizer
%                 function. Default is 'fmincon'.
%
% - 'optimset'  : See doc of the opt input to the nb_callOptimizer
%                 function. 
%
% Output:
%
% - obj         : A nb_model_forecast object. See the property 
%                 forecastOutput.
%  
% See also:
% nb_model_forecast.forecast, nb_distribution.perc2ParamDist
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if ~isscalar(obj)
        error('The obj input must be a scalar nb_model_forecast object.')
    end
    if ~obj.isforecasted
       error([mfilename ':: Model must be forecasted before calculating distribution.']) 
    end
    
    if isempty(obj.forecastOutput.perc)
       error([mfilename ':: Percentiles must be specified for this to work']) 
    end
    
    [obj.forecastOutput,dist] = nb_model_forecast.forecastPerc2ParamDist(obj.forecastOutput,distribution,draws,varargin);

end
