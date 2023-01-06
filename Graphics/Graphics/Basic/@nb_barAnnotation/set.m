function set(obj,varargin)
% Syntax:
%
% set(obj,varargin)
%
% Description:
%
% Sets the properties of an nb_barAnnotation object
%
% Input:
% 
% - obj      : An object of class nb_drawLine
% 
% - varargin : Every odd input must be a string with the name of 
%              the property wanted to be set. Every even input must
%              be the value you want to set the given property to.
%     
% Output
% 
% - obj      : An object of class nb_barAnnotation with 
%              the wanted properties set.
%     
% Examples:
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if size(varargin,1) && iscell(varargin{1})
        % Makes it possible to give options directly through a cell
        varargin = varargin{1};
    end

    for jj = 1:2:size(varargin,2)

        if ischar(varargin{jj})

            property = lower(varargin{jj});
            try
                propertyValue = varargin{jj+1};
            catch
                error([mfilename ':: Bad ''propertyName'', propertyValue combination.'])
            end

            switch property

                case 'color'
                    
                    if ischar(propertyValue) || isnumeric(propertyValue)
                        obj.color = propertyValue;
                    else
                        error([mfilename ':: The property ' property ' must be either a string with the color name or a 1x3 double with the RGB color.'])
                    end
                    
                case 'copyoption'

                    if or(~all(ismember(propertyValue,[0,1])),~isscalar(propertyValue))
                        error([mfilename ':: The property ' propertyName ' must be a logical scalar.'])
                    end
                    obj.copyOption = propertyValue;    
                    
                case 'decimals'
                    
                    if isscalar(propertyValue)
                        obj.decimals = propertyValue;
                    else
                       error([mfilename 'The property ' property ' must be a scalar.']) 
                    end
                    
                case 'fontname'
                    
                    if ischar(propertyValue)
                        obj.fontName = propertyValue;
                    else
                        error([mfilename ':: The property ' property ' must be a string.'])
                    end
                    
                case 'fontsize'
                    
                    if isscalar(propertyValue)
                        obj.fontSize = propertyValue;
                    else
                       error([mfilename 'The property ' property ' must be a scalar.']) 
                    end
                    
                case 'fontunits'
                    
                    if ~ischar(propertyValue)
                        error([mfilename ':: The property ' property ' must be a string.'])
                    end  
                    
                    oldFontSize   = obj.fontUnits;
                    obj.fontUnits = propertyValue;    
                    setFontSize(obj,oldFontSize) 
                    
                case 'fontweight'
                    
                    if ischar(propertyValue)
                        obj.fontWeight = propertyValue;
                    else
                        error([mfilename ':: The property ' property ' must be a string.'])
                    end
                    
                case 'force'
                    
                    if all(ismember(propertyValue,[0,1])) && isscalar(propertyValue)
                        obj.force = propertyValue;
                    else
                        error([mfilename ':: The property ' property ' must be a number (Either 1 or 0).'])
                    end
                    
                case 'language'
                    
                    if ischar(propertyValue)
                        obj.language = propertyValue;
                    else
                        error([mfilename ':: The property ' property ' must be a string.'])
                    end
                    
                case 'location'
                    
                    if ischar(propertyValue)
                        obj.location = propertyValue;
                    else
                        error([mfilename ':: The property ' property ' must be a string.'])
                    end
                    
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
                    
                case 'rotation'
                    
                    if isscalar(propertyValue)
                        obj.rotation = propertyValue;
                    else
                       error([mfilename 'The property ' property ' must be a 1x1 double.']) 
                    end
                    
                case 'space'
                    
                    if isnumeric(propertyValue)
                        obj.space = propertyValue;
                    else
                       error([mfilename 'The property ' property ' must be a number.']) 
                    end 
                    
                case 'string'
                    
                    if iscellstr(propertyValue)
                        obj.string = propertyValue;
                    else
                        error([mfilename 'The property ' property ' must be a cellstr.']) 
                    end
                    
                case 'type'
                    
                    if ischar(propertyValue)
                        obj.type = propertyValue;
                    else
                        error([mfilename ':: The property ' property ' must be a string.'])
                    end
        
                otherwise

                    error([mfilename ':: The class nb_barAnnotation has no property ''' varargin{jj} ''' or you have no access to set it.'])

            end

        end

    end
    
    plot(obj);

end
