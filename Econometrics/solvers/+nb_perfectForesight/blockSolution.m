function Y = blockSolution(obj,Y,inputs)
% Syntax:
%
% Y = nb_perfectForesight.blockSolution(obj,Y,inputs)
%
% Description:
%
% Part of the perfect forseight solver package nb_perfectForesight.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Solve for the steady-state
    oldSilent          = obj.options.silent;
    obj.options.silent = true;
    if ~obj.steadyStateSolved
        obj = checkSteadyState(obj);
    end

    % Compute derivatives of the dynamic model, if not already calculated
    if ~obj.takenDerivatives 
        obj = derivative(obj);       
    end
    obj.options.silent = oldSilent;

    % Block decompose model
    obj = blockDecompose(obj,false,true);
    
    % Remove epilogue from model and get main stacked system
    block                   = obj.parser.block;
    parserT                 = obj.parser;
    parserT.prologueVars    = obj.parser.endogenous(block.proEndo);
    parserT.endogenous      = obj.parser.endogenous(~block.epiEndo & ~block.proEndo);
    parserT.epilogueVars    = obj.parser.endogenous(block.epiEndo);
    inputs.epilogueSolution = zeros(1,length(parserT.epilogueVars));
    if any(obj.parser.isAuxiliary)
        parserT.equationsParsed = obj.parser.equationsParsed(~block.epiEqs & ~block.proEqs);
    else
        parserT.equations = obj.parser.equations(~block.epiEqs & ~block.proEqs);
    end
    [funcs,inputs] = nb_perfectForesight.getStackedSystemFunction(obj,inputs,parserT);
    
    % Solve the problem use the block decomposition
    if inputs.unexpected
        Y = nb_perfectForesight.unexpectedSolver(obj,funcs,inputs,Y,@nb_perfectForesight.blockIteration);    
    else
        [Y,err] = nb_perfectForesight.blockIteration(obj,funcs,inputs,1,false,Y);
        if ~isempty(err)
            error(err)
        end
    end
    
end
