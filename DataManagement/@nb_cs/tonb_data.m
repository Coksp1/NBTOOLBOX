function nb_data_DB = tonb_data(obj)
% Syntax:
%
% nb_data_DB = tonb_data(obj)
%
% Description:
%
% Transform from an nb_cs object to an nb_data object
% 
% Caution : This will only succeed if the types can be interpreted as
%           observations.
%
% Input: 
% 
% - obj        : An object of class nb_cs
%
% Output:
% 
% - nb_data_DB : An object of class nb_data
%               
% Examples:
% 
% nb_data_DB = obj.tonb_data();
% 
% Written by Kenneth S. Paulsen      

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    nb_data_DB = nb_data(double(obj),obj.dataNames,1,obj.variables);
    
    if obj.isUpdateable()
        
        obj        = obj.addOperation(@tonb_data);
        links      = obj.links;
        nb_data_DB = nb_data_DB.setLinks(links);
        
    end

end
