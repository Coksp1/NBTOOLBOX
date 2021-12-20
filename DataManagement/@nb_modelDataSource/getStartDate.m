function startDate = getStartDate(obj)
% Syntax:
%
% startDate = getStartDate(obj)
%
% Description:
%
% Get the start date of the data source.
% 
% Input:
% 
% - obj : An object of class nb_modelDataSource.
% 
% Output:
% 
% - startDate : A nb_date object.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    startDate = get(obj.data,'startDate');

end
