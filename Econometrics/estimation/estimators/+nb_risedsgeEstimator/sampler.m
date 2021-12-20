function [betaD,sigmaD,posterior] = sampler(posterior,draws)

    % Get the objective to draw from
    [objective,lb,ub,x0,SIG] = pull_objective(posterior.model); %#ok<ASGLU,NASGU>
    mcmc_options             = struct('burnin',posterior.burnin,'N',draws,'thin',posterior.thin); %#ok<NASGU>
    if strcmpi(posterior.algorithm,'mh_sampler')
        evalc('Results = mh_sampler(objective,lb,ub,mcmc_options,x0,SIG);');
    else
        evalc('Results = rrf_sampler(objective,lb,ub,mcmc_options,x0,SIG);');
    end
    posteriorDraws = Results.pop;
    params         = [posteriorDraws.x];
    draws          = size(params,2);
    betaD          = permute(params,[1,3,2]);
    sigmaD         = nan(0,0,draws);
    
    % Return all needed information to do posterior draws
    %----------------------------------------------------
    if nargout > 2
        posterior.betaD  = betaD;
        posterior.sigmaD = sigmaD;
    end
    
end
