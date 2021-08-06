function [h,inputs] = createParameterUncertaintyWaitbar(inputs)
% Syntax:
%
% [h,inputs] = nb_forecast.createParameterUncertaintyWaitbar(inputs)
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if ~inputs.parallel
        if isfield(inputs,'waitbar')
           h = inputs.waitbar;
        else
            if isfield(inputs,'index')
                figureName = ['Forecast for Model ' int2str(inputs.index) ' of ' int2str(inputs.nObj)];
            else
                figureName = 'Forecast';
            end
            h = nb_waitbar5([],figureName,true);
            inputs.waitbar = h;
        end
        h.text2          = 'Making the parameter draws...';
        h.maxIterations2 = inputs.parameterDraws;
        h.status2        = 0;
    else
        h = [];
    end
    
end
