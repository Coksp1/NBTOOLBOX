function tempSol = solveOLSEq(results,opt)
% Syntax:
%
% tempSol = nb_singleEq.solveOLSEq(results,opt)
%
% Written by Kenneth Sæterhagen Paulsen 

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Estimation results
    beta = permute(results.beta,[2,1,3,4]); % numDep x nExo x nPeriods x nQuantiles

    % Provide solution
    dep  = opt.dependent;
    endo = dep;
    exo  = opt.exogenous;
    if opt.time_trend
        exo = ['Time-trend',exo]; %#ok<*AGROW>
    end
    if opt.constant
        exo = ['Constant',exo];
    end
    numDep = length(dep);
    pred   = cell(1,numDep);
    for kk = 1:length(dep)
        pred{kk} = regexp(exo,[dep{kk},'_lag[0-9]*'],'match');
    end
    pred = nb_nestedCell2Cell(pred);

    if isempty(pred)
        
        leaded   = ~any(cellfun(@isempty,regexp(dep,'_lead[0-9]*$','match')));
        depClean = unique(regexprep(dep,'_lead[0-9]*$',''));
        if leaded && length(depClean) == 1
            tempSol = nb_singleEq.solveStepAhead(results,opt);
            return
        end

        % Get the equation y = B*x + C*e
        %------------------------------------------
        nPeriods   = size(beta,3);
        nQuantiles = size(beta,4);
        tempSol.B  = beta;
        tempSol.A  = zeros(numDep,numDep,nPeriods,nQuantiles);
        tempSol.C  = repmat(eye(size(beta,1)),[1,1,nPeriods,nQuantiles]);
           
    else

        % Get the equation y = A*y_1 + B*x + C*e
        % for the dynamic system
        %------------------------------------------
        nPeriods   = size(beta,3);
        nQuantiles = size(beta,4);
        
        % Remove the predetermined lags from the
        % exogenous variables
        ind = ~ismember(exo,pred);
        exo = exo(ind);

        % Seperate the coefficients of the 
        % exogenous and the predetermined lags
        predBeta = beta(:,~ind,:,:);
        beta     = beta(:,ind,:,:);

        % Find the max lag length
        maxLag = regexp(pred,'[0-9]*$','match');
        maxLag = nb_nestedCell2Cell(maxLag);
        maxLag = str2num(char(maxLag')); %#ok<ST2NM>
        maxLag = max(maxLag);

        % Find all possible lags and the locations
        % of the actual
        posLags     = nb_cellstrlag(dep,maxLag,'varFast');
        [~,indPred] = ismember(pred,posLags); 
        endo        = [endo,posLags(1:(maxLag - 1)*numDep)];

        predBetaFirst                = zeros(numDep,length(posLags),nPeriods,nQuantiles);
        predBetaFirst(:,indPred,:,:) = predBeta;

        % The final solution
        numRows   = (maxLag - 1)*numDep;
        tempSol   = struct();
        tempSol.B = [beta;zeros(numRows,length(exo),nPeriods,nQuantiles)];
        tempSol.A = [predBetaFirst;repmat(eye(numRows),[1,1,nPeriods,nQuantiles]),zeros(numRows,numDep,nPeriods,nQuantiles)];
        tempSol.C = [repmat(eye(numDep),[1,1,nPeriods,nQuantiles]);zeros(numRows,numDep,nPeriods,nQuantiles)];

    end

    % Get the ordering
    tempSol.endo = endo;
    tempSol.exo  = exo;
    tempSol.res  = strcat('E_',opt.dependent);
    tempSol.vcv  = results.sigma;

end
