function histData = getHistory(obj,vars,date)
% Syntax:
%
% histData = getHistory(obj,vars,date)
%
% Description:
%
% Get historical data.
% 
% Input:
% 
% - obj  : A scalar nb_model_convert object.
%
% - vars : A cellstr with the variables to get. May include
%          shocks/residuals. Only the variables found is returned, 
%          i.e. no error is provided if not all variables is found.
%
% - date : For recursivly estimated models, the residual vary with the
%          date of recursion, so by this option you can get the residual
%          of a given recursion.
%
%          The same apply for real-time data.
% 
% Output:
% 
% - histData : A nb_ts object with the historical data.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 3
        date = '';
        if nargin < 2
            vars = obj.forecastOutput.variables;
        end
    end
    
    % Get history of all the forecasted variables or the variables asked
    % for. If some variables are asked for, but not part of model we
    % just skip those!
    ind          = ismember(obj.historyOutput.variables,vars);
    varsToReturn = obj.historyOutput.variables(ind);
    histData     = window(obj.historyOutput,'','',varsToReturn);
    
end
