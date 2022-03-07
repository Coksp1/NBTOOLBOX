function irfData = irfPoint(solution,options,inputs,results)
% Syntax:
%
% irfData = nb_irfEngine.irfPoint(model,options,inputs,results)
%
% Description:
%
% Produce point IRF.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if isfield(results,'densities')
        dist = results.densities; % Used by PIT models
    else
        dist = [];
    end
    
    if strcmpi(options.class,'nb_dsge')
        if isfield(options.parser,'object')
            if isfield(options.parser.object.options,'stochastic_trend') && options.parser.object.options.stochastic_trend
                irfData = nb_irfEngine.irfPointStochTrend(options.parser.object,options,inputs);
                return
            end
        end
    end
    
    periods = inputs.periods;
    shocks  = inputs.shocks;
    vars    = inputs.variables;
    nShocks = length(shocks);
    sign    = inputs.sign;
    if isscalar(sign)
        sign = sign(ones(1,nShocks),1);
    else
        sign = sign(:);
        if size(sign,1) ~= nShocks
           error(['The sign input must either be a scalar double or vector with size ' int2str(nShocks) ' x 1.']) 
        end
    end
    
    % Get model information
    [A,B,C,vcv,Qfunc] = nb_forecast.getModelMatrices(solution,'end',1);

    endo = solution.endo;
    res  = solution.res;
    if isfield(options,'dependent') && ~strcmpi(options.class,'nb_mfvar')
        dep  = options.dependent;
    else
        dep = endo;
    end
    if isfield(options,'block_exogenous')
        dep = [dep,options.block_exogenous];
    end
    if isfield(options,'factors') % Factor model
        dep = [dep,options.factors];
    end
    nDep = length(dep);
    if isfield(options,'estim_method')
        if strcmpi(options.estim_method,'pit')
            dep = strrep(dep,'_normal','');
        end
    end
    
    % Calculate irfs
    nEndo   = length(endo);
    E       = zeros(length(res),periods);
    if iscell(B)
        X = zeros(size(B{1},2),periods);
    else
        X = zeros(size(B,2),periods);
    end
    if strcmpi(solution.class,'nb_sa') || strcmpi(solution.class,'nb_fmsa')
        
        dep  = unique(regexprep(options(end).dependent,'_{0,1}lead[0-9]*$',''));
        nDep = length(dep);
    
        % In this case we do an impulse to the exogenous variables instead
        % of the residuals
        Y = zeros(nDep,periods + 1,nShocks);
        for jj = 1:nShocks

            indS       = strcmpi(shocks{jj},solution.exo);
            XT         = X;
            XT(indS,1) = sign(jj); % One standard deviation  
            if any(indS)
                Yt    = B*XT(:,1);
                leads = size(Yt,1)/nDep;
                Yt    = reshape(Yt,[leads,nDep]);
                if strcmpi(solution.class,'nb_sa')
                    Yt = permute(Yt,[2,1]);
                end
                if periods < leads
                    Yt = Yt(:,1:periods);
                end
                Y(:,2:leads+1,jj) = Yt;
                
            else % This model does not have this shock
                Y(:,:,jj) = nan(nDep,periods + 1,1);
            end

        end
               
    elseif strcmpi(inputs.type,'girf') && iscell(A) && ~isempty(Qfunc) % GIRF with Markov switching model
        
        ss   = solution.ss;
        Y    = zeros(nEndo,periods + 1,nShocks,inputs.draws);
        y0   = inputs.y0;
        for ii = 1:inputs.draws
            
            PAI0        = inputs.PAI0(:,ii);
            Y(:,1,:,ii) = y0(:,ii,ones(1,nShocks)); % Intial values can be of importance, e.g. non-linear models
            for jj = 1:nShocks

                indS       = strcmpi(shocks{jj},res);
                ET         = E;
                ET(indS,1) = sign(jj); % One standard deviation innovation, here we assume that vcv is the identity matrix!    
                if any(indS)
                    [Y1,st]      = ms.computeForecastAnticipatedMS(A,B,C,ss,Qfunc,Y(:,:,jj),X,ET,inputs.states,PAI0);
                    Y2           = ms.computeForecastAnticipatedMS(A,B,C,ss,Qfunc,Y(:,:,jj),X,E,st,PAI0);
                    Y(:,:,jj,ii) = Y1 - Y2;
                else % This model does not have this shock
                    Y(:,:,jj,ii) = nan(nEndo,periods + 1,1);
                end

            end
            
        end
        
        % Only return the mean over the simulations
        Y = mean(Y,4);
        Y = Y(1:nDep,:,:);
          
    elseif strcmpi(inputs.type,'girf') && iscell(A) % GIRF with break-point model
        
        if any(isnan(inputs.states))
            error([mfilename ':: The states input cannot include nans when dealing with a break-point model.'])
        end
        ss   = solution.ss;
        Y    = zeros(nEndo,periods + 1,nShocks,inputs.draws);
        y0   = inputs.y0;
        for ii = 1:inputs.draws
            
            Y(:,1,:,ii) = y0(:,ii,ones(1,nShocks)); % Intial values can be of importance, e.g. non-linear models
            for jj = 1:nShocks

                indS       = strcmpi(shocks{jj},res);
                ET         = E;
                ET(indS,1) = sign(jj); % One standard deviation innovation, here we assume that vcv is the identity matrix!    
                if any(indS)
                    Y1           = nb_computeForecastAnticipatedBP(A,B,C,ss,Y(:,:,jj),X,ET,inputs.states);
                    Y2           = nb_computeForecastAnticipatedBP(A,B,C,ss,Y(:,:,jj),X,E,inputs.states);
                    Y(:,:,jj,ii) = Y1 - Y2;
                else % This model does not have this shock
                    Y(:,:,jj,ii) = nan(nEndo,periods + 1,1);
                end

            end
            
        end
        
        % Only return the mean over the simulations
        Y = mean(Y,4);
        Y = Y(1:nDep,:,:);    
        
    elseif strcmpi(inputs.type,'girf') % GIRF with non linear model
        
        Y  = zeros(nDep,periods + 1,nShocks,inputs.draws);
        YT = zeros(nEndo,periods + 1);
        y0 = inputs.y0;
        for ii = 1:inputs.draws
            
            for jj = 1:nShocks
                YT(:,1)    = y0(:,ii);                   % Intial values can be of importance, e.g. non-linear models
                indS       = strcmpi(shocks{jj},res);
                ET         = E;
                ET(indS,1) = sign(jj)*vcv(indS,indS); % One standard deviation innovation  
                if any(indS)
                    Y1 = nb_computeForecast(A,B,C,YT,X,ET);
                    Y2 = nb_computeForecast(A,B,C,YT,X,E);
                    if ~isempty(dist)
                        Y1 = nb_forecast.map2Density(dist,Y1(1:nDep,:),[],nDep);% Map back to correct density
                        Y2 = nb_forecast.map2Density(dist,Y2(1:nDep,:),[],nDep);
                    else
                        Y1 = Y1(1:nDep,:);% Map back to correct density
                        Y2 = Y2(1:nDep,:);
                    end
                    Y(:,:,jj,ii) = Y1 - Y2;
                else % This model does not have this shock
                    Y(:,:,jj,ii) = nan(nEndo,periods + 1,1);
                end

            end
            
        end
        
        % Only return the mean over the simulations
        Y = mean(Y,4);
        
    elseif iscell(A) % Normal irf with Markov-switching models, only one state simulation (or if condition on a state)
        
        Y = zeros(nEndo,periods + 1,nShocks);
        if ~isempty(inputs.y0)
            y0       = inputs.y0(:,end);
            Y(:,1,:) = y0(:,:,ones(1,nShocks)); % Intial values can be of importance, e.g. non-linear models
        end
        
        if length(shocks) == 1 && strcmpi(shocks{1},'states')
            % IRF where only the regime switches
            if isempty(Qfunc)
                Y = nb_computeForecastAnticipatedBP(A,B,C,solution.ss,Y,X,E,inputs.states);
            else
                Y = ms.computeForecastAnticipatedMS(A,B,C,solution.ss,Qfunc,Y,X,E,inputs.states,inputs.PAI0);
            end
        else
            for jj = 1:nShocks

                indS       = strcmpi(shocks{jj},res);
                ET         = E;
                ET(indS,1) = sign(jj); % One standard deviation innovation, here we assume that vcv is the identity matrix!  
                if any(indS)
                    ss = solution.ss;
                    if isempty(Qfunc)
                        Y(:,:,jj) = nb_computeForecastAnticipatedBP(A,B,C,ss,Y(:,:,jj),X,ET,inputs.states);
                    else
                        Y(:,:,jj) = ms.computeForecastAnticipatedMS(A,B,C,ss,Qfunc,Y(:,:,jj),X,ET,inputs.states,inputs.PAI0);
                    end
                else % This model does not have this shock
                    Y(:,:,jj) = nan(nEndo,periods + 1,1);
                end

            end
        end
        Y = Y(1:nDep,:,:);
        
    else
    
        Y = zeros(nEndo,periods + 1,nShocks);
        if ~isempty(inputs.y0)
            y0       = inputs.y0(:,end);
            Y(:,1,:) = y0(:,:,ones(1,nShocks)); % Intial values can be of importance, e.g. factor models
        end
        
        for jj = 1:nShocks

            indS       = strcmpi(shocks{jj},res);
            ET         = E;
            ET(indS,1) = sign(jj)*vcv(indS,indS); % One standard deviation innovation  
            if any(indS)
                Y(:,:,jj) = nb_computeForecast(A,B,C,Y(:,:,jj),X,ET);
            else % This model does not have this shock
                Y(:,:,jj) = nan(nEndo,periods + 1,1);
            end

        end
        Y = Y(1:nDep,:,:);
        
        % Map back to correct density
        if ~isempty(dist)
           Y = nb_forecast.map2Density(dist,Y,[],nDep);
        end
        
    end
    
    % Now we need to get the irf of the observables if we are dealing with
    % a factor model
    if isfield(solution,'G') && ~strcmpi(solution.class,'nb_arima')
        
        [ind,indO] = ismember(solution.observables,vars);
        indO       = indO(ind);
        if ~isempty(indO)
            
            G = solution.G(indO,:,end);  
            Z = nan(size(G,1),periods + 1,nShocks);
            for jj = 1:nShocks
                Z(:,:,jj) = G*Y(:,:,jj); % Observation equation
            end
            dep = [dep,solution.observables(ind)];
            Y   = [Y;Z];
            
        end
        
    end
    
    % Add irfs for observables if we are dealing with a MF-VAR
    ss = [];
    if strcmpi(options.class,'nb_mfvar')
        nShocks = size(Y,3);
        nObs    = size(solution.H,1);
        Yobs    = nan(nObs,size(Y,2),nShocks);% nObs x nHor x nShocks
        for ii = 1:nShocks
            Yobs(:,:,ii) = solution.H*Y(:,:,ii); % Get forecast on the observed variables
        end
        Y   = [Yobs;Y(1:nObs,:,:)];
        dep = [options.dependent,dep(1:nObs)];
    elseif isfield(solution,'ss')  
        if ~iscell(solution.ss)
            if inputs.addSS
                Y = bsxfun(@plus,Y,solution.ss);
            end
        end
        ss = solution.ss;
    end
    
    % Collect, normalize or transform IRFs
    irfData = nb_irfEngine.collect(options,inputs,Y,dep,results,ss);

end
