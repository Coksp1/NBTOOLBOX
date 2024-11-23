function collapsedNodeCallback(~,event)
% Syntax:
%
% collapsedNodeCallback(handle,event)
%
% Description:
%
% Callback storing the expand status of the uitree object.
% 
% Written by Kenneth Sæterhagen Paulsen

    if isa(event.Node.NodeData,'nb_treeNodeData')

        event.Node.NodeData.expanded = false;
        
        % Delete children of the children, and mark the children as not
        % drawn
        for ii = 1:length(event.Node.Children)
            if ~isempty(event.Node.Children(ii).Children)
                delete(event.Node.Children(ii).Children);
            end
            event.Node.Children(ii).NodeData.drawn = false;
        end

    end
    
end
