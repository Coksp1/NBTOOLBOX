function obj = set2nan(obj,testedVariable,settedVariable)
% Syntax:
%
% obj = set2nan(obj,testedVariable,settedVariable)
% 
% Input:
% 
% - obj               : An object of class nb_data
% 
% - testedVariable    : A string with the name of the variable you 
%                       are testing for nan values
% 
% - settedVariable    : A string with the name of the variable you
%                       are setting equal to nan where the  
%                       testedVariable are in fact nan.
% 
% Output:
% 
% - obj               : An nb_data object where the settedVariable 
%                       are set equal to nan at all the same dates 
%                       as the testedVariable is nan. 
% 
% Examples:
% 
% obj = nb_data([1,2;nan,1;2,3],'',1,{'Var1','Var2'});
%
% obj = set2nan(obj,'Var1','Var2');
%
% obj = 
% 
%     'Time'    'Var1'    'Var2'
%     '2012'    [   1]    [   2]
%     '2013'    [ NaN]    [ NaN]
%     '2014'    [   2]    [   3]
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if size(obj.data,3) > 1
        error([mfilename ':: This method does not support data with more pages'])
    end
    
    var              = obj.variables;
    indT             = strcmp(testedVariable,var);
    indS             = strcmp(settedVariable,var);
    data             = obj.data;
    dataT            = data(:,indT);
    ISNAN            = isnan(dataT);
    data(ISNAN,indS) = nan;
    obj.data         = data;

    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@set2nan,{testedVariable,settedVariable});
        
    end
    
end
