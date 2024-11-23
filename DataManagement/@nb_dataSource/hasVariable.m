function [ret,location] = hasVariable(obj,variable)
% Syntax:
%
% [ret,location] = hasVariable(obj,variable)
%
% Description:
%
% Test if an nb_cs object has a given variable
% 
% Input:
% 
% - obj      : An object of class nb_cs
% 
% - variable : The variable name as a string. Can also be a cellstr with
%              more variables.
% 
% Output:
% 
% - ret      : 1 if found otherwise 0
% 
% - location : The location of the variable if found. Otherwise [].
% 
% Examples:
% 
% ret            = obj.hasVariable('Var1')
% [ret,location] = hasVariable(obj,'Var1')
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if isa(obj,'nb_cell')
        error([mfilename ':: nb_cell object does not have variables.'])
    end
    
    if iscellstr(variable)
        [ret,location] = ismember(variable,obj.variables);
    else
        
        if ~ischar(variable)
            error([mfilename ':: The input ''variable'' must be a string or a cellstr.'])
        end
        
        ret   = 0;
        found = find(strcmp(variable,obj.variables),1);
        if ~isempty(found)
            ret = 1;
        end
        location = found;
    end

end
