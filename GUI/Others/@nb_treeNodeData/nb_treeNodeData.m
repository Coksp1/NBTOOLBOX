classdef nb_treeNodeData < handle
% Description:
%
% A class for storing expanded and selection states when assign to the
% NodeData property of a matlab.ui.container.TreeNode object.
%
% Assign the nb_treeNodeData.collapsedNodeCallback to the NodeCollapsedFcn
% property of the matlab.ui.container.Tree object, and assign 
% nb_treeNodeData.expandNodeCallback to the NodeExpandedFcn.
%
% This object will then store the expanded and selection statuses, so it 
% is possible to refresh a matlab.ui.container.Tree with memory.
% 
% Superclasses:
% handle
%
% Constructor:
%
%   Only default constructor
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen    
    
    properties (SetAccess=protected)

        % The children of this model in the hierarchy, as a vector of 
        % nb_treeNodeData objects
        children

    end

    properties

        % Stores if the node should be drawn or not in the uitree.
        drawn    = false;

        % A function handle called when expandNodeCallback function is
        % called.
        drawFunc = @(t,c,nd)nb_treeNodeData.draw(t,c,nd);

        % Stores the expanded state of this node when it is displayed in
        % a uitree. 
        expanded = false;

        % Stores the selected state of this node when it is displayed in
        % a uitree.
        selected = false;

    end

    methods (Abstract=true)

        % Syntax:
        %
        % text = getText(obj) 
        %
        % Description:
        %
        % Get the text displayed at this node when drawn in a uitree.
        % 
        % Input:
        % 
        % - obj  : A nb_treeNodeData object.
        % 
        % Output:
        % 
        % - text : A one line char
        %
        % Written by Kenneth Sæterhagen Paulsen
        text = getText(obj)

    end

    methods (Static=true)

        varargout = collapsedNodeCallback(varargin)
        varargout = draw(varargin)
        varargout = expandNodeCallback(varargin)
        varargout = getParentRecursively(varargin)

    end

end
