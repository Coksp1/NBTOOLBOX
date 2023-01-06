function data = getFullRep(obj)
% Syntax:
%
% data = getFullRep(obj)
%
% Description:
%
% Expands data to a full double with NaNs in places for missing 
% observations. 
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
% Written by Per Bjarne Bye

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    ind  = obj.locations;
    temp = nan(size(ind));
    if obj.indicator
        temp(logical(ind)) = obj.data;
    else
        temp(~ind) = obj.data;
    end
    
    if obj.numberOfDatasets > 1
        % Need to expand data to a 3D array (sparse matrices cannnot be
        % >2D, in obj, we save the locations as a 2D array with the 
        % different datasets stacked horizontally).
        temp = reshape(temp,[obj.numberOfObservations,obj.numberOfVariables,obj.numberOfDatasets]);
    end

    data = temp;

end
