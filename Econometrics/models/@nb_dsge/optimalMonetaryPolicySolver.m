function [H,D,DE,parser,err] = optimalMonetaryPolicySolver(parser,solution,options,expandedOnly,solveForEpi)
% Syntax:
%
% [H,D,DE,parser,err] = ...
% nb_dsge.optimalMonetaryPolicySolver(parser,solution,options,...
%   expandedOnly,solveForEpi)
%
% Description:
%
% This static method of the nb_dsge class implements the Klein algorithm
% to solve the problem. 
%
% Caution: This algorithm can only solve optimal monetary policy 
%          under full commitment or full discretion.
%
% Input:
% 
% - parser       : See nb_dsge.solveNB
%
% - solution     : See nb_dsge.solveNB
% 
% - options      : See nb_dsge.solveNB
%
% - expandedOnly : true if only the expanded solution is to be solved for.
%
% Output:
% 
% - H        : Transition matrix, as a nEndo + nMult x nEndo + nMult.
%
% - D        : Shock impact matrix as a nEndo + nMult x nExo.
%
% - DE       : Shock impact matrix as a nEndo x nExo x nHor, when solved
%              with anticipated shocks, otherwise [].
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 5
        solveForEpi = true;
    end

    err = '';
    
    % Get the options
    beta = options.lc_discount;
    gam  = options.lc_commitment;
    if gam ~= 1
        error([mfilename ':: The ''lc_commitment'' option must be set to 1 to be able to use the Klein solver.'])
    end
    
    % Get the jacobian
    JAC = full(solution.jacobian);
    if max(abs(imag(JAC(:)))) < eps^(0.8)
        JAC = real(JAC);
    else
        err = [mfilename ':: Cannot solve the model the jacobian is not real.'];
        if nargout < 5
            error(err)
        else
            [H,D,DE] = errorReturn();
            return    
        end
    end
    
    % Loss function 2. order derivative
    W = solution.W;

    if ~expandedOnly
        
        if options.blockDecompose && isfield(parser,'block')
            % Remove epilogue from model information needed to solve it
            W                           = W(~parser.block.epiEndo,~parser.block.epiEndo);
            parser.block.epiEndoVars    = parser.endogenous(parser.block.epiEndo);
            parser.endogenous           = parser.endogenous(~parser.block.epiEndo);
            parser.block.leadCurrentLag = parser.leadCurrentLag;
            if isfield(parser,'isMultiplier')
                parser.block.leadCurrentLag = parser.block.leadCurrentLag(~parser.isMultiplier,:);
            end
        end
        
        % Remove multipliers when already solved under optimal monetary
        % policy
        if isfield(parser,'isMultiplier')
            parser.leadCurrentLag = parser.leadCurrentLag(~parser.isMultiplier,:);
        end
        
        % Get the full structural representation including multipliers
        [Alead,A0,Alag,B] = nb_dsge.jacobian2StructuralMatricesNB(JAC,parser);
        Alead             = nb_dsge.applyDiscount(options,Alead);
        [Hlead,H0,Hlag,D] = nb_dsge.getOptimalMonetaryPolicyMatrices(Alead,A0,Alag,B,W,beta);
        parser            = nb_dsge.updateLeadLagGivenOptimalPolicy(parser,Alead,Alag);
        parser            = nb_dsge.addMultipliers(parser);
        parser            = nb_dsge.updateDynamicOrder(parser);
        parser            = nb_dsge.updateDrOrder(parser);
        
        % Find the solution using the Klein's algorithm
        HF        = Hlead(:,parser.isForwardOrMixed); % Only keep the columns of the forward looking variables
        HB        = Hlag(:,parser.isBackwardOrMixed); % Only keep the columns of the backward looking variables
        [H,D,err] = nb_dsge.kleinSolver(parser,HF,H0,HB,D);
        if ~isempty(err)
            if nargout < 5
                error(err)
            else
                [H,D,DE] = errorReturn();
                return
            end
        end
         
    else
        
        % Remove multipliers when already solved under optimal monetary
        % policy
        reset = false;
        if isfield(parser,'isMultiplier')
            reset                 = true;
            oldLeadCurrentLag     = parser.leadCurrentLag;
            parser.leadCurrentLag = parser.leadCurrentLag(~parser.isMultiplier,:);
        end
        
        % Get already found solution
        H                 = solution.A;
        D                 = solution.C;
        [Alead,A0,Alag,B] = nb_dsge.jacobian2StructuralMatricesNB(JAC,parser);
        [Hlead,H0]        = nb_dsge.getOptimalMonetaryPolicyMatrices(Alead,A0,Alag,B,W,beta,gam);
        
        if reset
            parser.leadCurrentLag = oldLeadCurrentLag;
        end
        
    end
    
    if options.blockDecompose && isfield(parser,'block') && solveForEpi
        % Solve for the epilogue, update the lead and lag incident
        [H,D,parser] = nb_dsge.solveForEpilogue(parser,solution,H,D,Alead,Alag,'klein');
    end
    
    % Do we want the expanded solution?
    if ~isempty(options.numAntSteps) && ~isempty(options.shockProperties)
        
        numAntSteps     = options.numAntSteps;
        shockProperties = options.shockProperties(solution.activeShocks);
        
        % Get the horizon of anticipation for each shock.
        [horizon,err] = nb_dsge.getHorizon(shockProperties,numAntSteps,solution);
        if ~isempty(err)
            [H,D,DE] = errorReturn();
            return
        end
        
        % Only keep active shocks
        D = D(:,solution.activeShocks);
        
        % Get solution matrices on anticipated shocks
        HGHiH = (Hlead*H + H0)\Hlead;
        DE    = nb_dsge.findAniticipatedMatrices(D,numAntSteps,HGHiH);
        
        % Time to set each shocks active horizon
        for j = 1:length(horizon)
            hh             = horizon(j) + 1;
            DE(:,j,hh:end) = 0;
        end
        
    else
        DE = [];
    end
    
end

%==========================================================================
function [H,D,DE] = errorReturn()

    H     = [];
    D     = [];
    DE    = [];
    
end
