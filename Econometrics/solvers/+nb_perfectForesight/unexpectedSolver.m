function Y = unexpectedSolver(obj,funcs,inputs,Y,funcHandle)
% Syntax:
%
% [YT,err] = nb_perfectForesight.unexpectedSolver(obj,funcs,inputs,Y,...
%               funcHandle)
%
% Description:
%
% Solver used when we are dealing with unexpected shocks.
%
% Part of the perfect forseight solver package nb_perfectForesight.
% 
% Input:
%
% - funcHandle : Either @nb_perfectForesight.normalIteration or 
%                @nb_perfectForesight.blockIteration
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    nSilent = ~obj.options.silent;
    nEndo   = obj.dependent.number;
    YT      = Y;
    for iter = 1:inputs.iterations

        if nSilent
            disp(['Starting outer iteration ' int2str(iter) ' of ' int2str(inputs.iterations)])
        end
        [YT,err] = funcHandle(obj,funcs,inputs,iter,true,YT);
        if ~isempty(err)
            error(err)
        end

        ind    = inputs.start(iter):inputs.finish(iter);
        Y(ind) = YT(1:inputs.periodsUEndo(iter));     % Solution for subperiod
        YT     = YT(inputs.periodsUEndo(iter)+1:end); % Initial condition for next iteration
        if iter ~= inputs.iterations
            inputs.initValU = YT(inputs.periodsUEndo(iter)-nEndo+1:inputs.periodsUEndo(iter));
        end

    end

end
