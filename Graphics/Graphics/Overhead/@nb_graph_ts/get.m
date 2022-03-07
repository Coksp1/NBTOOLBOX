function propertyValue = get(obj,propertyName)
% Syntax:
% 
% propertyValue = get(obj,propertyName)
% 
% Description:
% 
% Get some otherwise non-accessible properties of the nb_graph_ts
% 
% Input:
% 
% - obj           : An object of class nb_graph_ts
% 
% - propertyName  : A string with the name of the wanted property. 
% 
% Output:
% 
% - propertyValue : The property value of the given property.
%     
% Examples:
%
% Get the last axes handle of the nb_graph_ts object. Be aware that
% all the the axes handles are stored in the figurehandle property
% of the object.
% axeshandle   = obj.get('axeshandle');
%
% Get the handle of all the current figures of the nb_graph_ts 
% object.
% figurehandle = obj.get('figurehandle');
% 
% See also: 
% nb_figure, nb_axes, nb_ts
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    switch lower(propertyName)

        case 'axeshandle'

            propertyValue = obj.axesHandle;
            
        case 'datesofgraph'
            
            propertyValue = obj.datesOfGraph;

        case 'fandata'

            propertyValue = obj.fanData;
            
        case 'figtitleobjecteng'
                            
            propertyValue = obj.figTitleObjectEng;

        case 'figtitleobjectnor'

            propertyValue = obj.figTitleObjectNor;      

        case 'figurehandle'

            propertyValue = obj.figureHandle;
            
        case 'footerobjecteng'

            propertyValue = obj.footerObjectEng;  

        case 'footerobjectnor'

            propertyValue = obj.footerObjectNor;    
            
        case 'graphmethod'
            
            propertyValue = obj.graphMethod;
            
        case 'manuallysetendgraph'
            
            propertyValue = obj.manuallySetEndGraph;    
            
        case 'manuallysetstartgraph'
            
            propertyValue = obj.manuallySetStartGraph;
            
        case 'numberofgraphs'
            
            propertyValue = obj.numberOfGraphs;
            
        case 'uicontextmenu'
            
            propertyValue = obj.UIContextMenu;
            
        otherwise

            error([mfilename ':: Either it is not possible to get the property ''' propertyName ''' or you can get it by writing obj.propertyName.'])

    end

end
