function resid = nb_midasResiduals(p,y,x,constant,func,nExo,AR)
% Syntax:
%
% resid = nb_midasResiduals(p,y,x,constant,func,nExo,AR)
%
% Description:
%
% Calculate residuals of the MIDAS model given a parameter set.
% 
% Input:
% 
% - p        : A nParam x 1 double vector.
%
% - y        : A nobs x 1 double with the dependent variable of the model.
% 
% - x        : A nobs x nExo*nLags double with the exogenous variables of 
%              the model. Except constant.
%
% - constant : true or false. true if constant is included in the model.
%
% - func     : A function handle that map from the non-linear parameters to
%              the linear once.
%
% - nExo     : Number of exogenous variables of the model, exluding lag and
%              constant.
%
% - AR       : true or false. true if AR specification of the MIDAS model  
%              is used.
%
% Output:
% 
% - resid : A nobs x 1 double with the residuals of the model.
%
% See also:
% nb_midasMapToLinear, nb_midasFunc
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    nLags = (size(x,2) - constant)/nExo;
    beta  = nb_midasMapToLinear(p,func,AR,constant,nExo,nLags);
    if AR
        yLag = nb_lag(y);
        x    = [yLag,x];
        x    = x(2:end);
        y    = y(2:end);
    end
    resid = y - x*beta;

end
