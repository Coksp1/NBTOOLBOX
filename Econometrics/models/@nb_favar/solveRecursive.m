function tempSol = solveRecursive(results,opt,ident)
% Syntax:
%
% tempSol = nb_favar.solveRecursive(results,opt,ident)
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 3
        ident = [];
    end

    % Get model settings
    maxLag = max(opt.maxLagLength,opt.nLags);
    dep    = opt.dependent;
    if isfield(opt,'block_exogenous')
        dep = [dep,opt.block_exogenous];
    end
    exo = opt.exogenous;
    if opt.time_trend
        exo = ['Time-trend',exo]; %#ok<*AGROW>
    end
    if opt.constant
        exo = ['Constant',exo];
    end
    
    % Remove the predetermined lags from the
    % exogenous variables
    pred = nb_cellstrlag(dep,maxLag,'varFast');
    ind  = ~ismember(exo,pred);
    exo  = exo(ind);
    
    depAll    = [dep,opt.factors];
    nFactRHS  = length(opt.factorsRHS);
    numDep    = length(depAll);
    nLags     = (sum(~ind) + nFactRHS)/numDep;
    beta      = permute(results.beta,[2,1,3]);
    nPeriods  = size(beta,3);
    numRows   = (nLags - 1)*numDep;
    numRTot   = nLags*numDep;
    numExo    = length(exo);
    if ~nb_isempty(ident)
        if isfield(ident,'ordering')
            order     = ident.ordering;
            [~,indO]  = ismember(order,depAll);
            [~,indI]  = ismember(depAll,order);
        end
    end
    
    % Get the equation y = A*y_1 + B*x + C*e
    % for the dynamic system at each step
    %------------------------------------------

    % Seperate the coefficients of the 
    % exogenous and the predetermined lags
    factBeta = beta(:,end-nFactRHS+1:end,:);
    beta     = beta(:,1:end-nFactRHS,:);
    predBeta = [beta(:,~ind,:),factBeta];
    beta     = beta(:,ind,:);

    % Reorder the VAR, so the variables run fast
    allLagsOld = [nb_cellstrlag(dep,nLags,'varFast'),opt.factorsRHS];
    allLags    = nb_cellstrlag(depAll,nLags,'varFast');
    [~,ind]    = ismember(allLags,allLagsOld);
    predBeta   = predBeta(:,ind,:);
    
    % The final solution
    I = eye(numRows);
    I = I(:,:,ones(1,nPeriods));
    A = [predBeta;I,zeros(numRows,numDep,nPeriods)];
    B = [beta;zeros(numRows,numExo,nPeriods)];

    % Identification of the VAR
    res     = strcat('E_',depAll);
    counter = [];
    if nb_isempty(ident)
        C   = [eye(numDep);zeros(numRows,numDep)];
        C   = C(:,:,ones(1,nPeriods));
        vcv = results.sigma;
    else

        switch lower(ident.type)

            case 'cholesky'

                C = zeros(numRTot,numDep,nPeriods);
                for ii = 1:nPeriods
                    sigma = results.sigma(:,:,ii);
                    sigma = sigma(indO,indO);
                    try
                        CT = chol(sigma,'lower');
                    catch Err
                        sigmaC = nb_covrepair(sigma);
                        CT     = chol(sigmaC)';
                        if sum(sigmaC(:)-sigma(:)) > eps^(1/4)
                            rethrow(Err)
                        end
                    end
                    C(:,:,ii) = [CT(indI,indI);zeros(numRows,numDep)];
                end

            case 'combination'

                counter = nan(1,nPeriods);
                C       = zeros(numRTot,numDep,nPeriods,ident.draws);
                
                % Create waiting bar window
                h      = nb_waitbar([],'Identification',nPeriods,true);
                h.text = 'Starting...'; 
                
                for ii = 1:nPeriods
                    S           = nb_var.ABidentification(ident,A(:,:,ii),results.sigma(:,:,ii),ident.maxDraws,ident.draws);
                    C(:,:,ii,:) = [S.W;zeros(numRows,numDep,1,ident.draws)];
                    counter(ii) = S.counter;
                    
                    if h.canceling
                        error([mfilename ':: User terminated'])
                    end

                    h.status = ii;
                    h.text   = ['Finished with ' int2str(ii) ' recursive periods...'];
                    
                end
                shocks           = ident.shocks;
                nShocks          = length(shocks);
                res(1,1:nShocks) = shocks;

                % Delete the waitbar.
                delete(h) 
                
            otherwise
                 error([mfilename ':: Unsupported identification type ' ident.type])
        end
        
        vcv = eye(size(results.sigma(:,:,1)));
        vcv = vcv(:,:,ones(1,nPeriods));
        
    end
    
    tempSol   = struct();
    tempSol.A = A;
    tempSol.B = B;
    tempSol.C = C;

    % Get the ordering
    tempSol.endo           = [depAll,nb_cellstrlag(depAll,nLags-1,'varFast')];
    tempSol.exo            = exo;
    tempSol.obs            = depAll;
    tempSol.res            = res;
    tempSol.vcv            = vcv;
    tempSol.identification = ident;
    tempSol.counter        = counter;
    tempSol.class          = 'nb_favar';
    tempSol.type           = 'nb';

    % Now we need to solve the observation eq part as well
    tempSol.observables = [opt.observables,opt.observablesFast];
    order               = [opt.factors,dep];
    wanted              = [dep,opt.factors];
    [~,ind]             = ismember(wanted,order);
    tempSol.factors     = wanted;
    tempSol.F           = permute(results.lambda(1,:,:),[2,1,3]);
    G                   = permute(results.lambda(2:end,:,:),[2,1,3]);
    tempSol.G           = G(:,ind,:);
    
    % Assume a diagonal variance covariance matrix of the observation eq
    % (This is ok, as each eq is estimated by itself)
    R = results.R;
    for ii = 1:size(R,3)
        R(:,:,ii) = diag(diag(R(:,:,ii)));
    end
    tempSol.R = R;
    
end
