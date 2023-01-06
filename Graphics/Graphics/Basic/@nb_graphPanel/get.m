function propertyValue = get(obj,propertyName)
% Syntax:
% 
% propertyValue = get(obj,propertyName)
% 
% Description:
% 
% Get a property of an object of class nb_figure
% 
% Input:
% 
% - obj           : An object of class nb_figure
% 
% - propertyName  : A string with the propertyName 
% 
% Output:
% 
% - propertyValue : The value of the given property
%     
% Examples:
%
% propertyValue = obj.get('children');
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Get the propertyValue from the object
    switch lower(propertyName)

        case 'aspectratio'
            
            propertyValue = obj.aspectRatio;
        
        case 'children'

            propertyValue = obj.children;

        case 'deleteoption'

            propertyValue = obj.deleteOption;

        case 'figurehandle'

            propertyValue = obj.figureHandle;

        case 'figuretitle'

            propertyValue = obj.figureTitle;

        case 'footer'

            propertyValue = obj.footer;
            
        case 'panelhandle'
            
            propertyValue = obj.panelHandle;
            
        case 'userdata'
            
            propertyValue = obj.userData;
            
        otherwise

            propertyValue = get(obj.figureHandle,propertyName);

    end

end
