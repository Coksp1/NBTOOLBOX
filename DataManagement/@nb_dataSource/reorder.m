function obj = reorder(obj,newOrder,type)
% Syntax:
%
% obj = reorder(obj,newOrder,type)
%
% Description:
%
% Re-order the variables/types/datasets of the object.
% 
% Input:
% 
% - obj      : An object of class nb_ts, nb_cs or nb_data
%
% - newOrder : A cellstr with the new order of the
%              variables/types/datasets.
%
% - type     : Either 'variables' (default), 'types' or 'datasets'. 'types'
%              is only supported for nb_cs objects.
% 
% Output:
% 
% - obj      : An object of class nb_ts, nb_cs or nb_data
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 3
        type = 'variables';
    end
    
    switch lower(type)
        
        case 'variables'
            
            if isa(obj,'nb_cell')
                error([mfilename ':: Cannot reorder the type ''' type ''' for an object of class ' class(obj) '.'])
            end
            
            ind = ismember(obj.variables,newOrder);
            if any(~ind)
                error([mfilename ':: The following variables are missing in the newOrder input; ' toString(obj.variables(~ind))])
            end
            [~,loc] = ismember(newOrder,obj.variables);
            if isa(obj,'nb_bd')
                dataT = double(obj);
                dataT = dataT(:,loc,:);
                [obj.locations,obj.indicator,obj.data] = ...
                    nb_bd.getLocInd(dataT);
                obj.variables = newOrder;
                obj.sorted    = false;
            else
                obj.data      = obj.data(:,loc,:);
                obj.variables = newOrder;
                obj.sorted    = false;
            end
            
        case 'types'
            
            if ~isa(obj,'nb_cs')
                error([mfilename ':: Cannot reorder the type ''' type ''' for an object of class ' class(obj) '.'])
            end
            ind = ismember(obj.types,newOrder);
            if any(~ind)
                error([mfilename ':: The following types are missing in the newOrder input; ' toString(obj.types(~ind))])
            end
            [~,loc]   = ismember(newOrder,obj.types);
            obj.data  = obj.data(loc,:,:);
            obj.types = newOrder;
            
        case {'datasets','datanames'}
            
            ind = ismember(obj.dataNames,newOrder);
            if any(~ind)
                error([mfilename ':: The following datasets/dataNames are missing in the newOrder input; ' toString(obj.dataNames(~ind))])
            end
            [~,loc]       = ismember(newOrder,obj.dataNames);
            obj.data      = obj.data(:,:,loc);
            obj.dataNames = newOrder;
            
        otherwise
            error([mfilename ':: Cannot reorder the type ''' type ''' for an object of class ' class(obj) '.'])
    end
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@reorder,{newOrder,type});
        
    end
    
end
