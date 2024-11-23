function vars = getPlottedVariables(obj,forLegend) %#ok<INUSD>
% Syntax:
% 
% vars = getPlottedVariables(obj,forLegend)
% 
% Description:
% 
% Get the variables of the table
% 
% Input:
% 
% - obj       : An object of class nb_table_data_source
%
% Output:
%
% - vars     : As a cellstr
%
% Written by Kenneth S. Paulsen
    
% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    try
        vars = obj.variablesOfTable;
    catch %#ok<CTCH>
        vars = {};
    end

end
