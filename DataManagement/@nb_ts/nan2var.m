function obj = nan2var(obj,testedVariables,assignVariable)
% Syntax:
%
% obj = nan2var(obj,testedVariables,assignVariable)
% 
% Input:
% 
% - obj               : An object of class nb_ts
% 
% - testedVariables   : A cellstr with the variables you are 
%                       setting equal to the  assignVariable for  
%                       the nan values found.
% 
% - assignVariable    : A string with the name of the variable you 
%                       are assigning the found nan values.
% 
% Output:
% 
% - obj               : An nb_ts object where all the nan values of
%                       the variables in the testedVariables input
%                       is set to the matching value of the 
%                       variable given by the assignVariable input.
% 
% Examples:
% 
% obj = nb_ts([1,2;nan,1;nan,3],'','2012',{'Var1','Var2'});
% nan2var(obj,{'Var1'},'Var2')
% 
% ans = 
% 
%     'Time'    'Var1'    'Var2'
%     '2012'    [   1]    [   2]
%     '2013'    [   1]    [   1]
%     '2014'    [   3]    [   3]
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if size(obj.data,3) > 1
        error([mfilename ':: This method does not support data with more pages'])
    end
    
    if ischar(testedVariables)
        testedVariables = cellstr(testedVariables);
    elseif ~iscellstr(testedVariables)
        error([mfilename ':: The testedVariables input must be a cellstr.'])
    end
    
    var            = obj.variables;
    indT           = ismember(var,testedVariables);
    indS           = strcmp(assignVariable,var);
    data           = obj.data;
    dataT          = data(:,indT);
    dataT          = dataT(:);
    ISNAN          = isnan(dataT);
    dataS          = repmat(data(:,indS),[length(testedVariables),1,1]);
    dataT(ISNAN,:) = dataS(ISNAN);
    data(:,indT)   = reshape(dataT,obj.numberOfObservations,[]);
    obj.data       = data;

    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@nan2var,{testedVariables,assignVariable});
        
    end
    
end
