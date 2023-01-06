function Y = nb_computeForecastAnticipated(A,B,C,Y,X,E)
% Syntax:
%
% Y = nb_computeForecastAnticipated(A,B,C,Y,X,E)
%
% Description:
%
% Compute forcast of equations on the form; 
%
% Y(:,t+1) = A*Y(:,t) + B*X + C*E
% 
% Input:
% 
% - A    : See the equation above. A nEndo x nEndo 
%                       double.
%
% - B    : See the equation above. A nEndo x nExo 
%          double. 
% 
% - C    : See the equation above. A nEndo x nResidual 
%          double. If C have more pages, it means anticipated shocks.
%
% - Y    : A nendo x nSteps + 1 double, where the Y(:,1) element must be 
%          the initial values.
%
% - X    : A nexo x nSteps double with the exogenous forecast data.
%
% - E    : A nres x nSteps double with the residual data. E.g. simulated
%          shocks.
% 
% Output:
% 
% - Y    : The forecast of the endogenous variables as a nendo x nSteps
%          double.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    numAntPer = size(C,3);
    nSteps    = size(Y,2) - 1;
    for t = 1:max(0,nSteps)
        Y(:,t+1) = A*Y(:,t) + B*X(:,t);
        for j = 1:numAntPer
            Y(:,t+1) = Y(:,t+1) + C(:,:,j)*E(:,t+j-1);
        end
    end
    
end
