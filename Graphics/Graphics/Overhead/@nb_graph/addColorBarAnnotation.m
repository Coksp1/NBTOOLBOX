function addColorBarAnnotation(obj,~,~)
% Syntax:
%
% addColorBarAnnotation(obj,~,~)
%
% Description:
%
% Add text arrow to the current graph. Used by DAG.
%
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    if isempty(obj.DB)
        nb_errorWindow('Cannot add annotation, because the data of the graph is empty.')
        return
    end

    % Create an default arrow object 
    ann = nb_colorbar();

    % Assign it to the plotter object
    old = obj.annotation;
    new = [old,{ann}];
    obj.annotation = new;
    obj.graph();

    % Notify listeners
    notify(obj,'updatedGraph');

end
