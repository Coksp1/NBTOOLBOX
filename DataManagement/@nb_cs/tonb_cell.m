function nb_cell_DB = tonb_cell(obj)
% Syntax:
%
% nb_cell_DB = tonb_cell(obj)
%
% Description:
%
% Transform from a nb_cs object to a nb_cell object
% 
% Input: 
% 
% - obj        : An object of class nb_cs 
%   
% Output:
% 
% - nb_cell_DB : An object of class nb_cell
%               
% Examples:
% 
% nb_cell_DB = obj.tonb_cell();
% 
% Written by Kenneth S. Paulsen      

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    cellMatrix = asCell(obj);
    nb_cell_DB = nb_cell(cellMatrix,obj.dataNames);
    nb_cell_DB.localVariables = obj.localVariables;
    
    if obj.isUpdateable() 
        obj        = obj.addOperation(@tonb_cell,{});
        links      = obj.links;
        nb_cell_DB = nb_cell_DB.setLinks(links);
    end

end
