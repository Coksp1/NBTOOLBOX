function checkDOF(options,numCoeff,T)
% Syntax:
%
% nb_estimator.checkDOF(options,numCoeff,T)
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if isfield(options,'requiredDegreeOfFreedom')
        degreeOfFreedom = options.requiredDegreeOfFreedom;
    else
        degreeOfFreedom = 3;
    end
    dof = T - degreeOfFreedom - numCoeff;
    if dof < 0
        needed = degreeOfFreedom + numCoeff;
        error([mfilename ':: The sample is too short for estimation with the selected options. '...
                         'At least ' int2str(options.requiredDegreeOfFreedom) ' degrees of freedom are required. '...
                         'Which require a sample of at least ' int2str(needed) ' observations.'])
    end

end
