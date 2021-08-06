function Y = nb_computeForecastAnticipatedBP(A,B,C,ss,Y,X,E,states)
% Syntax:
%
% Y = nb_computeForecastAnticipatedBP(A,B,C,ss,Y,X,E,states)
%
% Description:
%
% Compute forcast of equations on the form; 
%
% Y(:,t+1) = ss{s(t+1)} + A{s(t+1)}*(Y(:,t) - ss{s(t+1)}) + 
%            B{s(t+1)}*X(:,t+1) + C{s(t+1)}*E(:,t+1)
% 
% With unanticipated switching of parameters (also possibly affecting the 
% steady-state)
%
% Input:
% 
% - A      : See the equation above. A cell array, each element must be a 
%            nEndo x nEndo double.
%
% - B      : See the equation above. A cell array, each element must be a 
%            nEndo x nExo double.
% 
% - C      : See the equation above. A cell array, each element must be a 
%            nEndo x nResidual double. If C have more pages, it means 
%            anticipated shocks.
%
% - ss     : A cell array with the steady-state of the model. Each element
%            must be a nEndo x 1 double.
%
% - Y      : A nEndo x nSteps + 1 double, where the Y(:,1) element must be 
%            the initial values.
%
% - X      : A nExo x nSteps double with the exogenous forecast data.
%
% - E      : A nRes x nSteps double with the residual data. E.g. simulated
%            shocks.
% 
% - states : A vector indicating which state we are going to be in at each
%            forecasting steps. A nSteps double, not including the
%            state of the period of the initial condition.
%
% Output:
% 
% - Y    : The forecast of the endogenous variables as a nEndo x nSteps
%          double.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    numAntPer = size(C{1},3);
    nSteps    = size(Y,2) - 1;
    for t = 1:max(0,nSteps)   
        % states does not contain initial conditions as Y, so therefore
        % indexing with t here should correspond timewise 
        Y(:,t+1) = A{states(t)}*(Y(:,t) - ss{states(t)}) + B{states(t)}*X(:,t);
        for j = 1:numAntPer
            Y(:,t+1) = Y(:,t+1) + C{states(t)}(:,:,j)*E(:,t+j-1);
        end
        Y(:,t+1) = Y(:,t+1) + ss{states(t)}; 
    end
    
end
