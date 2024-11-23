function obj = addVariable(obj,startObsOfData,Data,Variable)
% Syntax:
%
% obj = addVariable(obj,startObsOfData,Data,Variable)
%
% Description:
%
% Add a new variable to a existing nb_data object (including all 
% pages)
% 
% Input:
% 
% - obj             : An object of class nb_data
% 
% - startObsOfData  : The start observation of the data of the added
%                     variable. Must be an integer. Cannot be outside
%                     the window of the dates of the object. If empty,
%                     1 is default.
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
% - obj             : An object of class nb_data with the added 
%                     variable
% 
% Examples:
% 
% obj = addVariable(obj,'2012Q1',[2;2;2;2],'newVariable');
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 4
        error([mfilename ':: All inputs must be given to this function, i.e. addVariable(obj,startObsOfData,Data,Variable)'])
    end

    if isempty(startObsOfData)
        startObsOfData = 1;
    end
    
    try 
        varExists = sum(strcmp(Variable,obj.variables));
    catch 
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

    if isempty(obj)

        % Makes it possible to add a variable to a empty nb_ts 
        % object 
        obj = nb_ts(Data,'Database1',startObsOfData,{Variable});

    else

        indObs  = startObsOfData - obj.startObs + 1;
        if indObs < 1 || indObs > obj.numberOfObservations

            error([mfilename ':: the start obs of the data (''' int2str(startObs) ''') starts before the start date of the object '...
                             '(''' int2str(obj.startObs) ''') or after the end date of the object (' int2str(obj.endObs) ')'])

        end

        num = size(obj.data,1) - size(Data,1) - indObs + 1;
        if num < 0
            newEndObs = obj.endObs - num;
            obj       = obj.expand('',newEndObs,'nan');
        end

        Data = [nan(indObs-1,1,size3); 
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
