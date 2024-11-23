function obj = solve(obj)
% Syntax:
%
% obj = solve(obj)
%
% Description:
%
% Solve estimated model(s) represented by nb_mfvar object(s).
% 
% Input:
%
% - obj : A vector of nb_mfvar objects.
%
% Output:
% 
% - obj : A vector of nb_mfvar objects, where the solved model(s) is/are 
%         stored in the property solution.
%
% See also:
% nb_model_generic.solveVector 
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    obj  = obj(:);
    nobj = numel(obj);
    if nobj == 0
        error('Cannot solve an empty vector of nb_mfvar objects.')
    elseif nobj > 1
        for ii = 1:nobj
            try
                obj(ii) = solve(obj(ii)); 
            catch Err
                error(['Cannot solve the model '  int2str(ii) '. Error message:: ' Err.message])
            end
        end
    else
       
        if ~isestimated(obj)
            error('Model is not estimated.')
        end
        
        % Set up the estimator
        %------------------------------------------------------
        results = obj.results;
        opt     = obj.estOptions(end);
        if isfield(obj.solution,'identification')
            ident = obj.solution.identification;
        else
            ident = struct();
        end
        if opt.recursive_estim
            tempSol = nb_mfvar.solveRecursive(results,opt,ident);
        else
            tempSol = nb_mfvar.solveNormal(results,opt,ident);
        end

        % Estimate the model
        %------------------------------------------------------
        obj.solution = tempSol;
        
    end

end
