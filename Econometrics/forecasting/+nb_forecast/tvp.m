function [Y,XE] = tvp(restrictions,model,options,results,nSteps,iter,inputs,type)
% Syntax:
%
% [Y,XE] = nb_forecast.tvp(restrictions,model,options,results,nSteps,...
%                          iter,inputs,type)
%
% Description:
%
% Produce forecast of time-varying parameter models.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    try options = options(iter); catch; end %#ok<CTCH>
    
    % Get posterior draws
    if ~isfield(options,'pathToSave')
        error([mfilename ':: No estimation is done, so can''t draw from the posterior.'])
    end
    try
        coeffDraws = nb_loadDraws(options.pathToSave);
    catch Err
        nb_error('It seems to me that the estimation results has been saved in a folder you no longer have access to.',Err)
    end
    coeffDraws = coeffDraws(iter);
    H          = coeffDraws.h;
    
    startInd = inputs.startInd;
    if isempty(startInd)
        if options.recursive_estim  
            startInd = options.recursive_estim_start_ind + 1;
        else
            startInd = options.estim_end_ind + 1;
        end
    end
    if options.recursive_estim  
        indT = startInd + iter - 2;
    else
        indT = startInd + restrictions.index - 2;
    end
    omega0 = coeffDraws.y - coeffDraws.Z*(model.G(:,:,iter)');
    omega0 = omega0(indT-options.nLags+1:indT);
    
    if strcmpi(type,'point')
        
        % Get solution
        A    = model.A(:,:,iter);
        B    = model.B(:,:,iter);
        C    = model.C(:,:,iter);
        BP   = model.BP(:,:,iter);
        AP   = model.AP(:,:,iter);
        vcvP = model.vcvP(:,:,iter);
        vcvP = chol(vcvP);
        
        % Restrictions on shocks
        index = restrictions.index;
        if restrictions.condDistribution
            E = restrictions.E(:,:,index)'; % nb_distribution object
            E = mean(E); %#ok<UDIM>  
        else
            E = restrictions.E(:,:,index)'; % nb_distribution object 
        end
        X  = zeros(0,nSteps);
        XP = ones(1,nSteps);
        EP = zeros(1,nSteps);
        
        % Forecast
        omega = nb_forecast.condShockForecastEngine(omega0,A,B,C,[],[],X,E,[],[],nSteps);
        omega = omega(1,2:end);
        [Y,Z] = nb_forecast.addZContribution(omega,model,options,restrictions,inputs,1,iter);
        h0    = mean(H,3);
        h0    = h0(indT-options.nLags,:);
        HF    = nb_forecast.condShockForecastEngine(h0,AP,BP,vcvP,[],[],XP,EP,[],[],nSteps);
        HF    = HF(:,2:end,:);
        
    else
        
        draws          = inputs.draws;
        parameterDraws = inputs.parameterDraws;
        
        % Get solution
        A    = model.A(:,:,iter);
        B    = model.B(:,:,iter);
        C    = model.C(:,:,iter);
        vcv  = model.vcv(:,:,iter);
        BP   = model.BP(:,:,iter);
        AP   = model.AP(:,:,iter);
        vcvP = model.vcvP(:,:,iter);
        
        if parameterDraws == 1
            
            if restrictions.softConditioning
                error([mfilename ':: Soft conditioning is not supported for time-varying parameter models.'])
            elseif restrictions.type == 3
                error([mfilename ':: Conditioning on endogenous variable is not supported for time-varying parameter models.'])
            end
            E  = nb_forecast.drawShocksAndExogenous([],A,B,C,[],[],vcv,nSteps,draws,restrictions,[],inputs,options);
            X  = zeros(0,nSteps,draws);
            
            % Use U = exp(H/2)E
            h0 = mean(H,3);
            h0 = h0(indT-options.nLags,:)';
            EP = randn(size(h0,1),nSteps,draws);
            XP = ones(1,nSteps);
            HF = nan(size(h0,1),nSteps+1,draws);
            for ii = 1:draws
                HF(:,:,ii) = nb_forecast.condShockForecastEngine(h0,AP,BP,vcvP,[],[],XP,EP(:,:,ii),[],[],nSteps);
            end
            HF = HF(:,2:end,:);
            U  = exp(HF./2).*E;
            
            % Make draws number of simulations of the residual and forecast
            % conditional on those residuals
            nVars = length(omega0);
            Y     = nan(nVars,nSteps + 1,draws);
            for jj = 1:draws
                Y(:,:,jj) = nb_forecast.condShockForecastEngine(omega0,A,B,C,[],[],X(:,:,jj),U(:,:,jj),[],[],nSteps);
            end
            Y = Y(:,2:end,:);

            % Append contribution of exogenous variables when dealing with
            % univariate stochastic volatility models
            if strcmpi(options.prior.type,'usv')
                [Y,Z] = nb_forecast.addZContribution(Y,model,options,restrictions,inputs,draws,iter);
            end
            
        else
            error([mfilename ':: Forecasting of time-varying parameter models with parameter uncertainty is not yet supported.'])
        end
        
    end
    
    Y  = permute(Y,[2,1,3]);
    XE = [permute(Z,[2,1,3]),permute(E(:,1:nSteps,:),[2,1,3]),permute(HF,[2,1,3]),permute(EP,[2,1,3])];

end

