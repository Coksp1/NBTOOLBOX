function obj = rebalance(obj,methods)
% Syntax:
%
% obj = rebalance(obj,methods)
%
% Description:
%
% Rebalance the dataset with a spesific method for each variable.
%
% Caution: If a variable is not assign a spesific method. A AR(1) model
%          with automatic selection of the level of intergration is used
%          to backcast and forecast trailing and leading nan, while a
%          spline method is used to fill in the missing observations 
%          in-sample. See nb_arRebalance and spline for more.
% 
% Input:
% 
% - obj     : An T x nVars object of class nb_ts. Can only have one page.
%
% - methods : A nVars x 3 cell array. First column must be the variable
%             name, the second column must be the function to backcast 
%             and forecast trailing and leading nan, while the third 
%             column must be the function to fill in for nan values
%             in-sample.
%
%             E.g. {'Var1',@(x)nb_arRebalance(x),@(x)nb_spline(x)}
%
%             If 'all' is set as the variable name, the selected options
%             will be applied to all variables.
%
%             If not given or given as empty the default methods will be
%             used.
% 
% Output:
% 
% - obj    : A T x nVars object of class nb_ts.
%
% See also:
% nb_arRebalance, nb_spline
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 2
        methods = {};
    end

    % Leading and trailing nan values of all variables are removed firsy
    [Y,kept] = nb_estimator.removeLeadingAndTrailingNaN(obj.data);
    
    % Check the methods input
    default    = {@(x)nb_arRebalance(x),@(x)nb_spline(x)};
    methodsAll = [obj.variables', repmat(default,[obj.numberOfVariables,1])];
    if ~isempty(methods)
        
        if ~iscell(methods)
            error([mfilename ':: The methods input must be a nVars x 3 cell array.'])
        end
        [R,C] = size(methods);
        if C ~= 3
            error([mfilename ':: The methods input must be a nVars x 3 cell array.'])
        end
        vars = methods(:,1);
        if ~iscellstr(vars)
            error([mfilename ':: The first column of the methods input must be a cellstr.'])
        end
        [test,loc] = ismember(vars,obj.variables);
        if any(~test)
           error([mfilename ':: The following variables is not in the dataset; ' toString(vars(~test))]) 
        end
        methods = [obj.variables', repmat(default,[obj.numberOfVariables,1])];
        for ii = 1:R
            if ~isa(methods{ii,2},'function_handle')
                error([mfilename ':: The second column of the methods input for the variable ' methods{ii,1},...
                                 ' must be a function handle. Is ' class(methods{ii,2})])
            end
            if ~isa(methods{ii,3},'function_handle')
                error([mfilename ':: The third column of the methods input for the variable ' methods{ii,1},...
                                 ' must be a function handle. Is ' class(methods{ii,2})])
            end
            methodsAll(loc(ii),:) = methods(ii,:); 
        end
        
    end
    
    % Fill in missing values
    for ii = 1:size(methodsAll,1)
        % Fill in for in-sample missing values
        Y(:,ii) = methodsAll{ii,3}(Y(:,ii));
        % Fill in for leading and trailing missing values
        Y(:,ii) = methodsAll{ii,2}(Y(:,ii));
    end
    
    % Assign data back to object
    if any(kept)
        obj.data(kept,:) = Y;
    end
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@rebalance,{methods});
        
    end

end
