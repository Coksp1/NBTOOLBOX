function obj = setValue(obj,VarName,Value,startDateOfValues,endDateOfValues,pages)
% Syntax:
%
% obj = setValue(obj,VarName,Value,startDateOfValues,...
%                endDateOfValues,pages)
%
% Description:
%
% Set some values of the dataset(s). (Only one variable at a time.)
% You cannot use dates outside the objects dates (i.e. outside 
% obj.startDate:obj.endDate)
%
% Input:
% 
% - obj     : An object of class nb_ts
% 
% - VarName : The variable name of the variable you want to set 
%             some values of. As a string
% 
% - Value   : The values you want to assign to the variable. Must 
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
% - pages   : At which pages you want to set the values of a
%             variable. Must be a numerical index of the pages you 
%             want to set.
%             E.g. if you want to set the values of the 3 first 
%             datasets (pages of the data) of the object. And the 
%             number of datasets of the object is larger then 3. 
%             You can use; 1:3. If empty all pages must be set.
% 
% Output:
% 
% - obj : An nb_ts object where the data of the given variable has
%         been set.
% 
% Examples:
% 
% obj = nb_ts([2;3;4],'','2012',{'Var1'});
%
% obj = obj.setValue('Var1',[1;2;3]);
% obj = obj.setValue('Var1',2,'2013','2013',1);
% obj = obj.setValue('Var1',[1;2;3],'2012','2014');
%
% See also
% addVariable
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 6
        pages = 1:obj.numberOfDatasets;
        if nargin < 5
            endDateOfValues = '';
            if nargin < 4
                startDateOfValues = '';
                if nargin<3
                    error([mfilename,':: All but the two last inputs must be provided. I.e. setValue(obj,VarName,Value)'])
                end
            end
        end
    end

    if isempty(obj.variables)
        error([mfilename,':: cannot set a value for a dataset which has no variables'])
    end

    if size(Value,2) > 1
        error([mfilename,':: data must be a vertical vector of numbers (double)'])
    end

    % Find the pages
    if ~isempty(pages)
        m = max(pages);
        if m > obj.numberOfDatasets
            error([mfilename ':: The object consist only of ' int2str(obj.numberOfDatasets) ' datasets. You are trying to set '
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
    end

    % Find the end date of the values index
    if isempty(endDateOfValues)
        indEnd = obj.numberOfObservations;
    else
        endDateOfValuesT = interpretDateInput(obj,endDateOfValues);
        indEnd           = endDateOfValuesT - obj.startDate + 1;
    end

    % Find the variable index
    Var_id = find(strcmp(VarName,obj.variables),1);

    % Assign the data
    try
        obj.data(indStart:indEnd,Var_id,pages) = Value;
    catch Err

        if isempty(Var_id)
            error([mfilename,':: variable ',VarName,' do not exist in the dataset'])
        elseif indEnd - indStart < 0
            error([mfilename ':: The ''endDateOfValues'' (' endDateOfValuesT.toString ') is before the ''startDateOfValues'' (' startDateOfValuesT.toString ').'])
        elseif (indEnd - indStart + 1) ~= size(Value,1)
            error([mfilename,':: Number of Dates (' int2str(indEnd - indStart+ 1) ') should be equal to the number of values (' int2str(size(Value,1)) ')'])
        elseif indStart < 1 || indStart > obj.numberOfObservations
            error([mfilename,':: the ''startDateOfValues'' (' startDateOfValuesT.toString ') is outside the range of the database: [''' obj.startDate.toString ''':''' obj.endDate.toString ''']'])
        elseif indEnd < 1 || indEnd > obj.numberOfObservations
            error([mfilename,':: the ''endDateOfValues'' (' endDateOfValuesT.toString ') is outside the range of the database: [''' obj.startDate.toString ''':''' obj.endDate.toString ''']'])
        else
            rethrow(Err);
        end 

    end
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@setValue,{VarName,Value,startDateOfValues,endDateOfValues,pages});
        
    end

end
