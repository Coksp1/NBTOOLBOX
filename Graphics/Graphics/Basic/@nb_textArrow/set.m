function set(obj,varargin)
% Syntax:
% 
% set(obj,varargin)
% 
% Description:
% 
% Sets the properties of an object of class nb_textArrow. Give the 
% property name as a string. The input that follows should be the 
% value you want to assign to the property. 
%
% Multple properties could be set with one method call.
% 
% Input:
% 
% - obj      : An object of class nb_textArrow
% 
% - varargin : Every odd input must be a string with the name of 
%              the property wanted to be set. Every even input must
%              be the value you want to set the given property to.
% 
% Output:
% 
% - obj      : The same object of class nb_arrow with the given
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

                case 'color'
                    
                    if ~ischar(propertyValue) && ~isnumeric(propertyValue)
                        error([mfilename ':: The property ' propertyName ' must be a string or a double (1x3 with the RGB color).'])
                    end

                    obj.color = propertyValue;
                    
                case 'copyoption'

                    if or(~all(ismember(propertyValue,[0,1])),~isscalar(propertyValue))
                        error([mfilename ':: The property ' propertyName ' must be a logical scalar.'])
                    end
                    obj.copyOption = propertyValue;    
                    
                case 'deleteoption'
                    
                    if ~ischar(propertyValue)
                        error([mfilename ':: The property ' propertyName ' must be a string.'])
                    end
                    
                    obj.deleteOption = propertyValue;

                case 'fontangle'
                    
                    if ~ischar(propertyValue)
                        error([mfilename ':: The property ' propertyName ' must be a string.'])
                    end
                    
                    obj.fontAngle = propertyValue;
                    
                case 'fontname'
                    
                    if ~ischar(propertyValue)
                        error([mfilename ':: The property ' propertyName ' must be a string.'])
                    end
                    
                    obj.fontName = propertyValue; 
                    
                case 'fontsize'
                    
                    if ~isscalar(propertyValue)
                        error([mfilename ':: The property ' propertyName ' must be a scalar.'])
                    end
                    
                    obj.fontSize = propertyValue;
                    
                case 'fontunits'
                    
                    if ~ischar(propertyValue)
                        error([mfilename ':: The property ' propertyName ' must be a string.'])
                    end
                    
                    oldFontSize   = obj.fontUnits;
                    obj.fontUnits = propertyValue;    
                    setFontSize(obj,oldFontSize);
                    
                case 'fontweight'
                    
                    if ~ischar(propertyValue)
                        error([mfilename ':: The property ' propertyName ' must be a string.'])
                    end
                    
                    obj.fontWeight = propertyValue;    
                    
                case 'headlength'

                    if ~isscalar(propertyValue)
                        error([mfilename ':: The property ' propertyName ' must be a scalar.'])
                    end
                    
                    obj.headLength = propertyValue;
                    
                case 'headstyle'

                    if ~ischar(propertyValue)
                        error([mfilename ':: The property ' propertyName ' must be a string.'])
                    end
                    
                    obj.headStyle = propertyValue; 
                    
                case 'headwidth'

                    if ~isscalar(propertyValue)
                        error([mfilename ':: The property ' propertyName ' must be a scalar.'])
                    end
                    
                    obj.headWidth = propertyValue;    
                    
                case 'horizontalalignment'
                    
                    if ~ischar(propertyValue)
                        error([mfilename ':: The property ' propertyName ' must be a string.'])
                    end
                    
                    obj.horizontalAlignment = propertyValue;    
                    
                case 'interpreter'
                    
                    if ~ischar(propertyValue)
                        error([mfilename ':: The property ' propertyName ' must be a string.'])
                    end
                    
                    obj.interpreter = propertyValue;   
                    
                case 'linestyle'

                    if ~ischar(propertyValue)
                        error([mfilename ':: The property ' propertyName ' must be a string.'])
                    end
                    
                    obj.lineStyle = propertyValue;

                case 'linewidth'

                    if ~isscalar(propertyValue)
                        error([mfilename ':: The property ' propertyName ' must be a scalar.'])
                    end
                    
                    obj.lineWidth = propertyValue;
                    
                case 'normalized'
                    
                    if ischar(propertyValue)
                        obj.normalized = propertyValue;
                    else
                        error([mfilename ':: The input after the ''normalized'' property must be a string with either ''axes'' or ''figure''.'])
                    end  
                    
                case 'parent'
                    
                    if ~isa(propertyValue,'nb_axes') && ~isempty(propertyValue)
                        error([mfilename ':: The property ' propertyName ' must be an nb_axes object.'])
                    end
                    
                    if ~isempty(obj.parent)
                        if isvalid(obj.parent)
                            removeAnnotation(obj.parent,obj);
                        end
                    end
                    obj.parent = propertyValue;
                    if ~isempty(obj.parent)
                        addAnnotation(obj.parent,obj); 
                    end    
                    
                case 'side'
                    
                    if ~ischar(propertyValue)
                        error([mfilename ':: The property ' propertyName ' must be a string.'])
                    end
                    
                    obj.side = propertyValue;    

                case 'string'
                    
                    if ~ischar(propertyValue)
                        error([mfilename ':: The property ' propertyName ' must be a char.'])
                    end
                    
                    obj.string = propertyValue; 
                    
                case 'textbackgroundcolor'
                    
                    if ~ischar(propertyValue) && ~isnumeric(propertyValue)
                        error([mfilename ':: The property ' propertyName ' must be a string or a double (1x3 with the RGB color).'])
                    end
                    
                    obj.textBackgroundColor = propertyValue; 
                    
                case 'textcolor'
                    
                    if ~ischar(propertyValue) && ~isnumeric(propertyValue)
                        error([mfilename ':: The property ' propertyName ' must be a string or a double (1x3 with the RGB color).'])
                    end
                    
                    obj.textColor = propertyValue;    
                    
                case 'textedgecolor'
                    
                    if ~ischar(propertyValue) && ~isnumeric(propertyValue)
                        error([mfilename ':: The property ' propertyName ' must be a string or a double (1x3 with the RGB color).'])
                    end
                    
                    obj.textEdgeColor = propertyValue;    
                    
                case 'textlinewidth'

                    if ~isscalar(propertyValue)
                        error([mfilename ':: The property ' propertyName ' must be a scalar.'])
                    end
                    
                    obj.textLineWidth = propertyValue;    
                    
                case 'textmargin'

                    if ~isscalar(propertyValue)
                        error([mfilename ':: The property ' propertyName ' must be a scalar.'])
                    end
                    
                    obj.textMargin = propertyValue;
                    
                case 'textrotation'

                    if ~isscalar(propertyValue)
                        error([mfilename ':: The property ' propertyName ' must be a scalar.'])
                    end
                    
                    obj.textRotation = propertyValue;    
                    
                case 'units'
                    
                    if ~ischar(propertyValue)
                        error([mfilename ':: The property ' propertyName ' must be a string.'])
                    end
                    
                    obj.units = propertyValue;
                    
                case 'verticalalignment'
                    
                    if ~ischar(propertyValue)
                        error([mfilename ':: The property ' propertyName ' must be a string.'])
                    end
                    
                    obj.verticalAlignment = propertyValue;

                case 'xdata'

                    if ~isnumeric(propertyValue) || size(propertyValue,1) ~= 1 || size(propertyValue,2) ~= 2
                        error([mfilename ':: The property ' propertyName ' must be a 1x2 double.'])
                    end
                    
                    obj.xData = propertyValue;

                case 'ydata'
                    
                    if ~isnumeric(propertyValue) || size(propertyValue,1) ~= 1 || size(propertyValue,2) ~= 2
                        error([mfilename ':: The property ' propertyName ' must be a 1x2 double.'])
                    end

                    obj.yData = propertyValue;

                otherwise

                    error([mfilename ':: Bad property name; ' propertyName])

            end

        end

    end
    
    plot(obj);

end
