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

            switch propertyName

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
                    
                case 'curvature'

                    if ~isnumeric(propertyValue)
                        error([mfilename ':: The property ' propertyName ' must be a double.'])
                    end
                    
                    obj.curvature = propertyValue;    
                    
                case 'deleteoption'

                    if ~ischar(propertyValue)
                        error([mfilename ':: The proeprty ' propertyName ' must be a string.'])
                    end
                    
                    obj.deleteOption = propertyValue;     

                case 'edgecolor'

                    if ~ischar(propertyValue) && ~isnumeric(propertyValue)
                        error([mfilename ':: The property ' propertyName ' must be a string or a double (1x3 with the RGB color).'])
                    end
                    
                    obj.edgeColor = propertyValue;                         

                case 'facecolor'
                    
                    if ~ischar(propertyValue) && ~isnumeric(propertyValue)
                        error([mfilename ':: The property ' propertyName ' must be a string or a double (1x3 with the RGB color).'])
                    end

                    obj.faceColor = propertyValue;    
                    
                case 'linestyle'

                    if ~ischar(propertyValue)
                        error([mfilename ':: The proeprty ' propertyName ' must be a string.'])
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
                    
                case 'position'

                    if ~isnumeric(propertyValue)
                        error([mfilename ':: The property ' propertyName ' must be a double.'])
                    end
                    
                    obj.position = propertyValue;    

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

                otherwise

                    error([mfilename ':: Bad property name; ' propertyName])

            end

        end

    end
    
    plot(obj);

end
