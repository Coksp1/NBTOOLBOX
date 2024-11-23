function numCoeff = getNumCoeff(options)
% Syntax:
%
% numCoeff = nb_harmonizeEstimator.getNumCoeff(options)
%
% Description:
%
% Get the number of estimated coefficents
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    numCoeffMax = -inf;
    for mm = 1:length(options.harmonizers)
        harm = options.harmonizers{mm};
        for ii = 1:length(harm)
            numCoeffThis = length(harm(ii).variables); 
            if numCoeffMax < numCoeffThis
                numCoeffMax = numCoeffThis;
            end
        end
    end
    numCoeff = max(options.requiredDegreeOfFreedom,numCoeffMax);

end
