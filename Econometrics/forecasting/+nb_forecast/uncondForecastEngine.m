function [Y,states,AA] = uncondForecastEngine(y0,A,B,ss,Qfunc,E,states,transProbInit,maxiter)
% Syntax:
%
% [Y,states,AA] = nb_forecast.uncondForecastEngine(y0,A,B,ss,Qfunc,E,...
%                       states,transProbInit,maxiter)
%
% Description:
%
% Produce unconditional forecast with or without Markov-switching or a 
% break point model.
%
% See also:
% nb_forecast.conditionalProjectionEngine, ms.uncondForecastEngine
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if ~isempty(Qfunc) % Markov switching model
        [Y,states,AA] = ms.uncondForecastEngine(y0,A,B,ss,Qfunc,E,states,transProbInit,maxiter);
    elseif iscell(A) % Model with break-points
        
        endo_nbr = size(A{1},1);
        Aj       = eye(endo_nbr);
        AA       = zeros(endo_nbr,endo_nbr,maxiter);
        Y        = nan(size(y0,1),maxiter+1);
        if iscell(ss)
            % Conditional information is interpreted in the picked state
            % steady-state in history.
            Y(:,1) = y0;
            for t = 1:maxiter
                Aj             = Aj*A{states(t)};
                AA(:,:,t)      = Aj;
                Y(:,t+1)       = ss{states(t)} + A{states(t)}*(Y(:,t) - ss{states(t)}) + B{states(t)}*E(:,t);  
            end
        else
            % Conditional information is interpreted in the last
            % steady-state of history.
            Y(:,1) = y0 - ss;
            for t = 1:maxiter
                Aj             = Aj*A{states(t)};
                AA(:,:,t)      = Aj;
                Y(:,t+1)       = A{states(t)}*Y(:,t) + B{states(t)}*E(:,t);  
            end
        end
        
    else % Non-switching model
    
        endo_nbr = size(A,1);
        Aj       = eye(endo_nbr);
        AA       = zeros(endo_nbr,endo_nbr,maxiter);
        Y        = nan(size(y0,1),maxiter+1);
        Y(:,1)   = y0;
        for t = 1:maxiter
            Aj        = Aj*A;
            AA(:,:,t) = Aj;
            Y(:,t+1)  = A*Y(:,t) + B*E(:,t);
        end
         
    end

end
