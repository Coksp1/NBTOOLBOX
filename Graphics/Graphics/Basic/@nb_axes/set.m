function set(obj,varargin)
% Syntax:
% 
% set(obj,varargin)
% 
% Description:
% 
% Sets the properties of an object of class nb_axes. Give the 
% property name as a string. The input that follows should be the 
% value you want to assign to the property. 
%
% Multple properties could be set with one method call.
% 
% Input:
% 
% - obj      : An object of class nb_axes
% 
% - varargin : Every odd input must be a string with the name of 
%              the property wanted to be set. Every even input must
%              be the value you want to set the given property to.
% 
% Output:
% 
% - obj      : The same object of class nb_axes with the given
%              properties reset
% 
% Examples:
% 
% obj = obj.set('position',[0.1 0.1 0.8 0.8],'xLim',[0,1],...
%               'yLim',[0.1]);
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if numel(obj) > 1
        obj = obj(:);
        for ii = 1:numel(obj)
            set(obj(ii),varargin{:});
        end
        return
    end

    if size(varargin,1) && iscell(varargin{1})
        varargin = varargin{1};
    end

    cleanLegend = false;
    for jj = 1:2:size(varargin,2)

        if ischar(varargin{jj})

            propertyName  = lower(varargin{jj});

            try
                propertyValue = varargin{jj + 1};
            catch  %#ok<CTCH>
                error([mfilename ':: Bad combination of ''propertyName'' propertyValue'])
            end

            switch propertyName
                
                case 'alignaxes'
                    
                    obj.alignAxes = propertyValue;

                case 'axisvisible'

                    obj.axisVisible = propertyValue;

                case 'color'

                    obj.color = propertyValue;

                case 'colormap'
                    
                    obj.colorMap = propertyValue;    
                    
                case 'dashtype'
                    
                    obj.dashType = propertyValue;
                    
                case 'deleteoption'

                    obj.deleteOption = propertyValue;  
                    
                case 'fast'
                    
                    obj.fast = propertyValue;

                case 'findaxislimitmethod'

                    obj.findAxisLimitMethod = propertyValue;

                case 'fontname'

                    obj.fontName = propertyValue;

                case 'fontsize'

                    obj.fontSize = propertyValue;
                    
                case 'fontunits'
                    
                    if isempty(obj.axesHandle)
                        obj.fontUnits = propertyValue;    
                    else
                        t = get(obj.axesLabelHandle,'children');
                        set(t(1),'fontUnits',propertyValue);
                        obj.fontSize  = get(t(1),'fontSize');
                        obj.fontUnits = propertyValue;
                    end

                case 'fontweight'

                    obj.fontWeight = propertyValue;

                case 'grid'

                    obj.grid = propertyValue;

                case 'gridlinestyle'

                    obj.gridLineStyle = propertyValue;

                case 'language'

                    obj.language = propertyValue;
  
                case 'limmode'

                    obj.limMode = propertyValue;

                case 'linewidth'
                    
                    obj.lineWidth = propertyValue;
                    
                case 'normalized'
                    
                    obj.normalized = propertyValue;
                    
                case 'parent'

                    if isa(obj.parent,'nb_figure')
                        % Remove it from its old parent
                        obj.parent.removeAxes(obj);
                    end
                    cleanLegend = true;
                    obj.parent  = propertyValue;

                case 'plotboxaspectratio'
                    
                    obj.plotBoxAspectRatio = propertyValue;
                    
                case 'position'

                    obj.position = propertyValue;
                    cleanLegend  = true;
                    
                case 'precision'
                    
                    obj.precision = propertyValue;
                    
                case 'orientation'
                    
                    obj.orientation = propertyValue;

                case 'scalelinewidth'

                    obj.scaleLineWidth = propertyValue;        
                    
                case 'shading'

                    obj.shading = propertyValue;

                case 'tickdir'

                    obj.tickDir = propertyValue;

                case 'uicontextmenu'  
                    
                    obj.UIContextMenu = propertyValue;
                    
                case 'units'
                    
                    obj.units = propertyValue;
                    
                case 'update'

                    obj.update = propertyValue;

                case 'visible'

