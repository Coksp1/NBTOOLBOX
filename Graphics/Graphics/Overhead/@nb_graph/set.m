function set(obj,varargin)
% Syntax:
% 
% set(obj,varargin)
% 
% Description:
% 
% Set properties of the nb_graph class and its subclasses.
%
% See documentation NB Toolbox or type help('nb_graph') for more
% on the properties of the class.
% 
% Input:
% 
% - obj      : An object that is a subclass of nb_graph
% 
% - varargin : 'propertyName',propertyValue,...
%
% Output:
%
% No actual output, but the input objects properties will have been set to 
% their new value.
% 
% Examples:
% 
% data = nb_ts([2;1;2],'','2012Q1','Var1');
% obj  = nb_graph_ts(data);
% obj.set('startGraph','2012Q1','endGraph','2012Q3');
% obj.set('crop',1);
% 
% Written by Per Bjarne Bye

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    nobj = size(obj,2);
    if nobj > 1
        for ii = 1:nobj
            set(obj(ii),varargin{:});
        end
        return
    end
    
    if ~isa(obj,'nb_graph')
        error([mfilename ' :: The object must be a subclass of nb_graph.'])
    end

    if isempty(obj.DB)
        error([mfilename ':: The given dataset is empty and it will not be possible to set any properties in this case.'])
    end

    if size(varargin,1) && iscell(varargin{1})
        % Makes it possible to give options directly through a cell
        varargin = varargin{1};
    end
    
    classOfObj    = class(obj);
    specificTable = getClassSpecificTable(obj,classOfObj);
    table         = [getGenericOptions(obj);specificTable];

    for jj = 1:2:size(varargin,2)

        propertyName  = varargin{jj};
        propertyValue = varargin{jj + 1};

        if ischar(propertyName)
            
            % Making robust for all-lowercase / wrong capitalization of
            % propertyName
            setmethods = table(:,1);
            ind        = strcmpi(propertyName,setmethods);
             
            if any(ind)
                propertyName = setmethods{ind};
                [~,message]  = nb_parseInputs(mfilename,table,propertyName,propertyValue);
                if ~isempty(message)
                    error(message)
                else
                    % Do nothing. Property has been set by being called by
                    % nb_parseInputs.
                end
                
            else
                % Try to set the next one if there is more inputs
                warning(['Cannot find ', propertyName,' among the properties you have access to set.'])
            end

        else
            % Cannot give specific name, since propertyName is not a char..
            % Try to set the next one if there is more inputs
            warning('The propertyName must be given as a char. Failed to do anything with (one of) the propertie(s) you tried to set.')
        end
 
    end
end

function table = getClassSpecificTable(obj,classOfObj)
    % Returns settable properties of the class as a N x 4 cell.
    
    if strcmpi(classOfObj,'nb_graph_ts')
        table = getTSOptions(obj);
    elseif strcmpi(classOfObj,'nb_graph_cs')
        table = getCSOptions(obj);
    elseif strcmpi(classOfObj,'nb_graph_data')
        table = getDataOptions(obj);
    else % Must be nb_bd since we error checked for it being a subclass of nb_graph
        table = getBDOptions(obj);
    end
end
