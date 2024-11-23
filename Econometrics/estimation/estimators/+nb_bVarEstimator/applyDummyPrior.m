function [y,X,constant,options] = applyDummyPrior(options,y,X,yFull,XFull)
% Syntax:
%
% [y,X,constant,options] = nb_bVarEstimator.applyDummyPrior(...
%       options,y,X,yFull,XFull)
%
% Description:
%
% Add dummy observation prior.
% 
% See also:
% nb_bVarEstimator.doBayesian
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % The SVD prior was added 8/9-2022, so saved posterior struct may
    % not include this!
    options.prior = nb_defaultField(options.prior,'SVD',false);  
    if options.prior.LR || options.prior.SC || options.prior.DIO || options.prior.SVD
        nExo     = size(X,2) - size(y,2)*(options.nLags + 1);
        exoX     = XFull(:,1:nExo); % Pure exogenous variables
        constant = options.constant;
        if options.constant
            X                = [ones(size(X,1),1),X];
            options.constant = 0; % We have now added the constant, so we just tell it to not add it once more!
        end
        options.constantAR = constant;
    else
        constant           = options.constant;
        options.constantAR = constant;
        return
    end
    
    if options.time_trend
        error('Cannot set time_trend to true if using a dummy variable prior.')
    end
    
    if options.prior.SVD

        if ~isempty(options.covidAdj)
            error(['It does not make sense to use the SVD prior at the ',...
                'same time as you set the covidAdj option! Do either one of them'])
        end

        % Stochastic volatility dummy prior
        % How to estimate a vector autoregression after March 2020
        % Lenza and Primiceri (2020)
        T  = size(y,1);
        TC = options.prior.obsSVD;
        if TC <= T
            invWeights = nb_bVarEstimator.constructInvWeights(options.prior,T);
            y          = bsxfun(@times,(1./invWeights),y);
            X          = bsxfun(@times,(1./invWeights),X);
        end  
    end
    if options.prior.LR
        % Here we apply a conjugate dummy observation prior for the
        % long run as in Giannone et. al (2014).
        [yPlus,XPlus] = nb_bVarEstimator.setUpPriorLR(options.prior,yFull,...
            exoX,options.nLags+1,constant,options.time_trend);
        y = [y;yPlus];
        X = [X;XPlus];
    elseif options.prior.SC
        % Sum-of-coefficients prior by Doan, Litterman, and Sims (1984)
        [yPlus,XPlus] = nb_bVarEstimator.setUpPriorSC(options.prior,...
            yFull,exoX,options.nLags+1,constant,options.time_trend);
        y = [y;yPlus];
        X = [X;XPlus];
    end
    if options.prior.DIO
        % Dummy-initial-observation prior by Sims (1993)
        [yPlus,XPlus] = nb_bVarEstimator.setUpPriorDIO(options.prior,yFull,...
            exoX,options.nLags+1,constant,options.time_trend);
        y = [y;yPlus];
        X = [X;XPlus];
    end

end
