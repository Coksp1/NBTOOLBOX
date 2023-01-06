function addAdvancedComponents(obj,language)
% Syntax:
%
% addLegend(obj)
%
% Description:
% 
% Adds figure title and footer if some properties are set.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    switch lower(language)
        case {'norsk','norwegian'}
            addNorwegian(obj);      
        case {'engelsk','english'}
            addEnglish(obj)
    end
    
end

%==========================================================================
function addNorwegian(obj)

    if obj.addAdvanced

        if ~isempty(obj.figTitleObjectNor)

            obj.figTitleObjectNor.parent = obj.figureHandle;

            % Interpret the local variables and functions
            stringOld = obj.figTitleObjectNor.string;
            if isstruct(obj.localVariables)
                stringNew = nb_localVariables(obj.localVariables,stringOld);
            else
                stringNew = stringOld;
            end
            stringNew = nb_localFunction(obj,stringNew);
            if obj.defaultFigureNumbering
                if ischar(stringNew)
                    stringNew = cellstr(stringNew);
                end
                if isempty(stringNew)
                    stringNew = {'Figur 1.1'};
                else
                    stringNew{1} = ['Figur 1.1 ' stringNew{1}];
                end
                stringNew = char(stringNew);
            end 
            obj.figTitleObjectNor.string = stringNew;
            obj.figTitleObjectNor.update();
            obj.figTitleObjectNor.string = stringOld;

        end

        if ~isempty(obj.footerObjectNor)

            obj.footerObjectNor.parent = obj.figureHandle;

            % Interpret the local variables and functions
            stringOld = obj.footerObjectNor.string;
            if isstruct(obj.localVariables)
                stringNew = nb_localVariables(obj.localVariables,stringOld);
            else
                stringNew = stringOld;
            end
            stringNew                  = nb_localFunction(obj,stringNew);
            obj.footerObjectNor.string = stringNew;
            obj.footerObjectNor.update();
            obj.footerObjectNor.string = stringOld;

        end
        
    end
    
    if obj.addExtraText
        graphExtra(obj,'tooltipNor','excelTitleNor','excelFooterNor','footerObjectNor');
    end
            
end

%==========================================================================
function addEnglish(obj)

    if obj.addAdvanced

        if ~isempty(obj.figTitleObjectEng)

            obj.figTitleObjectEng.parent = obj.figureHandle;

            % Interpret the local variables and functions
            stringOld = obj.figTitleObjectEng.string;
            if isstruct(obj.localVariables)
                stringNew = nb_localVariables(obj.localVariables,stringOld);
            else
                stringNew = stringOld;
            end
            stringNew = nb_localFunction(obj,stringNew);
            if obj.defaultFigureNumbering
                if ischar(stringNew)
                    stringNew = cellstr(stringNew);
                end
                if isempty(stringNew)
                    stringNew = {'Chart 1.1'};
                else
                    stringNew{1} = ['Chart 1.1 ' stringNew{1}];
                end
                stringNew = char(stringNew);
            end 

            obj.figTitleObjectEng.string = stringNew;
            obj.figTitleObjectEng.update();
            obj.figTitleObjectEng.string = stringOld;

        end

        if ~isempty(obj.footerObjectEng)

            obj.footerObjectEng.parent = obj.figureHandle;

            % Interpret the local variables and functions
            stringOld = obj.footerObjectEng.string;
            if isstruct(obj.localVariables)
                stringNew = nb_localVariables(obj.localVariables,stringOld);
            else
                stringNew = stringOld;
            end
            stringNew                  = nb_localFunction(obj,stringNew);
            obj.footerObjectEng.string = stringNew;
            obj.footerObjectEng.update();
            obj.footerObjectEng.string = stringOld;

        end
        
    end
    
    if obj.addExtraText
        graphExtra(obj,'tooltipEng','excelTitleEng','excelFooterEng','footerObjectEng');
    end
            
end

