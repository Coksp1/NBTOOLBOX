function nb_ts_obj = tonb_ts(obj)
% Syntax:
%
% nb_ts_obj = tonb_ts(obj)
%
% Description:
%
% Transform from a nb_bd object to a nb_ts object
%
% Input: 
% 
% - obj       : An object of class nb_bd
%
% Output:
% 
% - nb_ts_obj : An object of class nb_ts
%               
% Examples:
% 
% nb_ts_obj = obj.tonb_ts();
% 
% Written by Per Bjarne Bye      

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen
    
    dataC      = asCell(obj);
    dataC{1,1} = 'time';
    nb_ts_obj  = nb_cell2obj(dataC,0,obj.sorted);
    
    if obj.isUpdateable()
        
        obj       = obj.addOperation(@tonb_ts);
        links     = obj.links;
        nb_ts_obj = nb_ts_obj.setLinks(links);
        
    end

end
