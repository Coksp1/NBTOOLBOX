function obj = createTimeDummy(obj,nameOfDummy,date,condition)
% Syntax:
%
% obj = createTimeDummy(obj,nameOfDummy,date,condition)
%
% Description:
%
% Creates and adds a dummy variable to the nb_ts object. Will
% test the conditions given the date provided.
% 
% Input:
% 
% - obj            : An object of class nb_ts.
%
% - nameOfDummy    : Name of the added dummy variable.
%
% - date           : The date to test. Either a string, a nb_date object
%                    or a 1 x 2 cell array, where each element is either 
%                    a string, a nb_date object.
%
% - condition      : The conditions to test.
%
%                    - '<'  : True before. Not suppored if date is a cell
%                             array.
% 
%                    - '>'  : True after. Not suppored if date is a cell
%                             array.
%
%                    - '<=' : True before and including. Not suppored if 
%                             date is a cell array.
%
%                    - '>=' : False before and including. Not suppored if 
%                             date is a cell array.
%
%                    - '==' : True for the given period (default). 
%
%                    - '~=' : True for all but the given period.
% 
% Output:
% 
% - obj : An object of class nb_ts. (With the added dummy variable)
%
% Examples:
%
% obj = nb_ts(ones(5,2),'','2012',{'Var1','Var2'});
% obj = createTimeDummy(obj,'Dummy','2013','>');
% obj = createTimeDummy(obj,'Dummy2',{'2013','2015'},'==');
% obj = createTimeDummy(obj,'Dummy3',{'2013','2015'},'~=');
%
% See also:
% nb_ts
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 4
        condition = '==';
    end

    % check the date input
    if iscell(date)
        
        if numel(date) ~= 2
            error('If the date is a cell input it must be a cell array.')
        end
        date1T               = interpretDateInput(obj,date{1});
        date2T               = interpretDateInput(obj,date{2});
        dummy                = false(obj.numberOfObservations,1,obj.numberOfDatasets);
        ind1                 = (date1T - obj.startDate) + 1;
        ind1                 = max(ind1,1);
        ind2                 = (date2T - obj.startDate) + 1;
        ind2                 = min(ind2,obj.numberOfObservations);
        dummy(ind1:ind2,:,:) = true;
        switch condition
            case '=='
                % Do nothing
            case '~='
                dummy = ~dummy; 
            otherwise
                error([mfilename ':: Unsupported logical operator ' condition ' when the date input is a cell array.'])
        end 
        
    else
        
        dateT = interpretDateInput(obj,date);
        ind   = dateT - obj.startDate;
        ind   = max(1,ind);
        ind   = min(ind,obj.numberOfObservations);
        rest  = obj.numberOfObservations - ind;

        % Create dummy
        switch condition

            case '<'
                dummy = [true(ind,1,obj.numberOfDatasets);false(rest,1,obj.numberOfDatasets)]; 
            case '>'
                dummy = [false(ind + 1,1,obj.numberOfDatasets);true(rest - 1,1,obj.numberOfDatasets)]; 
            case '<='
                dummy = [true(ind + 1,1,obj.numberOfDatasets);false(rest - 1,1,obj.numberOfDatasets)]; 
            case '>='
                dummy = [false(ind,1,obj.numberOfDatasets);true(rest,1,obj.numberOfDatasets)]; 
            case '=='
                dummy = [false(ind,1,obj.numberOfDatasets);true(1,1,obj.numberOfDatasets);false(rest - 1,1,obj.numberOfDatasets)]; 
            case '~='
                dummy = [true(ind,1,obj.numberOfDatasets);false(1,1,obj.numberOfDatasets);true(rest - 1,1,obj.numberOfDatasets)]; 
            otherwise
                error([mfilename ':: Unsupported logical operator ' condition '.'])
        end
        
    end
    
    % Secure that dummy stops at the same time as the latest of the other
    % series 
    dummy = double(dummy);
    isNaN = all(isnan(obj.data),2);
    for ii = 1:obj.numberOfDatasets
        last = find(~isNaN(:,:,ii),1,'last');
        if ~isempty(last)
            dummy(last+1:end,:,ii) = nan;
        end
    end
    
    % Add the variable to the object
    ind = strcmp(nameOfDummy,obj.variables);
    if any(ind)
        error([mfilename ':: The variable ' nameOfDummy ' already exists.'])
    end
    
    vars = obj.variables;
    vars = [vars,nameOfDummy];
    dat  = [obj.data,dummy];
    if obj.sorted
        [vars,ind] = sort(vars);
        dat        = dat(:,ind,:);
    end
    obj.data      = dat;
    obj.variables = vars; 
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@createTimeDummy,{nameOfDummy,date,condition});
        
    end

end
