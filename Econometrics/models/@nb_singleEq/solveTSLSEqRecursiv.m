function tempSol = solveTSLSEqRecursiv(results,opt)
% Syntax:
%
% tempSol = nb_singleEq.solveTSLSEqRecursiv(results,opt)
%
% Written by Kenneth Sæterhagen Paulsen 

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Get the main equation results
    mainEq     = results.mainEq;
    mainOpt    = opt.mainEq;
    mainBeta   = permute(mainEq.beta,[2,1,3]);
    mainSigma  = mainEq.sigma;
    mainExo    = mainOpt.exogenous;
    numExo     = length(mainExo) + mainOpt.constant + mainOpt.time_trend;
    allEndo    = [mainOpt.dependent,mainOpt.endogenous];
    numDep     = length(mainOpt.dependent);
    numEndo    = length(allEndo);
    instr      = mainOpt.instruments;
    allExo     = unique([mainExo, nb_nestedCell2Cell(instr(2:2:end))]);
    if mainOpt.time_trend
        allExo  = ['Time-trend',allExo]; %#ok<*AGROW>
        mainExo = ['Time-trend',mainExo];
    end
    if mainOpt.constant
        allExo  = ['Constant',allExo];
        mainExo = ['Constant',mainExo]; 
    end

    numAllExo  = length(allExo);

    % Get the equation A1*y = D*xt + E*e
    %----------------------------------------------
    nPeriods   = size(mainBeta,3);
    A1         = [repmat(eye(numDep),[1,1,nPeriods])     , -mainBeta(:,numExo + 1:end,:);...
                  zeros(numEndo - numDep,numDep,nPeriods), repmat(eye(numEndo - numDep),[1,1,nPeriods])];

    D                        = zeros(numEndo,numAllExo,nPeriods);          
    [~,indMainExo]           = ismember(mainExo,allExo);
    D(1:numDep,indMainExo,:) = mainBeta(:,1:numExo,:);

    vcv                      = zeros(numEndo,numEndo,nPeriods);
    vcv(1:numDep,1:numDep,:) = mainSigma;

    firstStage = mainEq.firstStage;
    for jj = 1:numEndo - numDep

        % Get the instruments
        instrumented   = instr{jj*2 - 1};
        instruments    = instr{jj*2};
        if opt.mainEq.time_trend % If the main eq has, so has the first stage
            instruments = ['Time-trend',instruments]; 
        end
        if opt.mainEq.constant % If the main eq has, so has the first stage
            instruments = ['Constant',instruments]; 
        end

        % Get locations
        ind            = strcmp(instrumented,allEndo);
        [~,indInstExo] = ismember(instruments,allExo);

        % Get the instrumented equation results
        instBeta  = firstStage(jj).beta;
        instSigma = firstStage(jj).sigma;

        % Assign
        D(ind,indInstExo,:) = permute(instBeta,[2,1,3]);
        vcv(ind,ind,:)      = instSigma;

    end

    % Add the Predicted_ prefix
    ind          = ismember(allEndo,mainOpt.endogenous);
    allEndo(ind) = strcat('Predicted_',allEndo(ind));

    % Get the equation y = B*x + C*e
    %----------------------------------------------
    B = nan(numEndo,numAllExo,nPeriods);
    C = nan(numEndo,numEndo,nPeriods);
    E = eye(numEndo);
    for ii = 1:nPeriods
        B(:,:,ii) = A1(:,:,ii)\D(:,:,ii); 
        C(:,:,ii) = A1(:,:,ii)\E;
    end
    
    tempSol      = struct();
    tempSol.B    = B;
    tempSol.A    = zeros(numEndo,numEndo,nPeriods);
    tempSol.C    = C;
    tempSol.endo = allEndo;
    tempSol.exo  = allExo;
    tempSol.res  = strcat('E_',allEndo);
    tempSol.vcv  = vcv;

end
