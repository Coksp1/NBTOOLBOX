function opt = nb_getOpt()
% Syntax:
%
% opt = nb_getOpt()
%
% Description:
%
% Get default options given to fminsearch used by the NBTOOLBOX
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    tol = eps;
    opt = optimset('Display','off','MaxFunEvals',10000,...
                   'MaxIter',10000,'TolFun',tol,'TolX',tol);

end


