function obj = unstruct(s)
% Syntax:
%
% obj = nb_ts.unstruct(s)
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
% - obj : An nb_ts object.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj = nb_ts();
    if isempty(s.data)
        return;
    end
    
    obj.data       = s.data;
    obj.dataNames  = s.dataNames;
    obj.endDate    = nb_date.toDate(s.endDate,s.frequency);
    obj.frequency  = s.frequency;
    obj.startDate  = nb_date.toDate(s.startDate,s.frequency);
    obj.userData   = s.userData;
    obj.variables  = s.variables;
    obj.links      = s.links;
    obj.updateable = s.updateable;
    
    if isfield(s,'localVariables')
        obj.localVariables = s.localVariables;
    end
    
    if isfield(s,'sorted')
        obj.sorted = s.sorted;
    end    
end
