function [betaDraws,sigmaDraws] = drawParameters(results,~,draws,iter)
% Syntax:
%
% [betaDraws,sigmaDraws] = nb_arimaEstimator.drawParameters(results,...
%                                               options,draws,iter)
%
% Description:
%
% Draw parameters using asymptotic normality assumeption and numerically
% calculated Hessian from ML estimation. Do not draw from the distribution
% of the std of the residual.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 6
        iter = 'end';
    end

    if ~isfield(results,'omega')
        error([mfilename ':: Cannot draw parameters from the model using asymptotic normality as long as ML '...
                         'estimation is not done. (May also be due to an outdated model object, in this case '...
                         'please try to re-estimate the model)'])
    end
    
    omega = results.omega;
    if strcmpi(iter,'end')
        iter = size(omega,3);
    end
    omega = omega(:,:,iter);
    mode  = results.beta(:,:,iter)';
    
    % Asume normal distribution on coefficients and constant std on
    % residual
    variance = diag(omega);
    dist     = nb_distribution.double2NormalDist(mode,variance);
    sigma    = nb_cov2corr(omega);
    copula   = nb_copula(dist,'sigma',sigma);
    
    % Make draws
    %----------------------
    betaDraws  = random(copula,draws,1);    % draws x nPar x 1
    betaDraws  = permute(betaDraws,[2,3,1]);   % nPar x 1 x draws
    sigmaDraws = results.sigma(:,:,ones(1,draws));
 
end
