function calculateCallback(gui,hObject,~)
% Syntax:
%
% calculateCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Get the upper and lower bounds selected
    string = get(gui.edit1,'string');
    low    = round(str2double(string));
    string = get(gui.edit4,'string');
    high   = round(str2double(string));

    if isnan(high)
        nb_errorWindow('The upper bound of the band pass filter must be a number greater than 0.')
        return
    elseif high <= 0
        nb_errorWindow('The upper bound of the band pass filter must be a number greater than 0.')
        return
    end
    
    if isnan(low)
        nb_errorWindow('The lower bound of the band pass filter must be a number greater than 0.')
        return
    elseif low <= 0
        nb_errorWindow('The lower bound of the band pass filter must be a number greater than 0.')
        return
    end
    
    if low >= high
        nb_errorWindow('The lower bound on the band-pass filter must be lower than the upper bound.')
        return
    end
    
    % Get postfixes
    gapPostfix   = get(gui.edit2,'string');
    trendPostfix = get(gui.edit3,'string');
    
    if isempty(gapPostfix)
        nb_errorWindow('The gap postfix cannot be empty.')
        return
    end
    
    if isempty(trendPostfix)
        nb_errorWindow('The trend postfix cannot be empty.')
        return
    end
    
    message = nb_checkPostFix(gapPostfix);
    if ~isempty(message)
        nb_errorWindow(message);
        return
    end
    
    message = nb_checkPostFix(trendPostfix);
    if ~isempty(message)
        nb_errorWindow(message);
        return
    end
    
    % Check what to return
    retTrend = get(gui.rb2,'value');
    retGap   = get(gui.rb1,'value');
    retGraph = get(gui.rb4,'value');

    % Get the selected variables
    string = get(gui.list1,'string');
    index  = get(gui.list1,'value');
    vars   = string(index);
    
    % Get if the filter should be 1 or 2 sided
    oneSided = get(gui.rb3,'value');
    
    % Select method
    if oneSided
        if temp.numberOfObservations < 5
            nb_errorWindow('The dataset must have at least 5 observations for doing one-sided band pass-filter.')
            return
        end
        method = 'bkfilter1s';
    else
        method = 'bkfilter';
    end

    % Calculate
    d = gui.data;
    if retTrend
        try
            d = extMethod(d, 'detrend', vars, trendPostfix, method, 'trend', low, high);
        catch %#ok<CTCH>
            nb_errorWindow(['To add the selected trend postfix will result in conflicting variable names. '...
                            'Select another postfix!'])
            return
        end    
    end
    
    if retGap 
        try
            d = extMethod(d, 'detrend', vars, gapPostfix, method, 'gap', low, high);
        catch %#ok<CTCH>
            nb_errorWindow(['To add the selected gap postfix will result in conflicting variable names. '...
                            'Select another postfix!'])
            return
        end
    end
    
    % Notify listeners that the calculation are done
    gui.data = d;
    notify(gui,'methodFinished');
    
    % Close window
    close(get(hObject,'parent'));
    
    % Create graph if wanted
    if retGraph
        
        d = extMethod(gui.data, 'detrend', vars, trendPostfix, method, 'trend', low, high);
        d = extMethod(d, 'detrend', vars, gapPostfix, method, 'gap', low, high);
        
        % Get the expression to be graphed
        %--------------------------------------------------------------
        plottedVar = cell(1,length(vars)*2);
        for ii = 1:length(vars)

            plottedVar{ii*2 - 1} = ['[' vars{ii} ',' vars{ii} trendPostfix ']'];
            plottedVar{ii*2}     = [vars{ii},gapPostfix];

        end
        
        % Create the GraphStruct input to the nb_graph_ts class
        %----------------------------------------------------------
        GraphStruct = struct();
        for ii = 1:length(vars)

            field = strrep(vars{ii},' ','_');
            GraphStruct.(field) = {plottedVar{ii*2 - 1},  {'title', vars{ii}, 'colorOrder',{'black','red'},'legends',{'Raw Data','Trend'}};
                                   plottedVar{ii*2},{'title', vars{ii}, 'colorOrder',{'blue'},'legends',{'Gap'}}};

        end
        
        % Initilize nb_graph_ts object
        %----------------------------------------------------------
        plotter = nb_graph_init(d);
        plotter.set('GraphStruct',GraphStruct,'baseline',0);
        
        % Create a window to display the graphs
        %----------------------------------------------------------
        nb_graphInfoStructGUI(plotter,gui.parent);
        
    end
    
end
