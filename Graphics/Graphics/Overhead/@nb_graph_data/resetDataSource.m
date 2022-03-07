function [message,err] = resetDataSource(obj,dataSource,updateProps)
% Syntax:
% 
% [message,err] = resetDataSource(obj,varargin)
% 
% Description:
% 
% Reset the data source of the nb_graph_data object.
%
% Input:
% 
% - obj        : An object of class nb_graph_data
% 
% - dataSource : An nb_data object with the new data.
%
% - updateProps : If the variablesToPlot should be updated to be
%                 equal to dataSource.variables + the startGraph
%                 and endGraph properties are set to the startDate
%                 and endDate of the new data source.
%
%                 Can also be 'gui'. Then all properties will be check
%                 against the new dataset, and if the new dataset does not
%                 comply with the properties, the properties will be
%                 updated!
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 3
        updateProps = 1;
    end

    if ~isa(dataSource,'nb_data')
        if strcmpi(updateProps,'gui')
            err     = 1;
            message = 'The new data must be dimensionless!';
            return
        else
            error([mfilename ':: The dataSource input must be an object of class nb_data.'])
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
        
        if updateProps

            % Set some default properties
            if ~obj.manuallySetStartGraph
                obj.startGraph = obj.DB.startObs;
            end

            if ~obj.manuallySetEndGraph
                obj.endGraph = obj.DB.endObs;
            end

            obj.variablesToPlot = obj.DB.variables;
            obj.plotType        = 'line';
            
        end
        
    end
    
end
