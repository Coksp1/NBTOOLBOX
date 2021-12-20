function Y = normalSolution(obj,Y,inputs,funcs)
% Syntax:
%
% [YT,err] = nb_perfectForesight.normalSolution(obj,Y,inputs,funcs)
%
% Description:
%
% Part of the perfect forseight solver package nb_perfectForesight.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if ~obj.options.silent
        disp(' ')
    end
    
    if inputs.unexpected      
        Y = nb_perfectForesight.unexpectedSolver(obj,funcs,inputs,Y,@nb_perfectForesight.normalIteration);
    else
        [Y,err] = nb_perfectForesight.normalIteration(obj,funcs,inputs,1,false,Y);
        if ~isempty(err)
            error(err)
        end
    end
    
end
