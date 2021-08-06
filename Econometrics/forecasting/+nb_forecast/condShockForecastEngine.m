function [Y,states,PAI,MUs] = condShockForecastEngine(y0,A,B,C,ss,Qfunc,MUx,MUs,states,restrictions,nSteps,inputs)
% Syntax:
%
% [Y,states,PAI] = nb_forecast.condShockForecastEngine(y0,A,B,C,ss,Qfunc,MUx,...
%                       MUs,states,restrictions,nSteps,inputs)
%
% Description:
%
% Produce forecast conditional on shocks only forecast with or without 
% Markov-switching 
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 12
        inputs = [];
    end
    
    Y      = nan(size(y0,1),nSteps+1);
    Y(:,1) = y0;
    if nb_isempty(inputs)
        if ~isempty(Qfunc) % Markov switching model
            [Y,states,PAI] = ms.computeForecastAnticipatedMS(A,B,C,ss,Qfunc,Y,MUx,MUs,states,restrictions.PAI0);
        elseif iscell(A) % Break point model
            Y   = nb_computeForecastAnticipatedBP(A,B,C,ss,Y,MUx,MUs,states);
            PAI = nan(0,nSteps+1);
        else % Non-switching model
            if size(C,3) > 1
                Y = nb_computeForecastAnticipated(A,B,C,Y,MUx,MUs);
            else
                Y = nb_computeForecast(A,B,C,Y,MUx,MUs);
            end
            PAI = nan(0,nSteps+1);
        end  
    else
        [Y,MUs] = nb_forecast.computeBoundedForecasts(A,B,C,ss,Y,restrictions,MUx,MUs,inputs,inputs.solution,[],[],[],[],Y,MUs,1);
        PAI     = nan(0,nSteps+1);
    end
    
end
