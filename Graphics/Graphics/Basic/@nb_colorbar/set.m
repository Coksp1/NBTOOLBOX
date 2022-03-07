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

                case 'direction'
                    
                    if ~ischar(propertyValue)
                        error([mfilename ':: The property ' propertyName ' must be a string.'])
                    end
                    obj.direction = propertyValue;     
                    
                case 'fontname'
                    
                    if ~ischar(propertyValue)
                        error([mfilename ':: The property ' propertyName ' must be a string.'])
                    end
                    obj.fontName = propertyValue; 
                    
                case 'fontsize'
                    
                    if ~nb_isScalarNumber(propertyValue)
                        error([mfilename ':: The property ' propertyName ' must be a scalar double.'])
                    end
                    obj.fontSize = propertyValue;
                    
                case 'fontunits'
                    
                    if ~ischar(propertyValue)
                        error([mfilename ':: The property ' propertyName ' must be a string.'])
                    end
                    
                    oldFontSize   = obj.fontUnits;
                    obj.fontUnits = propertyValue;    
                    setFontSize(obj,oldFontSize)   
                    
                case 'fontweight'
                    
                    if ~ischar(propertyValue)
                        error([mfilename ':: The property ' propertyName ' must be a string.'])
                    end
                    obj.fontWeight = propertyValue;   
                    
                case 'invert'
                    
                    if ~nb_isScalarLogical(propertyValue)
                        error([mfilename ':: The property ' propertyName ' must be a scalar logical.'])
                    end
                    obj.invert = propertyValue; 
                    
                case 'language'
                    
                    if ischar(propertyValue)
                        obj.language = propertyValue;
                    else
                        error([mfilename ':: The property ' property ' must be a string.'])
                    end    
                    
                case 'location'

                    if ~ischar(propertyValue)
                        error([mfilename ':: The property ' propertyName ' must be a char.'])
                    end
                    obj.location = propertyValue;
                    
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
                    
                case 'space'
                    
                    if ~nb_isScalarNumber(propertyValue)
                        error([mfilename ':: The property ' propertyName ' must be a scalar double.'])
                    end
                    obj.space = propertyValue;     

                case 'strip'

                    if ~isnumeric(propertyValue)
                        error([mfilename ':: The property ' propertyName ' must be a N x 3 double.'])
                    end
                    obj.strip = propertyValue;     
                    
                case 'side' 
                    
                case 'ticklabels'

                    obj.tickLabels    = propertyValue; 
                    obj.tickLabelsSet = true;
                     
                case 'ticks'

                    if ~isnumeric(propertyValue)
                        error([mfilename ':: The property ' propertyName ' must be a double vector.'])
                    end
                    obj.ticks    = propertyValue(:); 
                    obj.ticksSet = true;

                otherwise

                    error([mfilename ':: Bad property name; ' propertyName])

            end

        end

    end
    
    plot(obj);

end
