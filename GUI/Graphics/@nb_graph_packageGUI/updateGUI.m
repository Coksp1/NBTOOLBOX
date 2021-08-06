function updateGUI(gui,varargin)
% Syntax:
%
% updateGUI(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen
    
    % Get list of figure names
    pkg     = gui.package;
    idents  = pkg.identifiers;
    
    if isempty(idents)
        % No graphs in graph package (new graph package)
        list = idents;
    else
        % Numbering graphs in graph package
        numObj  = nb_numbering(pkg.start,pkg.chapter,'english',pkg.bigLetter);
        figNums = figNumsAsCell(numObj,length(idents));
        list    = strcat(figNums,{' '},idents');
    end
        
    set(gui.graphList,'String',list);

end
