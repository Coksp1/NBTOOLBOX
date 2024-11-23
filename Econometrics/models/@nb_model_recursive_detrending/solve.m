function obj = solve(obj)
% Syntax:
%
% obj = solve(obj)
%
% Description:
%
% Solve estimated model(s) represented by nb_model_recursive_detrending 
% object(s).
% 
% Input:
%
% - obj : A vector of nb_model_recursive_detrending objects.
%
% Output:
% 
% - obj : A vector of nb_model_recursive_detrending objects, where the  
%         solved model(s) is/are stored in the property solution. 
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if numel(obj) > 1
        obj = nb_callMethod(obj,@solve,@nb_model_recursive_detrending);
        return
    end

    obj.modelIter = solve(obj.modelIter);
    
    % Check which fields are cell arrays, as we want to discard these
    % during merging
    solution1 = obj.modelIter(1).solution;
    fields    = fieldnames(solution1);
    indC      = false(1,length(fields));
    for ii = 1:length(fields)
        indC(ii) = iscell(solution1.(fields{ii}));
    end
    fieldsAsCell = fields(indC);
    
    % Get the solution of all the recursive periods
    sol = struct;
    for mm = 1:length(obj.modelIter)
        sol = nb_realTimeEstimator.mergeResults(sol,rmfield(obj.modelIter(mm).solution,fieldsAsCell));
    end
    
    % Then we set the cell fields
    for ii = 1:length(fieldsAsCell)
        sol.(fieldsAsCell{ii}) = solution1.(fieldsAsCell{ii});
    end
    
    % Assign solution to object
    obj.solution = sol;

end
