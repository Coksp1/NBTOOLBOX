function JF = getJacobianOnePeriod(Y,funcs)
% Syntax:
%
% JF = nb_perfectForesight.getJacobianOnePeriod(funcs,Y,varargin)
%
% Description:
%
% Evaluate the Jacobian at the current iteration
%
% Part of the perfect forseight solver package nb_perfectForesight.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if funcs.symbolic
        nY = size(Y,1);
        V  = funcs.FDeriv(Y);
        I  = funcs.ind(:,1);
        J  = funcs.ind(:,2);
        JF = sparse(I,J,V,nY,nY); 
    else
        myDeriv   = myAD(Y);
        derivator = funcs.F(myDeriv);
        JF        = getderivs(derivator);
    end

end
