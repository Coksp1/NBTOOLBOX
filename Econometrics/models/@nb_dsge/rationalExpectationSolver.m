function [A,D,DE,err] = rationalExpectationSolver(parser,solution,options,expandedOnly)
% Syntax:
%
% [A,D,DE,err] = nb_dsge.rationalExpectationSolver(parser,solution,...
%                       options)
%
% Description:
%
% Solving forward looking models under the rational expectation assumption.
%
% This uses the solution approach put forward by Paul Klein. See 
% nb_solveLinearRationalExpModel.
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
% - A        : Transition matrix, as a nEndo x nEndo.
%
% - D        : Shock impact matrix as a nEndo x nExo.
%
% - DE       : Shock impact matrix as a nEndo x nExo x nHor, when solved
%              with anticipated shocks, otherwise [].
%
% See also:
% nb_solveLinearRationalExpModel, nb_dsge.selectSolveAlgorithm
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    err  = '';   
    ind  = solution.jacobianType;
    JAC  = full(solution.jacobian);
    if max(abs(imag(JAC(:)))) < eps^(0.8)
        JAC = real(JAC);
    else
        err = [mfilename ':: Cannot solve the model the jacobian is not real.'];
        if nargout < 4
            error(err)
        else
            [A,D,DE] = errorReturn();
            return    
        end
    end

    if ~expandedOnly
        
        if options.blockDecompose
            
            % Get the structural matrices
            [FF,F0,FB,FU] = nb_dsge.jacobian2StructuralMatricesNB(JAC,parser);
            
            % Remove epilogue from model information needed to solve it
            if isfield(parser,'block')
                parser.block.epiEndoVars    = parser.endogenous(parser.block.epiEndo);
                parser.endogenous           = parser.endogenous(~parser.block.epiEndo);
                parser.block.leadCurrentLag = parser.leadCurrentLag;
                parser.leadCurrentLag       = parser.leadCurrentLag(~parser.block.epiEndo,:);
                parser                      = nb_dsge.updateClassifications(parser);
                parser                      = nb_dsge.updateDynamicOrder(parser);
                parser                      = nb_dsge.updateDrOrder(parser);
            end
            
            % Trim matrices
            FF = FF(:,parser.isForwardOrMixed); % Only keep the columns of the forward looking variables
            FB = FB(:,parser.isBackwardOrMixed); % Only keep the columns of the backward looking variables;
            
        else
            FF = JAC(:,ind == 1);
            F0 = JAC(:,ind == 0);
            FB = JAC(:,ind == -1); 
            FU = JAC(:,ind == 2);
        end
        FF = nb_dsge.applyDiscount(options,FF);

        [A,D,err] = nb_dsge.kleinSolver(parser,FF,F0,FB,FU);
        if ~isempty(err)
            if nargout < 4
                error(err)
            else
                [A,D,DE] = errorReturn();
                return
            end
        end
        
        if options.blockDecompose && isfield(parser,'block')
            % Solve for the epilogue, update the lead and lag incident
            [A,D,parser] = nb_dsge.solveForEpilogue(parser,solution,A,D,[],[],'klein');
        end
        
    else
        A      = solution.A;
        D      = solution.C;
        parser = nb_rmfield(parser,'block');
    end
    
    % Do we want the expanded solution?
    if ~isempty(options.numAntSteps) && ~isempty(options.shockProperties)
        
        numAntSteps     = options.numAntSteps;
        shockProperties = options.shockProperties(solution.activeShocks);
        
        % Get the horizon of anticipation for each shock.
        [horizon,err] = nb_dsge.getHorizon(shockProperties,numAntSteps,solution);
        if ~isempty(err)
            [A,D,DE] = errorReturn();
            return
        end
        
        % Only keep active shocks
        D = D(:,solution.activeShocks);
        
        % Get solution matrices on anticipated shocks
        [Alead,A0,~,~] = nb_dsge.jacobian2StructuralMatricesNB(JAC,parser);
        AGAiA          = (Alead*A + A0)\Alead;
        DE             = nb_dsge.findAniticipatedMatrices(D,numAntSteps,AGAiA);
        
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
function [A,D,DE] = errorReturn()

    A  = [];
    D  = [];
    DE = [];
    
end
