function set(obj,varargin)
% Syntax:
% 
% set(obj,varargin)
% 
% Description:
% 
% Sets the properties of an object of class nb_footer. Give the 
% property name as a string. The input that follows should be the 
% value you want to assign to the property. 
%
% Multple properties could be set with one method call.
% 
% Input:
% 
% - obj      : An object of class nb_footer
% 
% - varargin : Every odd input must be a string with the name of 
%              the property wanted to be set. Every even input must
%              be the value you want to set the given property to.
% 
% Output:
% 
% - obj      : The same object of class nb_footer with the given
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

                case 'children'

                    obj.children = propertyValue;    

                case 'deleteoption'

                    obj.deleteOption = propertyValue;

                case 'fontname'

                    obj.fontName = propertyValue;    

                case 'fontsize'

                    obj.fontSize = propertyValue; 
                    
                case 'fontunits'
                    
                    obj.fontUnits = propertyValue;

                case 'fontweight'

                    obj.fontWeight = propertyValue;    

                case 'interpreter'

                    obj.interpreter = propertyValue;       

                case 'parent'

                    if isa(obj.parent,'nb_figure')
                        % Remove it from its old parent
                        obj.parent.removeFooter(obj);
                    end

                    obj.parent = propertyValue;    

                case 'placement'

                    obj.placement = propertyValue; 

                case 'position'

                    obj.position = propertyValue;    

                case 'string'

                    obj.string = propertyValue;    

                case 'visible'

                    obj.visible = propertyValue;   
                    
                case 'wrap'
                    
                    obj.wrap = propertyValue;   

                otherwise

                    error([mfilename ':: Bad property name; ' propertyName])

            end

        end

    end

    if isempty(obj.parent)
        obj.parent = nb_figure();
    end

    % Then replot given the settings
    obj.parent.addFooter(obj);

end
