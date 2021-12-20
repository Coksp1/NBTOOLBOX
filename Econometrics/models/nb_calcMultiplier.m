function m = nb_calcMultiplier(dx,dy,r,gross)
% Syntax:
%
% m = nb_calcMultiplier(dx,dy,r,gross)
%
% Description:
%
% Calculate multiplier using the formula (3) page 11 of "Clearing Up the
% Fiscal Multiplier Morass" (2015) by Leeper, Traum and Walker.
%
% Input:
% 
% - dx    : A nObs x nVar x nSim double with the affected variables.
%
% - dy    : A nObs x 1 x nSim double with the policy variable of interest.
%
% - r     : A nObs x 1 x nSim double with the gross or net interest rates.
%
% - gross : Give true if r is the gross interest rate (default) or false
%           if it is the net interest rate.
% 
% Output:
% 
% - m     : A 1 x nVar x nSim double with the calculated multipliers.
%
% See also:
% nb_dsge.calculateMultiplers
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    [nObs,nVar,~] = size(dx);
    [nObsY,nY,~]  = size(dy);
    [nObsR,nR,~]  = size(r);
    if nObs ~= nObsY
        error([mfilename ':: The dy input must has as many rows as the dx input.'])
    end
    if nObs ~= nObsR
        error([mfilename ':: The r input must has as many rows as the dx input.'])
    end
    if nY > 1
        error([mfilename ':: The dy input must be a column vector.'])
    end
    if nR > 1
        error([mfilename ':: The r input must be a column vector.'])
    end
    
    if gross
        realRateGross = r;
    else
        realRateGross = 1 + r;
    end
    R   = cumprod(1./realRateGross,1);
    R   = R(:,ones(1,nVar),:);
    dy  = dy(:,ones(1,nVar),:);
    m   = sum(R.*dx,1)./sum(R.*dy,1);

end
