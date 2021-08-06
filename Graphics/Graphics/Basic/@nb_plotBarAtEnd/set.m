function set(obj,varargin)
% Syntax:
% 
% set(obj,varargin)
% 
% Description:
% 
% Sets the properties of an object of class nb_plot. Give the 
% property name as a string. The input that follows should be the 
% value you want to assign to the property. 
%
% Multple properties could be set with one method call.
% 
% Input:
% 
% - obj      : An object of class nb_plot
% 
% - varargin : Every odd input must be a string with the name of 
%              the property wanted to be set. Every even input must
%              be the value you want to set the given property to.
% 
% Output:
% 
% - obj      : The same object of class nb_plot with the given
%              properties reset
% 
% Examples:
% 
% obj.set('propertyName',propertyValue,...);
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    if size(varargin,1) && iscell(varargin{1})
        varargin = varargin{1};
    end

    for jj = 1:2:size(varargin,2)

        if ischar(varargin{jj})

            propertyName  = lower(varargin{jj});
            propertyValue = varargin{jj + 1};

            switch propertyName

                case 'barperiods'

                    if ~nb_iswholenumber(propertyValue)
                        error([mfilename ':: The barPeriods property must be set to a vector of integer.'])
                    end
                    obj.barPeriods = propertyValue(:); 
                
                case 'cdata'

                    obj.cData = propertyValue;

                case 'cdatabar'

                    if ~nb_isOneLineChar(propertyValue)
                        error([mfilename ':: The cDataBar property must be set to a one line char.'])
                    end
                    obj.cDataBar = propertyValue;    
                    
                case 'clipping'

                    obj.clipping = propertyValue;

                case 'endbarwidth'    
                    
                    if nb_isScalarInteger(propertyValue)
                        obj.endBarWidth = propertyValue;
                    else
                        error([mfilename ':: The input after the ''endBarWidth'' property must be a scalar integer.'])
                    end    
                    
                case 'deleteoption'

                    obj.deleteOption = propertyValue; 

                case 'legendinfo'

                    obj.legendInfo = propertyValue;    

                case 'linestop'

                    if ~nb_isScalarInteger(propertyValue)
                        error([mfilename ':: The lineStop property must be set to a scalar strictly positive integer.'])
                    end
                    obj.lineStop = propertyValue;    
                    
                case 'linestyle'

                    obj.lineStyle = propertyValue;

                case 'linewidth'

                    obj.lineWidth = propertyValue; 

                case 'marker'

                    obj.marker = propertyValue;

                case 'markeredgecolor'

                    obj.markerEdgeColor = propertyValue;

                case 'markerfacecolor'

                    obj.markerFaceColor = propertyValue;

                case 'markersize'

                    obj.markerSize = propertyValue;

                case 'parent'

                    if isa(obj.parent,'nb_axes')
                        % Remove it from its old parent
                        obj.parent.removeChild(obj);
                    end

                    obj.parent = propertyValue;

                case 'side'

                    obj.side = propertyValue;    

                case 'visible'

                    obj.visible = propertyValue;    

                case 'xdata'

                    obj.xData = propertyValue;

                case 'ydata'

                    obj.yData = propertyValue;

                otherwise
                    error([mfilename ':: Bad property name; ' propertyName])
            end

        end
            
    end

    % Then replot given the settings
    plotLines(obj);

end
