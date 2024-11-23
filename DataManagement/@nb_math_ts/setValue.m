function obj = setValue(obj,Value,startDateOfValues,endDateOfValues,pages,ignore)
% Syntax:
%
% obj = setValue(obj,Value,startDateOfValues,...
%                endDateOfValues,pages)
%
% Description:
%
% Set some values of the dataset(s). 
% You cannot use dates outside the objects dates (i.e. outside 
% obj.startDate:obj.endDate)
%
% Input:
% 
% - obj     : An object of class nb_math_ts
%  
% - Value   : The values you want to assign to the object. Must 
%             be a numerical vector (with the same number of pages  
%             as given by pages or as the number of dataset the  
%             object consists of.) Cannot be outside the window of  
%             the data of the object.
%
% - startDateOfValues : A date string with the start date of the
%                       data. If not given or given as a empty 
%                       string it will assume that the setted data 
%                       start at the startDate of the object.
%
%                       This input could also be an object which is
%                       of a subclass of the nb_date class.
% 
% - endDateOfValues   : A date string with the end date of the
%                       data. If not given or given as a empty 
%                       string it will assume that the setted data
%                       end at the endDate of the object.
%
%                       This input could also be an object which is
%                       of a subclass of the nb_date class
% 
% - pages   : At which pages you want to set the values of.
%             Must be a numerical index of the pages you 
%             want to set.
%             E.g. if you want to set the values of the 3 first 
%             datasets (pages of the data) of the object. And the 
%             number of datasets of the object is larger then 3. 
%             You can use; 1:3. If empty all pages must be set.
%
% - ignore  : A logical true/false for ignoring that startDateOfValues and 
%             endDateOfValues are after the realEndDate of the time series.
% 
% Output:
% 
% - obj : An nb_math_ts object where the data has been set.
% 
% Examples:
% 
% obj = nb_math_ts([2;2;2;2],'2012');
%
% obj = obj.setValue([1;2;3;4]);
% obj = obj.setValue(2,'2013','2013',1);
% obj = obj.setValue([1;2;3],'2012','2014');
%
% Written by Atle Loneland

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen
    if nargin < 6
        ignore = false;
        if nargin < 5
            pages = 1:obj.dim3;
            if nargin < 4
                endDateOfValues = '';
                if nargin < 3
                    startDateOfValues = '';
                    if nargin<2
                        error([mfilename,':: All but the two last inputs must be provided. I.e. setValue(obj,VarName,Value)'])
                    end
                end
            end
        end
    end

    if size(Value,2) > 1
        error([mfilename,':: data must be a vertical vector of numbers (double)'])
    end
    
    if ~nb_isLogical(ignore)
        error([mfilename,':: ignore must be a logical.'])
    end

    % Find the pages
    if ~isempty(pages)
        m = max(pages);
        if m > obj.dim3
            error([mfilename ':: The object consist only of ' int2str(obj.dim3) ' datasets. You are trying to set '
                             'values for the dataset ' int2str(m) ', which is not possible.'])
        end 
    else
        error([mfilename ':: You cannot set the values of no pages at all!'])
    end

    % Find the start date of the values index
    if isempty(startDateOfValues)
        indStart = 1;
    else
        startDateOfValuesT = interpretDateInput(obj,startDateOfValues);
        indStart           = startDateOfValuesT - obj.startDate + 1;
        
        % Should we allow for this case?
        if (startDateOfValuesT>nb_date.date2freq(obj.getRealEndDate) && ignore) 
            return
        end
    end

    % Find the end date of the values index
    if isempty(endDateOfValues)
        indEnd = obj.dim1;
    else
        endDateOfValuesT = interpretDateInput(obj,endDateOfValues);
        if (endDateOfValuesT>nb_date.date2freq(obj.getRealEndDate) && ignore)
            endDateOfValuesT = nb_date.date2freq(obj.getRealEndDate);
        elseif (endDateOfValuesT>nb_date.date2freq(obj.getRealEndDate))
            error([mfilename ':: The ''endDateOfValues'' (' endDateOfValuesT.toString ') is after the ''realEndDate'' (' obj.getRealEndDate.toString '). To ignore this error set the input ''ignore'' as true.']) 
        end
        indEnd           = endDateOfValuesT - obj.startDate + 1;
    end

    % Assign the data
    try
        % Should we allow to set values after the real end date?
        if (size(Value,1) > 1 && ignore)
            Value                       = Value(1:indEnd-indStart+1);    
        end
        obj.data(indStart:indEnd,pages) = Value;
    catch Err

        if indEnd - indStart < 0
            error([mfilename ':: The ''endDateOfValues'' (' endDateOfValuesT.toString ') is before the ''startDateOfValues'' (' startDateOfValuesT.toString ').'])
        elseif indStart < 1 || indStart > dim1
            error([mfilename,':: the ''startDateOfValues'' (' startDateOfValuesT.toString ') is outside the range of the database: [''' obj.startDate.toString ''':''' obj.endDate.toString ''']'])
        elseif (indEnd - indStart + 1) ~= size(Value,1)
            error([mfilename,':: Number of Dates (' int2str(indEnd - indStart+ 1) ') should be equal to the number of values (' int2str(size(Value,1)) ')'])
        elseif indEnd < 1 || indEnd > dim1
            error([mfilename,':: the ''endDateOfValues'' (' endDateOfValuesT.toString ') is outside the range of the database: [''' obj.startDate.toString ''':''' obj.endDate.toString ''']'])
        else
            rethrow(Err);
        end 

    end
    
end
