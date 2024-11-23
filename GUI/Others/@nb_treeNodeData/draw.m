function selectedNode = draw(tree,currentNode,children)
% Syntax:
%
% selectedNode = nb_treeNodeData.draw(tree,children)
%
% Description:
%
% Draw nodes of the children.
%
% - tree        : A uitree handle.
%
% - currentNode : A uitreenode handle.
% 
% Written by Kenneth Sæterhagen Paulsen

    selectedNode = [];
    for ii = 1:length(children)

        % Get name of node
        name = getText(children(ii));

        % Add node
        thisNode = uitreenode(currentNode,...
            'Text',    name,...
            'NodeData',children(ii));

        % Add children (If this node is displayed)
        if ~nb_isempty(children(ii).children) && children(ii).drawn
            selectedNodeThis = addTreeNodes(tree,thisNode,children(ii).children);
        else
            selectedNodeThis = [];
        end

        % Expand tree node
        if children(ii).expanded
            expand(thisNode)
        end

        % Is this the node that has been selected
        if isempty(selectedNode)
            if children(ii).selected
                selectedNode = thisNode;
            else
                selectedNode = selectedNodeThis;
            end
        end

    end
    
end
