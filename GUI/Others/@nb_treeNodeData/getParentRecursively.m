function parent = getParentRecursively(treeNode)
% Syntax:
%
% parent = nb_treeNodeData.getParentRecursively(treeNode)
%
% Description:
%
% Get uitree parent of the curren uitreenode object.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if ~isprop(treeNode, 'parent')
        parent = treeNode;
        return
    end
    if isa(treeNode,'matlab.ui.container.Tree')
        parent = treeNode;
        return
    end
    parent = treeNode.Parent;
    while ~isa(parent,'matlab.ui.container.Tree')
        parent = parent.Parent;
    end
    
end
