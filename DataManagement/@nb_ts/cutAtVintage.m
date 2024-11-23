function obj = cutAtVintage(obj,lags)
% Syntax:
%
% obj = cutAtVintage(obj,lags)
%
% Description:
%
% Cut each vintage that include forecast at the period of the vintage tag
% minus the number of wanted lags.
% 
% Input:
% 
% - obj  : An object of class nb_ts
% 
% - lags : The number of lags to do to find the end date at each vintage.
%          Default is 1.
%
% Output:
% 
% - obj  : An object of class nb_ts
% 
% Examples:
% 
% obj = cutAtVintage(obj);
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 2
        lags = 1;
    end

    if obj.numberOfVariables > 1
        error('This method does not handle the case of more than 1 variable.')
    end
    
    vints = obj.dataNames;
    for ii = 1:length(vints)
        d                      = nb_day(vints{ii});
        newEndDate             = convert(d,obj.frequency) - lags;
        per                    = (newEndDate - obj.startDate) + 2;
        obj.data(per:end,1,ii) = nan; 
    end
    
    % Remove trailing nans
    obj.data    = obj.data(1:per-1,1,:);
    obj.endDate           = obj.startDate + (size(obj.data,1) - 1);
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@cutAtVintage,{lags});
        
    end
    
end
