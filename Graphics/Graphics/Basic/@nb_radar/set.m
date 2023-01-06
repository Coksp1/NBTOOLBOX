function set(obj,varargin)
% Syntax:
% 
% set(obj,varargin)
% 
% Description:
% 
% Sets the properties of an object of class nb_radar. Give the 
% property name as a string. The input that follows should be the 
% value you want to assign to the property. 
%
% Multple properties could be set with one method call.
% 
% Input:
% 
% - obj      : An object of class nb_radar
% 
% - varargin : Every odd input must be a string with the name of 
%              the property wanted to be set. Every even input must
%              be the value you want to set the given property to.
% 
% Output:
% 
% - obj      : The same object of class nb_radar with the given
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

                case 'axescolor'

                    obj.axesColor = propertyValue;

                case 'axeslimmax'

                    obj.axesLimMax = propertyValue;

                case 'axeslimmin'

                    obj.axesLimMin = propertyValue;    

                case 'axeslinewidth'

                    obj.axesLineWidth = propertyValue; 

                case 'cdata'

                    obj.cData = propertyValue;

                case 'deleteoption'

                    obj.deleteOption = propertyValue;     

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

                case 'isolinecolor'

                    obj.isoLineColor = (propertyValue ~= 0);

                case 'isolinestyle'

                    obj.isoLineStyle = propertyValue;

                case 'isolinewidth'

                    obj.isoLineWidth = propertyValue;

                case 'labels'

                    obj.labels = propertyValue;

                case 'legendinfo'

                    obj.legendInfo = propertyValue;     

                case 'linestyle'

                    obj.lineStyle = propertyValue;

                case 'linewidth'

                    obj.lineWidth = propertyValue; 

                case 'location'

                    obj.location = propertyValue;

                case 'numberofisolines'

                    obj.numberOfIsoLines = propertyValue;

                case 'parent'

                    if isa(obj.parent,'nb_axes')
                        % Remove it from its old parent
                        obj.parent.removeChild(obj);
                    end

                    obj.parent = propertyValue;

                case 'rotate'

                    obj.rotate = propertyValue;

                case 'scale'
                    
                    obj.scale = propertyValue;
                    
                case 'visible'

                    obj.visible = propertyValue; 

                case 'xdata'

                    obj.xData = propertyValue;

                otherwise

                    error([mfilename ':: Bad property name; ' propertyName])

            end

        end

    end

    % Rotate the radar plot of size 7 so it look nices
    if obj.rotate == 0 && size(obj.xData,1) == 7
        obj.rotate = -0.225;
    end

    % Then replot given the settings
    plotRadar(obj);

end
