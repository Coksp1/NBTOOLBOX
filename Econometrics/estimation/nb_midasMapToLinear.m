function beta = nb_midasMapToLinear(p,func,AR,constant,nExo,nLags)
% Syntax:
%
% beta = nb_midasMapToLinear(p,AR,constant,nExo,nLags)
%
% Description:
%
% Map from the non-linear estimated parameter to the linear coefficient
% of the MIDAS model, i.e. map from
%
% y = X*f(p) + eps, eps ~ N(0,eps'*eps/nobs) (1)
%
% to
%
% y = X*beta + eps, eps ~ N(0,eps'*eps/nobs) (1)
% 
% Input:
% 
% - p        : A nParam x 1 double vector.
% 
% - func     : A function handle that map from the non-linear parameters to
%              the linear once.
%
% - AR       : true or false. true if AR specification of the MIDAS model  
%              is used.
%
% - constant : true or false. true if constant is included in the model.
%
% - nExo     : Number of exogenous variables of the model, exluding lag and
%              constant.
%
% - nLags    : Number of lags of the exogenous variables.
%
% Output:
% 
% - beta     : A constant + AR + nExo*nLags x 1 double vector.
%
% See also:
% nb_midasFunc
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    nCoeff = nLags*nExo;
    beta   = nan(AR+constant+nCoeff,1);
    ind    = 1;
    if constant
        beta(ind) = p(ind);
        ind       = ind + 1;
    end
    if AR
        beta(ind) = p(ind);
        ind       = ind + 1;
    end
    
    % Parameters in front of lag polynomial
    loc   = ind;
    scale = p(ind);
    loc   = loc + 1;
    
    % Parameters of the lag polynomial 
    for ii = 1:nExo
        beta(ind:ind+nLags-1) = scale*func(p(loc:loc+1)',nLags);
        ind = ind + nLags;
        loc = loc + 2;
    end

end
