function obj = set(obj,varargin)
% Syntax:
% 
% set(obj,varargin)
% 
% Description:
% 
% Set the properties of the nb_graph_package object
% 
% Input:
% 
% - obj      : An object of class nb_graph_package
% 
% - varargin : ...,'propertyName',propertyValue,...
%
% Output :
%
% - obj      : The input objects properties are updated.
% 
% Examples:
% 
% obj.set('propertyName',propertyValue,...)
% obj = obj.set('lookupmatrix',{'QUA_PCPI','CPI','KPI'});
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    for ii = 1:2:size(varargin,2)

        propertyName  = varargin{ii};
        propertyValue = varargin{ii + 1};

        switch lower(propertyName)

            case 'bigletter'

                if nb_isScalarLogical(propertyValue) || nb_isScalarNumber(propertyValue)
                    obj.bigLetter = propertyValue;
                else
                    error([mfilename ':: The ' propertyName ' property must be a number. Either 1 (true) or 0 (false).'])
                end  
            
            case 'firstpagenamenor'
                
                if ischar(propertyValue) || iscellstr(propertyValue)
                    obj.firstPageNameNor = propertyValue;
                else
                    error([mfilename ':: The ' propertyName ''' must be given as an string or a cellstr.'])
                end
                    
            case 'firstpagenameeng'
                
                if ischar(propertyValue) || iscellstr(propertyValue)
                    obj.firstPageNameEng = propertyValue;
                else
                    error([mfilename ':: The ' propertyName ''' must be given as an string or a cellstr.'])
                end
                
            case 'flip'

                if isscalar(propertyValue)
                    obj.flip = propertyValue;
                else
                    error([mfilename ':: The input after the ''flip'' property must be an integer, '...
                                     'either 1 or 0.'])
                end       
                
            case 'lookupmatrix'

                if ischar(propertyValue)
                    eval(propertyValue);
                elseif iscell(propertyValue)
                    obj.lookUpMatrix = propertyValue;
                else
                    error([mfilename ':: The input after the ''lookUpMatrix'' property must be a string (filname) or a cell, with the '...
                                     'info on how to match a mnemonics with a variable description (both english and norwegian). For more type help nb_graph_package.'])
                end 
                
            case 'roundoff'
                
                if isscalar(propertyValue) && isnumeric(propertyValue)
                    if propertyValue >= 0
                        obj.roundoff = propertyValue;
                    else
                        error([mfilename ':: The ' propertyName ''' must be given as an integer greater than or equal to 0.'])
                    end
                else
                    error([mfilename ':: The ' propertyName ''' must be given as an integer greater than or equal to 0.'])
                end
                
            case 'userdata'
                    
                obj.userData = propertyValue;        

            otherwise

                error([mfilename ':: Unsupported property ' propertyName ' for class nb_graph_package or you have no access to set it.'])

        end

    end

end
