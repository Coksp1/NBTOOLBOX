function [solution,err] = derivativeNB(parser,solution,paramV)
% Syntax:
%
% solution       = nb_dsge.derivativeNB(parser,solution,paramV)
% [solution,err] = nb_dsge.derivativeNB(parser,solution,paramV)
%
% Description:
%
% Take derivatives of the DSGE model.
% 
% See also:
% nb_dsge.derivative
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    err = '';
    if isfield(solution,'ssOriginal')
        ss = solution.ssOriginal;
    else
        ss = solution.ss;
    end
    
    % Take derivatives of the structural equation
    [~,type,ssOrd] = nb_dsge.getOrderingNB(parser,ss);   
    if isfield(parser,'derivativeFunc') % Symbolic derivatives!
        nEqs              = max(parser.derivativeInd(:,1));
        nCol              = size(type,2);
        deriv             = parser.derivativeFunc(ssOrd,paramV);
        solution.jacobian = sparse(parser.derivativeInd(:,1),parser.derivativeInd(:,2),deriv,nEqs,nCol);
    else % Automatic derivatives
        myDeriv           = myAD(ssOrd);
        derivator         = parser.eqFunction(myDeriv,paramV);
        solution.jacobian = getderivs(derivator);
    end
    
    if any(~isfinite(solution.jacobian(:)))
        err = [mfilename ':: There are nan or inf in the jacobian.'];
        if nargout == 1
            error(err)
        else
            return
        end
    end
    solution.jacobianType = type;

    % Take 2-order derivatives of loss function under optimal monetary
    % policy using symbolic derivatives
    if parser.optimal || parser.optimalSimpleRule
        solution = nb_dsge.derivativeLossFunction(parser,solution,paramV);
    end
    
    % Take derivative of the obs_model
    if ~isempty(parser.obs_equations)
        
        % It is assumed that the obs_model is linear, so the steady-state
        % of the part is not important!
        ssObs      = zeros(size(parser.all_endogenous,2),1);
        [~,loc]    = ismember(parser.endogenous,parser.all_endogenous);
        ssObs(loc) = ss;
        
        % Get the ordering including lagged endogenous and exogenous
        [~,type,ssObsOrd] = nb_dsge.getObsOrderingNB(parser,ssObs);
        
        if isfield(parser,'obsDerivativeFunc') % Symbolic derivatives!
            nEqs                 = max(parser.obsDerivativeInd(:,1));
            nCol                 = size(type,2);
            deriv                = parser.obsDerivativeFunc(ssObsOrd,paramV);
            solution.obsJacobian = sparse(parser.obsDerivativeInd(:,1),parser.obsDerivativeInd(:,2),deriv,nEqs,nCol);
        else % Automatic derivatives
            myDeriv              = myAD(ssObsOrd);
            derivator            = parser.obsEqFunction(myDeriv,paramV);
            solution.obsJacobian = getderivs(derivator);
        end
        solution.obsJacobianType = type;
        
    end
    
end
