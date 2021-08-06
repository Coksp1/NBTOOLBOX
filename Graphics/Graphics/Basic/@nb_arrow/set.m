function set(obj,varargin)
% Syntax:
% 
% set(obj,varargin)
% 
% Description:
% 
% Sets the properties of an object of class nb_arrow. Give the 
% property name as a string. The input that follows should be the 
% value you want to assign to the property. 
%
% Multple properties could be set with one method call.
% 
% Input:
% 
% - obj      : An object of class nb_arrow
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

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

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

                case 'head1length'

                    if ~isscalar(propertyValue)
                        error([mfilename ':: The property ' propertyName ' must be a scalar.'])
                    end
                    
                    obj.head1Length = propertyValue;
                    
                case 'head1style'

                    if ~ischar(propertyValue)
                        error([mfilename ':: The property ' propertyName ' must be a string.'])
                    end
                    
                    obj.head1Style = propertyValue; 
                    
                case 'head1width'

                    if ~isscalar(propertyValue)
                        error([mfilename ':: The property ' propertyName ' must be a scalar.'])
                    end
                    
                    obj.head1Width = propertyValue;    
                    
                case 'head2length'

                    if ~isscalar(propertyValue)
                        error([mfilename ':: The property ' propertyName ' must be a scalar.'])
                    end
                    
                    obj.head2Length = propertyValue; 
                    
                case 'head2style'

                    if ~ischar(propertyValue)
                        error([mfilename ':: The property ' propertyName ' must be a string.'])
                    end
                    
                    obj.head2Style = propertyValue; 
                    
                case 'head2width'

                    if ~isscalar(propertyValue)
                        error([mfilename ':: The property ' propertyName ' must be a scalar.'])
                    end
                    
                    obj.head2Width = propertyValue;    

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
                    
                case 'units'
                    
                    if ~ischar(propertyValue)
                        error([mfilename ':: The property ' propertyName ' must be a string.'])
                    end
                    
                    obj.units = propertyValue;

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
