function tempSol = solveRecursive(results,opt,ident)
% Syntax:
%
% tempSol = nb_mfvar.solveRecursive(results,opt,ident)
%
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    if nargin < 3
        ident = [];
    end

    % Get model settings
    dep = opt.dependent;
    if isfield(opt,'block_exogenous')
        dep = [dep,opt.block_exogenous];
    end
    obs = dep;
    dep = dep(~opt.indObservedOnly);
    exo = opt.exogenous;
    if opt.time_trend
        exo = ['Time-trend',exo]; %#ok<*AGROW>
    end
    if opt.constant
        exo = ['Constant',exo];
    end
    nDep = length(dep);
    nExo = length(exo);
    
    % Get measurment equation
    H       = nb_mlEstimator.getMeasurmentEqMFVAR(opt);
    nStates = size(H,2)/nDep;
    
    % Get the equation y = A*y_1 + B*x + C*e
    % for the dynamic system
    %------------------------------------------
    
    % Seperate the coefficients of the 
    % exogenous and the predetermined lags
    beta     = permute(results.beta,[2,1,3]);
    nPeriods = size(beta,3);
    predBeta = beta(:,nExo+1:end,:);
    beta     = beta(:,1:nExo,:);
    nLags    = size(predBeta,2)/length(dep);
    nExtra   = nStates - nLags; 
    
    % The final solution
    numRows  = (nStates - 1)*nDep;
    I        = eye(numRows);
    I        = I(:,:,ones(1,nPeriods));
    predBeta = [predBeta,zeros(nDep,nExtra*nDep,nPeriods)];
    A        = [predBeta;I,zeros(numRows,nDep,nPeriods)];
    B        = [beta;zeros(numRows,length(exo),nPeriods)];
    if ~nb_isempty(ident)
        if isfield(ident,'ordering')
            order     = ident.ordering;
            [~,indO]  = ismember(order,dep);
            [~,indI]  = ismember(dep,order);
        end
    end

    % Identification of the VAR
    res     = strcat('E_',dep);
    counter = [];
    if nb_isempty(ident)
        C   = [eye(nDep);zeros(numRows,nDep)];
        C   = C(:,:,ones(1,nPeriods));
        vcv = results.sigma;
    else

        switch lower(ident.type)

            case 'cholesky'

                C = zeros(numRTot,nDep,nPeriods);
                for ii = 1:nPeriods
                    sigma     = results.sigma(:,:,ii);
                    sigma     = sigma(indO,indO);
                    CT        = chol(sigma,'lower');
                    C(:,:,ii) = [CT(indI,indI);zeros(numRows,nDep)];
                end

            case 'combination'

                counter = nan(1,nPeriods);
                C       = zeros(numRTot,nDep,nPeriods,ident.draws);
                
                % Create waiting bar window
                h      = nb_waitbar([],'Identification',nPeriods,true);
                h.text = 'Starting...'; 
                
                for ii = 1:nPeriods
                    
                    S           = nb_var.ABidentification(ident,A(:,:,ii),results.sigma(:,:,ii),ident.maxDraws,ident.draws);
                    C(:,:,ii,:) = [S.W;zeros(numRows,nDep,1,ident.draws)];
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

    % Get measurment equation
    tempSol.H = nb_mlEstimator.getMeasurmentEqMFVAR(opt);
    tempSol.H = tempSol.H(:,:,ones(1,nPeriods));
    
    % Get the ordering
    auxDep                 = strcat('AUX_',dep);
    tempSol.endo           = [auxDep,nb_cellstrlag(auxDep,nStates-1,'varFast')];
    tempSol.exo            = exo;
    tempSol.obs            = obs;
    tempSol.res            = res;
    tempSol.vcv            = vcv;
    tempSol.identification = ident;
    tempSol.counter        = counter;
    if isfield(opt,'class')
        tempSol.class = opt.class;
    else
        tempSol.class = 'nb_mfvar';
    end
    tempSol.type = 'nb';

end
