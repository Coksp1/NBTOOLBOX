function dataOfObject = double(obj)
% Syntax:
%
% dataOfObject = double(obj)
%
% Description:
%
% Get the data of the object as a double matrix
% 
% Caution : If the data of the object is represents as an object of class 
%           nb_distribution the mean is returned.
%
% Input:
% 
% - obj          : An object of class nb_ts, nb_cs or nb_data
%
% Output:
%
% - dataOfObject : The data of the nb_ts, nb_cs or nb_data object
%
% Examples:
%
% dataOfObject = double(obj)
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if isa(obj.data,'nb_distribution')
        dataOfObject = mean(obj.data);
    elseif islogical(obj.data)
        dataOfObject = double(obj.data);
    else
        dataOfObject = obj.data;
    end
    
end
