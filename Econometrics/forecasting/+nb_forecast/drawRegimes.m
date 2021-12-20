function [E,X,states,solution] = drawRegimes(y0,A,B,C,ss,Qfunc,vcv,nSteps,draws,restrictions,solution,inputs,options)
% Syntax:
%
% [E,X,states,solution] = nb_forecast.drawRegimes(y0,A,B,C,ss,Qfunc,...
%                   vcv,nSteps,draws,restrictions,solution,inputs,options)
%
% Description:
%
% Draw regimes.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    regimeDraws  = inputs.regimeDraws;

    % Create waiting bar window (If already created we add a new 
    % waiting bar to that one)
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
        h.maxIterations3 = regimeDraws;
    end

    % Simulation regime paths
    E      = nan(size(C{1},2),nSteps,regimeDraws*draws);
    X      = nan(size(B{1},2),nSteps,regimeDraws*draws);
    states = nan(nSteps,1,regimeDraws*draws);
    noteR  = nb_when2Notify(regimeDraws);
    for ii = 1:regimeDraws

        mm  = draws*(ii-1);
        ind = 1+mm:draws+mm;
        [E(:,:,ind),X(:,:,ind),states(:,:,ind),solution] = nb_forecast.drawShocksAndExogenous(y0,A,B,C,ss,Qfunc,vcv,nSteps,draws,restrictions,solution,inputs,options); 

        % Report current status in the waitbar's message field
        if ~inputs.parallel
            if h.canceling
                error([mfilename ':: User terminated'])
            end
            if rem(ii,noteR)
                h.status3 = ii;
                h.text3   = ['Finished with ' int2str(ii) ' of ' int2str(regimeDraws) ' regime draws...'];
            end
        end

    end
    if ~inputs.parallel
        deleteThird(h);
    end

end
