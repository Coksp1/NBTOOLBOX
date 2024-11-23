function obj = checkExpressions(obj,expression,shift)
% Syntax:
%
% obj = checkExpressions(obj,expression)
% obj = checkExpressions(obj,expression,shift)
%
% Description:
%
% Check expressions, and add to dataset
% 
% Input:
% 
% - obj        : An object of class nb_ts
%
% - expression : A cell on the format:
%
%                {Name1,  expression1,   description1;...
%                 Name2,  expression2,   description2};
%
%                The first column sets the name of the created variable.
%           
%                The second column sets the expression to apply to the
%                existing variables in the object. All methods of the 
%                nb_math_ts class that perserve the time span are 
%                supported in expression. You can also call user defined 
%                functions, as long as they take and return a nb_math_ts 
%                object. A nb_math_ts object is just a double with a time
%                dimension! To get a list of all the methods of the 
%                nb_math_ts class use; methods('nb_math_ts'). 
%
%                Caution: expression2 can depend on the Name1 variable.
%                Caution: If Name1 is a name of an existing variable in
%                         the object, it will be replaced.
% 
% - shift      : An object of class nb_ts storing the shift/trend 
%                variables. These are added to the matching variable 
%                before the transformations are applied. If empty, this
%                input is ignored. Default is [].
%
% Output:
% 
% - obj        : An object of class nb_ts
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 3
        shift = [];
    end

    % Get data and variables to be forecast
    vars  = obj.variables;
    dataF = obj.data;

    % Add shift variables
    if ~isempty(shift)
        
        shiftVariables = shift.variables;
        shiftD         = shift.data;  
        [ind,indS]     = ismember(shiftVariables,vars);
        indS           = indS(ind);
        [indM,indMS]   = ismember(shiftVariables,strcat(vars,'_multshift'));
        indMS          = indMS(indM);
        d              = size(shiftD,1) - size(dataF,1);
        if d < 0
            error([mfilename ':: The shift/trend data has not the correct number of observations.'])
        else
            shiftD = shiftD(1:end-d,:); 
        end
        dataF(:,indMS,:) = dataF(:,indMS,:).*shiftD(:,indM);
        dataF(:,indS,:)  = dataF(:,indS,:) + shiftD(:,ind);
    end
    
    % Check each expression
    dataTS = nb_math_ts(dataF,obj.startDate);
    dataN  = obj.data;
    for ii = 1:size(expression,1)
        expr = expression{ii,2};
        try
            dataT = nb_eval(expr,vars,dataTS);
        catch Err
            nb_error([mfilename ':: Error while evaluation expression; ' expression{ii,1} ' = ' expr '.'], Err)
        end
        
        % To make it possible to use newly created variables in the 
        % expressions to come, we must append it in this way
        if ~any(strcmp(expression{ii,1},vars))
            dataTS = horzcatfast(dataTS,dataT); 
            dataN  = [dataN,double(dataT)]; %#ok<AGROW>
            vars   = [vars,expression{ii,1}]; %#ok<AGROW>
        else
            ind  = strcmp(expression{ii,1},vars);
            test = max(abs(dataTS.data(:,ind) - double(dataT)));
            if test > eps^(1/3)
                error([mfilename ':: The variable ' expression{ii,1} ' already exist in the data of the model, with other observations! ',...
                    'Error while evaluation expression; ' expression{ii,1} ' = ' expr '.'])
            end
        end
        
    end
    
    if obj.sorted
        [vars,ind] = sort(vars);
        dataN      = dataN(:,ind,:);
    end
    
    % Update properties
    obj.data      = dataN;
    obj.variables = vars;    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@checkExpressions,{expression,shift});
        
    end
    
end
