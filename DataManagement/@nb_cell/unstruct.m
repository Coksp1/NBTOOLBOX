function obj = unstruct(s)
% Syntax:
%
% obj = nb_cell.unstruct(s)
%
% Description:
%
% Reverse of the struct method.
% 
% Input:
% 
% - s   : See the s output of the struct method. 
% 
% Output:
% 
% - obj : An nb_cell object.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj            = nb_cell();
    ind            = cellfun(@isnumeric,s.data);
    newData        = nan(size(s.data));
    newData(ind)   = cell2mat(s.data(ind));
    obj.data       = newData;
    obj.c          = s.data;
    obj.dataNames  = s.dataNames;
    obj.userData   = s.userData;
    obj.links      = s.links;
    obj.updateable = s.updateable;

    if isfield(s,'localVariables')
        obj.localVariables = s.localVariables;
    end
    if isfield(s,'sorted')
        obj.sorted = s.sorted;
    end   
end
