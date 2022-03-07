function data = getData(obj)
% Syntax:
% 
% data = getData(obj,zeroLowerBound)
% 
% Description:
% 
% Get the data of the table
% 
% Input:
% 
% - obj      : An object of class nb_table_data_source
% 
% Output:
%
% - data     : As a nb_cs or nb_cell object.
%
% Example:
% 
% data = obj.getData();
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    dataAsCell = getDataAsCell(obj);
    if isa(obj,'nb_cell')
        data = nb_cell(dataAsCell,'');
    else
        data = nb_cs(cell2mat(dataAsCell(2:end,2:end)),'',dataAsCell(2:end,1)',dataAsCell(1,2:end),false);
    end
    
end


