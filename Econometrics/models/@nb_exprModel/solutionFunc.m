function Z = solutionFunc(Z,t,E,h,beta,depTransFunc,depLagFunc,exoFuncs,nLags,nExo,locDep,nDep)
% Syntax:
%
% yPred = nb_exprModel.solutionFunc(Z,t,E,h,beta,depTransFunc,...
%           depLagFunc,exoFuncs,nLags,nExo,locDep,nDep)
%
% Description:
%
% The function that is used to forecast a model of class nb_exprModel.
%
% Input:
%
% - Z    : A nObs x nVar double with the data of the model. 
%
% - t    : The period to forecast. t <= nObs.
%
% - E    : A nRes x nSteps double with the values on the residuals.
%
% - h    : The forecasting step.
% 
% - beta : The parameters of the model as a 1 x nDep cell array. Each
%          element contains a nExo(ii) x 1 double with the parameters of
%          equation ii.
%
% Output
%
% - Z : A nObs x nVar double with the data of the model, and where the
%       forecast is been filled in at Z(t,locDep). 
%
% See also:
% nb_exprModel.solveRecursive
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Predict left hand side expression
    for ii = 1:nDep
        
        kk = locDep(ii);
        
        if isnan(Z(t,kk))
        
            % Add contribution of right hand side variables (may include lags
            % of dependent)
            Z(t,kk) = 0;
            for jj = 1:nExo(ii)
                Xjj     = exoFuncs{ii}{jj}(Z,nLags+1:t);
                Z(t,kk) = Z(t,kk) + beta{ii}(jj)*Xjj(end);
            end

            % Add contribution of own lag due to growth or diff expressions 
            % used for the dependent variable
            Z(t,kk) = Z(t,kk) + depLagFunc{ii}(Z,t) + E(ii,h);

            % Map to dependent variable
            Z(t,kk) = depTransFunc{ii}(Z(t,kk));
            
        end
        
    end 

end
