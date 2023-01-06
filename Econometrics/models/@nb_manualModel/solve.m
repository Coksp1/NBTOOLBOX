function obj = solve(obj)
% Syntax:
%
% obj = solve(obj)
%
% Description:
%
% Solve estimated model(s) represented by nb_manualModel object(s).
% 
% This method calls the function specisifed by the solveFunc option.
% The inputs to this function are the results property and the (hidden)
% estOptions property!
%
% The output of this function must be a struct with the fields;
% > A    : A nDep x nDep x iter double.
% > B    : A nDep x nExo x iter double.
% > C    : A nDep x nRes x iter double.
% > vcv  : A nDep x nDep x iter double.
% > obs  : A 1 x nDep cellstr with the names of the dependent variables of
%          the model.
% > endo : A 1 x nStates cellstr with all the names of the state 
%          variables. The data on these must be stored in the data field 
%          of estOptions property or in the smoothed field of the results 
%          property.
% > exo  : A 1 x nExo cellstr with the names of the exogenous. Name
%          the contant term 'constant' and the time-trend 'Time-trend', if
%          used. 
% > res  : A 1 x nRes cellstr with the names of the residuals.
%
% Input:
%
% - obj : A vector of nb_manualModel objects.
%
% Output:
% 
% - obj : A vector of nb_manualModel objects, where the solved model(s)  
%         is/are stored in the property solution.
%
% See also:
% nb_model_generic.solveVector, nb_manualEstimator.estimate 
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    obj  = obj(:);
    nobj = numel(obj);
    if nobj == 0
        error('Cannot solve an empty vector of nb_model_generic objects.')
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
        obj.solution = nb_manualModel.solveNormal(obj.results,obj.estOptions(end));
    end

end