%                     if ~isempty(obj.parent)
% 
%                         if strcmpi(get(obj.parent,'visible'),'off')
%                             error([mfilename ':: The parent ''visible'' property is set to ''off'', so it is not possible '...
%                                              'to set the ''visible'' property of any of its children.']);
%                         end  
% 
%                     end

                    obj.visible = propertyValue;

                    % Set the visible property of the children,
                    % whitout replotting them
                    for ii = 1:size(obj.children,2)
                        obj.children{ii}.set('Visible',obj.visible);
                    end

                    for ii = 1:size(obj.horizontalLine,2)
                        obj.horizontalLine{ii}.set('Visible',obj.visible);
                    end

                    for ii = 1:size(obj.verticalLine,2)
                        obj.verticalLine{ii}.set('Visible',obj.visible);
                    end

                    if ~isempty(obj.title)
                        obj.title.setVisible();
                    end

                    if ~isempty(obj.yLabel)
                        obj.yLabel.setVisible();
                    end

                    if ~isempty(obj.yLabelRight)
                        obj.yLabelRight.setVisible();
                    end

                    if ~isempty(obj.xLabel)
                        obj.xLabel.setVisible();
                    end

                case 'xlim'

                    obj.xLim    = propertyValue;
                    if isempty(obj.xLim)
                        obj.xLimSet = 0;
                    else
                        obj.xLimSet = 1;
                    end

                case 'xoffset'

                    obj.xOffset = propertyValue;
                    
                case 'xscale'
                    
                    obj.xScale = propertyValue;

                case 'xtick'

                    obj.xTick    = propertyValue;
                    obj.xTickSet = 1;

                case 'xticklabel'

                    obj.xTickLabel    = propertyValue;
                    if isempty(obj.xTickLabel)
                        obj.xTickLabelSet = 0;
                    else
                        obj.xTickLabelSet = 1;
                    end
                    
                case 'xticklabelalignment'

                    obj.xTickLabelAlignment    = propertyValue;  
                    
                case 'xticklabellocation'

                    obj.xTickLabelLocation    = propertyValue;  

                case 'xticklocation'
                    
                    obj.xTickLocation    = propertyValue;  
                      
                case 'xtickrotation'

                    obj.xTickRotation = propertyValue;

                case 'xtickvisible' 
                    
                    obj.xTickVisible = propertyValue;

                case 'ydir'

                    obj.yDir = propertyValue;

                case 'ydirright'

                    obj.yDirRight = propertyValue;   

                case 'ylim'

                    obj.yLim    = propertyValue;
                    if isempty(obj.yLim)
                        obj.yLimSet = 0;
                    else
                        obj.yLimSet = 1;
                    end

                case 'ylimright'

                    obj.yLimRight    = propertyValue;
                    if isempty(obj.yLimRight)
                        obj.yLimRightSet = 0;
                    else
                        obj.yLimRightSet = 1;
                    end

                case 'yoffset'

                    obj.yOffset = propertyValue; 
                    
                case 'yscale'
                    
                    obj.yScale = propertyValue;    

                case 'ytick'

                    obj.yTick    = propertyValue;
                    obj.yTickSet = 1;

                case 'ytickright'

                    obj.yTickRight    = propertyValue;
                    obj.yTickRightSet = 1;

                case 'yticklabel'

                    obj.yTickLabel = propertyValue;
                    if isempty(obj.yTickLabel)
                        obj.yTickLabelSet = 0;
                    else
                        obj.yTickLabelSet = 1;
                    end

                case 'yticklabelright'

                    obj.yTickLabelRight    = propertyValue;
                    if isempty(obj.yTickLabelRight)
                        obj.yTickLabelRightSet = 0;
                    else
                        obj.yTickLabelRightSet = 1;
                    end
                    
                case 'ytickvisible' 
                    
                    obj.yTickVisible = propertyValue;    

                otherwise

                    error([mfilename ':: Bad property name; ' propertyName ' or you have no access to set it.'])

            end

        end

    end

    % Clean legend in some cases
    if ~isempty(obj.legend)
        if cleanLegend
           obj.legend.clean();
        end
    end
    
    % Then replot given the settings
    graphAxes(obj);

end
