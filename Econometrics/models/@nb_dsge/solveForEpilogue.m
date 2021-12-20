function [A,B,parser] = solveForEpilogue(parser,solution,H,D,Alead,Alag,algorithm)
% Syntax:
%
% [A,B,parser] = nb_dsge.solveForEpilogue(parser,solution,H,D,Alead,Alag,algorithm)
%
% Description:
%
% Solve for the epilogue when it is remove during normal solving.
% 
% See also:
% nb_dsge.looseOptimalMonetaryPolicySolver, 
% nb_dsge.optimalMonetaryPolicySolver, nb_dsge.rationalExpectationSolver
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if isempty(Alead) % Called in nb_dsge.rationalExpectationSolver
        
        % Reset the lead, current and lag indices
        parser.leadCurrentLag = parser.block.leadCurrentLag;
        parser.block          = rmfield(parser.block,{'epiEndoVars','leadCurrentLag'});
        
    elseif strcmpi(algorithm,'klein') % Called in nb_dsge.optimalMonetaryPolicySolver
        
        % Add the endogenous variables of the epilogue back again
        epiInd            = parser.block.epiEndo;
        endoSub           = parser.endogenous(~parser.isMultiplier);
        lambda            = parser.endogenous(parser.isMultiplier);
        endo              = cell(1,length(parser.block.epiEndoVars) + length(endoSub));
        endo(epiInd)      = parser.block.epiEndoVars;
        endo(~epiInd)     = endoSub;
        endo              = [endo,lambda];
        parser.endogenous = endo;
        
        % Reset the lead, current and lag indices
        parser.leadCurrentLag = parser.block.leadCurrentLag;
        parser.block          = rmfield(parser.block,{'epiEndoVars','leadCurrentLag'});
        
    end

    epiEqsI = parser.block.epiEqs;
    nEpiEqs = sum(epiEqsI);
    if nEpiEqs > 1
        
        epiEndoI = parser.block.epiEndo;
        nEpiEndo = sum(epiEndoI);
        if isempty(Alead)
            nOrigEndo = size(parser.block.epiEqs,1) - nEpiEndo; % Same number of variables as equations
            nMult     = 0;
        else
            nOrigEndo = size(Alead,2);
            nMult     = size(Alead,1);
        end
        nRedEndo = size(H,1);
        nEndo    = nRedEndo + nEpiEndo;
        indRed   = [~epiEndoI;true(nMult,1)]; % Locations of variables already solved for (including multipliers)   
        indEpi   = [epiEndoI;false(nMult,1)]; % Locations of epilogue

        % Create epilogue equation
        JAC  = solution.jacobian;
        lcl  = parser.leadCurrentLag;
        ind0 = sum(lcl(:,1)) + (1:nOrigEndo + nEpiEndo);
        C0   = full(JAC(epiEqsI,ind0)); 
        C1   = C0(:,~epiEndoI);
        C1   = [C1,zeros(nEpiEqs,nMult)];
        C2   = C0(:,epiEndoI);
        nExo = size(parser.exogenous,2);
        R    = full(JAC(epiEqsI,end-nExo+1:end));

        % On the lags
        nLag           = sum(lcl(:,3));
        indL           = ind0(end)+1:ind0(end)+nLag;
        M0             = zeros(nEpiEndo,nOrigEndo + nEpiEndo); 
        M0(:,lcl(:,3)) = full(JAC(epiEqsI,indL));
        M1             = M0(:,~epiEndoI);
        M1             = [M1,zeros(nEpiEqs,nMult)];
        M2             = M0(:,epiEndoI);
        
        % Construct the equation G y(t) = K y(t-1) + Q eps(t)
        % Where G = [I, 0; C1, C2], K = [A, 0; 0, 0] and Q = [D;R]
        G                = zeros(nEndo,nEndo);
        G(indRed,indRed) = eye(nRedEndo);
        G(indEpi,indRed) = C1;
        G(indEpi,indEpi) = C2;
        K                = zeros(nEndo,nEndo);
        K(indRed,indRed) = H;
        K(indEpi,indRed) = -M1;
        K(indEpi,indEpi) = -M2;
        nExo             = size(R,2);
        Q                = zeros(nEndo,nExo);
        Q(indEpi,:)      = R;
        Q(~indEpi,:)     = D;

        % Then get the final full solution on the form 
        % [x(t),y(t)]' = A [x(t-1),y(t-1)]' + B eps(t)
        A = G\K;
        B = G\Q;
        
    else
        % No epilogue!
        A = H;
        B = D;
    end
    
    % Update lead, current and lag indices
    if ~isempty(Alead) % Optimal monetary policy
        isF                   = any(Alead,2);
        isB                   = any(Alag,2);
        leadCLagMult          = [false(nMult,1),true(nMult,1),false(nMult,1)]; 
        leadCLagMult(isF,3)   = true; % If lagged multiplier on leaded variables
        leadCLagMult(isB,1)   = true; % If leaded multiplier on lagged variables
        parser.leadCurrentLag = [parser.leadCurrentLag;leadCLagMult];
        parser                = nb_dsge.updateClassifications(parser);
        fullEndo              = nOrigEndo + nEpiEndo;
        parser.isMultiplier   = [false(fullEndo,1);true(nMult,1)];
    end
    
end
