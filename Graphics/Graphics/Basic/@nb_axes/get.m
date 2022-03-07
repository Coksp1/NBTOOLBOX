function propertyValue = get(obj,propertyName)
% Syntax:
% 
% propertyValue = get(obj,propertyName)
% 
% Description:
% 
% Get a property of an object of class nb_axes
% 
% Input:
% 
% - obj           : An object of class nb_axes
% 
% - propertyName  : A string with the propertyName 
% 
% Output:
% 
% - propertyValue : The value of the given property
%     
% Examples:
%
% propertyValue = obj.get('color');
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if ~ischar(propertyName)
        error([mfilename ':: The propertyName must be a string.'])
    end

    switch lower(propertyName)
        
        case 'alignaxes'

            propertyValue = obj.alignAxes;

        case 'axeshandle'

            propertyValue = obj.axesHandle;

        case 'axeshandleright'

            propertyValue = obj.axesHandleRight;
            
        case 'axeslabelhandle'
            
            propertyValue = obj.axesLabelHandle;

        case 'axisvisible'

            propertyValue = obj.axisVisible;

        case 'children'

            propertyValue = obj.children;

        case 'color'

            propertyValue = obj.color;
            
        case 'colormap'

            propertyValue = obj.colorMap;    

        case 'dashtype'
                    
            propertyValue = obj.dashType;    
            
        case 'deleteoption'

            propertyValue = obj.deleteOption;    

        case 'fast'

            propertyValue = obj.fast;      
            
        case 'findaxislimitmethod'

            propertyValue = obj.findAxisLimitMethod;    

        case 'fontname'

            propertyValue = obj.fontName;

        case 'fontsize'

            propertyValue = obj.fontSize;
            
        case 'fontunits'
                    
            propertyValue = obj.fontUnits;       

        case 'fontweight'

            propertyValue = obj.fontWeight;

        case 'grid'

            propertyValue = obj.grid;

        case 'gridlinestyle'

            propertyValue = obj.gridLineStyle;

        case 'highlighted'

            propertyValue = obj.highLighted;

        case 'horizontalline'

            propertyValue = obj.horizontalLine;

        case 'language'

            propertyValue = obj.language;

        case 'legend'

            propertyValue = obj.legend;

        case 'limmode'

            propertyValue = obj.limMode;  
            
        case 'linewidth'

            propertyValue = obj.lineWidth;    
            
        case 'normalized'
            
            propertyValue = obj.normalized; 

        case 'parent'

            propertyValue = obj.parent;

        case 'plotaxeshandle'

            propertyValue = obj.plotAxesHandle;  

        case 'plotaxeshandleright'

            propertyValue = obj.plotAxesHandleRight; 

        case 'plotboxaspectratio'
                    
            propertyValue = obj.plotBoxAspectRatio;    
            
        case 'position'

            propertyValue = obj.position;

        case 'precision'

            propertyValue = obj.precision;
            
        case 'orientation'
            
            propertyValue = obj.orientation;
            
        case 'scalelinewidth'

            propertyValue = obj.scaleLineWidth;    
            
        case 'shading'

            propertyValue = obj.shading;

        case 'shadingaxes'

            propertyValue = obj.shadingAxes;

        case 'tickdir'

            propertyValue = obj.tickDir;

        case 'title'

            propertyValue = obj.title;
            
        case 'units'
            
            propertyValue = obj.units;

        case 'update'

            propertyValue = obj.update;

        case 'verticalline'

            propertyValue = obj.verticalLine;

        case 'visible'

            propertyValue = obj.visible;

        case 'xlabel'

            propertyValue = obj.xLabel;    

        case 'xlim'

            propertyValue = obj.xLim;

        case 'xoffset'

            propertyValue = obj.xOffset;
            
        case 'xscale'
                    
            propertyValue = obj.xScale;    

        case 'xtick'

            propertyValue = obj.xTick;

        case 'xticklabel'

            propertyValue = obj.xTickLabel;

        case 'xticklabelalignment'

            propertyValue = obj.xTickLabelAlignment;  

        case 'xticklabellocation'

            propertyValue = obj.xTickLabelLocation;  

        case 'xticklocation'

            propertyValue = obj.xTickLocation;    

        case 'xtickrotation'

            propertyValue = obj.xTickRotation; 
            
        case 'xtickvisible' 
                    
            propertyValue = obj.xTickVisible;        

        case 'ydir'

            propertyValue = obj.yDir;

        case 'ydirright'

            propertyValue = obj.yDirRight;     

        case 'ylabel'

            propertyValue = obj.yLabel;

        case 'ylabelright'

            propertyValue = obj.yLabelRight;    

        case 'ylim'

            propertyValue = obj.yLim;

        case 'ylimright'

            propertyValue = obj.yLimRight;

        case 'yoffset'

            propertyValue = obj.yOffset;
            
        case 'yscale'
                    
            propertyValue = obj.yScale;    

        case 'ytick'

            propertyValue = obj.yTick;

        case 'ytickright'

            propertyValue = obj.yTickRight;

        case 'yticklabel'

            propertyValue = obj.yTickLabel;

        case 'yticklabelright'

            propertyValue = obj.yTickLabelRight;

        case 'ytickvisible' 
                    
            propertyValue = obj.yTickVisible;    
            
        otherwise

            error([mfilename ':: Bad property name; ' propertyName])

    end

end
