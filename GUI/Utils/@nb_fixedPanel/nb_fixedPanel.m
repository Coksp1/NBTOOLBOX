classdef nb_fixedPanel < handle
% Description:
%
% A class for creating a tab panels.
%
% Superclasses:
%
% nb_settable, handle
%
% Constructor:
%
%   obj = nb_fixedPanel
%   obj = nb_fixedPanel(parent,num,dimension)
% 
%   Input:
%
%   - parent   : A figure, uipanel handle or nb_figure object.
%
%   Output:
% 
%   - obj      : An nb_fixedPanel object.
% 
%   Examples:
%
%   h = nb_fixedPanel();
% 
% See also:
% uipanel, figure, nb_figure
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    properties 
        
        % Are the given dimension of the added panels fixed? Must be set 
        % to a 1  x nChildren logical. 
        fixed       = [];
        
        % Default is minimum 10 pixels for non-fixed panels! Must be set 
        % to a 1  x nChildren double. (The values that corresponds to the
        % fixed panels will not be used!) 
        minimum     = [];
        
        % The weights of each panel. Must be set to a 1  x nChildren
        % double. 
        weights     = [];
        
    end

    properties (SetAccess=protected) 
   
        % Index of the active tab panel.
        children    = [];
        
        % Parent handle
        parent      = [];
        
        % The positions of the children in pixels, as a N x 4 double.
        position    = [];
        
        % Dimension to fix sizes
        dimension   = 'y';
        
    end
        
    methods
        
        function obj = nb_fixedPanel(parent,num,dimension)
            
            if nargin < 3
                dimension = 'y';
                if nargin < 2
                    num = 3;
                    if nargin < 1
                        parent = figure();
                    end
                end
            end
            if isempty(parent)
                parent = figure();
            end
            
            if not(nb_isFigure(parent) || nb_isUipanel(parent) || isa(parent,'nb_figure'))
                error([mfilename ':: The parent input must be a figure or uipanel handle.'])
            end
            obj.parent   = parent;
            if isa(parent,'nb_figure')
                addlistener(obj.parent,'resized',@obj.resizeCallback);
                parent = parent.figureHandle;
            else
                set(obj.parent,'resizeFcn',@obj.resizeCallback);
            end
            
            % Set default position for the different panels.
            obj.children = nb_gobjects(1,num);
            eSize        = 1/num;
            if strcmpi(dimension,'x')
                pos      = [0,0,eSize,1];
                pos      = pos(ones(num,1),:);
                pos(:,1) = eSize.*(0:num-1);
            else
                pos      = [0,0,1,eSize];
                pos      = pos(ones(num,1),:);
                pos(:,2) = eSize.*(0:num-1);
            end
            for ii = 1:num
                obj.children(ii) = uipanel(parent,'units','normalized','position',pos(ii,:),'BorderType','none');
            end
            
            % Store information needed when figure is resized.
            obj.dimension = dimension;
            obj.fixed     = false(1,num);
            obj.minimum   = ones(1,num)*10; 
            obj.weights   = eSize(1,ones(1,num));
            posP          = nb_getInUnits(obj.children, 'position','pixels');
            obj.position  = vertcat(posP{:});
            
        end
        
        function set.minimum(obj,value)
            
            if isempty(obj.minimum)
                % Called in the constructor.
                obj.minimum = value;
                return
            end
            
            num = size(obj.minimum,2);
            if ~nb_sizeEqual(value,[1,num])
                error([mfilename ':: The minimum must set to 1x' int2str(num) '.'])
            end
            obj.minimum = nb_rowVector(value);
            resizeCallback(obj,[],[]);
            
        end
        
        function set.weights(obj,value)
        % Set method for the weights property
            
            if isempty(obj.weights)
                % Called in the constructor.
                obj.weights = value;
                return
            end
            
            num = size(obj.weights,2);
            if ~nb_sizeEqual(value,[1,num])
                error([mfilename ':: The weights must set to 1x' int2str(num) '.'])
            end
            value       = value/sum(value); % Must sum to one
            obj.weights = nb_rowVector(value);
            update(obj);
            
        end
        
        function update(obj)
        % Update positions given changed weights
        
            pos = get(obj.children,'position');
            pos = vertcat(pos{:});
            if strcmpi(obj.dimension,'x')
                pos(:,3)     = obj.weights;
                pos(2:end,1) = pos(1,1) + cumsum(pos(1:end-1,3));
            else
                pos(:,4)     = obj.weights;
                pos(2:end,2) = pos(1,2) + cumsum(pos(1:end-1,4));
            end
            for ii = 1:size(obj.children,2)
                set(obj.children(ii),'position',pos(ii,:));
            end
            posP          = nb_getInUnits(obj.children, 'position','pixels');
            obj.position  = vertcat(posP{:});
            
        end
        
        function resizeCallback(obj,~,~)
        % Callback function called when figure is resized.
        
            if ~any(obj.fixed)
                return
            end
            
            if strcmpi(obj.dimension,'x')
                pInd = 1;
                dInd = 3;
            else
                pInd = 2;
                dInd = 4;
            end
            
            % Find out if any of the panels has change their position
            fPos    = nb_getInUnits(obj.parent, 'position','pixels');
            posP    = nb_getInUnits(obj.children, 'position','pixels');
            posP    = vertcat(posP{:});
            totNotF = fPos(dInd) - sum(obj.position(obj.fixed,dInd));
            diff    = totNotF - sum(obj.position(~obj.fixed,dInd));
            if abs(diff) < eps^(0.5)
                % No big change, so we just return
                return
            end

            % Calculate the new positions
            posNotFixed           = posP(~obj.fixed,dInd);
            posNotFixed           = posNotFixed + diff/sum(~obj.fixed);
            minNotFixed           = obj.minimum(~obj.fixed);
            ind                   = posNotFixed < minNotFixed;
            posNotFixed(ind)      = minNotFixed(ind);
            posP(~obj.fixed,dInd) = posNotFixed;
            posP(obj.fixed,dInd)  = obj.position(obj.fixed,dInd);
            posP(2:end,pInd)      = posP(1,pInd) + cumsum(posP(1:end-1,dInd));
            obj.position          = posP;
            if any(ind)
                % Figure cannot be made smaller, so fix the figure size
                % at its current size.
                oldUnits   = get(obj.parent,'units');
                set(obj.parent,'units','pixels');
                fPos       = get(obj.parent,'position');
                fPos(dInd) = obj.position(end,pInd) + obj.position(end,dInd);
                set(obj.parent,'position',fPos);
                set(obj.parent,'units',oldUnits);
            end

            % Update the new positions
            set(obj.children,'units','pixels');
            for ii = 1:size(obj.children,2)
                set(obj.children(ii),'position',obj.position(ii,:));
            end
            set(obj.children,'units','normalized');
            
        end
        
    end
    
    methods (Static=true)
        
        function h = testY()
            
            h      = nb_fixedPanel([],2);
            childs = h.children;
            for ii = 1:size(childs,2)
                set(childs(ii),'background',rand(1,3));
            end
            h.fixed(2) = true;
            h.weights  = [0.9,0.1];
            
        end
        
        function h = testY3()
            
            h      = nb_fixedPanel();
            childs = h.children;
            for ii = 1:size(childs,2)
                set(childs(ii),'background',rand(1,3));
            end
            h.fixed([1,3]) = true; 
            
        end
        
        function h = testX()
            
            h      = nb_fixedPanel([],2,'x');
            childs = h.children;
            for ii = 1:size(childs,2)
                set(childs(ii),'background',rand(1,3));
            end
            h.fixed(2) = true;
            h.weights  = [0.9,0.1];
            
        end
        
        
    end
        
end
