function getColorsSelected(gui)

    obj = gui.parent;

    % Locate or give default color to the variable
    endc = gui.defaultColors;
  
    % Locate the selected color in the color list
    valueC = nan(1,size(obj.cData,1));
    for ii = 1:size(obj.cData,1)
        
        colorTemp      = obj.cData(ii,:);
        [~,valueC(ii)] = ismember(colorTemp,endc,'rows');
        if valueC(ii) == 0
            endc              = [endc;colorTemp]; %#ok<AGROW>
            valueC(ii)        = size(endc,1);
            gui.defaultColors = endc;
        end
        
    end
    gui.valueColor = valueC;
    
    % Using html coding to get the background of the 
    % listbox colored  
    gui.colors = nb_htmlColors(endc);

end
