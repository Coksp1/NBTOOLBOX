function tempSol = solveRecursive(results,opt,ident)
% Syntax:
%
% tempSol = nb_var.solveRecursive(results,opt,ident)
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 3
        ident = [];
    end

    % Get model settings
    maxLag = max(opt.maxLagLength + 1,opt.nLags + 1);
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
    
    % Estimation results
    beta = permute(results.beta,[2,1,3]);
    
    % Seperate the coefficients of the exogenous and the predetermined lags
    if isempty(opt.prior)
        priorType = '';
    else
        priorType = opt.prior.type;
    end
    if strcmpi(opt.estim_method,'ml') || any(strcmpi(priorType,nb_var.mfPriors()))
        nExo     = length(exo);
        predBeta = beta(:,nExo+1:end,:);
        beta     = beta(:,1:nExo,:);
    else
        pred     = nb_cellstrlag(dep,maxLag,'varFast');
        ind      = ~ismember(exo,pred);
        exo      = exo(ind); % Remove lagged dependent from rhs variables in estimation
        predBeta = beta(:,~ind,:);
        beta     = beta(:,ind,:);
    end

    % Get the equation y = A*y_1 + B*x + C*e
    % for the dynamic system
    %------------------------------------------
    nPeriods = size(beta,3);
    nLags    = size(predBeta,2)/length(dep);
    numDep   = length(dep);
    numRows  = (nLags - 1)*numDep;
    I        = eye(numRows);
    I        = I(:,:,ones(1,nPeriods));
    A        = [predBeta;I,zeros(numRows,numDep,nPeriods)];
    B        = [beta;zeros(numRows,length(exo),nPeriods)];
    
    % Identification of the VAR
    res     = strcat('E_',dep);
    counter = [];
    if nb_isempty(ident)
        C   = [eye(numDep);zeros(numRows,numDep)];
        C   = C(:,:,ones(1,nPeriods));
        vcv = results.sigma;
    else

        switch lower(ident.type)

            case 'cholesky'

                order    = ident.ordering;
                [~,indO] = ismember(order,dep);
                [~,indI] = ismember(dep,order);
                if any(indO == 0)
                    error([mfilename ':: Identification failed. The following variables are not part of the model; ' toString(order(ind==0))])
                end
                C = zeros(numRows + numDep,numDep,nPeriods);
                for ii = 1:nPeriods
                    sigma     = results.sigma(:,:,ii);
                    sigma     = sigma(indO,indO);
                    CT        = chol(sigma,'lower');
                    C(:,:,ii) = [CT(indI,indI);zeros(numRows,numDep)];
                end

            case 'combination'

                counter = nan(1,nPeriods);
                C       = zeros(numRows + numDep,numDep,nPeriods,ident.draws);
                
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
    tempSol.endo           = [dep,nb_cellstrlag(dep,nLags-1,'varFast')];
    tempSol.exo            = exo;
    tempSol.obs            = dep;
    tempSol.res            = res;
    tempSol.vcv            = vcv;
    tempSol.identification = ident;
    tempSol.counter        = counter;
    if isfield(opt,'class')
        tempSol.class = opt.class;
    else
        tempSol.class = 'nb_var';
    end
    tempSol.type = 'nb';

end
