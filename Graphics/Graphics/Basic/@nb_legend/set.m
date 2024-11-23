function set(obj,varargin)
% Syntax:
% 
% set(obj,varargin)
% 
% Description:
% 
% Sets the properties of an object of class nb_legend. Give the 
% property name as a string. The input that follows should be the 
% value you want to assign to the property. 
%
% Multple properties could be set with one method call.
% 
% Input:
% 
% - obj      : An object of class nb_legend
% 
% - varargin : Every odd input must be a string with the name of 
%              the property wanted to be set. Every even input must
%              be the value you want to set the given property to.
% 
% Output:
% 
% - obj      : The same object of class nb_legend with the given
%              properties reset
% 
% Examples:
% 
% obj.set('propertyName',propertyValue,...);
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if size(varargin,1) && iscell(varargin{1})
        % Makes it possible to give options directly through a cell
        varargin = varargin{1};
    end

    for jj = 1:2:size(varargin,2)

        if ischar(varargin{jj})

            propertyName  = lower(varargin{jj});

            try
                propertyValue = varargin{jj + 1};
            catch 
                error([mfilename ':: Bad combination of ''propertyName'' propertyValue'])
            end

            switch lower(propertyName)

                case 'box'

                    obj.box = propertyValue; 

                case 'color'

                    obj.color = propertyValue; 

                case 'columns'

                    obj.columns = propertyValue;

                case 'columnwidth'

                    obj.columnWidth = propertyValue;    

                case 'deleteoption'

                    obj.deleteOption = propertyValue; 
                    
                case 'fakelegends'
                    
                    obj.fakeLegends = propertyValue; 
                    
                case 'fontcolor'
                    
                    obj.fontColor = propertyValue;

                case 'fontname'

                    obj.fontName = propertyValue;

                case 'fontsize'

                    obj.fontSize = propertyValue;
                    
                case 'fontunits'
                    
                    obj.fontUnits = propertyValue;

                case 'fomtweight'

                    obj.fontWeight = propertyValue;

                case 'interpreter'

                    obj.interpreter = propertyValue;
                    
                case 'legends'
                    
                    if size(propertyValue,1) > 1 && size(propertyValue,2) == 1
                        propertyValue = propertyValue';
                    end
                    obj.legends = propertyValue;

                case 'location'
                    
                    obj.location = propertyValue;

                case 'normalized'
                    
                    obj.normalized = propertyValue;    
                    
                case 'objecttonotify'  
                    
                    obj.objectToNotify = propertyValue;
                    
                case 'parent'

                    if ~isempty(obj.parent)
                        % Remove the title form the old parent
                        obj.parent.removeLegend(obj);
                    end

                    if isa(propertyValue,'nb_axes')
                        % Assign the new parent
                        obj.parent = propertyValue;
                    else
                        error([mfilename ':: The ''parent'' property must be a nb_axes handle.']) 
                    end 

                case 'position'

                    obj.position = propertyValue;
                    
                case 'reorder'
                    
                    obj.reorder = propertyValue;

                case 'space'

                    obj.space = propertyValue;

                case 'visible'

                    obj.visible = propertyValue;

                otherwise

                    error([mfilename ':: No property ''' varargin{jj} ''' or you have not access to set it.'])

            end

        end

    end

    %--------------------------------------------------------------
    % Add the legend to its parent, where it is plotted
    %--------------------------------------------------------------
    if isempty(obj.parent)
        obj.parent = nb_axes();
    end
    obj.parent.addLegend(obj);

end

