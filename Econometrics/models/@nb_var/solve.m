function obj = solve(obj)
% Syntax:
%
% obj = solve(obj)
%
% Description:
%
% Solve estimated model(s) represented by nb_var object(s).
% 
% Input:
%
% - obj : A vector of nb_var objects.
%
% Output:
% 
% - obj : A vector of nb_var objects, where the solved model(s) is/are 
%         stored in the property solution.
%
% See also:
% nb_model_generic.solveVector 
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj  = obj(:);
    nobj = numel(obj);
    if nobj == 0
        return
    elseif nobj > 1
        for ii = 1:nobj
            try
                obj(ii) = solve(obj(ii)); 
            catch Err
                error([mfilename ':: Cannot solve the model '  int2str(ii) '. Error message:: ' Err.message])
            end
        end
    else
       
        if ~isestimated(obj)
            error([mfilename ':: Model is not estimated.'])
        end
        
        % Solve the model
        %------------------------------------------------------
        results = obj.results;
        opt     = obj.estOptions(end);
        if isfield(obj.solution,'identification')
            ident = obj.solution.identification;
        else
            ident = struct();
        end
        if opt.recursive_estim
            tempSol = nb_var.solveRecursive(results,opt,ident);
        else
            tempSol = nb_var.solveNormal(results,opt,ident);
        end

        % Assign solution
        %------------------------------------------------------
        obj.solution = tempSol;
        
    end

end
