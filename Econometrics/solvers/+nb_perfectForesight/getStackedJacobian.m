function JF = getStackedJacobian(Y,inputs,funcs,iter)
% Syntax:
%
% JF = nb_perfectForesight.getStackedJacobian(Y,inputs,funcs,iter)
%
% Description:
%
% Evaluate the Jacobian at the current iteration.
%
% Part of the perfect forseight solver package nb_perfectForesight.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Are we using symbolic deriv?
    if funcs.symbolic
        JF = nb_perfectForesight.getStackedJacobianSymbolic(inputs,funcs,Y,iter);
    else
        JF = nb_perfectForesight.getStackedJacobianAutomatic(inputs,funcs,Y,iter);
    end

end
