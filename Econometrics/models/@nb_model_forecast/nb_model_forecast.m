classdef (Abstract) nb_model_forecast < nb_model_name
% Description:
%
% An abstract superclass for all models producing forecast.
%
% See also:
% nb_model_generic, nb_model_group
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    properties

        % A struct with forecast output
        forecastOutput = struct();

    end

    methods

        function obj = setForecastOutput(obj,forecastOutput)
            obj.forecastOutput = forecastOutput;
        end
        
    end
        
    methods (Abstract=true)
        varargout = getHistory(varargin);
    end
    
    methods (Sealed = true)
        varargout = getRecursiveScore(varargin);
        varargout = getScore(varargin);
        varargout = isDensityForecast(varargin);
        varargout = isforecasted(varargin);
        varargout = plotForecast(varargin);
    end
   
    methods (Static = true)
        varargout = forecastPerc2Dist(varargin);
        varargout = forecastPerc2ParamDist(varargin);
        varargout = simulateFromDensity(varargin);
    end
    
end
