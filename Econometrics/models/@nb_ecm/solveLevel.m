function sol = solveLevel(obj)
% Syntax:
%
% sol = solveLevel(obj)
%
% Description:
%
% Convert the standard solution into a solution in only levels.
% 
% Input:
% 
% - obj : An object of class nb_ecm.
% 
% Output:
% 
% - sol : A struct on the same format as the solution property, but now the
%         solution is in level variable only (dependent only!).
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if ~issolved(obj)
        obj = solve(obj);
    end
    
    sol         = obj.solution;
    delta       = sol.A(1,1:end-1); % diff lags
    beta        = sol.A(1,end); % lag1
    AL1R        = [delta,0] - [0,delta];
    AL1R(1)     = 1 + AL1R(1) + beta;
    nLags       = size(sol.A,1) - 1; % Number of lags plus 1
    AL          = [AL1R;eye(nLags),zeros(nLags,1)];
    BL          = sol.B;
    BL(2:end,:) = 0;
    CL          = sol.C;
    CL(end)     = 0;
    sol.A       = AL;
    sol.B       = BL;
    sol.C       = CL;
    sol.endo    = [obj.dependent.name,nb_cellstrlag(obj.dependent.name,nLags)];

end
