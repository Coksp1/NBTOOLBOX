function E = nb_identifyShocks(A,B,C,Y0,X,E,MUy,indY)
% Syntax:
%
% E = nb_identifyShocks(A,B,C,Y0,X,E,MUy,indY)
%
% Description:
%
% Compute forcast of equations on the form; 
%
% Y(:,t) = A*Y(:,t-1) + B*X(:,t) + C*E(:,t)
% 
% But where the Y(:,t) for each iteration is set to its conditional
% restrictions.
%
% Input:
% 
% - A    : See the equation above. A nendo x nendo double.
%
% - B    : See the equation above. A nendo x nexo 
%          double. 
% 
% - C    : See the equation above. A nendo x nresidual 
%          double.
%
% - Y0   : A nendo x 1 double, with the initial values.
%
% - X    : A nexo x nSteps double with the exogenous forecast data.
%
% - E    : A nres x nSteps double with the residual data. E.g. simulated
%          shocks.
% 
% - MUy  : A nvar (<nendo) x nSteps double.
%
% - indY : The location of MUy in Y. First dimension.
%
% Output:
% 
% - E    : Identified shocks, as nShock x nSteps double.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    nSteps = size(MUy,2);
    Yt     = Y0;
    Ys     = Y0;
    for t = 1:max(0,nSteps)
        
        Y         = A*Yt + B*X(:,t);
        MUyt      = MUy(:,t);
        g         = ~isnan(MUyt);
        indYg     = indY(g);
        if ~isempty(indYg)
            Ys(indYg) = MUyt(g);
            yDiff     = Ys(indYg) - Y(indYg);
            gg        = isnan(E(:,t));
            if size(yDiff,1) == 1 && sum(gg) > 1
                E(gg,t) = C(indYg,gg)\yDiff;
            else  
                [~,U] = lu(C(indYg,gg));
                if isempty(U)
                    error([mfilename ':: Check your restrictions or the shocks that should explain those restrictions.'])
                else
                    detC = prod(diag(U));
                    if abs(detC) < 2e-10
                        error([mfilename ':: Check your restrictions or the shocks that should explain those restrictions.'])
                    else
                        E(gg,t) = C(indYg,gg)\yDiff;
                    end
                end
            end
        end
        
        % As we may not condition on all variables, we need to update the
        % consequence on the other variables as well
        Yt = A*Yt + B*X(:,t) + C*E(:,t); 
        
    end
    
end
