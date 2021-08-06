function [YT,err] = normalIteration(obj,funcs,inputs,iter,outer,YT)
% Syntax:
%
% [YT,err] = nb_perfectForesight.normalIteration(obj,funcs,inputs,iter,...
%                   outer,YT)
%
% Description:
%
% Part of the perfect forseight solver package nb_perfectForesight.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    nSilent = ~obj.options.silent;
    funcs   = nb_perfectForesight.updateStackedSystemFunction(obj,funcs,inputs,iter);
    F       = @(Y)nb_perfectForesight.getFunctionValue(Y,funcs,inputs,iter);
    if strcmpi(inputs.solver,'nb_solve')
        JF              = @(Y)nb_perfectForesight.getStackedJacobian(Y,inputs,funcs,iter);
        [YT,~,exitflag] = nb_solve.call(F,YT,inputs.optimset,JF);
    elseif strcmpi(inputs.solver,'nb_abc')
        [YT,~,exitflag] = nb_abcSolve.call(F,YT,[],[],inputs.optimset);
    else
        error([mfilename ':: Unsupported solver ' inputs.solver])
    end
    err = nb_interpretExitFlag(inputs.solver,exitflag);
    
    % Notify about outer loop, if some...
    if ~isempty(err)    
        if outer
            err = ['Failed at outer iteration ' int2str(iter) ':'];
        end
    else
        if nSilent && outer
            disp(['Finished with outer iteration ' int2str(iter) ' of ' int2str(inputs.iterations)])
            disp(' ')
        end
    end
    
end
