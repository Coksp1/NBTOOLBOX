function copySubplotCallback(obj,hObject,~)
% Copy a subplot to a object that can call the graph method to replicate
% the original subplot in a normal graph

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    plotter = copy(obj);
    if strcmpi(obj.graphMethod,'graphSubPlots')

        var = get(hObject,'tag');
        if isa(obj,'nb_graph_cs')
            data = obj.DB.window({},{var}); 
        else
            data = obj.DB.window('','',{var});        
        end

        % Reset data source
        [message,err] = resetDataSource(plotter,data,true);
        if err
            nb_errorWindow(message)
            return
        end 
        
        % Set needed properties
        if ~plotter.noTitle 
            plotter.set('title',var);
        end
        
        % Check for fan chart
        if isa(obj,'nb_graph_ts')
            if isa(obj.fanDatasets,'nb_ts') && ~isempty(obj.fanDatasets)
                fData = obj.fanDatasets;
                fData = fData.window('','',{var});   
                plotter.set('fanDatasets',fData,'fanVariable',var);
            end
        end
        
    else
        
        userData       = get(hObject,'userData');
        [fName,fIndex] = deal(userData{:}); 
        expression     = obj.GraphStruct.(fName){fIndex,1};
        
        % Get plotted variables in subplot
        ind = strfind(expression,'[');
        if isempty(ind)
            vars      = {expression};
        else
            vars      = regexp(expression,',','split');
            vars{1}   = vars{1}(2:end);
            vars{end} = vars{end}(1:end-1);
        end 
        
        % Some may have to be created?
        data = obj.DB;
        ind  = ismember(vars,data.variables);
        data = createVariable(data,vars(~ind),vars(~ind));
        if isa(obj,'nb_graph_cs')
            data = data.window({},vars); 
        else
            data = data.window('','',vars);        
        end 
        
        % Reset data source
        [message,err] = resetDataSource(plotter,data,true);
        if err
            nb_errorWindow(message)
            return
        end 
        
        % Set needed properties
        try
            optionalInputs = obj.GraphStruct.(fName){fIndex,2};
        catch %#ok<CTCH>
            optionalInputs = {};
        end
        
        nVars = length(vars);
        indC  = find(strcmpi('colorOrder',optionalInputs),1,'last');
        if ~isempty(indC)
            colorOrder = optionalInputs{indC+1};
            colors     = cell(1,2*nVars);
            for ii = 1:nVars
                colors{ii*2-1} = vars{ii};
                colors{ii*2}   = colorOrder{ii};
            end
            optionalInputs{indC+1} = colors;
            optionalInputs{indC}   = 'colors';
        end
        
        indL = find(strcmpi('legends',optionalInputs),1,'last');
        if ~isempty(indL)
            legends = optionalInputs{indL+1};
            legText = cell(1,2*nVars);
            for ii = 1:nVars
                legText{ii*2-1} = vars{ii};
                legText{ii*2}   = legends{ii};
            end
            optionalInputs{indL+1} = legText;
            optionalInputs{indL}   = 'legendText';
        end
        
        % Check for fan chart
        if isa(obj,'nb_graph_ts')
            if isa(obj.fanDatasets,'nb_ts') && ~isempty(obj.fanDatasets)
                fData          = obj.fanDatasets;
                fData          = createVariable(fData,vars(~ind),vars(~ind));
                fData          = fData.window('','',vars);   
                optionalInputs = [optionalInputs,{'fanDatasets',fData,'fanVariable',vars{1}}];
            end
        end
        
        if ~plotter.noTitle 
            expression = '';
        end
        plotter.set('variablesToPlot',vars,'title',expression,optionalInputs{:});
        
    end
    
    % Add it to the nb_GUI as the copied object
    obj.parent.copiedObject = plotter;
            
end
