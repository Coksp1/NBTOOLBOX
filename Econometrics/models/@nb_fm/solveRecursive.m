function tempSol = solveRecursive(results,opt)
% Syntax:
%
% tempSol = nb_fm.solveRecursive(results,opt)
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    nLags  = opt.nLags;

    % Estimation results
    beta     = permute(results.beta,[2,1,3]);
    nPeriods = size(beta,3);

    % Get the truly exogenous variables of the model by removing the 
    % predetermined lags from the exogenous variables. The lagged factors
    % are not included here!
    time_trend = opt.time_trend;
    constant   = opt.constant;
    exo        = opt.exogenous;
    depAll     = opt.dependent;
    endo       = depAll;
    if time_trend
        exo = ['Time-trend',exo]; %#ok<*AGROW>
    end
    if constant
        exo = ['Constant',exo];
    end
    nExo = length(exo);
    
    % Provide solution
    factors = opt.factors;
    allRHS  = nb_cellstrlag(factors,nLags,'varFast');
    allRHS  = [factors,allRHS];
    
    % Look for lags of depedent variables
    numDep = length(depAll);
    pred   = cell(1,numDep);
    for kk = 1:length(depAll)
        pred{kk} = regexp(exo,[depAll{kk},'_lag[0-9]*'],'match');
    end
    pred = nb_nestedCell2Cell(pred);
    if isempty(pred)
        A       = zeros(1,1,nPeriods);
        numRows = 0;
    else
        
        % Remove the predetermined lags from the
        % exogenous variables
        ind  = ~ismember(exo,pred);
        exo  = exo(ind);
        nExo = length(exo);

        % Seperate the coefficients of the 
        % exogenous and the predetermined lags
        ind      = [ind,true(1,length(allRHS))];
        predBeta = beta(:,~ind,:);
        beta     = beta(:,ind,:);

        % Find the max lag length
        maxLag = regexp(pred,'[0-9]*','match');
        maxLag = nb_nestedCell2Cell(maxLag);
        maxLag = str2num(char(maxLag')); %#ok<ST2NM>
        maxLag = max(maxLag);

        % Find all possible lags and the locations
        % of the actual
        posLags     = nb_cellstrlag(depAll,maxLag,'varFast');
        [~,indPred] = ismember(posLags,pred); 
        endo        = [endo,posLags(1:(maxLag - 1)*numDep)];

        % Get the matrix on the lags
        numRows                    = (maxLag - 1)*numDep;
        predBetaFirst              = zeros(numDep,length(posLags),nPeriods);
        predBetaFirst(:,indPred,:) = predBeta;
        A                          = [predBetaFirst;repmat(eye(numRows),[1,1,nPeriods]),zeros(numRows,numDep,nPeriods)];
        
    end
    
    % Get the equation y_h = A_h*y_h_1 + B_h*[x,F] + C_h*e
    %-----------------------------------------------------

    % Get the coefficients on the right hand side factors
    factRHS  = opt.factorsRHS;
    nFactRHS = length(factRHS);
    B2       = beta(:,end-nFactRHS+1:end,:);

    % Then we get the coefficient on the exogenous variables
    B = beta(:,1:nExo,:);
    B = [B,B2];
    if ~isempty(pred)
        B = [B;zeros(numRows,size(B,2),nPeriods)];
    end

    % The final solution
    tempSol   = struct();
    tempSol.A = A;
    tempSol.B = B;
    numDep    = length(depAll);
    I         = eye(numDep);
    tempSol.C = [I(:,:,ones(1,nPeriods));zeros(numRows,numDep,nPeriods)];
    
    % Get the covariance matrix
    vcv = results.sigma;
    
    % Get the ordering
    tempSol.endo       = endo;
    tempSol.factorsRHS = allRHS;
    tempSol.exo        = [exo,factors];
    tempSol.res        = strcat('E_',depAll);
    tempSol.vcv        = vcv;
    tempSol.class      = 'nb_fm';
    tempSol.type       = 'nb';
    
    % Now we need to solve the observation eq part as well, I add the
    % dependent variables to make it generic to favar models
    tempSol.observables = opt.observables;
    tempSol.factors     = factors;
    tempSol.F           = permute(results.lambda(1,:,:),[2,1,3]);
    tempSol.G           = permute(results.lambda(2:end,:,:),[2,1,3]);
    
    % Assume a diagonal variance covariance matrix of the observation eq
    % (This is ok, as each eq is estimated by itself)
    if isfield(results,'R')
        R = results.R;
        for ii = 1:nPeriods
            R(:,:,ii) = diag(diag(R(:,:,ii)));
        end
        tempSol.R = R;
    end
    
end
