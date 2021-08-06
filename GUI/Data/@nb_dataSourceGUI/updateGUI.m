function updateGUI(gui)
% Syntax:
%
% updateGUI(gui)
%
% Description:
%
% Part of DAG.
% 
% Update GUI.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if isa(gui.data,'nb_modelDataSource')
        set(gui.sourceSelect, 'String', {'SMART'});
    else

        % Update source selection popup
        gui.sourceLinks = get(gui.data,'links');    
        gui.sourceLinks = gui.sourceLinks;
        sourceList      = {gui.sourceLinks.subLinks.source};

        counter = [];
        for ii = 1:size(sourceList,2)      
            if iscell(sourceList{ii})
                counter = [counter;ones(size(sourceList{ii},2),1)*ii]; %#ok<AGROW>
            else
                counter = [counter;ii]; %#ok<AGROW>
            end      
        end
        gui.linkInfo = counter;
        sourceList   = nb_nestedCell2Cell(sourceList);

        numericSource               = cellfun(@isnumeric,sourceList);
        sourceList(numericSource)   = {'Private'};
        set(gui.sourceSelect, 'String', sourceList);
    
    end
        
    % Update panels
    gui.sourceCallback([], []);
    
end
