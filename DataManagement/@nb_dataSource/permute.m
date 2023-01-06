function obj = permute(obj,variables)
% Syntax:
%
% obj = permute(obj,variables)
%
% Description:
%
% Switch the second and third dimension of the nb_ts, nb_cs or nb_data 
% object.
% 
% Input:
% 
% - obj       : An object of class nb_ts, nb_cs or nb_data
%
% - variables : A cellstr with size 1 x numberOfDatasets. Default is to use
%               dataNames property. I.e. when not provided or if empty.
% 
% Output:
% 
% - obj : An object of class nb_ts, nb_cs or nb_data.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 2
        variables = {};
    end
    
    if isa(obj,'nb_cell')
        obj.c         = permute(obj.c,[1,3,2]);
        obj.data      = permute(obj.data,[1,3,2]);
        obj.dataNames = strcat('Database',strtrim(cellstr(int2str([1:size(obj.data,3)]'))))'; %#ok<NBRAK>    
        return
    end
    
    obj.data = permute(obj.data,[1,3,2]);
    if isempty(variables)
        variables = obj.dataNames;
    else
        if ~iscellstr(variables)
            error([mfilename ':: The variables input must be a cellstr.'])
        elseif size(variables,2) ~= obj.numberOfVariables || size(variables,1) ~= 1
            error([mfilename ':: The variables input must be a 1 x ' int2str(obj.numberOfVariables) ' cellstr.'])
        end
    end
    obj.dataNames = obj.variables;
    
    % Here we also need to sort things!
    if obj.sorted
        [variables,ind] = sort(variables);
        obj.data        = obj.data(:,ind,:);
    end
    obj.variables = variables;
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@permute);
        
    end
        
end
