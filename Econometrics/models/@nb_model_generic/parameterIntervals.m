function ci = parameterIntervals(obj,alpha)
% Syntax:
%
% ci = parameterIntervals(obj,alpha)
%
% Description:
%
% Get confidence intervals (classic) or probability intervals (bayesian).
% 
% Confidence intervals are constructed as:
%
% beta + (+/-nb_distribution.t_icdf(alpha/2))*stdBeta. 
% 
% Probabilty intervals are constructed as the per
%
% Input:
% 
% - obj   : A scalar object of class nb_model_generic. 
% 
% - alpha : Confidence level/probabilty band.
%
% Output:
% 
% - ci    : A nPar x 3 cell matrix. 
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    parNames = obj.parameters.name;
    if strcmpi(obj.estOptions.estimType,'classic')
        beta     = obj.results.beta(:,:,end);
        [N,E]    = size(beta);
        beta     = beta(:);
        stdBeta  = obj.results.stdBeta(:,:,end);
        stdBeta  = stdBeta(:);
        T        = obj.estOptions.estim_end_ind - obj.estOptions.estim_start_ind + 1;
        t        = nb_distribution.t_icdf(1-alpha/2,T - N);
        ci       = [beta - t*stdBeta,beta + t*stdBeta];
        ci       = [parNames(1:N*E),num2cell(ci)];
        ci       = [{'Coefficient','Lower','Upper'};ci];
    else    
        out      = obj.parameterDraws(1000, 'posterior');
        beta     = out.beta;
        [N,E,~]  = size(beta);
        betaDist = nb_distribution.sim2KernelDist(beta);
        betaDist = betaDist(:);
        ci       = icdf(betaDist,[alpha/2;1-alpha/2]);
        ci       = ci';
        ci       = [parNames(1:N*E),num2cell(ci)];
        ci       = [{'Coefficient','Lower','Upper'};ci];     
    end
    
end
