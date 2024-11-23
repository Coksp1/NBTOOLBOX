function Y = nb_computeMidasForecast(A,B,Y,X,E)
% Syntax:
%
% Y = nb_computeMidasForecast(A,B,Y,X,E)
%
% Description:
%
% Compute forcast of a MIDAS model 
%
% Input:
% 
% - A    : See the equation above. A 1 x 1 double or empty. If not empty
%          a AR component is added to the MIDAS model.
%
% - B    : See the equation above. A nSteps x nexo double. 
%
% - Y    : A 1 x nSteps + 1 double, where the Y(:,1) element must be 
%          the initial values.
%
% - X    : A nexo x 1 double with the exogenous variables of the model or
%          a nexo x 1 x nSteps double (if the regressors change with the
%          forecasting step (e.g. MIDAS beta lag model!))
%
% - E    : A 1 x nSteps double with the residual data. E.g. simulated
%          shocks.
% 
% Output:
% 
% - Y    : The forecast of the endogenous variables as a 1 x nSteps
%          double.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    nSteps = size(Y,2) - 1;
    if isempty(A)
        A = zeros(nSteps,1);
    end
    if size(X,3) > 1
        for t = 1:max(0,nSteps)
            Y(:,t+1) = A(t,:)*Y(:,t) + B(t,:)*X(:,1,t) + E(:,t);
        end
    else
        for t = 1:max(0,nSteps)
            Y(:,t+1) = A(t,:)*Y(:,t) + B(t,:)*X(:,1) + E(:,t);
        end
    end
    
end
