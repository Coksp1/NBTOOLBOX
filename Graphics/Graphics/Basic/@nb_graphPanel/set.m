function set(obj,varargin)
% Syntax:
% 
% set(obj,varargin)
% 
% Description:
% 
% Sets the properties of an object of class nb_figure. Give the 
% property name as a string. The input that follows should be the 
% value you want to assign to the property. 
%
% Multple properties could be set with one method call.
% 
% Input:
% 
% - obj      : An object of class nb_figure
% 
% - varargin : Every odd input must be a string with the name of 
%              the property wanted to be set. Every even input must
%              be the value you want to set the given property to.
% 
% Output:
% 
% - obj      : The same object of class nb_figure with the given
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

    resized = false;
    for jj = 1:2:size(varargin,2)

        if ischar(varargin{jj})

            propertyName  = lower(varargin{jj});
            propertyValue = varargin{jj + 1};

            switch propertyName
                
                case 'advanced'
                    
                    obj.advanced = propertyValue;

                case 'aspectratio'
            
                    obj.aspectRatio = propertyValue;
                    resized         = true;
                    
                case 'deleteoption'

                    obj.deleteOption = propertyValue;    

                case 'position'
                    
                    set(obj.figureHandle,'position',propertyValue);
                    resized = true;
                    
                case 'visible'

                    % Set the visibility of the MATLAB figure
                    % handle
                    set(obj.figureHandle,'Visible',propertyValue);

                case 'userdata'
 
                    obj.userData = propertyValue;
                    
                case 'color'
                    
                    set(obj.figureHandle,propertyName,propertyValue); 
                    set(obj.panelHandle,'backgroundColor',propertyValue); 

                otherwise

                    % Then try to set the figureHandle properties
                    set(obj.figureHandle,propertyName,propertyValue);    

            end

        end

    end
    
    if resized
        nb_graphPanel.resizeFcn(obj.figureHandle,[],obj);
    end

    % Update the figureTitle and the footer
    update(obj);

end
