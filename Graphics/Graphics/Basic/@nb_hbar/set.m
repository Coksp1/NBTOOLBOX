function set(obj,varargin)
% Syntax:
% 
% set(obj,varargin)
% 
% Description:
% 
% Sets the properties of an object of class nb_bar. Give the 
% property name as a string. The input that follows should be the 
% value you want to assign to the property. 
%
% Multple properties could be set with one method call.
% 
% Input:
% 
% - obj      : An object of class nb_bar
% 
% - varargin : Every odd input must be a string with the name of 
%              the property wanted to be set. Every even input must
%              be the value you want to set the given property to.
% 
% Output:
% 
% - obj      : The same object of class nb_bar with the given
%              properties reset
% 
% Examples:
% 
% obj.set('propertyName',propertyValue,...);
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if size(varargin,1) && iscell(varargin{1})
        varargin = varargin{1};
    end

    for jj = 1:2:size(varargin,2)

        if ischar(varargin{jj})

            propertyName  = lower(varargin{jj});
            propertyValue = varargin{jj + 1};

            switch propertyName

                case 'alpha1'

                    obj.alpha1 = propertyValue;
                
                case 'alpha2'

                    obj.alpha2 = propertyValue;    
                
                case 'barwidth'

                    obj.barWidth = propertyValue;

                case 'basevalue'

                    obj.baseValue = propertyValue;

                case 'blend'

                    obj.blend = propertyValue;        
                    
                case 'cdata'

                    obj.cData = propertyValue;

                case 'deleteoption'

                    obj.deleteOption = propertyValue;    

                case 'direction'

                    obj.direction = propertyValue; 

                case 'edgecolor'

                    obj.edgeColor = propertyValue;  

                case 'legendinfo'

                    obj.legendInfo = propertyValue;     

                case 'linestyle'

                    obj.lineStyle = propertyValue;

                case 'linewidth'

                    obj.lineWidth = propertyValue;    

                case 'parent'

                    if isa(obj.parent,'nb_axes')
                        % Remove it from its old parent
                        obj.parent.removeChild(obj);  
                    end
                    
                    if isa(propertyValue,'nb_axes')
                        obj.parent = propertyValue;
                    else
                        error([mfilename ':: The ''parent'' property must be set to an object of class nb_axes.'])
                    end

                case 'shadecolor'

                    obj.shadeColor = propertyValue;

                case 'shaded'

                    obj.shaded = propertyValue;
                    
                case 'side'
                    
                    obj.side = propertyValue;

                case 'style'

                    obj.style = propertyValue;

                case 'sumto'

                    obj.sumTo = propertyValue;    

                case 'visible'

                    obj.visible = propertyValue;

                case 'xdata'

                    obj.xData = propertyValue;

                case 'ydata'

                    obj.yData = propertyValue;

                otherwise

                    error([mfilename ':: Bad property name; ' propertyName])

            end

        end

    end

    % Then replot given the settings
    plotBars(obj);

end
