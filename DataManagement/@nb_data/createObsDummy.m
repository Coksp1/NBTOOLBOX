function obj = createObsDummy(obj,nameOfDummy,obs,condition)
% Syntax:
%
% obj = createObsDummy(obj,nameOfDummy,obs,condition)
%
% Description:
%
% Creates and adds a dummy variable to the nb_data object. Will
% test the conditions given the date provided.
% 
% Input:
% 
% - obj            : An object of class nb_data.
%
% - nameOfDummy    : Name of the added dummy variable.
%
% - obs            : The obs to test. As an integer.
%
% - condition      : The conditions to test.
%
%                    - '<'  : True before.
% 
%                    - '>'  : True after.
%
%                    - '<=' : True before and including.
%
%                    - '>=' : False before and including.
%
%                    - '==' : True for the given period. 
%
%                    - '~=' : True for all but the given period.
% 
% Output:
% 
% - obj : An object of class nb_data. (With the added dummy variable)
%
% Examples:
%
% obj = nb_ts([1,2;-3,1;-1,3],'',1,{'Var1','Var2'});
% obj = createObsDummy(obj,'Dummy',2,'>');
%
% See also:
% nb_ts
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if ~isnumeric(obs) && mod(obs,1) ~= 0
        error([mfilename ':: The input obs must be an integer.'])
    end

    % check the date input
    ind  = obs - obj.startObs;
    ind  = max(1,ind);
    ind  = min(ind,obj.numberOfObservations);
    rest = obj.numberOfObservations - ind;
    
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
        obj = obj.addOperation(@createTimeDummy,{nameOfDummy,obs,condition});
        
    end

end
