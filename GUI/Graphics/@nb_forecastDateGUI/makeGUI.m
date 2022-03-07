function makeGUI(gui)
% Syntax:
%
% makeGUI(gui)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    plotterAdv = gui.plotter;
    if isa(plotterAdv.plotter(1).parent,'nb_GUI')
        name = [plotterAdv.plotter(1).parent.guiName ': Forecast Date'];
    else
        name = 'Forecast Date';
    end
    
    % GUI window
    %--------------------------------------------------------------
    currentMonitor    = nb_getCurrentMonitor();
    defaultBackground = get(0,'defaultUicontrolBackgroundColor');
    f = figure('visible',        'off',...
                  'units',          'characters',...
                  'position',       [65   15  75   25],...
                  'Color',          defaultBackground,...
                  'name',           name,...
                  'numberTitle',    'off',...
                  'menuBar',        'None',...
                  'toolBar',        'None',...
                  'resize',         'off',...
                  'windowStyle',    'modal');
    movegui(f,'center');
    nb_moveFigureToMonitor(f,currentMonitor);
    gui.figureHandle = f;
          
    % Get variables of the plot
    %--------------------------------------------------------------
    plotter = plotterAdv.plotter;
    vars    = {};
    for ii = 1:size(plotter,2)
        
        % Get normal variables
        vars = [vars, plotter(ii).getPlottedVariables()]; %#ok<AGROW>
        
        % Get fan layers variables
        if isa(plotter(ii),'nb_graph_ts')

            if ~isempty(get(plotter(ii),'fanData')) && strcmpi(plotter(ii).plotType,'line')

                % Get the percentiles
                num     = length(plotter(ii).fanPercentiles);
                textPer = cell(1,num*2); 
                for jj = 1:num

                    number = plotter(ii).fanPercentiles(jj);
                    number = num2str(number);
                    loc    = strfind(number,'.');
                    number = number(loc + 1:end);

                    if size(number,2) == 1
                        number = [number '0']; %#ok
                    end

                    textPer{jj}       = ['Lower ' number '%'];
                    textPer{num + jj} = ['Upper ' number '%'];

                end
                vars = [vars,textPer]; %#ok<AGROW>

            end

        end
        
    end
    
    if isempty(vars)
        nb_errorWindow('Not possible to set the forecast date option when the plot is empty.')
        close(f);
        return
    end
    
    % Interpret the old forecastDate property
    %--------------------------------------------------------------
    s            = size(vars,2);
    forecastDate = plotterAdv.forecastDate;
    if isempty(forecastDate)
        fcstDEdit = repmat({''},size(vars,2),1);
    elseif ischar(forecastDate) 
        fcstDEdit = repmat({forecastDate},s,1);
    else  
        fcstDEdit = cell(size(vars,2),1);
        for ii = 1:size(forecastDate,2)/2
            var = forecastDate{ii*2 - 1};
            ind = find(strcmp(var,vars),1,'last');
            if ~isempty(ind)
                date           = forecastDate{ii*2};
                fcstDEdit{ind} = date;
            end
        end
    end
    
    % Ensure the format {'var1','forecastDate1',...}
    temp  = cell(1,s*2);
    for ii = 1:s
        temp{ii*2 - 1} = vars{ii};
        temp{ii*2    } = fcstDEdit{ii};
    end
    plotterAdv.forecastDate = temp;
        
    % Create table with forecast date options
    %--------------------------------------------------------------
    tableData = [vars',fcstDEdit];
    colNames  = {'Variables','First Forecast Date (Can be empty)'};
    colEdit   = [false,true];
    colForm   = cell(1,2);
    colForm(:)= {'char'};
    nb_uitable(f,...
            'units',                'normalized',...
            'position',             [0 0 1 1],...
            'data',                 tableData,...
            'columnName',           colNames,...
            'columnFormat',         colForm,...
            'columnEdit',           colEdit,...
            'cellEditCallback',     @gui.cellEdit);
        
    % Make figure visible
    %--------------------------------------------------------------
    set(f,'visible','on')
          
end
