function nb_cell_DB = tonb_cell(obj,strip)
% Syntax:
%
% nb_cell_DB = tonb_cell(obj)
%
% Description:
%
% Transform from a nb_data object to a nb_cell object
% 
% Input: 
% 
% - obj        : An object of class nb_data
%
% - strip      : - 'on'  : Strip all observations where all 
%                          the variables has no value. 
% 
%                - 'off' : Does not strip all observations 
%                          where all the variables has no value. 
%                          Default. 
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

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 2
        strip = 'off';
    end
    
    cellMatrix = asCell(obj,strip);
    nb_cell_DB = nb_cell(cellMatrix,obj.dataNames);
    nb_cell_DB.localVariables = obj.localVariables;
    
    if obj.isUpdateable() 
        obj        = obj.addOperation(@tonb_cell,{strip});
        links      = obj.links;
        nb_cell_DB = nb_cell_DB.setLinks(links);
    end

end
