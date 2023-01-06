function set(obj,varargin)
% Syntax:
% 
% set(obj,varargin)
% 
% Description:
% 
% Sets the properties of an object of class nb_candle. Give the 
% property name as a string. The input that follows should be the 
% value you want to assign to the property. 
%
% Multple properties could be set with one method call.
% 
% Input:
% 
% - obj      : An object of class nb_candle
% 
% - varargin : Every odd input must be a string with the name of 
%              the property wanted to be set. Every even input must
%              be the value you want to set the given property to.
% 
% Output:
% 
% - obj      : The same object of class nb_candle with the given
%              properties reset
% 
% Examples:
% 
% obj.set('propertyName',propertyValue,...);
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if size(varargin,1) && iscell(varargin{1})
        varargin = varargin{1};
    end

    for jj = 1:2:size(varargin,2)

        if ischar(varargin{jj})

            propertyName  = lower(varargin{jj});
            try
                propertyValue = varargin{jj + 1};
            catch
                error([mfilename ':: Bad ...,''propertyName'', propertyValue,... combination.'])
            end

            switch propertyName

                case 'candlewidth'

                    obj.candleWidth = propertyValue;

                case 'cdata'

                    obj.cData = propertyValue;

                case 'close'
                    
                    obj.close = propertyValue;
                    
                case 'deleteoption'

                    obj.deleteOption = propertyValue;    

                case 'direction'

                    obj.direction = propertyValue; 

                case 'edgecolor'

                    obj.edgeColor = propertyValue; 
                    
                case 'indicator'
                    
                    obj.indicator = propertyValue;
                    
                case 'indicatorcolor'
                    
                    obj.indicatorColor = propertyValue;
                 
                case 'indicatorlinestyle'
                    
                    obj.indicatorLineStyle = propertyValue;    
                    
                case 'indicatorlinewidth'
                    
                    obj.indicatorLineWidth = propertyValue;
                    
                case 'indicatorwidth'
                    
                    obj.indicatorWidth = propertyValue;
                     
                case 'high'
                    
                    obj.high = propertyValue;

                case 'hllinewidth'
                    
                    obj.hlLineWidth = propertyValue;
                    
                case 'legendinfo'

                    obj.legendInfo = propertyValue;     

                case 'linestyle'

                    obj.lineStyle = propertyValue;

                case 'linewidth'

                    obj.lineWidth = propertyValue;    

                case 'low'
                    
                    obj.low = propertyValue;
                    
                case 'marker'
                    
                    obj.marker = propertyValue;    
                    
                case 'open'
                    
                    obj.open = propertyValue;    
                    
                case 'parent'

                    if isa(obj.parent,'nb_axes')
                        % Remove it from its old parent
                        obj.parent.removeChild(obj);
                    end

                    obj.parent = propertyValue;

                case 'shadecolor'

                    obj.shadeColor = propertyValue;

                case 'shaded'

                    obj.shaded = propertyValue;

                case 'side'

                    obj.side = propertyValue;    

                case 'visible'

                    if strcmpi(get(obj.parent,'visible'),'off') && strcmpi(propertyValue,'on')
                            warning([mfilename ':: The parent ''visible'' property is set to ''off'', so it is not possible '...
                                             'to set the ''visible'' property of any of its children.']);
                    else
                        obj.visible = propertyValue;
                    end

                case 'xdata'

                    obj.xData = propertyValue;

                otherwise

                    error([mfilename ':: Bad property name; ' propertyName])

            end

        end

    end

    % Then replot given the settings
    plotCandles(obj);

end
