function [YT,err] = blockIteration(obj,funcs,inputs,iter,outer,YT)
% Syntax:
%
% [YT,err] = nb_perfectForesight.blockIteration(obj,funcs,inputs,iter,...
%                   outer,YT)
%
% Description:
%
% Part of the perfect forseight solver package nb_perfectForesight.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Solve for the prologue
    [YT,err] = nb_perfectForesight.proSolver(obj,inputs,YT,iter);
    if ~isempty(err)
        return
    end
       
    % Get the index of the vector Y to solve for, i.e. her we fix
    % the values of the variables of the prologue and the epilogue
    epiY  = obj.parser.block.epiEndo(:,ones(inputs.periodsU(iter),1));
    epiY  = epiY(:);
    proY  = obj.parser.block.proEndo(:,ones(inputs.periodsU(iter),1));
    proY  = proY(:);
    mainY = ~epiY & ~proY;
    
    nSilent = ~obj.options.silent;
    inputs  = nb_perfectForesight.getSolvedPrologue(obj,inputs,YT,proY,iter);
    funcs   = nb_perfectForesight.updateStackedSystemFunction(obj,funcs,inputs,iter);
    F       = @(Y)nb_perfectForesight.getFunctionValue(Y,funcs,inputs,iter);
    YM      = YT(mainY);
    if strcmpi(inputs.solver,'nb_solve')
        JF              = @(Y)nb_perfectForesight.getStackedJacobian(Y,inputs,funcs,iter);
        [YM,~,exitflag] = nb_solve.call(F,YM,inputs.optimset,JF);
    elseif strcmpi(inputs.solver,'nb_abc')
        [YM,~,exitflag] = nb_abcSolve.call(F,YM,[],[],inputs.optimset);
    else
        error([mfilename ':: Unsupported solver ' inputs.solver])
    end
    err = nb_interpretExitFlag(inputs.solver,exitflag);
    
    % Notify about outer loop, if some...
    if ~isempty(err)    
        if outer
            err = ['Failed at outer iteration ' int2str(iter) ':'];
            if ~isempty(err)
                return
            end
        end
    else
        if nSilent && outer
            disp(['Finished with outer iteration ' int2str(iter) ' of ' int2str(inputs.iterations)])
            disp(' ')
        end
    end
    YT(mainY) = YM;
    
    % Solve the epilogue
    [YT,err] = nb_perfectForesight.epiSolver(obj,inputs,YT,iter);
            
end
