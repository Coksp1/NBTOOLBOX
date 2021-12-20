function [beta,sigma,yD] = nb_drawFromPosterior(posterior,draws,waitbar)
% Syntax:
%
% [beta,sigma]    = nb_drawFromPosterior(posterior,draws,waitbar)
% [beta,sigma,yD] = nb_drawFromPosterior(posterior,draws,waitbar)
%
% Description:
%
% Make draws from a posterior. 
%
% Caution: Will use the last paramter draw given by the
% posterior.betaD(:,:,end) and posterior.sigmaD(:,:,end), where that
% applies.
% 
% Input:
% 
% - posterior : A struct with the needed inputs to the different functions
%               to make posterior draws. See the posterior output of;
%               
%               > nb_bVarEstimator.minnesota
%               > nb_bVarEstimator.minnesotaMF
%               > nb_bVarEstimator.jeffrey
%               > nb_bVarEstimator.glp
%               > nb_bVarEstimator.glpMF
%               > nb_bVarEstimator.nwishart
%               > nb_bVarEstimator.nwishartMF
%               > nb_bVarEstimator.inwishart
%               > nb_bVarEstimator.inwishartMF
%               > nb_risedsgeEstimator.sampler
%               > nb_statespaceEstimator.sampler
%               > nb_dsge.priorPredictiveAnalysis
% 
% - nDraws    : Number of draws form the posterior distribution
%
% - waitbar   : true, false or an object of class nb_waitbar5.
%
% Output:
% 
% - beta      : The posterior draws of the model coefficients, as a nCoeff
%               x nEq x nDraws double.
%
% - sigma     : The posterior draws of the residual covariance matrix as a
%               nEq x nEq x nDraws double.
%
% - yD        : Sampling from the posterior of missing observations. []
%               if models does not handle missing observations.
%
% See also:
% nb_bVarEstimator
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 3
        waitbar = true;
    end
    
    if isfield(posterior,'maxTries')
        maxTries = posterior.maxTries;
    else
        maxTries = 100;
    end
    
    yD   = [];
    burn = 10;
    switch lower(posterior.type)
        
        case {'dynare','assign'}
            
            beta  = posterior.betaD;
            sigma = posterior.sigmaD; 
            try
                beta  = beta(:,:,1:draws);
                sigma = sigma(:,:,1:draws);
            catch %#ok<CTCH>
                error([mfilename ':: It is not possible to do more posterior draws than already assign. Max is: ' int2str(size(posterior.betaD,3))])
            end
              
        case 'minnesota'
            
            method = 'default';
            if isfield(posterior,'method')
                method = posterior.method;
                if strcmpi(method,'mci')
                    method = 'default'; 
                end
            end
            
            initBeta     = posterior.betaD(:,:,end);
            initSigma    = posterior.sigmaD(:,:,end); 
            y            = posterior.dependent;
            X            = posterior.regressors;
            restrictions = posterior.restrictions;
            if strcmpi(method,'default')
                [beta,sigma] = nb_bVarEstimator.minnesotaMCI(draws,y,X,initBeta,initSigma,posterior.a_prior,posterior.V_prior,restrictions,waitbar);
            else
                [beta,sigma] = nb_bVarEstimator.minnesotaGibbs(draws,y,X,initBeta,initSigma,posterior.a_prior,posterior.V_prior,posterior.S_prior,...
                                    posterior.v_post,restrictions,burn,posterior.thin,waitbar);
            end
            
        case 'minnesotamf'
            
            method = 'default';
            if isfield(posterior,'method')
                method = posterior.method;
                if strcmpi(method,'mci')
                    method = 'default'; 
                end
            end
            
            initBeta     = posterior.betaD(:,:,end);
            initSigma    = posterior.sigmaD(:,:,end); 
            y            = posterior.dependent;
            X            = posterior.regressors;
            H            = posterior.H;
            restrictions = posterior.restrictions;
            if ~strcmpi(method,'default')
                [beta,sigma,yD] = nb_bVarEstimator.minnesotaMFGibbs(draws,y,X,H,posterior.R_prior,initBeta,initSigma,posterior.a_prior,posterior.V_prior,posterior.S_prior,...
                                    posterior.v_post,restrictions,burn,posterior.thin,waitbar,maxTries);
            else
                [beta,sigma,yD] = nb_bVarEstimator.minnesotaMFMCI(draws,y,X,H,posterior.R_prior,initBeta,initSigma,posterior.a_prior,posterior.V_prior,restrictions,...
                                    burn,posterior.thin,waitbar,maxTries);
            end    
            
        case 'jeffrey'
            
            initSigma      = posterior.sigmaD(:,:,end); 
            [numCoeff,nEq] = size(posterior.betaD(:,:,end));
            X              = posterior.regressors;
            T              = posterior.T;
            restrictions   = posterior.restrictions;
            [beta,sigma]   = nb_bVarEstimator.jeffreyMCI(draws,X,T,numCoeff,nEq,initSigma,posterior.SSE,posterior.a_ols,restrictions,waitbar);
            
        case {'nwishart','glp'}
            
            initBeta     = posterior.betaD(:,:,end);
            initSigma    = posterior.sigmaD(:,:,end); 
            restrictions = posterior.restrictions;
            [beta,sigma] = nb_bVarEstimator.nwishartMCI(draws,initBeta,initSigma,posterior.a_post,...
                                posterior.V_post,posterior.S_post,posterior.v_post,restrictions,waitbar);
          
        case {'nwishartmf','glpmf'}
            
            initBeta        = posterior.betaD(:,:,end);
            initSigma       = posterior.sigmaD(:,:,end); 
            restrictions    = posterior.restrictions;
            y               = posterior.dependent;
            X               = posterior.regressors;
            H               = posterior.H;
            [beta,sigma,yD] = nb_bVarEstimator.nwishartMFGibbs(draws,y,X,H,posterior.R_prior,initBeta,initSigma,posterior.a_prior,...
                                posterior.V_prior_inv,posterior.S_prior,posterior.v_post,restrictions,posterior.thin,burn,waitbar,maxTries);
                            
        case 'inwishart'
            
            initBeta     = posterior.betaD(:,:,end);
            initSigma    = posterior.sigmaD(:,:,end); 
            y            = posterior.dependent;
            X            = posterior.regressors;
            restrictions = posterior.restrictions;
            [beta,sigma] = nb_bVarEstimator.inwishartGibbs(draws,y,X,initBeta,initSigma,posterior.a_prior,...
                                posterior.V_prior,posterior.S_prior,posterior.v_post,restrictions,posterior.thin,burn,waitbar);                    
                 
        case 'inwishartmf'
            
            initBeta        = posterior.betaD(:,:,end);
            initSigma       = posterior.sigmaD(:,:,end); 
            y               = posterior.dependent;
            X               = posterior.regressors;
            H               = posterior.H;
            restrictions    = posterior.restrictions;
            [beta,sigma,yD] = nb_bVarEstimator.inwishartMFGibbs(draws,y,X,H,posterior.R_prior,initBeta,initSigma,posterior.a_prior,...
                                posterior.V_prior,posterior.S_prior,posterior.v_post,restrictions,posterior.thin,burn,waitbar,maxTries); 
            
        case 'priorpredictive'
            
            beta  = permute(random(posterior.distr,draws,1),[3,2,1]);   
            sigma = nan(0,1,draws); 
                            
        case 'risedsge'
            
            [beta,sigma] = nb_risedsgeEstimator.sampler(posterior,draws);                     
               
        case 'statespace'
            
            if nb_isempty(posterior.output)
                error([mfilename ':: The M-H has not converged. Either set the ''draws'' to an integer larger than 0 before ',...
                                 'calling estimate, or use the sample() method.'])
            else
                % The M-H has converged, so we only need to continue from
                % where we are
                [beta,sigma] = nb_statespaceEstimator.sampler(posterior,draws);       
            end
            
        case 'usv'
            
            initBeta       = posterior.betaD(:,:,end); 
            prior          = posterior.prior;
            [beta,~,sigma] = nb_stochvolEstimator.usvGibbs(draws,posterior.y,posterior.Z,initBeta,posterior.AR,prior,prior.thin,burn,waitbar); 
                            
        otherwise
            error([mfilename ':: The posterior type '  posterior.type ' can not be drawn from.'])
    end
    
end
