function [forecastOutput,dist] = forecastPerc2ParamDist(forecastOutput,distribution,draws,varargin)
% Syntax:
%
% [forecastOutput,dist] = nb_model_forecast.forecastPerc2ParamDist(...
%     forecastOutput,distribution,draws,varargin)
%
% Description:
%
% Calculates a parameterized density from percentiles using a matching 
% percentiles estimator, and then simulate draws from this distribution. 
% See the nb_distribution.perc2ParamDist function.
% 
% Input:
% 
% - forecastOutput : A forecast property of the nb_model_forecast 
%                    class where the forecastOutput.data stores 
%                    the forecast of the percentiles. 
% 
% - distribution   : The distribution you want to estimate based on the
%                    percentiles. You must have at least as many 
%                    percentiles as there are parameters!
%
% - draws          : Number of draws to make from the estimated 
%                    distributions.
%
% Optional input:
%
% - 'optimizer'    : See doc of the optimizer input to the nb_callOptimizer
%                    function. Default is 'fmincon'.
%
% - 'optimset'     : See doc of the opt input to the nb_callOptimizer
%                    function. 
%
% Output:
%
% - forecastOutput : A struct on the same format as the 
%                    nb_model_forecast.forecastOutput property
%
% See also:
% nb_model_forecast.forecast, nb_distribution.perc2ParamDist
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Get forecasted percentiles and other info
    perc    = forecastOutput.perc;
    data    = forecastOutput.data; % nHor x nVars x nPerc + 1 x nRec
    horizon = size(data,1);
    if ~((length(perc) + 1) == size(data,3))
        error([mfilename ':: Model need to have been forecasted on percentiles for this to work. To ',...
            'trigger the forecast of percentiles of aquantile models you need to set the "draws" ',...
            'option to a number greater than 1, otherwise use the ''perc'' option.'])
    end
    perc = [perc,50]; % Add mean/median/mode
    
    % Estimate distributions
    nVars   = size(data,2);
    nRec    = size(data,4);
    newData = nan(horizon,nVars,draws + 1,nRec);
    if nargout > 1
        dist(horizon,nVars,1,nRec) = nb_distribution();
    end
    for ii = 1:nRec
        
        for vv = 1:size(data,2)
        
            for hh = 1:horizon
                percData = squeeze(data(hh,vv,:,ii));
                if all(abs(percData(1) - percData) < eps^(0.5))
                    distObj             = nb_distribution('type','constant','parameters',{percData(1)});
                    newData(hh,vv,:,ii) = percData(1);
                else
                    distObj                     = nb_distribution.perc2ParamDist(distribution,perc,percData,varargin{:});
                    newData(hh,vv,1:draws,ii)   = random(distObj,1,draws);
                    newData(hh,vv,draws + 1,ii) = mean(distObj);
                end
                if nargout > 1
                    dist(hh,vv,1,ii) = distObj;
                end
            end
            
        end
    
    end
    
    forecastOutput.data = newData;
    forecastOutput.perc = [];

end
