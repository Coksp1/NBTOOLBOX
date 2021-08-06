function opt = nb_getOpt()
% Syntax:
%
% opt = nb_getOpt()
%
% Description:
%
% Get default options given to fminsearch used by the NBTOOLBOX
%
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    tol = eps;
    opt = optimset('Display','off','MaxFunEvals',10000,...
                   'MaxIter',10000,'TolFun',tol,'TolX',tol);

end


