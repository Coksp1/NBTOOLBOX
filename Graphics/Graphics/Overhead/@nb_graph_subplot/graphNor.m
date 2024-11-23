function graphNor(obj,figureHandle,gui) %#ok<INUSD>
% Syntax:
% 
% graphNor(obj)
% 
% Description:
% 
% Plot the graph (norwegian )
% 
% Input:
% 
% - obj  : An object of class nb_graph_adv
%     
% Output:
% 
% The graph plotted on the screen (norwegian version)
%
% Examples:
%
% obj.graphNor()
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

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
    obj.language  = 'norsk';
    
    % Update the graph object
    graph(obj);

    % Reset some properties
    %--------------------------------------------------------------
    obj.pdfBook  = pdfBookTemp;
    obj.language = languageTemp;
    
end