%==========================================================================
function graphExtra(obj,tooltip,excelTitle,excelFooter,footer)
    
    posA   = obj.axesHandle.position;
    margin = 1;
    if ~isempty(obj.(tooltip))
        
        % Get location of tooltip
        x = getRightMost(obj.axesHandle) + 0.03;
        x = nb_pos2pos(x,[posA(1),posA(1) + posA(3)],[0,1]);
        y = getYHigh(obj.axesHandle);
        y = nb_pos2pos(y,[posA(2),posA(2) + posA(4)],[0,1]);
        
        % Create text box to include the tooltip in.
        tooltipObj = nb_textBox(...
            'edgeColor',[0,0,0],....
            'margin',margin,...
            'verticalAlignment','top',...
            'units','normalized',...
            'xData',x,...
            'yData',y);
        
        % Interpret the string property
        tooltipStr = obj.(tooltip);
        tooltipStr = cellstr(tooltipStr);
        if ~isempty(obj.lookUpMatrix)
            tooltipStr = nb_graph.findVariableName(obj,tooltipStr);
        end

        % Interpret the local variables syntax
        if ~isempty(obj.localVariables)
            tooltipStr = nb_localVariables(obj.localVariables,tooltipStr);
        end
        tooltipStr    = nb_localFunction(obj,tooltipStr);
        tooltipStr{1} = ['Tooltip: ', tooltipStr{1}];

        % Set the fontUnits to be the same as for the
        % object itself
        set(tooltipObj,...
            'fontUnits',     obj.fontUnits,...
            'fontName',      obj.fontName,...
            'normalized',    obj.normalized,...
            'parent',        obj.axesHandle,...
            'string',        char(tooltipStr),...
            'copyOption',    true);

        % Wrap the text box.
        xR   = nb_pos2pos(0.95,[posA(1),posA(1) + posA(3)],[0,1]);
        posB = [x,0,xR - x,0];
        nb_breakText(tooltipObj.children(1), posB);
        
        
    end
    if ~isempty(obj.(excelTitle))
        
        % Get location of excel title
        [x,y] = getGraphLow(obj,footer,posA);
        
        % Create text box to include the tooltip in.
        titleObj = nb_textBox(...
            'edgeColor',[0,0,0],....
            'margin',margin,...
            'verticalAlignment','top',...
            'units','normalized',...
            'xData',x,...
            'yData',y);
        
        % Interpret the string property
        titleStr = obj.(excelTitle);
        titleStr = cellstr(titleStr);
        if ~isempty(obj.lookUpMatrix)
            titleStr = nb_graph.findVariableName(obj,titleStr);
        end

        % Interpret the local variables syntax
        if ~isempty(obj.localVariables)
            titleStr = nb_localVariables(obj.localVariables,titleStr);
        end
        titleStr    = nb_localFunction(obj,titleStr);
        titleStr{1} = ['Excel title: ', titleStr{1}];

        % Set the fontUnits to be the same as for the
        % object itself
        set(titleObj,...
            'fontUnits',     obj.fontUnits,...
            'fontName',      obj.fontName,...
            'normalized',    obj.normalized,...
            'parent',        obj.axesHandle,...
            'string',        char(titleStr),...
            'copyOption',    true);

        % Wrap the text box.
        xR   = getRightMost(obj.axesHandle);
        %xR   = nb_pos2pos(xR,[posA(1),posA(1) + posA(3)],[0,1]);
        posB = [x,0,xR - x,0];
        nb_breakText(titleObj.children(1), posB);
        
    end
    if ~isempty(obj.(excelFooter))
        
        % Get location of excel title
        if isempty(obj.(excelTitle))
            [x,y] = getGraphLow(obj,footer,posA);
        else
            x    = getLeftMost(obj.axesHandle);
            x    = nb_pos2pos(x,[posA(1),posA(1) + posA(3)],[0,1]);
            tLow = get(titleObj.children(1),'extent');
            y    = tLow(2) - 0.02;
            y    = nb_pos2pos(y,[posA(2),posA(2) + posA(4)],[0,1]);
        end
        
        % Create text box to include the tooltip in.
        footerObj = nb_textBox(...
            'edgeColor',[0,0,0],....
            'margin',margin,...
            'verticalAlignment','top',...
            'units','normalized',...
            'xData',x,...
            'yData',y);
        
        % Interpret the string property
        footerStr = obj.(excelFooter);
        footerStr = cellstr(footerStr);
        if ~isempty(obj.lookUpMatrix)
            footerStr = nb_graph.findVariableName(obj,footerStr);
        end

        % Interpret the local variables syntax
        if ~isempty(obj.localVariables)
            footerStr = nb_localVariables(obj.localVariables,footerStr);
        end
        footerStr    = nb_localFunction(obj,footerStr);
        footerStr{1} = ['Excel footer: ', footerStr{1}];

        % Set the fontUnits to be the same as for the
        % object itself
        set(footerObj,...
            'fontUnits',     obj.fontUnits,...
            'fontName',      obj.fontName,...
            'normalized',    obj.normalized,...
            'parent',        obj.axesHandle,...
            'string',        char(footerStr),...
            'copyOption',    true);

        % Wrap the text box.
        xR   = getRightMost(obj.axesHandle);
        %xR   = nb_pos2pos(xR,[posA(1),posA(1) + posA(3)],[0,1]);
        posB = [x,0,xR - x,0];
        nb_breakText(footerObj.children(1), posB);
        
    end
    
    % Print source type
    if isempty(obj.(excelTitle)) && isempty(obj.(excelFooter))
        [x,y] = getGraphLow(obj,footer,posA);
    elseif isempty(obj.(excelFooter))
        x    = getLeftMost(obj.axesHandle);
        x    = nb_pos2pos(x,[posA(1),posA(1) + posA(3)],[0,1]);
        tLow = get(titleObj.children(1),'extent');
        y    = tLow(2) - 0.02;
        y    = nb_pos2pos(y,[posA(2),posA(2) + posA(4)],[0,1]);
    else
        x    = getLeftMost(obj.axesHandle);
        x    = nb_pos2pos(x,[posA(1),posA(1) + posA(3)],[0,1]);
        tLow = get(footerObj.children(1),'extent');
        y    = tLow(2) - 0.02;
        y    = nb_pos2pos(y,[posA(2),posA(2) + posA(4)],[0,1]);
    end
    
    % Create text box to include the tooltip in.
    sourceObj = nb_textBox(...
        'edgeColor',[0,0,0],....
        'margin',margin,...
        'verticalAlignment','top',...
        'units','normalized',...
        'xData',x,...
        'yData',y);

    % Get the source type
    sources = getSourceList(obj.DB);
    sources = strrep(sources,'\','\\');
    if isempty(sources)
        sources = {'Unknown'};
    end
    sources{1} = ['Source: ', sources{1}];
        
    % Set the fontUnits to be the same as for the
    % object itself
    set(sourceObj,...
        'fontUnits',     obj.fontUnits,...
        'fontName',      obj.fontName,...
        'normalized',    obj.normalized,...
        'parent',        obj.axesHandle,...
        'string',        char(sources),...
        'copyOption',    true);

    % Wrap the text box.
    xR   = getRightMost(obj.axesHandle);
    %xR   = nb_pos2pos(xR,[posA(1),posA(1) + posA(3)],[0,1]);
    posB = [x,0,xR - x,0];
    nb_breakText(sourceObj.children(1), posB);

end

%==========================================================================
function [x,y] = getGraphLow(obj,footer,posA)

    x = getLeftMost(obj.axesHandle);
    x = nb_pos2pos(x,[posA(1),posA(1) + posA(3)],[0,1]);
    if isempty(obj.(footer))
        tLow = inf(1,2); 
    else
        tLow = get(obj.(footer).children,'extent');
        if isempty(tLow)
            tLow = inf(1,2); 
        end
    end
    y = min(getYLow(obj.axesHandle),tLow(2)) - 0.02;
    y = nb_pos2pos(y,[posA(2),posA(2) + posA(4)],[0,1]);

end
