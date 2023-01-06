function retStruct = toStructure(obj,old)
% Syntax:
%
% retStruct = toStructure(obj)
% retStruct = toStructure(obj,old)
%
% Description:
%
% Transform an nb_ts obj to a structure 
% 
% Input: 
% 
% - obj       : An object of class nb_ts
%   
% - old       : Indicate if old mat file format is wanted. Default is 0 
%               (false).
%
% Output:
% 
% - retStruct : A structure with fieldsnames given by the object
%               variables and field given by the variables data. 
%               (Can have more then one page). And a own field with
%               the start date of the data. (As a string.)
%               
% Examples:
%
% obj = nb_ts(ones(8,1),'','2012Q1',{'Var1'});
% s   = obj.toStructure()
% 
% s = 
% 
%               Var1: [8x1 double]
%          variables: {'Var1'}
%          startDate: '2012Q1'
%              class: 'nb_ts'
%           userData: ''
%     localVariables: []
%             sorted: 1
% 
% See also:
% nb_ts.struct
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
    
    retStruct.startDate      = obj.startDate.toString();
    retStruct.class          = 'nb_ts';
    retStruct.userData       = obj.userData;
    retStruct.localVariables = obj.localVariables;
    retStruct.sorted         = obj.sorted;
    
end
