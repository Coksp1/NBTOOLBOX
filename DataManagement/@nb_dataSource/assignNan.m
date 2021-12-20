function obj = assignNan(obj,variables,value)
% Syntax:
%
% obj = expand(obj,variables,value)
%
% Description:
%
% Assign all the nan observation to the value input.
% 
% Input:
% 
% - obj       : An object of class nb_dataSource.
% 
% - variables : A char or a cellstr with the variables to assign nan 
%               values.
% 
% - value     : A scalar number. 
% 
% Output:
% 
% - obj          : An nb_ts object with expanded timespan
% 
% Examples:
%
% obj          = nb_ts.rand('2012Q1',10,2,3);
% obj(1:2,1,:) = nan;
% obj          = assignNan(obj,'Var1',0)
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if ischar(variables)
        variables = cellstr(variables);
    end
    
    indV                = ismember(obj.variables,variables);
    dataV               = obj.data(:,indV,:);
    dataV(isnan(dataV)) = value;
    obj.data(:,indV,:)  = dataV;

    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object.
        obj = obj.addOperation(@assignNan,{variables,value});
        
    end

end
