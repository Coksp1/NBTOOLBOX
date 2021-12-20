function obj = addVariable(obj,startDate,data,varname)
% Syntax:
%
% obj = addVariable(obj,startDateOfData,Data,Variable)
%
% Description:
%
% Add a new variable to a existing nb_bd object (including all 
% pages)
% 
% Input:
% 
% - obj             : An object of class nb_bd
% 
% - startDate       : The start date of the data of the added
%                     variable. Must be a string or a date object. 
%                     Cannot be outside the window of the dates of  
%                     the object.
% 
% - data            : The data of the added variable. Cannot be
%                     outside the window of the data of the object.
%                     Must be a n x 1 or 1 x n double.
% 
% - varname         : A string with the added variable name. Cannot
%                     be the same as a existing variable. (Then use 
%                     setValue instead)
% 
% Output:
% 
% - obj             : An object of class nb_bd with the added 
%                     variable
% 
% Examples:
% 
% obj = addVariable(obj,'2012Q1',[2;2;2;2],'newVariable');
%
% Written by Per Bjarne Bye

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 4
        error([mfilename ':: All inputs must be given to this function, i.e. addVariable(obj,startDateOfData,Data,Variable)'])
    end

    try 
        varExists = sum(strcmp(varname,obj.variables));
    catch  %#ok<CTCH>
        error([mfilename ':: The input ''Variable'' must be a string.'])
    end

    if varExists
        if ischar(varname)
            error([mfilename ' :: The variable ''' varname ''' already exists. Use setValue.'])
        else
            error([mfilename ' :: The variable ''' varname{1} ''' already exists. Use setValue.'])
        end
    end
    
    % Robust for data on row-form
    if size(data,2) > 1 && size(data,1) == 1
        data = data';
    end
    
    if size(data,2) > 1
        error([mfilename ' :: You can only add a vector of data (one variable) at a time.'])
    end

    size3 = size(data,3);
    
    fullData = getFullRep(obj);
    
    if size(fullData,3)~=size3
        error([mfilename ' :: the Data of the variable you are trying to add, has not the same number of pages as the object. (added: '...
            int2str(size3) ', object: ' int2str(size(fullData,3)) ' )'])
    end
    
    % Interpret the start date (could be a local variable)
    if ischar(startDate) || isstring(startDate)
        [startDate,freq,~] = nb_date.date2freq(startDate,'xls');
        if isempty(obj.frequency)
            obj.frequency = freq;
        end
    end
    startDateAsDate = interpretDateInput(obj,startDate);
    if isempty(obj)

        % Makes it possible to add a variable to a empty nb_bd 
        % object 
        obj = nb_bd(data,'Database1',startDateAsDate,{varname},[],[]);

    else

        startDateAsDate = nb_date.toDate(startDateAsDate, obj.frequency);
        indDate          = startDateAsDate - obj.startDate + 1;
        if indDate < 1 || indDate > obj.numberOfObservations
            error([mfilename ':: the start date of the data (''' startDateAsDate.toString ''') starts before the start date of the object '...
                             '(''' obj.startDate.toString ''') or after the end date of the object (' obj.endDate.toString ')'])
        end
        
        % Check if the existing dataset extends beyond the new data
        num = size(obj.locations,1)-size(data,1) - indDate + 1;
        if num < 0
            newEndDate = obj.endDate - num;
            obj        = obj.expand('',newEndDate,'off');
        end

        dataVec = [nan(indDate-1,1,size3); data; nan(num,1,size3)];
        logVec  = isnan(dataVec);
        newData = [fullData,dataVec];
        
        ind     = isnan(newData);
        numOnes = sum(ind,'all');
        
        if numOnes > 0.5 * numel(newData)
            obj.indicator = 1;
            ind           = ~ind;
            logVec        = ~logVec;
        else
            obj.indicator = 0;
        end

        if obj.sorted
            obj.variables = sort([obj.variables, varname]);
            varInd        = find(strcmp(varname,obj.variables));
            locations     = [ind(:,1:varInd-1,:), logVec, ind(:,varInd:end-1,:)];
            [s1,s2,s3]    = size(locations);
            if s3 > 1
                locations = reshape(locations,[s1,s2*s3]);
            end
            obj.locations = sparse(logical(locations));
            expData       = [fullData(:,1:varInd-1,:), dataVec, fullData(:,varInd:end,:)];
            obj.data      = expData(~isnan(expData(:)));
        else
            obj.variables = [obj.variables, varname];
            expData       = [fullData,dataVec];
            obj.data      = expData(~isnan(expData(:)));
            obj.locations = sparse(logical(ind));
        end
    end
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@addVariable,{startDate,dataVec,varname});
        
    end

end
