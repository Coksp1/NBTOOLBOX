function dataObject = get(obj,id)
% Syntax:
%
% obj = get(obj,id)
%
% Description:
%
% Get the object with the given identifier
% 
% Input:
% 
% - obj        : An object of class nb_DataCollection
% 
% - id         : The identifier of the object you want to get. As a 
%                string.
% 
% Output:
% 
% - dataObject : The data object which match the identifier. 
%                Either a nb_cs, nb_ts or nb_data
% 
% Examples:
%
% dataObject = get(obj,'Dataset1');
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    dataObject = obj.list.get(id);

end
