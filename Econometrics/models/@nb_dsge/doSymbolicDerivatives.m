function [derivFunc,derivInd,symDeriv,jacobian] = doSymbolicDerivatives(obj,obs)
% Syntax:
%
% [derivFunc,derivInd,symDeriv,jacobian] = doSymbolicDerivatives(obj,obs)
%
% Description:
%
% Create a function handle with the derivatives.
% 
% Input:
% 
% - obj : An object of class nb_dsge.
% 
% - obs : Give true to calculate symbolic derivatives of the obs_model 
%         instead of the core model. Default is false 
%
% Output:
% 
% - derivFunc : A function handle returning the non trivial derivatives of
%               the equations of the model. This function takes two inputs;
%               the value of the variables (including lead, lags and 
%               exogenous), and the value of the parameters. 
%
% - derivInd  : Let JT be the output from derivFunc, then the full jacobian
%               is given by sparse(derivInd(:,1),derivInd(:,2),JT,...
%               nEqs,nCol). For more see nb_dsge.derivativeNB.
%
% - symDeriv  : A vector of nb_mySD storing the non-trivial derivatives
%               of the model.
%
% - jacobian  : The jacobian as a sparse matrix of size nEqs x nCol. See
%               the getDerivOrder for the ordering of the jacobian.
%
% See also:
% nb_dsge.derivative, nb_dsge.derivativeNB, nb_dsge.getDerivOrder
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 2
        obs = false;
    end

    if obs
        eqFunc = obj.parser.obsEqFunction;
        vars   = nb_dsge.getObsOrderingNB(obj.parser,[]);
    else
        eqFunc = obj.parser.eqFunction;
        vars   = nb_dsge.getOrderingNB(obj.parser,[]);
    end
    pars = obj.parser.parameters;
    
    % Find generic names for the variables and parameters
    varsN  = nb_createGenericNames(vars,'vars');
    paramN = nb_createGenericNames(pars,'pars');
    
    % Calculate the symbolic derivatives using nb_mySD
    varsD     = nb_mySD(varsN);
    paramD    = nb_param(paramN);
    symDeriv  = eqFunc(varsD,paramD);
    derivEqs  = [symDeriv.derivatives];
    derivFunc = nb_cell2func(derivEqs,'(vars,pars)');
     
    % Collect sparse indexes
    [I,J]    = nb_getSymbolicDerivIndex(symDeriv,'vars',derivEqs);
    derivInd = [I,J];
    
    % Are we going to return the jacobian?
    if nargout > 3
        
        if isfield(obj.solution,'ssOriginal')
            ss = obj.solution.ssOriginal;
        else
            ss = obj.solution.ss;
        end
        if obs
             % It is assumed that the obs_model is linear, so the steady-state
            % of the part is not important!
            ssObs        = zeros(size(obj.parser.all_endogenous));
            [~,loc]      = ismember(obj.parser.endogenous,obj.parser.all_endogenous);
            ssObs(loc)   = ss;
            [~,typeV,ss] = nb_dsge.getObsOrderingNB(obj.parser,ssObs);
        else
            [~,typeV,ss] = nb_dsge.getOrderingNB(obj.parser,ss);
        end
        nEqs     = max(derivInd(:,1));
        nCol     = size(typeV,2);
        deriv    = derivFunc(ss,obj.results.beta);
        jacobian = sparse(derivInd(:,1),derivInd(:,2),deriv,nEqs,nCol);
        
    end
    
end
