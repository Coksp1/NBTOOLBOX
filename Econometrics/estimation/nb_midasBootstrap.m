function ysim = nb_midasBootstrap(p,resid,x,constant,func,nExo,AR,draws,method)
% Syntax:
%
% ysim = nb_midasBootstrap(p,resid,x,constant,func,nExo,AR,draws,method)
%
% Description:
%
% Calculate residuals of the MIDAS model given a parameter set.
% 
% Input:
% 
% - p        : A nParam x 1 double vector.
%
% - resid    : A nobs x 1 double with the residuals of the model.
% 
% - x        : A nobs x nExo*nLags double with the exogenous variables of 
%              the model. Except constant.
%
% - constant : true or false. true if constant is included in the model.
%
% - func     : A function handle that map from the non-linear parameters to
%              the linear once. If empty the MIDAS model is unrestricted.
%
% - nExo     : Number of exogenous variables of the model, exluding lag and
%              constant.
%
% - AR       : true or false. true if AR specification of the MIDAS model  
%              is used.
%
% - draws    : Number of draws from the distribution of the dependent
%              variable.
%
% - method   : See the method input to the nb_bootstrap function. Default
%              is 'bootstrap'.
%
% Output:
% 
% - ysim     : A nobs x draws double with the simulated dependent variable 
%              of the model.
%
% See also:
% nb_midasMapToLinear, nb_midasFunc
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 9
        method = 'bootstrap';
    end

    if isempty(func)
        
        % Bootstrap unrestricted MIDAS model
        if constant
            x = [ones(size(x,1),1),x];
        end
        residSim = nb_bootstrap(resid,draws,method);
        residSim = permute(residSim,[3,2,1]);
        ysim     = bsxfun(@plus,x*p,residSim);
        
    else
        
        error([mfilename ':: Bootstrapping a beta lag or almon lag MIDAS model is not yet finished. ',...
                         'Please set the draws option to 1 or use unrestricted MIDAS.'])
        
        % Bootstrap restricted MIDAS model
        nLags = (size(x,2) - constant)/nExo;
        beta  = nb_midasMapToLinear(p,func,AR,constant,nExo,nLags);
        if AR
            yLag = lag(y);
            x    = [yLag,x];
            x    = x(2:end);
        end
        residSim = nb_bootstrap(resid,draws,method);
        residSim = permute(residSim,[3,2,1]);
        ysim     = bsxfun(@plus,x*beta,residSim);
        
    end

end
