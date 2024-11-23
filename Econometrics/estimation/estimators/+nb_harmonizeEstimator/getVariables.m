function [dependent,variables] = getVariables(options)
% Syntax:
%
% [dependent,variables] = nb_harmonizeEstimator.getVariables(options)
%
% Description:
%
% Get the variables used by the harmonizers.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if strcmpi(options.algorithm,'lossFunc')
        dependent       = {};
        restictionsVars = {};
        for mm = 1:length(options.harmonizers)
            dependent       = [dependent, nb_harmonizeEstimator.getVariablesFromLossFunc(options.harmonizers{mm})]; %#ok<AGROW>
            restictionsVars = [restictionsVars, nb_harmonizeEstimator.getVariablesFromRestrictions(options.harmonizers{mm})]; %#ok<AGROW>
        end
        dependent = unique(dependent);
        variables = unique([dependent,restictionsVars]);
    else
        dependent  = {};
        parameters = {};
        for mm = 1:length(options.harmonizers)
            harm = options.harmonizers{mm};
            for ii = 1:length(harm)
                if iscell(harm(ii).parameters)
                    param = nb_rowVector(harm(ii).parameters);
                else
                    param = {};
                end
                parameters = [parameters,param]; %#ok<AGROW>
                dependent  = [dependent,{harm(ii).restricted},nb_rowVector(harm(ii).variables)]; %#ok<AGROW>
            end
        end
        dependent = unique(dependent);
        variables = unique([dependent,parameters]);
    end

end
