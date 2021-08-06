function [h,iter,closeWaitbar] = createWaitbar(inputs,start,finish)
% Syntax:
%
% [h,iter,closeWaitbar] = nb_forecast.createWaitbar(inputs,start,finish)
%
%
% Written by Kenneth Sæterhagen Paulsen

    iter         = finish - start + 1;
    closeWaitbar = true;
    if inputs.parallel
        h            = inputs.waitbar;
        closeWaitbar = false;
    else
        h = [];
        if isfield(inputs,'waitbar')
            if isa(inputs.waitbar,'nb_waitbar5')
                h            = inputs.waitbar;
                closeWaitbar = false;
            end
        end
        if isempty(h)
            if isfield(inputs,'index')
                h = nb_waitbar5([],['Recursive Forecast for Model '  int2str(inputs.index) ' of ' int2str(inputs.nObj) ],true);
            else
                h = nb_waitbar5([],'Recursive Forecast',true);
            end
        end
        h.maxIterations1 = iter;
        h.text1          = 'Starting...'; 
        inputs.waitbar   = h;
    end

end
