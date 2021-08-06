function tempSol = solveTSLSEq(results,opt)
% Syntax:
%
% tempSol = nb_singleEq.solveTSLSEq(results,opt)
%
% Written by Kenneth Sæterhagen Paulsen 

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Get the main equation results
    mainEq     = results.mainEq;
    mainOpt    = opt.mainEq;
    mainBeta   = mainEq.beta;
    mainSigma  = diag(diag(mainEq.sigma));
    mainExo    = mainOpt.exogenous;
    indExo     = cellfun('isempty',strfind(mainExo,'Predicted_'));
    mainEndo   = mainExo(~indExo); % Instrumented endogenous variables
    mainEndo   = strrep(mainEndo,'Predicted_','');
    mainExo    = mainExo(indExo);
    numExo     = length(mainExo) + mainOpt.constant + mainOpt.time_trend;
    allEndo    = [mainOpt.dependent,mainEndo];
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
    A1         = [eye(numDep)                   , -mainBeta(numExo + 1:end,:)';...
                  zeros(numEndo - numDep,numDep), eye(numEndo - numDep)];

    D                      = zeros(numEndo,numAllExo);          
    [~,indMainExo]         = ismember(mainExo,allExo);
    D(1:numDep,indMainExo) = mainBeta(1:numExo,:)';

    vcv                    = zeros(numEndo,numEndo);
    vcv(1:numDep,1:numDep) = mainSigma;

    for jj = 1:numEndo - numDep

        % Get the instruments
        instrumented   = instr{jj*2 - 1};
        instruments    = instr{jj*2};
        if opt.(['firstStageEq' int2str(jj)]).time_trend
            instruments = ['Time-trend',instruments]; 
        end
        if opt.(['firstStageEq' int2str(jj)]).constant
            instruments = ['Constant',instruments]; 
        end

        % Get locations
        ind            = strcmp(instrumented,allEndo);
        [~,indInstExo] = ismember(instruments,allExo);

        % Get the instrumented equation results
        instEq    = results.(['firstStageEq' int2str(jj)]);
        instBeta  = instEq.beta;
        instSigma = instEq.sigma;

        % Assign
        D(ind,indInstExo) = instBeta';
        vcv(ind,ind)      = instSigma;

    end

    % Add the Predicted_ prefix
    ind          = ismember(allEndo,mainEndo);
    allEndo(ind) = strcat('Predicted_',allEndo(ind));

    % Get the equation y = B*x + C*e
    %----------------------------------------------
    tempSol      = struct();
    tempSol.B    = A1\D; 
    tempSol.A    = zeros(numEndo);
    tempSol.C    = A1\eye(numEndo);
    tempSol.endo = allEndo;
    tempSol.exo  = allExo;
    tempSol.res  = strcat('E_',allEndo);
    tempSol.vcv  = vcv;

end
