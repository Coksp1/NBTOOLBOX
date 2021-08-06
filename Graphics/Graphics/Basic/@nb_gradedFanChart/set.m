function set(obj,varargin)
% Syntax:
% 
% set(obj,varargin)
% 
% Description:
% 
% Sets the properties of an object of class nb_fanChart. Give the 
% property name as a string. The input that follows should be the 
% value you want to assign to the property. 
%
% Multple properties could be set with one method call.
% 
% Input:
% 
% - obj      : An object of class nb_fanChart
% 
% - varargin : Every odd input must be a string with the name of 
%              the property wanted to be set. Every even input must
%              be the value you want to set the given property to.
% 
% Output:
% 
% - obj      : The same object of class nb_fanChart with the given
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

                case 'alpha'
                    
                    obj.alpha = propertyValue;
                
                case 'cdata'

                    obj.cData = propertyValue;

                case 'central'
                    
                    obj.central = propertyValue;
                    
                case 'deleteoption'

                    obj.deleteOption = propertyValue;

                case 'legendinfo'

                    obj.legendInfo = propertyValue;    

                case 'linewidth'

                    obj.lineWidth = propertyValue;     
                 
                case 'method'

                    obj.method = propertyValue;        
                    
                case 'parent'

                    if isa(obj.parent,'nb_axes')
                        % Remove it from its old parent
                        obj.parent.removeChild(obj);
                    end

                    obj.parent = propertyValue; 

                case 'side'

                    obj.side = propertyValue;
                    
                case 'style'

                    obj.style = propertyValue;    
                    
                case 'visible'

                    obj.visible = propertyValue;

                case 'xdata'               

                    obj.xData = propertyValue;

                case 'ydata'

                    obj.yData = propertyValue;

                otherwise

                    error([mfilename ':: Noexisting property name ' propertyName ' or you have no access to set it.'])

            end

        end

    end

    % Then replot given the settings
    plotFan(obj);

end

