function data = getStrippedRep(obj)
% Syntax:
%
% data = getStrippedRep(obj)
%
% Description:
%
% Expands data to a double with NaNs in places for missing 
% observations, but where each row with all missing observation is 
% stripped. 
%
% Input:
% 
% - obj  : An object of class nb_bd
% 
% Output:
% 
% - data : A n x m x p double.
% 
% See also:
% nb_bd.double
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if obj.numberOfDatasets > 1
        
        % Slow and ugly solution in this case
        data  = getFullRep(obj);
        isNaN = all(all(isnan(data),2),3);
        data  = data(~isNaN,:,:);
        
    else

        if obj.indicator    
            ind = obj.locations;
        else
            ind = ~obj.locations;
        end
        [r,c]  = find(ind);
        ur     = unique(r);
        numRow = size(ur,1);
        data   = nan(numRow,obj.numberOfVariables);
        for ii = 1:numRow
            ind             = r == ur(ii);
            data(ii,c(ind)) = obj.data(ind);  
        end
        
    end

end
