function tempSol = solveRecursive(~,options)
% Syntax:
%
% tempSol = nb_exprModel.solveRecursive(results,options)
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if options.minLags < 1 && ~istril(options.indCont)
        error([mfilename ':: Cannot forecast a model with contemporaneous ',...
                         'dependent variables as right hand side variable, and ',...
                         'where the system is not lower triangular. The ',...
                         'dependent variables are ' toString(options.dependentOrig) '.'])
    end
    nDep         = length(options.dependent);
    [~,locDep]   = ismember(options.dependentOrig,options.dataVariables);
    depTransFunc = cell(1,nDep);
    depLagFunc   = cell(1,nDep);
    for ii = 1:nDep
        depOne  = options.dependent{ii};
        indOpen = strfind(depOne,'(');
        if size(indOpen,2) == 1
            method = 'level';
        else
            method  = depOne(1:indOpen(1)-1);
        end
        switch method
            case 'diff'
                % diff(x(t),p) = F(Z(t))
                % x(t)         = x(t-p) + F(Z(t))
                lags = regexp(depOne,',(\d+)\)','tokens');
                if isempty(lags)
                    lags = '1';
                else
                    lags = lags{1}{1};
                end
                depTransFunc{ii} = @(x)x;
                depLagFunc{ii}   = str2func(['@(vars,t)vars(t-' lags ',' int2str(locDep(ii)) ')']);
            case 'exp'    
                % exp(x(t)) = F(Z(t))
                % x(t)      = log(0 + F(Z(t)))
                depTransFunc{ii} = @(x)log(x);
                depLagFunc{ii}   = str2func('@(vars,t)zeros(1,1)');
            case 'growth'
                % growth(x(t),p) = F(Z(t))
                % x(t)           = exp( log(x(t-p)) + F(Z(t)) )
                lags = regexp(depOne,',(\d+)\)','tokens');
                if isempty(lags)
                    lags = '1';
                else
                    lags = lags{1}{1};
                end
                depTransFunc{ii} = @(x)exp(x);
                depLagFunc{ii}   = str2func(['@(vars,t)log(vars(t-' lags ',' int2str(locDep(ii)) '))']);
            case 'log'
                % log(x(t)) = F(Z(t))
                % x(t)      = exp(0 + F(Z(t)))
                depTransFunc{ii} = @(x)exp(x);
                depLagFunc{ii}   = str2func('@(vars,t)zeros(1,1)');
            case 'level'
                depTransFunc{ii} = @(x)x;
                depLagFunc{ii}   = str2func('@(vars,t)zeros(1,1)');
            otherwise
                error([mfilename ':: Cannot forecast a model with the expression ',...
                                 'for a dependent variable equal to ' depOne '.'])
        end
                
    end
    
    % Add function handles for constant and time_trend
    exoFuncs = options.exoFuncs;
    nExo     = options.nExo;
    if options.time_trend
        timeTrendFunc = @(vars,t)t(end);
        nExo          = nExo + 1;
        for ii = 1:nDep
            exoFuncs{ii} = [{timeTrendFunc},exoFuncs{ii}];
        end
    end
    if options.constant
        constFunc = @(vars,t)ones(1,1);
        nExo      = nExo + 1;
        for ii = 1:nDep
            exoFuncs{ii} = [{constFunc},exoFuncs{ii}];
        end
    end
    
    % Create function handle that provide one step ahead forecast
    nLags              = options.nLags;
    tempSol.fcstHandle = @(Z,t,E,h,beta)nb_exprModel.solutionFunc(Z,t,E,h,beta,depTransFunc,...
                            depLagFunc,exoFuncs,nLags,nExo,locDep,nDep);
                        
    % Give other information
    tempSol.endo = options.dependentOrig;
    tempSol.res  = strcat('E_',options.dependentOrig);
    tempSol.exo  = options.exogenousOrig;
    if options.time_trend
        tempSol.exo = ['time_trend',tempSol.exo];
    end
    if options.constant
        tempSol.exo = ['constant',tempSol.exo];
    end
    tempSol.class = 'nb_exprModel';
    tempSol.type  = 'nb';
    
end
