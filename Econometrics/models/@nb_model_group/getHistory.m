function histData = getHistory(obj,vars,date,notSmoothed,type)
% Syntax:
%
% histData = getHistory(obj,vars,date,notSmoothed,type)
%
% Description:
%
% Get historical data
% 
% Input:
% 
% - obj         : A scalar nb_model_group object
%
% - vars        : A cellstr with the variables to get. May include
%                 shocks/residuals. Only the variables found is returned, 
%                 i.e. no error is provided if not all variables are found.
%
% - date        : For recursivly estimated models, the residual vary with 
%                 the date of recursion, so by this option you can get the 
%                 residual of a given recursion.
%
%                 The same apply for real-time data.
% 
% - notSmoothed : Prevent getting history from smoothed estimates.
%
% - type        : Either 'smoothed' or 'updated'. Default is 'smoothed'.
%
% Output:
% 
% - histData    : A nb_ts object with the historical data.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 5
        type = 'smoothed';
        if nargin < 4
            notSmoothed = false;
            if nargin < 3
                date = '';
            end
        end
    end
    
    if numel(obj)>1
        error([mfilename ':: This function only handles scalar nb_model_group objects.'])
    end
    
    % Get history of all the forecasted variables
    histData = nb_ts;
    cont     = 1;
    ii       = 1;
    while cont

        try
            data = getHistory(obj.models{ii},vars,date,notSmoothed,type);
        catch %#ok<CTCH>
            break
        end
        try
            histData = merge(histData,data);
        catch Err
            error([mfilename ':: It seems to me that the estimation data are conflicting for some of the variable. Error: ' Err.message])
        end
        cont = ~all(ismember(vars,histData.variables));                
        ii   = ii + 1;

    end
    
end
