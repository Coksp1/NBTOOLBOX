function finishUp(gui,~,~)
% Syntax:
%
% finishUp(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Get the already stored graphs
    appGraphs = gui.parent.graphs;
    locVar    = gui.parent.settings.localVariables;

    % Get the already stored data
    stored        = fieldnames(gui.graphs);
    currentGraphs = fieldnames(appGraphs);
    ind           = ismember(stored,currentGraphs);
    updated       = stored(ind);
    added         = stored(~ind);
    
    % Overwrite existing dataset
    for ii = 1:length(stored)
        temp = gui.graphs.(stored{ii});
        setSpecial(temp,'localVariables',locVar);
        appGraphs.(stored{ii}) = temp;
    end

    % Assign it to the main GUI object so I can use it later. This will
    % also make it display in the list of the GUI, see nb_GUI.set.graphs
    gui.parent.graphs = appGraphs;

    % Then we need to check for graphs used in packages, and update them
    % accordingly
    appPackages = gui.parent.graphPackages;
    packages    = fieldnames(appPackages);
    for ii = 1:length(packages)
        
        packageT = appPackages.(packages{ii}); % We don't need to push it back as it is a handle
        for jj = 1:length(stored)
        
            ind = find(strcmpi(stored{jj},packageT.identifiers),1);
            if ~isempty(ind)
                packageT.graphs{ind} = copy(appGraphs.(stored{jj}));
            end
            
        end
        
    end
    
    % Delete import window
    delete(gui.figureHandle)
    
    % Provide some information
    nb_infoWindow(['The following graphs has been updated; ' nb_cellstr2String(updated,', ',' and ') ' (If '...
                   'they are included in a package this has also been synced), and '...
                   'the following graphs has been added; ' nb_cellstr2String(added,', ',' and ') '.'])

               
    % Notify listeners
    notify(gui,'importingDone');
    
end
