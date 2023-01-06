classdef nb_legendDetails
% Syntax:
%     
% obj = nb_legendDetails()
%     
% Description:
%     
% This is a class for storing information of how the legend should
% look.
% 
% Constructor:
%     
%     obj = nb_legendDetails()
%
%     Input:
%
%     No inputs.
%    
%     Output:
% 
%     - obj : An object of class nb_legendDetails
%     
%     Examples:
%     
% See also:
% nb_legend
%     
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen


    %======================================================================
    % Properties of the class
    %======================================================================
    properties
        
        fontColor              = [0,0,0];
        lineColor              = [0 0 0];
        lineStyle              = '-';
        lineWidth              = 1;
        lineMarker             = 'none';
        lineMarkerEdgeColor    = 'auto';
        lineMarkerFaceColor    = 'auto';
        lineMarkerSize         = 9;
        patchColor             = [0 0 0];
        patchDirection         = 'north';
        patchEdgeColor         = 'same';
        patchEdgeLineStyle     = '-';
        patchEdgeLineWidth     = 1;
        patchFaceAlpha         = 1;
        patchFaceLighting      = 'none';
        side                   = 'left';
        type                   = 'line';
        
    end
    
    %======================================================================
    % Accessible methods
    %======================================================================
    methods
        
        %{
        -------------------------------------------------------------------
        An empty constructor of the nb_legendDetails class
        -------------------------------------------------------------------
        %}
        function obj = nb_legendDetails()
            
        end
        
        function handles = plot(obj,x,y,t,ty,leg,ax,string,fontU,fontS)
            
            if ischar(obj.fontColor)
                obj.fontColor = nb_plotHandle.interpretColor(obj.fontColor);
            end

            h = text(x(2)+ t, y(2) + ty, string, ...
                     'fontUnits',           fontU,...
                     'fontSize',            fontS,...
                     'color',               obj.fontColor,...
                     'fontWeight',          leg.fontWeight,...
                     'fontName',            leg.fontName,...
                     'interpreter',         leg.interpreter,...
                     'horizontalAlignment', 'left',...
                     'verticalAlignment',   'top',...
                     'parent',              ax,...
                     'visible',             leg.visible);
            
            if strcmpi(obj.lineMarkerFaceColor,'auto')
                markerFaceColor = obj.lineColor;
            else
                markerFaceColor = obj.lineMarkerFaceColor;
            end
            
            switch obj.type
                
                case 'line'
                    
                    if strcmp(obj.lineStyle,'---')

                        handles    = cell(1,4);
                        handles{1} = h;
                        
                        % I need to plot the line in to steps so it looks nice
                        x1 = [x(1), x(1) + (x(2) - x(1))*(3/5)];
                        x2 = [x(1) + (x(2) - x(1))*(4/5), x(1) + (x(2) - x(1))*(5/5)];

                        h = line(x1,y,...
                                 'clipping',     'off',...
                                 'color',        obj.lineColor,...
                                 'lineStyle',    '-',...
                                 'lineWidth',    obj.lineWidth,...
                                 'parent',       ax,...
                                 'visible',      leg.visible);
            
                        handles{2} = h;
                        
                        h = line(x2,y,...
                                 'clipping',     'off',...
                                 'color',        obj.lineColor,...
                                 'lineStyle',    '-',...
                                 'lineWidth',    obj.lineWidth,...
                                 'parent',       ax,...
                                 'visible',      leg.visible);
           
                        handles{3} = h;
                             
                        % I need the marker to be centered                                          
                        h = line([x(1) + (x(2)-x(1))/2,x(1) + (x(2)-x(1))/2],y,...
                                 'clipping',        'off',...
                                 'color',           obj.lineColor,...
                                 'lineStyle',       'none',...
                                 'marker',          obj.lineMarker,...
                                 'markerSize',      obj.lineMarkerSize,...
                                 'markerEdgeColor', obj.lineMarkerEdgeColor,...
                                 'markerFaceColor', markerFaceColor,...
                                 'parent',          ax,...
                                 'visible',         leg.visible);
                             
                        handles{4} = h;      

                    else

                        h = line(x,y,...
                                 'clipping',     'off',...
                                 'color',        obj.lineColor,...
                                 'lineStyle',    obj.lineStyle,...
                                 'lineWidth',    obj.lineWidth,...
                                 'parent',       ax,...
                                 'visible',      leg.visible);

                        handles    = cell(1,1);     
                        handles{1} = h;

                        % I need the marker to be centered                                                
                        h = line([x(1) + (x(2)-x(1))/2,x(1) + (x(2)-x(1))/2],y,...
                                 'clipping',        'off',...
                                 'color',           obj.lineColor,...
                                 'lineStyle',       'none',...
                                 'marker',          obj.lineMarker,...
                                 'markerSize',      obj.lineMarkerSize,...
                                 'markerEdgeColor', obj.lineMarkerEdgeColor,...
                                 'markerFaceColor', markerFaceColor,...
                                 'parent',          ax,...
                                 'visible',         leg.visible);
                                     
                        handles{2} = h;           

                    end
                    
                case 'patch'
                    
                    set(h,'units','data');     
                    extent     = get(h,'extent');
                    s          = size(string,1);
                    ht         = extent(4)/s;
                    ht         = ht/2;
                    handles    = cell(1,2);
                    handles{1} = h;
                    
                    if strcmpi(obj.patchEdgeColor,'same')
                        edgeColor = obj.patchColor(1,:);
                    else
                        edgeColor = obj.patchEdgeColor;
                    end
                    
                    xP = [x(1), x(1), x(2), x(2)];
                    yP = [y(1) - ht/2, y(1) + ht/2, y(1) + ht/2, y(1) - ht/2];

                    h = nb_patch(xP,yP,obj.patchColor,...
                                 'clipping',        'off',...
                                 'direction',       obj.patchDirection,...
                                 'edgeColor',       edgeColor,...
                                 'faceAlpha',       obj.patchFaceAlpha,...
                                 'faceLighting',    obj.patchFaceLighting,...
                                 'lineStyle',       obj.patchEdgeLineStyle,...
                                 'lineWidth',       obj.patchEdgeLineWidth,...
                                 'parent',          ax,...
                                 'visible',         leg.visible);       
                    handles{2} = h;          
                    
                case 'dot'
                    
                    set(h,'units','data');     
                    extent     = get(h,'extent');
                    ht         = extent(4)/2;
                    handles    = cell(1,2);
                    handles{1} = h;
                    
                    if strcmpi(obj.patchEdgeColor,'same')
                        edgeColor = obj.patchColor(1,:);
                    else
                        edgeColor = obj.patchEdgeColor;
                    end
                    
                    xe = diff(x)/3;
                    xP = [x(1)+xe, x(1)+xe, x(2)-xe, x(2)-xe];
                    yP = [y(1)-ht*1/2, y(1)+ht*1/2, y(1)+ht*1/2, y(1)-ht*1/2];

                    h = nb_patch(xP,yP,obj.patchColor,...
                                 'clipping',        'off',...
                                 'direction',       obj.patchDirection,...
                                 'edgeColor',       edgeColor,...
                                 'faceAlpha',       obj.patchFaceAlpha,...
                                 'faceLighting',    obj.patchFaceLighting,...
                                 'lineStyle',       obj.patchEdgeLineStyle,...
                                 'lineWidth',       obj.patchEdgeLineWidth,...
                                 'parent',          ax,...
                                 'visible',         leg.visible);
                             
                    handles{2} = h;    
                    
                otherwise
                    
                    error([mfilename ':: Only ''line'', ''dot'' and ''path'' are supported types of this class.'])
                    
            end
            
        end
        
    end
    
    
    %======================================================================
    % Protected methods
    %======================================================================
    methods (Access=protected)
        
       
        
    end
    
    %======================================================================
    % Static methods of the class
    %======================================================================
    methods (Static=true)
        
        
        
    end
     
end
