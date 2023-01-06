function Y = nb_computeForecast(A,B,C,Y,X,E)
% Syntax:
%
% Y = nb_computeForecast(A,B,C,Y,X,E)
%
% Description:
%
% Compute forcast of equations on the form; 
%
% Y(:,t+1) = A*Y(:,t) + B*X + C*E
% 
% Input:
% 
% - A    : See the equation above. A nEndo x nEndo double.
%
% - B    : See the equation above. A nEndo x nExo double. 
% 
% - C    : See the equation above. A nEndo x nRes 
%          double.
%
% - Y    : A nEndo x nSteps + 1 double, where the Y(:,1) element must be 
%          the initial values.
%
% - X    : A nExo x nSteps double with the exogenous forecast data.
%
% - E    : A nRes x nSteps double with the residual data. E.g. simulated
%          shocks.
% 
% Output:
% 
% - Y    : The forecast of the endogenous variables as a nendo x nSteps
%          double.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    nSteps = size(Y,2) - 1;
    if isempty(A)
        for t = 1:max(0,nSteps)
            Y(:,t+1) = B*X(:,t) + C*E(:,t);
        end
    else
        for t = 1:max(0,nSteps)
            Y(:,t+1) = A*Y(:,t) + B*X(:,t) + C*E(:,t);
        end
    end
    
end
