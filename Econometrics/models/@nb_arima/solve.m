function obj = solve(obj)
% Syntax:
%
% obj = solve(obj)
%
% Description:
%
% Solve estimated model(s) represented by nb_arima object(s).
% 
% Input:
%
% - obj : A vector of nb_arima objects.
%
% Output:
% 
% - obj : A vector of nb_arima objects, where the solved model(s) is/are 
%         stored in the property solution.
%
% See also:
% nb_model_generic.solveVector 
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    obj  = obj(:);
    nobj = numel(obj);
    if nobj == 0
        error('Cannot solve an empty vector of nb_arima objects.')
    elseif nobj > 1
        for ii = 1:nobj
            try
                obj(ii) = solve(obj(ii)); 
            catch Err
                nb_error([mfilename ':: Cannot solve the model '  int2str(ii) '.', Err])
            end
        end
    else
       
        if ~isestimated(obj)
            error([mfilename ':: Model is not estimated.'])
        end
        res = obj.results;
        opt = obj.estOptions(end);
        if obj.options.recursive_estim
            obj.solution = nb_arima.solveRecursive(res,opt);
        else
            obj.solution = nb_arima.solveNormal(res,opt);
        end
           
    end

end

