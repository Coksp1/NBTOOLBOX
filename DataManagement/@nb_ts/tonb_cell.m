function nb_cell_DB = tonb_cell(obj,dateFormat,strip)
% Syntax:
%
% nb_cell_DB = tonb_cell(obj,dateFormat)
%
% Description:
%
% Transform from a nb_ts object to a nb_cell object
% 
% Input: 
% 
% - obj        : An object of class nb_ts
%
% - dateFormat : The date format of the dates of the return nb_cell 
%                object.
%
%                > 'default' (default)
%                > 'fame'
%                > 'NBEnglish' or 'NBEngelsk'
%                > 'NBNorsk' or 'NBNorwegian'
%                > 'xls'
%
% - strip      : - 'on'  : Strip all observation dates where all 
%                          the variables has no value. 
% 
%                - 'off' : Does not strip all observation dates 
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

    if nargin < 3
        strip = 'off';
        if nargin < 2
            dateFormat = 'default';
        end
    end
    
    cellMatrix = asCell(obj,dateFormat,strip);
    nb_cell_DB = nb_cell(cellMatrix,obj.dataNames);
    nb_cell_DB.localVariables = obj.localVariables;
    
    if obj.isUpdateable()  
        obj        = obj.addOperation(@tonb_cell,{dateFormat,strip});
        links      = obj.links;
        nb_cell_DB = nb_cell_DB.setLinks(links);
    end

end
