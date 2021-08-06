function obj = percentiles(obj,perc)
% Syntax:
%
% obj = percentiles(obj,perc)
%
% Description:
%
% Take the percentile over the third dimension of the data of the object.
% 
% Input:
% 
% - obj  : An object of class nb_ts
%
% - perc : A double with the wanted percentiles of the data. E.g.
%          0.5 (median), or [0.05,0.15,0.25,0.35,0.5,0.65,0.75,0.85,0.95].
% 
% Output:
% 
% - obj : A nb_ts object with the percentiles stored as different pages
%         of the object. See the dataNames property for the ordering.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if obj.numberOfDatasets < length(perc)
        error([mfilename ':: The number of datasets (pages) of the object must be at least greater than the number of calculated percentiles!'])
    end
    
    if size(perc,2) > 1
        perc = perc';
    end
    
    try
        obj.data = prctile(obj.data,perc*100,3);
    catch
        obj.data = nb_percentiles(obj.data,perc*100,3);
    end
    obj.dataNames = strcat('Percentile',strtrim(cellstr(num2str(perc*100))))';
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@percentiles,{perc});
        
    end
    
    
end
