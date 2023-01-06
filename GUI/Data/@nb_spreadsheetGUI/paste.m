function paste(gui,~,~,type)
% Syntax:
%
% paste(gui,hObject,event,type)
%
% Description:
%
% Part of DAG. Paste data from clipboard and try to convert in to a
% nb_dataSource object.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if strcmpi(type,'sarepta')

        try
            dataT = nb_sarepta2nb_ts();
        catch Err
            nb_errorWindow('The copied element is not a Sarepta to MATLAB link.',Err);
            return
        end
        
        if isempty(dataT)
            return % Error window displayed in nb_sarepta2nb_ts
        end
        
    elseif strcmpi(type,'locally')
        
        dataT = gui.parent.copiedObject;
        if not(isa(dataT,'nb_ts') || isa(dataT,'nb_data') || isa(dataT,'nb_cs'))
            nb_errorWindow('The locally copied element is not a dataset.');
            return
        end
        
    else
        
        input = nb_pasteFromClipboard(type);

        if isempty(input)
            nb_errorWindow('The copied element cannot be converted to time-series data, cross-sectional data or dimensionless data.')
            return
        else

            if iscell(input)

                try
                    dataT = nb_cell2obj(input);
                catch %#ok<CTCH>
                    nb_errorWindow('The copied element cannot be converted to time-series data, cross-sectional data or dimensionless data.')
                    return
                end

            else
                nb_errorWindow('The copied element cannot be converted to time-series data, cross-sectional data or dimensionless data.')
                return
            end

        end
        
    end
    
    % Assign the local variables of the session
    dataT.localVariables = gui.parent.settings.localVariables;
    
    % Remove invalid signs in the variable names
%     varNames            = dataT.variables;
%     [varNames, message] = nb_checkSaveName(varNames);
%     
%     if ~isempty(message)
%        nb_errorWindow(message) 
%        return
%     end
%     
%     dataT.variables = varNames;
    
    % Update spreadsheet
    gui.data = dataT;
    
end
