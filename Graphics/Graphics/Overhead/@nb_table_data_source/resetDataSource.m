function [message,err] = resetDataSource(obj,dataSource,updateProps)
% Syntax:
% 
% [message,err] = resetDataSource(obj,dataSource,updateProps)
% 
% Description:
% 
% Reset the data source of the nb_table_data_source object.
%
% Input:
% 
% - obj        : An object of class nb_table_data_source
% 
% - dataSource : An nb_dataSource object with the new data.
%
% - updateProps : If properties should be updated or not.
%
%                 Can also be 'gui'. Then all properties will be check
%                 against the new dataset, and if the new dataset does not
%                 comply with the properties, the properties will be
%                 updated!
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 3
        updateProps = 1;
    end

    if isa(obj,'nb_table_ts')
        
        if ~isa(dataSource,'nb_ts')
            if strcmpi(updateProps,'gui')
                err     = 1;
                message = 'The new data must be time-series!';
                return
            else
                error([mfilename ':: The dataSource input must be an object of class nb_ts.'])
            end
        end
        
    elseif isa(obj,'nb_table_data')
        
        if ~isa(dataSource,'nb_data')
            if strcmpi(updateProps,'gui')
                err     = 1;
                message = 'The new data must be dimensionless data!';
                return
            else
                error([mfilename ':: The dataSource input must be an object of class nb_data.'])
            end
        end
        
    elseif isa(obj,'nb_table_cs')
        
        if ~isa(dataSource,'nb_cs')
            if strcmpi(updateProps,'gui')
                err     = 1;
                message = 'The new data must be cross-sectional!';
                return
            else
                error([mfilename ':: The dataSource input must be an object of class nb_cs.'])
            end
        end
        
    else % nb_table_cell
        
        if ~isa(dataSource,'nb_cell')
            if strcmpi(updateProps,'gui')
                err     = 1;
                message = 'The new data must be cell data!';
                return
            else
                error([mfilename ':: The dataSource input must be an object of class nb_cell.'])
            end
        end    
        
    end
        
    
    err     = 0;
    message = '';
    if strcmpi(updateProps,'gui')
        
        [message,err,s] = updatePropsWhenReset(obj,dataSource);
        if err
            return
        end
       
        % Here I update the properties given the possible loss of data
        % or observations
        props  = s.properties;
        fields = fieldnames(props);
        for ii = 1:length(fields)
            obj.(fields{ii}) = props.(fields{ii});
        end
        
        % Then we update the data properties
        obj.DB = dataSource;
        
    else

        % Assign the data properties
        obj.DB = dataSource;
        test   = updateProps;
        if isa(obj,'nb_table_ts')
            oldFreq = obj.DB.frequency;
            test    = test || oldFreq ~= obj.DB.frequency;
        end
        if isa(obj,'nb_table_cs')
            test = false;
        end
        
        if test

            % Set some default properties
            if ~obj.manuallySetStartTable
                obj.startTable = obj.DB.startDate;
            end

            if ~obj.manuallySetEndTable
                obj.endTable = obj.DB.endDate;
            end

        end

        if updateProps 

            obj.variablesToPlot = obj.DB.variables;
            obj.plotType        = 'line';

        end
        
    end
    
    % Merge local variables
    try
        obj.localVariables = nb_structcat(obj.localVariables,obj.DB.localVariables);
    catch Err
        error([mfilename ':: Could not merge the local variables from the new data source and the nb_graph_ts object. ' Err.message])
    end
    obj.DB.localVariables = obj.localVariables;
    
end
