function retStruct = toStructure(obj,old)
% Syntax:
%
% retStruct = toStructure(obj)
% retStruct = toStructure(obj,old)
%
% Description:
%
% Transform an nb_data obj to a structure 
% 
% Input: 
% 
% - obj       : An object of class nb_data
%   
% - old       : Indicate if old mat file format is wanted. Default is 0 
%               (false).
%   
% Output:
% 
% - retStruct : A structure with fieldsnames given by the object
%               variables and field given by the variables data. 
%               (Can have more then one page). And a own field with
%               the start obs of the data. (As an integer.)
%               
% Examples:
%
% obj = nb_data(ones(8,1),'',1,{'Var1'});
% s   = obj.toStructure()
% s = 
% 
%               Var1: [8x1 double]
%          variables: {'Var1'}
%           startObs: 1
%              class: 'nb_data'
%           userData: ''
%     localVariables: []
%             sorted: 1
%
% See also:
% nb_data.struct
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
    
    retStruct.variables      = obj.variables;
    retStruct.startObs       = obj.startObs;
    retStruct.class          = 'nb_data';
    retStruct.userData       = obj.userData;
    retStruct.localVariables = obj.localVariables;
    retStruct.sorted         = obj.sorted;

end
