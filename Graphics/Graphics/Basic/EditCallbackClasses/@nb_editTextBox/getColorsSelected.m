function getColorsSelected(gui)

    obj = gui.parent;

    % Locate or give default color to the variable
    endc = gui.defaultColors;
  
    % Locate the selected text box background color in the color 
    % list
    colorTemp = obj.backgroundColor;
    if ischar(colorTemp)
        colorTemp = nb_plotHandle.interpretColor(colorTemp);
    elseif iscell(colorTemp)
        colorTemp = nb_plotHandle.interpretColor(colorTemp);
    end

    if strcmpi(colorTemp,'none')
        valueC = 1;
    else
        [~,valueC] = ismember(colorTemp,endc,'rows');
        if valueC == 0
            endc              = [endc;colorTemp];
            valueC            = size(endc,1);
            gui.defaultColors = endc;
        end
        valueC = valueC + 1; % 'none' is also added later
    end
    gui.valueColorTBC = valueC;

    % Locate the selected text box edge color in the color list
    colorTemp = obj.edgeColor;
    if ischar(colorTemp)
        colorTemp = nb_plotHandle.interpretColor(colorTemp);
    elseif iscell(colorTemp)
        colorTemp = nb_plotHandle.interpretColor(colorTemp);
    end

    if strcmpi(colorTemp,'none')
        valueC = 1;
    else
        [~,valueC] = ismember(colorTemp,endc,'rows');
        if valueC == 0
            endc              = [endc;colorTemp];
            valueC            = size(endc,1);
            gui.defaultColors = endc;
        end
        valueC = valueC + 1; % 'none' is also added later
    end
    gui.valueColorTEC = valueC;
    
    % Locate the selected font color in the color list
    colorTemp = obj.color;
    if ischar(colorTemp)
        colorTemp = nb_plotHandle.interpretColor(colorTemp);
    elseif iscell(colorTemp)
        colorTemp = nb_plotHandle.interpretColor(colorTemp);
    end

    [~,valueC] = ismember(colorTemp,endc,'rows');
    if valueC == 0
        endc              = [endc;colorTemp];
        valueC            = size(endc,1);
        gui.defaultColors = endc;
    end
    gui.valueColorTC = valueC;
    
    % Using html coding to get the background of the 
    % listbox colored  
    gui.colors = nb_htmlColors(endc);

end
