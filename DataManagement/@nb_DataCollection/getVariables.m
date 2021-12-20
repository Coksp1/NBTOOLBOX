function data = getVariables(obj,vars,interpolateDate,method,rename)
% Syntax:
%
% obj = getVariables(obj,vars,interpolateDate,method,rename)
%
% Description:
%
% Get the variables given by the vars input stored in the
% nb_DataCollection object.
% 
% Caution : Be aware that the variables you try to get can only 
%           represent time series or cross-sectional data.
%
% Caution : If the variables represent different frquencies the
%           lowest frequencies will be converted to the highest 
%           frequency.
% 
% Input:
% 
% - obj             : An object of class nb_DataCollection
% 
% - vars            : A cellstr array of the variable you want to 
%                     load.
% 
% - interpolateDate : 
%
%         How to transform the database with the lowest 
%         frequency.
%
%         - 'start' : The interpolated data are taken as given at 
%                     the start of the periods. I.e. use 01.01.2012 
%                     and 01.01.2013 when interpolating data on 
%                     yearly frequency. (Default)                             
% 
%         - 'end'   : The interpolated data are taken as given at 
%                     the end of the periods. I.e. use 31.12.2012 
%                     and 31.12.2013 when interpolating data on 
%                     yearly frequency.
% 
% - method          : The method to use when converting:
%
%                     - 'linear'   : Linear interpolation
%                     - 'cubic'    : Shape-preserving piecewise 
%                                    cubic interpolation 
%                     - 'spline'   : Piecewise cubic spline 
%                                    interpolation  
%                     - 'none'     : No interpolation. All data in  
%                                    between is given by nans 
%                                    (missing values)(Default)
% 
% - rename          : > 'on'  : Renames the prefixes (default)
%                     > 'off' : Do not rename the prefixes
%
%                     For more see the 'rename' option of the 
%                     convert method.
%
% Output:
% 
% - obj        : An object of class nb_ts or nb_cs.
% 
% Examples:
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 5
        rename = 'on';
        if nargin < 4
            method = 'none';
            if nargin < 3
                interpolateDate = 'start';
            end
        end
    end
    
    % Return an empty nb_ts object if the object of interest are
    % itself empty
    if isempty(obj.list.ids)
        data = nb_ts();
        return
    end
    
    % See if the variables are stored in the first object
    type     = '';
    temp     = obj.list.getFirst();
    tempData = temp.getElement();
    if ~isempty(tempData)
        tempData = tempData.keepVariables(vars);
        if ~isempty(tempData)
            type = class(tempData);
            data = tempData;
        end
    end
    
    % See if the variables are stored in the rest of the objects
    while temp.hasNext
        
        temp     = temp.getNext();
        tempData = temp.getElement();
        if ~isempty(tempData)
            tempData = tempData.keepVariables(vars);
            if ~isempty(tempData)

                if ~isempty(type)

                    ret = isa(tempData,type);
                    if ret == 0
                        error([mfilename ':: It is not possible to merge an object of class ' class(tempData) ' with an object of class ' type '.'])
                    end
                    data = data.merge(tempData,interpolateDate,method,rename);

                else
                    type = class(tempData);
                    data = tempData; 
                end

            end
        end
        
    end

end
