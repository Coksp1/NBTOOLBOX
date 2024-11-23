function expandNodeCallback(~,event)
% Syntax:
%
% expandNodeCallback(handle,event)
%
% Description:
%
% Callback storing the expand status of the uitree object.
% 
% Written by Kenneth Sæterhagen Paulsen

    if isa(event.Node.NodeData,'nb_treeNodeData')
        
        event.Node.NodeData.expanded = true;

        % Draw the children of the children, and mark the children as
        % drawn
        if ~isempty(event.Node.Children)

            tree = nb_treeNodeData.getParentRecursively(event.Node);
            for ii = 1:length(event.Node.Children)
                if ~isempty(event.Node.Children(ii).NodeData.children)
                    childs = event.Node.Children(ii).NodeData.children;
                    event.Node.Children(ii).NodeData.drawFunc(tree,...
                        event.Node.Children(ii),childs);
                end
                event.Node.Children(ii).NodeData.drawn = true;
            end

        end

    end

end
