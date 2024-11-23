function saveToFile(gui,~,~)
% Syntax:
%
% saveToFile(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Get the selected file name
    %------------------------------------------------------
    filename = get(gui.edit1,'string');
    
    if isempty(filename)
        nb_errorWindow('You must provide a file name/path.')
        return
    end
    
    % Get extension
    %--------------------------------------------------
    [pathname,filename] = fileparts(filename);

    % Construct the save name
    if isempty(pathname)
        pathname = pwd;
    end
    filename = [pathname,'\',filename,'.mat']; 
    
    % List of graphs
    appGraphs  = gui.parent.graphs;
    graphNames = fieldnames(appGraphs);

    % Get the selected graphs
    index      = get(gui.list1,'value');
    graphNames = graphNames(index);
    if isempty(graphNames)
        nb_errorWindow('No graph selected, so nothing is saved.')
        return
    end
    
    s = struct();
    for ii = 1:length(graphNames)
       s.(graphNames{ii}) = struct(appGraphs.(graphNames{ii}));
    end
    
    % Save down graph as MATLAB object
    save(filename,'-struct','s');
         
    % Close window
    %--------------------------------------------------------------
    delete(gui.figureHandle);

end
