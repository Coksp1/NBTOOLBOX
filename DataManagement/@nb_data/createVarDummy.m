function obj = createVarDummy(obj,nameOfDummy,varargin)
% Syntax:
%
% obj = createVarDummy(obj,nameOfDummy,varargin)
%
% Description:
%
% Creates and adds a dummy variable to the nb_data object. Will
% test the conditions given for the variable provided by the
% testedVariable input.
% 
% Input:
% 
% - obj            : An object of class nb_data.
%
% - nameOfDummy    : Name of the added dummy variable.
%
% - varargin       : The conditions to test.
%
%                    - '<'  : Less than. Second input must be a 
%                             double (scalar), an nb_data object
%                             (if more variables it must be less 
%                             then all the stored variables) or a 
%                             string with the variable to test 
%                             against. The third input must either 
%                             be '|' or '&' indicating if you want 
%                             to check that this condition and 
%                             ('&') or or ('|') the next is 
%                             satisfied. The and operator(s) will 
%                             have presedens over the or operator.
% 
%                    - '>'  : Greater than. (Or else same as '<')
%
%                    - '<=' : Less than or equal to. (Or else same  
%                             as '<')
%
%                    - '>=' : Less than or equal to. (Or else same  
%                             as '<')
%
%                    - '==' : Equal to. (Or else same as '<') 
%
%                    - '~=' : Not equal to. (Or else same as '<') 
% 
% Output:
% 
% - obj : An object of class nb_data. (With the added dummy variable)
%
% Examples:
%
% obj = nb_data([1,2;-3,1;-1,3],'',1,{'Var1','Var2'});
% obj = createVarDummy(obj,'Dummy','Var1','>',0,'&');
% obj = createVarDummy(obj,'Dummy','Var1','>','Var2','&');
% obj = createVarDummy(obj,'D2','Var1','>',0,'|','Var2','<',1,'&');
% obj = createVarDummy(obj,'D2','Var1','>',0,'&','Var2','<',1,'&');
%
% See also:
% nb_ts
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 3
        return
    end
    
    % Get the restrictions to test
    variables  = varargin(1:4:end);
    conditions = varargin(2:4:end);
    tests      = varargin(3:4:end);
    operators  = varargin(4:4:end);
    
    if rem(size(varargin,2),4) ~= 0
        error([mfilename ':: The optional input must come in quadruplet.'])
    end
    
    % Group the conditions after presendens (i.e. '&' have 
    % presedens over '|')
    ind = find(strcmp(operators,'|'));
    if isempty(ind)
        ind = size(operators,2);
    else
        if ind(end) ~= size(operators,2)
            ind = [ind,size(operators,2)];
        end
    end
    oldInd = 1;
    dummy  = false(obj.numberOfObservations,1,obj.numberOfDatasets);
    for ll = 1:length(ind)
        
        % Test each group (with & operator)
        varsTemp       = variables(oldInd:ind(ll));
        testsTemp      = tests(oldInd:ind(ll));
        conditionsTemp = conditions(oldInd:ind(ll));
        %operatorsTemp  = operators(oldInd:ind);
        
        dummyT = true(obj.numberOfObservations,1,obj.numberOfDatasets);
        for ii = 1:size(testsTemp,2)

            % Get the data to test against
            var     = varsTemp{ii};
            indVar  = strcmp(var,obj.variables);
            varData = obj.data(:,indVar,:);
            
            condition = conditionsTemp{ii};
            tested    = testsTemp{ii};
            if isa(tested,'nb_data')
                logi = testAgainstObject(condition,tested,varData);
            elseif ischar(tested)
                logi = testAgainstVar(condition,tested,varData,obj);
            elseif isnumeric(tested) && isscalar(tested)
                logi = testAgainstScalar(condition,tested,varData);
            else
                error([mfilename ':: All tested inputs must be either a nb_data object or a double (scalar).'])
            end
            dummyT = dummyT & logi;

        end
        
        dummy  = dummy | dummyT;
        oldInd = ind(ll) + 1;
        
    end
    
    % Add the variable to the object
    ind = strcmp(nameOfDummy,obj.variables);
    if any(ind)
        error([mfilename ':: The variable ' nameOfDummy ' already exists.'])
    end
    
    vars = [obj.variables,nameOfDummy];
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
        obj = obj.addOperation(@createVarDummy,[{nameOfDummy}, varargin]);
        
    end

end

%==================================================================
% Sub
%==================================================================
function ind = testAgainstObject(condition,tested,varData)

    dim3   = size(varData,3);
    tested = double(tested);
    if size(tested,3) == 1 
        tested = repmat(tested,[1,1,dim3]);
    end
    
    if size(tested,1) ~= size(varData,1)
        error([mfilename ':: When the a restriction is added as an nb_data object. '...
            'It must have as many observations as the object which the dummy variable is added to.'])
    elseif size(tested,3) ~= dim3
        error([mfilename ':: When the a restriction is added as an nb_data object. '...
            'It must have as many pages (or only one page) as the object which the '...
            'dummy variable is added to.'])
    end
       
    sizeTested = size(tested,2);
    if sizeTested > 1
        varData = repmat(varData,[1,sizeTested,1]);
    end
    
    % Vectorize    
    tested  = tested(:);   
    varData = varData(:);

    switch condition
        
        case '<'
            ind = varData < tested; 
        case '>'
            ind = varData > tested;
        case '<='
            ind = varData <= tested;
        case '>='
            ind = varData >= tested;
        case '=='
            ind = varData == tested;
        case '~='
            ind = varData ~= tested;
        otherwise
            error([mfilename ':: Unsupported logical operator ' condition '.'])
    end
    
    ind = reshape(ind,[],sizeTested,dim3);
    ind = all(ind,2);

end

function ind = testAgainstVar(condition,tested,varData,obj)

    ind = strcmp(tested,obj.variables);
    if ~any(ind)
        error([mfilename 'The variable ' tested ' does not exist in the object.'])
    end
    dim3   = size(varData,3);
    tested = obj.data(:,ind,:);
    
    % Vectorize    
    tested  = tested(:);   
    varData = varData(:);

    switch condition
        
        case '<'
            ind = varData < tested; 
        case '>'
            ind = varData > tested;
        case '<='
            ind = varData <= tested;
        case '>='
            ind = varData >= tested;
        case '=='
            ind = varData == tested;
        case '~='
            ind = varData ~= tested;
        otherwise
            error([mfilename ':: Unsupported logical operator ' condition '.'])
    end
    
    ind = reshape(ind,[],1,dim3);

end

function ind = testAgainstScalar(condition,tested,varData)
  
    % Vectorize
    dim3    = size(varData,3);
    varData = varData(:);

    switch condition
        
        case '<'
            ind = varData < tested; 
        case '>'
            ind = varData > tested;
        case '<='
            ind = varData <= tested;
        case '>='
            ind = varData >= tested;
        case '=='
            ind = varData == tested;
        case '~='
            ind = varData ~= tested;
        otherwise
            error([mfilename ':: Unsupported logical operator ' condition '.'])
    end
    
    ind = reshape(ind,[],1,dim3);

end
