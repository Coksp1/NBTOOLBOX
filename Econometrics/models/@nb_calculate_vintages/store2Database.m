function obj = store2Database(obj,inputs)
% Syntax:
%
% obj = store2Database(obj,inputs)
%
% Description:
%
% Store calculated to database.
% 
% See also:
% nb_model_update_vintages.write
%
% Written by Kenneth Sæterhagen Paulsen

    if isa(obj.options.store2,'nb_store2Database')
        
        if isa(obj.options.dataSource,'nb_modelDataSource')
           if ~isempty(obj.options.dataSource.calendar)
               error(['You cannot provide a calendar to the datasource and at the ',...
                      'same time write the forecast to a database (store2 property ',...
                      'not empty)! This is the case for model ' getName(obj) '.'])
           end
        end
        
        % Get the variables to write
        if isempty(obj.options.store2.variables)
            obj.options.store2.variables = obj.results.data.variables;
        end
        
        % Do we need to initialize anything?
        obj = initialize(obj.options.store2,obj,inputs);
        
        % Write the calculated time-series to database
        if ~isempty(obj.contexts2Write)
            obj.options.store2.put(real(keepPages(obj.results.data,obj.contexts2Write)));
        end
        
        % Write status of the model
        updateStatus(obj.options.store2,obj.valid);
        
    end

end
