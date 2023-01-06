function set(obj,varargin)
% Syntax:
% 
% set(obj,varargin)
% 
% Description:
% 
% Sets the properties of an object of class nb_fanLegend. Give the 
% property name as a string. The input that follows should be the 
% value you want to assign to the property. 
%
% Multple properties could be set with one method call.
% 
% Input:
% 
% - obj      : An object of class nb_fanLegend
% 
% - varargin : Every odd input must be a string with the name of 
%              the property wanted to be set. Every even input must
%              be the value you want to set the given property to.
% 
% Output:
% 
% - obj      : The same object of class nb_fanLegend with the given
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
                    
                case 'location'
                    
                    obj.location = propertyValue;

                case 'parent'
                    
                    if ~isa(propertyValue,'nb_axes')
                        error([mfilename ':: The ''parent'' property must be a nb_axes handle.']) 
                    end
                    
                    % Find out if any of the children of the axesofplot input is a
                    % nb_fanChart handle
                    %--------------------------------------------------------------
                    for ii = 1:length(propertyValue.children)

                        ret = isa(propertyValue.children{ii},'nb_fanChart');
                        if ret
                            break;
                        end

                    end

                    if ret == 1
                        
                        obj.colors = propertyValue.children{ii}.cData;
                        
                        % Delete all children
                        for ii = 1:size(obj.children)
                            if ishandle(obj.children(ii))
                                delete(obj.children(ii));
                            end
                        end
                        
                    else
                        error([mfilename ':: Parent axes doesn''t contain any nb_fanChart handle. So I cannot produce a fan legend.'])
                    end

                    
                    % Assign the new parent
                    obj.parent = propertyValue;

                case 'string'

                    obj.string = propertyValue; 

                case 'visible'

                    obj.visible = propertyValue; 

                otherwise

                    error([mfilename ':: Bad property name; ' propertyName])

            end

        end

    end

    % If initialize the parent axes
    if isempty(obj.parent)
        obj.parent = nb_axes('visible',obj.visible);
    end

    % Plot the legend
    %--------------------------------------------------------------
    createLegend(obj);

end
