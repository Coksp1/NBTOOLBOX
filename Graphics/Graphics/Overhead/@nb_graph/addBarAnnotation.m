function addBarAnnotation(obj,~,~)
% Syntax:
%
% addBarAnnotation(obj,~,~)
%
% Description:
%
% Add bar annotation to the current graph. Used by DAG.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if isempty(obj.DB)
        nb_errorWindow('Cannot add annotation, because the data of the graph is empty.')
        return
    end

    % Check if we can add a bar annotation object
    ax  = obj.axesHandle;
    ind = zeros(1,size(ax.children,2));
    for ii = 1:size(ax.children,2)

        if isa(ax.children{ii},'nb_bar')
            ind(ii) = 1;
        end

    end

    if ~any(ind)
        nb_errorWindow('Cannot add bar annotation when a bar plot is not graphed.')
        return;
    end

    ann = obj.annotation;
    if ~isempty(ann)
        ind = find(cellfun('isclass',ann,'nb_barAnnotation'),1);
        if ~isempty(ind)
            nb_errorWindow('It is only possible to add one bar annotation object in a graph.')
            return
        end
    end

    % Create an bar annotation object 
    ann = nb_barAnnotation();

    % Assign it to the plotter object
    old = obj.annotation;
    new = [old,{ann}];
    obj.annotation = new;
    obj.graph();

    % Notify listeners
    notify(obj,'updatedGraph');

end
