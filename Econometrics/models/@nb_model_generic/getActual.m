function actual = getActual(options,solution,vars,startFcst,nSteps,inputs,nowcast)
% Syntax:
%
% actual = nb_model_generic.getActual(options,solution,vars,startFcst,...
%               nSteps,inputs,nowcast)
%
% Description:
%
% Get actual data to compare against the forecast. 
% 
% Input:
% 
% - options   : See the (hidden) property estOptions of the 
%               nb_model_generic. For real-time models, the last element
%               of this struct array should be used.
%
% - solution  : See the property solution of the nb_model_generic object.
%
% - vars      : A cellstr with the names of the variables to get the actual 
%               data of.
%
% - startFcst : The recursive forecasting periods. Either as a double
%               with the indecies or a cellstr with the dates.
%
% - nSteps    : Number of forecasting steps. If empty the sample will not
%               be split.
%
% - inputs    : A struct with some options passed to the 
%               nb_forecast.getActual function. Optional.
%
% - nowcast   : Indicate how many periods there has been produced nowcast 
%               of. 
% 
% Output:
% 
% - actual : A nSteps x nVars x nPeriods double with the actual data for
%            each recursive forecast if nSteps is given, otherwise a nobs
%            x nVars double.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 7
        nowcast = 0;
        if nargin < 6
            inputs = struct('compareTo','','compareToRev','');
        end
    end
    if iscellstr(startFcst)
        startDataObj = nb_date.date2freq(options(end).dataStartDate);
        startFcst1   = nb_date.date2freq(startFcst(1,1));
        startFcstEnd = nb_date.date2freq(startFcst(1,end));
        if startFcst1.frequency ~= startDataObj.frequency
            % I.e. dealing with mixed frequency models
            startDataObj = convert(startDataObj,startFcst1.frequency);
        end
        startInd     = startFcst1 - startDataObj + 1;
        endInd       = startFcstEnd - startDataObj + 1;
        startFcst    = startInd:endInd;
    end
    actual = nb_forecast.getActual(options,inputs,solution,nSteps,...
                    vars,startFcst-nowcast,~isempty(nSteps));
    
end
