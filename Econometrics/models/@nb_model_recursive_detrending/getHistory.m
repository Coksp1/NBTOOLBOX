function histData = getHistory(obj,vars,date)
% Syntax:
%
% histData = getHistory(obj,vars,date)
%
% Description:
%
% Get historical data
% 
% Input:
% 
% - obj  : A scalar nb_model_recursive_detrending object
%
% - vars : A cellstr with the variables to get. May include
%          shocks/residuals. Only the variables found is returned, 
%          i.e. no error is provided if not all variables is found.
%
% - date : For recursivly detrended and estimated models, the residual and 
%          data vary with the date of recursion, so by this option you 
%          can get the residual of a given recursion.
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
    end
    
    if numel(obj) > 1
        error([mfilename ':: This method only handle a scalar nb_model_recursive_detrending object.'])
    end
    
    % Get history of all the forecasted variables
    if isempty(date)
        histData = getHistory(obj.modelIter(end),vars,'');
    else
        if isa(date,'nb_date')
            date = toString(date);
        end
        indD = find(strcmpi(date,obj.options.recursive_start_date:obj.getRecursiveEndDate()));
        if isempty(indD)
            error([mfilename ':: Are not able to locate the recursive estimation date ' date '.']);
        end
        histData = getHistory(obj.modelIter(indD),vars,'');
    end
    
end
