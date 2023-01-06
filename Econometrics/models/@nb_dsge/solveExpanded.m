function tempSol = solveExpanded(model,results,opt,numAntSteps,shockProperties)
% Syntax:
%
% tempSol = nb_dsge.solveExpanded(model,results,opt,numAntSteps,...
%                       shockProperties)
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if ~isempty(opt.riseObject) % Dealing with RISE
        tempSol = solveRISEExpanded(results,opt,numAntSteps,shockProperties);
    else % Dealing with Dynare
        try
            tempSol = dsge.solveDynareExpanded(model,results,opt,numAntSteps,shockProperties);
        catch
            error([mfilename ':: This version of NB toolbox cannot find the state space ',...
                             'representation of models parsed and solved with Dynare.'])
        end
    end
      
    % Get the ordering
    tempSol.class  = 'nb_dsge';
    tempSol.method = 'expanded';
    
end

%==========================================================================
function tempSol = solveRISEExpanded(results,opt,numAntSteps,shockProperties)

    tempSol = struct;
    model   = opt.riseObject;
    dep     = model.endogenous.name;
    exo     = {};
    res     = model.exogenous.name;
    obs     = model.observables.name;

    % Check if new calibration is assigned
    model   = opt.riseObject;
    isInUse = model.parameters.is_in_use;
    check   = any(model.parameter_values(isInUse) ~= results.beta(isInUse));
    if check
        model = nb_dsge.updateParams(model,results);
    end

    % Predefine inputs to RISE
    horizon      = cell(length(res),2);
    horizon(:,1) = res;
    param        = struct();

    % Time to set each shock to its standard
    ShockNames = {shockProperties.Name};
    for j = 1:numel(ShockNames)

        sj    = ShockNames{j};
        sj_id = find(strcmp(sj, res),1);
        if isempty(sj_id)
            error([mfilename,':: shock ',sj,' is undeclared'])
        end

        % Horizon
        hh = shockProperties(j).Horizon;
        if isnan(hh)
            hh = numAntSteps;
        elseif hh > numAntSteps
            error([mfilename,':: Maximum horizon for shock ',sj,' (',int2str(hh),') exceeds the maximum anticipation horizon (',int2str(numAntSteps),')']) 
        end
        horizon{sj_id,2} = hh - 1;

        % standard deviation
        if isfield(shockProperties(j),'StandardDeviation')
            if ~isnan(shockProperties(j).StandardDeviation)
                sname         = ['std_' sj];
                param.(sname) = shockProperties(j).StandardDeviation;
            end
        end

    end

    % Call RISE to get updated forward expansion due to turned
    % off/on shocks and expected shock horizon
    if ~nb_isempty(param)
        model = set(model,'parameters',param);
    end
    if isempty(opt.solve_initialization)
        opt.solve_initialization = 'zeros';
    end
    model = set(model,'solve_shock_horizon',horizon);
    model = solve(model,...
        'fix_point_TolFun',     opt.fix_point_TolFun,...
        'fix_point_verbose',    opt.fix_point_verbose,...
        'fix_point_maxiter',    opt.fix_point_maxiter,...
        'lc_reconvexify',       opt.lc_reconvexify,...
        'steady_state_imposed', opt.steady_state_imposed,...
        'steady_state_unique',  opt.steady_state_unique,...
        'solve_initialization', opt.solve_initialization,...
        'solve_check_stability',opt.solve_check_stability);
    [A,CE,~] = load_solution(model,'iov');

    % Here I need to reshape the CS matrix from size endo_nbr
    % x exo_nbr*horizon to endo_nbr x exo_nbr x horizon   
    numS = length(CE);
    for ii = 1:numS
        CE{ii} = reshape(CE{ii},[length(dep),length(res),numAntSteps]);
    end

    if numel(A) == 1
        tempSol.A   = A{1};
        tempSol.B   = zeros(size(A{1},1),0); % No exogenous variables!
        CE          = CE{1};
        tempSol.C   = CE(:,:,1);
        tempSol.vcv = eye(size(CE,2));
        tempSol.ss  = model.solution.ss{1};
    else  % Markov switching model
        numS = length(A);
        B    = cell(1,numS);
        vcv  = cell(1,numS);
        C    = cell(1,numS);
        for ii = 1:numS
            B{ii}   = zeros(size(A{ii},1),0);
            vcv{ii} = eye(size(CE{ii},2));
            C_temp  = CE{ii};
            C{ii}   = C_temp(:,:,1);
        end
        tempSol.A   = A;    
        tempSol.B   = B;
        tempSol.C   = C;
        tempSol.vcv = vcv;
        tempSol.ss  = model.solution.ss;

        % For endoegnous switching models this is only the steady-state
        tempSol.Q     = model.solution.transition_matrices.Q; 

        % For exogenous switching models this is the same as tempSol.Q,
        % but for endogenous switching model this is a function of the
        % other variables of the model and parameters.
        tempSol.Qfunc   = prepare_transition_routine(model); 
        tempSol.regimes = opt.riseObject.markov_chains.regime_names;

    end

    % Time to set each shocks active horizon
    for j = 1:size(horizon,1)

        hh = horizon{j,2} + 2;
        if iscell(CE)
            for ii = 1:length(CE)
                CE{ii}(:,j,hh:end) = 0;
            end
        else
            CE(:,j,hh:end) = 0;
        end
    end
    tempSol.CE = CE;

    tempSol.endo = dep;
    tempSol.exo  = exo;
    tempSol.obs  = obs;
    tempSol.res  = res;
        
end
