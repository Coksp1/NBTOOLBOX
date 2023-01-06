function obj = addVariable(obj,startDateOfData,Data,Variable)
% Syntax:
%
% obj = addVariable(obj,startDateOfData,Data,Variable)
%
% Description:
%
% Add a new variable to a existing nb_ts object (including all 
% pages)
% 
% Input:
% 
% - obj             : An object of class nb_ts
% 
% - startDateOfData : The start date of the data of the added
%                     variable. Must be a string or a date object. 
%                     Cannot be outside the window of the dates of  
%                     the object.
% 
% - Data            : The data of the added variable. Cannot be
%                     outside the window of the data of the object.
%                     Must be a double.
% 
% - Variable        : A string with the added variable name. Cannot
%                     be the same as a existing variable. (Then use 
%                     setValue instead)
% 
% Output:
% 
% - obj             : An object of class nb_ts with the added 
%                     variable
% 
% Examples:
% 
% obj = addVariable(obj,'2012Q1',[2;2;2;2],'newVariable');
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 4
        error([mfilename ':: All inputs must be given to this function, i.e. addVariable(obj,startDateOfData,Data,Variable)'])
    end

    try 
        varExists = sum(strcmp(Variable,obj.variables));
    catch  %#ok<CTCH>
        error([mfilename ':: The input ''Variable'' must be a string.'])
    end

    if varExists
        if ischar(Variable)
            error([mfilename ' :: The variable ''' Variable ''' already exists. Use setValue.'])
        else
            error([mfilename ' :: The variable ''' Variable{1} ''' already exists. Use setValue.'])
        end
    end

    if size(Data,2) > 1 && size(Data,1) == 1
        Data = Data';
    end

    size3 = size(Data,3);

    if size(obj.data,3)~=size3
        error([mfilename ' :: the Data of the variable you are trying to add, has not the same number of pages as the object. (added: '...
            int2str(size3) ', object: ' int2str(size(obj.data,3)) ' )'])
    end
    
    % Interpret the start date (could be a local variable)
    startDateOfDataT = interpretDateInput(obj,startDateOfData);
    if isempty(obj)

        % Makes it possible to add a variable to a empty nb_ts 
        % object 
        obj = nb_ts(Data,'Database1',startDateOfDataT,{Variable});

    else

        startDateOfDataT = nb_date.toDate(startDateOfDataT, obj.frequency);
        indDate          = startDateOfDataT - obj.startDate + 1;
        if indDate < 1 || indDate > obj.numberOfObservations
            error([mfilename ':: the start date of the data (''' startDateOfDataT.toString ''') starts before the start date of the object '...
                             '(''' obj.startDate.toString ''') or after the end date of the object (' obj.endDate.toString ')'])
        end

        num = size(obj.data,1)-size(Data,1) - indDate + 1;
        if num < 0
            newEndDate = obj.endDate - num;
            obj = obj.expand('',newEndDate,'nan');
        end

        Data = [nan(indDate-1,1,size3); 
                Data; 
                nan(num,1,size3)];

        if obj.sorted
            obj.variables = sort([obj.variables, Variable]);
            varInd        = find(strcmp(Variable,obj.variables));
            obj.data      = [obj.data(:,1:varInd-1,:), Data, obj.data(:,varInd:end,:)];
        else
            obj.variables = [obj.variables, Variable];
            obj.data      = [obj.data,Data];
        end
    end
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@addVariable,{startDateOfData,Data,Variable});
        
    end

end
