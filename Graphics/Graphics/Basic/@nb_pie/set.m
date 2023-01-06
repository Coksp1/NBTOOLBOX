function set(obj,varargin)
% Syntax:
% 
% set(obj,varargin)
% 
% Description:
% 
% Sets the properties of an object of class nb_pie. Give the 
% property name as a string. The input that follows should be the 
% value you want to assign to the property. 
%
% Multple properties could be set with one method call.
% 
% Input:
% 
% - obj      : An object of class nb_pie
% 
% - varargin : Every odd input must be a string with the name of 
%              the property wanted to be set. Every even input must
%              be the value you want to set the given property to.
% 
% Output:
% 
% - obj      : The same object of class nb_pie with the given
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

                case 'axisvisible'
                
                    obj.axisVisible = propertyValue;
                    
                case 'bite'

                    obj.bite = (propertyValue ~= 0);

                case 'cdata'

                    obj.cData = propertyValue;

                case 'deleteoption'

                    obj.deleteOption = propertyValue;     

                case 'dimension'

                    % Deprecated

                case 'edgecolor'

                    obj.edgeColor = propertyValue; 

                case 'explode'

                    obj.explode = (propertyValue ~= 0);

                case 'fontcolor'

                    obj.fontColor = propertyValue;

                case 'fontname'

                    obj.fontName = propertyValue;

                case 'fontsize'

                    obj.fontSize = propertyValue;
                    
                case 'fontunits'

                    obj.fontUnits = propertyValue;    

                case 'fontweight'

                    obj.fontWeight = propertyValue; 

                case 'labels'

                    obj.labels = propertyValue;

                case 'labelsextension'

                    obj.labelsExtension = propertyValue;

                case 'legendinfo'

                    obj.legendInfo = propertyValue;     

                case 'linestyle'

                    obj.lineStyle = propertyValue;

                case 'linewidth'

                    obj.lineWidth = propertyValue; 

                case 'location'

                    obj.location = propertyValue;

                case {'nolabels','noLabel'}

                    obj.noLabels = propertyValue;
                    
                case 'origoposition'

                    obj.origoPosition = propertyValue;
                    
                case 'parent'

                    if isa(obj.parent,'nb_axes')
                        % Remove it from its old parent
                        obj.parent.removeChild(obj);
                    end

                    obj.parent = propertyValue;
                    
                case 'textexplode'

                    % Deprecated

                case 'visible'

                    obj.visible = propertyValue;     

                case {'ydata','xdata'}

                    obj.yData = propertyValue;

                otherwise

                    error([mfilename ':: Bad property name; ' propertyName])

            end

        end

    end

    % Then replot given the settings
    plotPie(obj);

end
