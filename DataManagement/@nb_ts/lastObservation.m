function obj = lastObservation(obj,number)
% Syntax:
%
% obj = lastObservation(obj,number)
%
% Description:
%
% Get the last (real) observation(s) of the object.
% 
% Input:
% 
% - obj    : An object of class nb_ts.
%
% - number : Number of elements to return. Default is 1, i.e only the last.
%            As a integer.
% 
% Output:
% 
% - obj    : An object of class nb_ts.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 2
        number = [];
    end
    
    if isempty(number)
        number = 1;
    end
    
    if number > obj.numberOfObservations
       error('nb_ts:lastObservation:outOfBounds', [mfilename ':: Number out of bounds']); 
    end

    endD          = getRealEndDate(obj,'nb_date');
    ind           = endD - obj.startDate + 1;
    obj.data      = obj.data(ind-number+1:ind,:,:);
    obj.startDate = endD - number + 1;
    obj.endDate   = endD;

    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object. (Cannot give pages, because the links are already
        % removed)
        obj = obj.addOperation(@lastObservation,{number});
        
    end
    
end
