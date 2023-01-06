function nb_ts_DB = tonb_ts(obj)
% Syntax:
%
% nb_ts_DB = tonb_data(obj)
%
% Description:
%
% Transform from a nb_cs object to a nb_ts object
% 
% Caution : This will only succeed if the types can be interpreted as
%           dates.
%
% Input: 
% 
% - obj        : An object of class nb_cs
%
% Output:
% 
% - nb_data_DB : An object of class nb_ts
%               
% Examples:
% 
% nb_ts_DB = obj.tonb_ts();
% 
% Written by Kenneth S. Paulsen      

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    dataC    = asCell(obj);
    nb_ts_DB = nb_cell2obj(dataC,0,obj.sorted);
    nb_ts_DB.localVariables = obj.localVariables;
    
    if obj.isUpdateable()
        
        obj      = obj.addOperation(@tonb_ts);
        links    = obj.links;
        nb_ts_DB = nb_ts_DB.setLinks(links);
        
    end

end
