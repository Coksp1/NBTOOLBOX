function obj = hpfilter1s(obj,lambda)
% Syntax:
%
% obj = hpfilter1s(obj,lambda)
%
% Description:
%
% Do one-sided hp-filtering of all the dataseries of the nb_data 
% object. (Returns the gap). Will strip nan values when calculating 
% the filter. 
% 
% Input:
% 
% - obj     : An object of class nb_data
% 
% - lambda  : The lambda of the hp-filter 
% 
% Output:
% 
% - obj     : An nb_data object with the hp-filtered timeseries.
% 
% Examples:
% 
% gap   = hpfilter1s(data,3000);
% trend = data-gap;
%
% See also:
% hpfilter
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    filter = nan(obj.numberOfObservations,obj.numberOfVariables,obj.numberOfDatasets);
    for ii = 1:obj.numberOfVariables

        for jj = 1:obj.numberOfDatasets
        
            % Find first finite observation 
            isFinite = isfinite(obj.data(:,ii,jj));
            first    = find(isFinite,1);

            % Need at least 5 observation 
            last = first + 4;

            % Do the one sided filter
            
            while last <= obj.numberOfObservations

                tempData           = obj.data(first:last,ii,jj);
                isNaN              = isnan(tempData);
                tempData           = tempData(~isNaN);
                tempFilter         = hpfilter(tempData,lambda);
                filter(last,ii,jj) = tempFilter(end);

                last = last + 1;

            end
            
        end

    end
    
    obj.data = filter;
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@hpfilter1s,{lambda});
        
    end

end
