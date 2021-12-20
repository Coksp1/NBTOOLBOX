function ret = hasConditionalInfo(obj)
% Syntax:
%
% ret = hasConditionalInfo(obj)
%
% Description:
%
% Has the data source conditional information?
% 
% Input:
% 
% - obj : An object of class nb_modelDataSource.
% 
% Output:
% 
% - ret : true or false.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    ret = hasConditionalInfo(obj.source);
    if ret == -1
        if isempty(obj.data)
            ret = false;
        else
            % Look for the dates that splits history and forecast
            endHistDates = obj.data.userData;
            if isempty(endHistDates)
                ret = false;
            elseif isa(endHistDates,'nb_date')
                if size(endHistDates,1) == obj.data.numberOfDatasets && ...
                    size(endHistDates,2) == obj.data.numberOfVariables
                    ret = true;
                end
            else
                ret = false;
            end
        end
    end

end
