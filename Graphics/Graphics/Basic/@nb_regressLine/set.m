function set(obj,varargin)
% Syntax:
% 
% set(obj,varargin)
% 
% Description:
% 
% Sets the properties of an object of class nb_drawLine. Give the 
% property name as a string. The input that follows should be the 
% value you want to assign to the property. 
%
% Multple properties could be set with one method call.
% 
% Input:
% 
% - obj      : An object of class nb_drawLine
% 
% - varargin : Every odd input must be a string with the name of 
%              the property wanted to be set. Every even input must
%              be the value you want to set the given property to.
% 
% Output:
% 
% - obj      : The same object of class nb_drawLine with the given
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
            propertyValue = varargin{jj + 1};

            switch lower(propertyName)

                case 'cdata'

                    if ~ischar(propertyValue) && ~isnumeric(propertyValue)
                        error([mfilename ':: The property ' propertyName ' must be a string or a double (1x3 with the RGB color).'])
                    end
                    
                    obj.cData = propertyValue;
                    
                case 'clipping'

                    if ~ischar(propertyValue)
                        error([mfilename ':: The property ' propertyName ' must be a string.'])
                    end
                    
                    obj.clipping = propertyValue;
                    
                case 'copyoption'

                    if or(~all(ismember(propertyValue,[0,1])),~isscalar(propertyValue))
                        error([mfilename ':: The property ' propertyName ' must be a logical scalar.'])
                    end
                    obj.copyOption = propertyValue;  
                    
                case 'deleteoption'
                    
                    if ~ischar(propertyValue)
                        error([mfilename ':: The proeprty ' propertyName ' must be a string.'])
                    end
                    
                    obj.deleteOption = propertyValue;    

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

                case 'index'
                    
                    if ~nb_iswholenumber(propertyValue)
                        error([mfilename ':: The property ' propertyName ' must be a an integer.'])
                    end
                    
                    obj.index = propertyValue;        

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

                case 'marker'

                    if ~ischar(propertyValue)
                        error([mfilename ':: The property ' propertyName ' must be a string.'])
                    end
                    
                    obj.marker = propertyValue;

                case 'markeredgecolor'

                    if ~ischar(propertyValue) && ~isnumeric(propertyValue)
                        error([mfilename ':: The property ' propertyName ' must be a string or a double (1x3 with the RGB color).'])
                    end
                    
                    obj.markerEdgeColor = propertyValue;

                case 'markerfacecolor'

                    if ~ischar(propertyValue) && ~isnumeric(propertyValue)
                        error([mfilename ':: The property ' propertyName ' must be a string or a double (1x3 with the RGB color).'])
                    end
                    
                    obj.markerFaceColor = propertyValue;

                case 'markersize'

                    if ~isscalar(propertyValue)
                        error([mfilename ':: The property ' propertyName ' must be a scalar.'])
                    end
                    
                    obj.markerSize = propertyValue;
                    
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
                    
                case 'positionx'

                    if ~isnumeric(propertyValue)
                        error([mfilename ':: The property ' propertyName ' must be a double.'])
                    end
                    
                    obj.positionX = propertyValue;

                case 'positiony'

                    if ~isnumeric(propertyValue)
                        error([mfilename ':: The property ' propertyName ' must be a double.'])
                    end
                    
                    obj.positionY = propertyValue;

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
                   
                case 'verticalalignment'
                    
                    if ~ischar(propertyValue)
                        error([mfilename ':: The property ' propertyName ' must be a string.'])
                    end
                    
                    obj.verticalAlignment = propertyValue;     
                    
                otherwise

                    error([mfilename ':: Bad property name; ' propertyName])

            end

        end

    end
    
    plot(obj);

end
