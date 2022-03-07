function set(obj,varargin)
% Syntax:
% 
% set(obj,varargin)
% 
% Description:
% 
% Sets the properties of an object of class nb_xlabel. Give the 
% property name as a string. The input that follows should be the 
% value you want to assign to the property. 
%
% Multple properties could be set with one method call.
% 
% Input:
% 
% - obj      : An object of class nb_xlabel
% 
% - varargin : Every odd input must be a string with the name of 
%              the property wanted to be set. Every even input must
%              be the value you want to set the given property to.
% 
% Output:
% 
% - obj      : The same object of class nb_xlabel with the given
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

                case 'alignment'
                    
                    obj.alignment = propertyValue; 
                
                case 'deleteoption'

                    obj.deleteOption = propertyValue; 

                case 'fontname'

                    obj.fontName = propertyValue;

                case 'fontsize'

                    obj.fontSize = propertyValue; 
                    
                case 'fontunits'

                    obj.fontUnits = propertyVal ue;        

                case 'fontweight'

                    obj.fontWeight = propertyValue; 

                case 'interpreter'

                    obj.interpreter = propertyValue;    

                case 'normalized'
                    
                    obj.normalized = propertyValue;      
                    
                case 'parent'

                    if ~isempty(obj.parent)
                        % Remove the x-label form the old parent
                        obj.parent.removeXLabel(obj);
                    end

                    if isa(propertyValue,'nb_axes')
                        % Assign the new parent
                        obj.parent = propertyValue;
                    else
                        error([mfilename ':: The ''parent'' property must be a nb_axes handle.']) 
                    end

                case 'placement'
                    
                    obj.placement = propertyValue;    
                    
                case 'offset'

                    obj.offset = propertyValue; 

                case 'string'

                    obj.string = propertyValue; 

                case 'visible'

                    obj.visible = propertyValue;    

                otherwise

                    error([mfilename ':: Bad property name; ' propertyName])

            end

        end

    end

    %--------------------------------------------------------------
    % Add the x-label to its parent, where it is plotted
    %--------------------------------------------------------------
    if isempty(obj.parent)
        obj.parent = nb_axes();
    end

    obj.parent.addXLabel(obj);

end
