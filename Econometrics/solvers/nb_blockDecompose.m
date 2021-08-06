function blocks = nb_blockDecompose(F,y,p,tol,fixed,varargin)
% Syntax:
%
% blocks = nb_blockDecompose(F,y,p,tol,fixed,varargin)
%
% Description:
%
% Block decompose system of non-linear equations F(y,p,varargin{:}) = 0.
%
% For more see see Mihoubi (2011), "Solving and estimating stochastic 
% models with block decomposition" section 2. 
%
% Input:
% 
% - F     : A function_handle that takes 2 inputs. 
%
% - y     : The initial values of the variables to solve for, as a nVar x 1
%           double.
%
% - p     : The parameters of the function F (this may include exogenous 
%           variables!). As a nPar x 1 double.
% 
% - tol   : The tolerance level for setting elements of the jacobian to 0.
%
% - fixed : A 1 x nVar logical with elements set to true if the variable
%           value is already known.
%
% Optional input:
%
% - varargin : Optional inputs given to the function handle F when being
%              evaluated.
%
% Output:
% 
% - blocks : A struct with how to block the model.
%
% See also:
% nb_solver
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Calculate the derivative
    yd         = myAD(y); 
    derY       = F(yd,p,varargin{:});
    jacY       = getderivs(derY);
    indY       = abs(jacY) < tol;
    jacY(indY) = 0;
    jacY       = abs(jacY);
    for ii = 1:10
        % A small pertubation away from the initial conditions, as we may be
        % very close to the true solution
        yd         = myAD(y + rand(size(y,1),1)); 
        derT       = F(yd,p,varargin{:});
        jacT       = getderivs(derT);
        indY       = abs(jacT) < tol;
        jacT(indY) = 0;
        jacY       = jacY + abs(jacT);
    end
    jacY(abs(jacY)>0) = 1;
    
    % Construct output
    nEqs                  = size(jacY,1);
    nEndo                 = size(jacY,2);
    blocks.prologue       = false(nEqs,1);
    blocks.pIteration     = zeros(nEqs,1);
    blocks.pVarsInd       = false(nEndo,1);
    blocks.epilogue       = false(nEqs,1);
    blocks.eIteration     = zeros(nEqs,1);
    blocks.eVarsInd       = false(nEndo,1);
    blocks.emptyEquations = false(nEqs,1);
    blocks.iterations     = 1;
    blocks.fixed          = fixed;

    % Setting the elements of the jacobian to 0 for the variable that
    % are already known (fixed)
    jacY(:,fixed) = 0;
    
    % Now find the equations that only depend on the last iteration of the
    % prologue
    kk = 1;
    while true 
        
        % Only look at the system of equations we have left
        [blocks,cont] = locate(blocks,jacY,kk);%,F,y,p,tol
        if ~cont
            break
        end
        kk = kk + 1;
        
    end
    blocks.iterations = kk;
    
    % Decompose the rest
    blocks.main     = not(blocks.prologue | blocks.epilogue | blocks.emptyEquations);
    blocks.mVarsInd = not(blocks.pVarsInd | blocks.eVarsInd | blocks.fixed);
        
end

function [blocks,cont] = locate(blocks,jacY,iter)%,F,y,p,tol

    % Get sub-system
    eqInd = not(blocks.epilogue | blocks.prologue | blocks.emptyEquations);
    jacT  = jacY(eqInd,:);
    
    % Remove variables already included in prologue
    jacT(:,blocks.pVarsInd) = 0;

    % Locate equations that in the steady-state are superfluous
    nEqs           = size(jacT,1);
    eqsNoVars      = find(sum(abs(jacT)>0,2) == 0);
    emptyEquations = false(nEqs,1);
    if any(eqsNoVars)
        emptyEquations(eqsNoVars)    = true;
        blocks.emptyEquations(eqInd) = emptyEquations;
        eqInd = not(blocks.epilogue | blocks.prologue | blocks.emptyEquations);
    end
    
    % Locate the prologue
    jacT          = jacT(~emptyEquations,:);
    nEqs          = size(jacT,1);
    prologue      = false(nEqs,1);
    pIteration    = zeros(nEqs,1);
    varsOnlyOneEq = find(sum(abs(jacT)>0,1) == 1);
    eqsOnlyOneVar = find(sum(abs(jacT)>0,2) == 1);
    varInd        = zeros(length(eqsOnlyOneVar),1);
    ind           = false(length(eqsOnlyOneVar),1);
    for ii = 1:length(eqsOnlyOneVar)
        varInd(ii)            = find(jacT(eqsOnlyOneVar(ii),:));
        locVar                = varInd(ii) == varsOnlyOneEq;
        ind(ii)               = ~any(varInd(ii) == varsOnlyOneEq);
        if ind(ii)
            varsOnlyOneEq(locVar) = [];
        end
    end
    prologue(eqsOnlyOneVar(ind))   = true;
    if all(~prologue)
        cont = false;
        return
    else
        cont = true;
    end
    pIteration(eqsOnlyOneVar(ind)) = iter;
    blocks.pVarsInd(varInd(ind))   = true;
    
    % Assign prologue to full system
    blocks.prologue(eqInd)   = prologue;
    blocks.pIteration(eqInd) = pIteration;
    
    % Locate the epilogue
    if iter == 1
        
        epilogue      = false(nEqs,1);
        eIteration    = zeros(nEqs,1);
        for ii = 1:length(varsOnlyOneEq)
            epilogue(jacT(:,varsOnlyOneEq(ii)) > 0) = true;
        end
        eIteration(epilogue)           = iter;
        blocks.eVarsInd(varsOnlyOneEq) = true;
        
        % Assign epilogue to full system
        blocks.epilogue(eqInd)   = epilogue;
        blocks.eIteration(eqInd) = eIteration;
        
    end
    
end
