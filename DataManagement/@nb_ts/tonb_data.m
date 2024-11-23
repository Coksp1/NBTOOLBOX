function nb_data_DB = tonb_data(obj,start)
% Syntax:
%
% nb_data_DB = tonb_data(obj)
% nb_data_DB = tonb_data(obj,start)
%
% Description:
%
% Transform from a nb_ts object to a nb_data object. The startObs will
% automatically be set to 1, if not the start input is provided.
% 
% Input: 
% 
% - obj      : An object of class nb_ts
%   
% - start    : Start observation.
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

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 2
        start = 1;
    end

    nb_data_DB = nb_data(obj.data,obj.dataNames,start,obj.variables,obj.sorted);
    nb_data_DB.localVariables = obj.localVariables;
    
    if obj.isUpdateable()
        
        obj        = obj.addOperation(@tonb_data);
        links      = obj.links;
        nb_data_DB = nb_data_DB.setLinks(links);
        
    end

end
