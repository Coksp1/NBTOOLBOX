function [E,X,states,solution] = conditionalOnDistributionEngine(y0,model,ss,nSteps,draws,restrictions,solution,inputs)
% Syntax:
%
% [E,X,states,solution] = nb_forecast.conditionalOnDistributionEngine(y0,
%                       model,ss,nSteps,draws,restrictions,...
%                       solution)
%
% Description:
%
% Conditional on restrictions given by marginal distributions. A copula is
% used to draw from the marginal given a correlation matrix. For each draw
% the shocks/residual to match the drawn conditional information is
% identified. And as a result you end up with the wanted number of draws
% from the distributions of the shocks/residual to match the conditional
% information.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Make waitbar or append already made waitbar
    if isfield(inputs,'waitbar')
       h = inputs.waitbar;
    else
        if isfield(inputs,'index')
            figureName = ['Forecast for Model ' int2str(inputs.index) ' of ' int2str(inputs.nObj)];
        else
            figureName = 'Forecast';
        end
        h = nb_waitbar5([],figureName,true);
    end 
    h.text4          = 'Draw from the distribution...';
    h.maxIterations4 = draws + 1;
    note             = nb_when2Notify(draws);
    
    % Get some inputs
    index = restrictions.index;
    if isfield(restrictions,'covY')
        % sigma is the autocorrelation matrix with size 
        % nvar*nSteps x nvar*nSteps 
        sigma = restrictions.covY;
    else
        error([mfilename ':: When condition on distributions of endogenous variables the sigma input must be given.'])
    end

    % Draw the exogenous variables (may be constants!)
    X = restrictions.X(:,:,index); % nb_distribution object
    X = random(X,draws,1);         % draws x 1 x nSteps x nvar
    X = permute(X,[4,3,1,2]);      % nvar x nSteps x draws
    
    % Draw the exogenous variables (may be nan!)
    E = restrictions.E(:,:,index); % nb_distribution object
    E = random(E,draws,1);         % draws x 1 x nSteps x nvar
    E = permute(E,[4,3,1,2]);      % nvar x nSteps x draws
   
    % Get the number of iterations
    distY = restrictions.Y(:,:,index); % nSteps x nvar nb_distribution object
    both  = any(~isnan(E(:))) && ~isempty(distY);
        
    % Make draws from the different distributions
    nVar = size(distY,2);
    if both
    
        if isfield(inputs,'initPeriods')
            if inputs.initPeriods > 0
                error([mfilename ':: It is not possible to use the initPeriod input and at '...
                                 'the same time condition on both shocks and endogenous variables']);
            end
        end

        % For each draw of the shock we get paths of the endogenous 
        % variables. To make draws that makes sense from the endogenous 
        % variables that are conditioned from the start we must 
        % condition on a set of other endogenous variables. The
        % set must consist of at least as many variables as there are 
        % shocks...
        ind     = isnan(E);
        count   = sum(ind(:));
        ET      = E;
        ET(ind) = randn(count,1);
        if iscell(C)
            Ct = C{1};
        else
            Ct = C;
        end
        
        % Simulate the observations on the restricted endogenous 
        % variables
        states = nan(nSteps,1,draws);
        if size(Ct,3) > 1
            ET = [ET,zeros(size(ET,1),size(Ct,3)-1,size(ET,3))];
        end

        YTCOND = nan(nVar,nSteps,draws);
        for ii = 1:draws
            [YT,states(:,:,ii)] = nb_forecast.condShockForecastEngine(y0,...
                model.A,model.B,model.C,ss,model.Qfunc,X(:,:,ii),ET(:,:,ii),...
                states(:,:,ii),restrictions.PAI0,nSteps);
            YTCOND(:,:,ii)      = YT(restrictions.indY,2:nSteps+1)';        % nSteps x nrest   This has to be decided!!!
        end
        distUncond = nb_distribution.sim2KernelDist(YTCOND);
        distUncond = distUncond(:);
        clearvars ET YT YTCOND
          
        % Draw paths from the uncond and conditional distirbutions
        sigma  = [sigma,sigma;sigma,sigma];
        dist   = distY';                               % nvar x nSteps nb_distribution object
        dist   = dist(:);                              % nvar*nSteps x 1 nb_distribution object
        dist   = [distUncond;dist];                    % (2*nvar)*nSteps nb_distribution object  
        copula = nb_copula(dist','sigma',sigma,'type',restrictions.covYType);
        Y      = random(copula,1,draws);               % 1 x 2*nvar*nSteps x draws
        breakO = numel(distY); 
        Y      = Y(:,breakO+1:end,:);
        Y      = reshape(Y,[1,nVar,nSteps,draws]);     % 1 x nvar x nSteps x draws 
        Y      = permute(Y,[3,2,4,1]);                 % nSteps x nvar x draws
        
        % For each draw identify the shocks matching those restrictions
        simRestrictions = struct('index',1,'indY',restrictions.indY,...
                                 'softConditioning',0,'class',restrictions.class);
        h.status4 = 1;
        h.text4   = 'Start identification of shocks...';
        for ii = 1:draws

            % Assign the draw from the different variables
            simRestrictions.X      = X(:,:,ii)';
            simRestrictions.E      = E(:,:,ii)';
            simRestrictions.Y      = Y(:,:,ii);
            simRestrictions.states = states(:,:,ii);

            % Identify the shocks that meets the restriction from this draw
            [ET,~,states(:,:,ii),solution] = nb_forecast.conditionalProjectionEngine(y0,model,ss,nSteps,simRestrictions,solution);
            E(:,:,ii)                      = ET(:,1:nSteps,:);
            
            % Report current status in the waitbar's message field
            if h.canceling
                error([mfilename ':: User terminated'])
            end
            if rem(ii,note) == 0
                h.status4 = ii + 1;
                h.text4   = ['Identified shocks from draw ' int2str(ii) ' of ' int2str(draws) ' draws from the copula...'];
            end

        end
            
    else % Only endogenous
        
        if isfield(inputs,'initPeriods')
            tSteps = nSteps + inputs.initPeriods;
        else
            tSteps = nSteps;
        end

        distY  = distY';                           % nvar x nSteps nb_distribution object
        distY  = distY(:);                         % nvar*nSteps x 1 nb_distribution object
        distY  = distY';
        copula = nb_copula(distY,'sigma',sigma,'type',restrictions.covYType);
        Y      = random(copula,1,draws);           % 1 x nvar*nSteps x draws 
        Y      = reshape(Y,[1,nVar,tSteps,draws]); % 1 x nvar x nSteps x draws 
        Y      = permute(Y,[3,2,4,1]);             % nSteps x nvar x draws
        if isfield(inputs,'initPeriods')
            Y = Y(inputs.initPeriods+1:end,:,:); % Remove inital periods
        end                     
        states = nan(nSteps,1,draws);
        
        % For each draw identify the shocks matching those restrictions
        simRestrictions = struct('index',1,'indY',restrictions.indY,...
                                 'softConditioning',0,'class',restrictions.class,...
                                 'kalmanFilter',restrictions.kalmanFilter);
        h.status4 = 1;
        h.text4   = 'Start identification of shocks...';
        for ii = 1:draws

            % Assign the draw from the different variables
            simRestrictions.X      = X(:,:,ii)';
            simRestrictions.E      = E(:,:,ii)';
            simRestrictions.Y      = Y(:,:,ii);
            simRestrictions.states = states(:,:,ii);

            % Identify the shocks that meets the restriction from this draw
            [ET,~,states(:,:,ii),solution] = nb_forecast.conditionalProjectionEngine(y0,model,ss,nSteps,simRestrictions,solution);
            E(:,:,ii) = ET(:,1:nSteps,:);

            % Report current status in the waitbar's message field
            if h.canceling
                error([mfilename ':: User terminated'])
            end
            if rem(ii,note) == 0
                h.status4 = ii + 1;
                h.text4   = ['Identified shocks from draw ' int2str(ii) ' of ' int2str(draws) ' draws from the copula...'];
            end

        end
        
    end
    
    deleteFourth(h);

end
