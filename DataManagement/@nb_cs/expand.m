function obj = expand(obj,newTypes,type,warningOff)
% Syntax:
%
% obj = expand(obj,newTypes,type,warning)
%
% Description:
%
% Expand the current nb_cs object with more types and data
% 
% Input:
% 
% - obj          : An object of class nb_cs
% 
% - newTypes     : The wanted new start date of the data.
% 
% - type         : Type of the appended data :
% 
%                  - 'nan'   : Expanded data is all nan (default)
%                  - 'zeros' : Expanded data is all zeros
%                  - 'ones'  : Expanded data is all ones
%                  - 'rand'  : Expanded data is all random numbers
% 
% - warningOff   : Give 'off' to suppress warning if no expansion 
%                  has taken place. All 'newTypes' are already stored 
%                  in the object.
% 
% Output:
% 
% - obj          : An nb_cs object with expanded types.
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 4
        warningOff = 'on';
        if nargin < 3
            type = '';
            if nargin < 2
                newTypes = '';
            end
        end
    end

    if isempty(type)
       type = 'nan';
    end

    if isempty(newTypes)
        newTypes = obj.types;
    end

    dim2 = obj.numberOfVariables;
    dim3 = obj.numberOfDatasets;

    % Find the number of added periods
    ind = ismember(newTypes,obj.types);
    if ~all(ind)
        
        newTypes = newTypes(~ind);
        num      = length(newTypes);
        switch type 
            case 'nan'
                newData = nan(num,dim2,dim3);
            case 'zeros'
                newData = nan(num,dim2,dim3);
            case 'ones'
                newData = nan(num,dim2,dim3);
            case 'rand'
                newData = nan(num,dim2,dim3);
            case 'obs'
                newData = nan(num,dim2,dim3);
            otherwise
                error([mfilename ':: Unsupported type; ' type ' (The supported types is; ''obs'', ''rand'', ''nan'', ''zeros'' and ''ones'')'])
        end
        if isa(obj.data,'nb_distribution')
            newData = nb_distribution.double2Dist(newData);
        end
        obj.data  = [obj.data;newData];
        obj.types = [obj.types,newTypes];
        
    end
    
    if obj.isUpdateable() && ~obj.isBeingMerged
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@expand,{newTypes,type,warningOff});
        
    end

end
