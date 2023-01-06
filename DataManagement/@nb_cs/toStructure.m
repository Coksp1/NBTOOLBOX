function retStruct = toStructure(obj,old)
% Syntax:
%
% retStruct = toStructure(obj)
% retStruct = toStructure(obj,old)
% 
% Description:
%
% Transform the obj to a structure 
% 
% Input: 
% 
% - obj     : An object of class nb_cs
%   
% - old       : Indicate if old mat file format is wanted. Default is 0 
%               (false).
% 
% Output:
% 
% - retStruct : A structure with fieldsnames given by the object
%               variables and field given as the variables data. 
%               (Can have more then one page). 
% 
%               Caution: A extra field is also added to save the 
%                        objects types. (Saved under the field 
%                        'types')
%                        
% Examples:
% 
% obj = nb_cs([2,2],'test',{'First'},{'Var1','Var2'});
% s   = obj.toStructure()
% s = 
% 
%               Var1: 2
%               Var2: 2
%          variables: {'Var1'  'Var2'}
%              types: {'First'}
%              class: 'nb_cs'
%           userData: ''
%     localVariables: []
%             sorted: 1
%
% See also:
% nb_cs.struct
%
% Written by Kenneth S. Paulsen                     

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 2
        old = 0;
    end

    retStruct = struct();
    if old
        vars = obj.variables;
        for ii = 1:size(obj.variables,2)
            retStruct.(vars{ii}) = obj.data(:,ii,:);
        end
    else
        for ii = 1:size(obj.variables,2)
            retStruct.(['Var' int2str(ii)]) = obj.data(:,ii,:);
        end
        retStruct.variables = obj.variables;
    end
    
    retStruct.types          = obj.types;
    retStruct.class          = 'nb_cs';
    retStruct.userData       = obj.userData;
    retStruct.localVariables = obj.localVariables;
    retStruct.sorted         = obj.sorted;

end
