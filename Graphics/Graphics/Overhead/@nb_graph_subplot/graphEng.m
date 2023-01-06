function graphEng(obj,figureHandle,gui) %#ok<INUSD>
% Syntax:
% 
% graphEng(obj)
% 
% Description:
% 
% Plot the graph (english version)
% 
% Input:
% 
% - obj  : An object of class nb_graph_adv
%     
% Output:
% 
% The graph plotted on the screen (english version)
%
% Examples:
%
% obj.graphEng()
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin<3
        gui = 0;
    end

    if nargin < 2
        figureHandle = nb_graphPanel('[4,3]',...
                         'advanced',       1,...
                         'visible',        'on',...
                         'units',          'characters',...
                         'position',       [40   15  220   50],...
                         'Color',          [1 1 1],...
                         'name',           '',...
                         'numberTitle',    'off',...
                         'dockControls',   'off',...
                         'menuBar',        'None',...
                         'toolBar',        'None');
         movegui(figureHandle.figureHandle,'center');
    end

    % Graph the figure
    %--------------------------------------------------------------
    if ~isempty(figureHandle)
        if ~isempty(figureHandle.children)
            % Delete the axes of the past created graph
            childs = figureHandle.children;
            for ii = 1:length(childs)
                childs(ii).deleteOption = 'all';
            end
            delete(figureHandle.children)
        end
        obj.set('figureHandle',figureHandle);
    end
    
    languageTemp  = obj.language;
    pdfBookTemp   = obj.pdfBook;
    obj.pdfBook   = 1;
    obj.language  = 'english';
    
    % Update the graph object
    graph(obj);

    % Save the graph to pdf
    %--------------------------------------------------------------
%     saveFigure(obj);
    
    % Reset some properties
    %--------------------------------------------------------------
    obj.pdfBook  = pdfBookTemp;
    obj.language = languageTemp;
    
end
