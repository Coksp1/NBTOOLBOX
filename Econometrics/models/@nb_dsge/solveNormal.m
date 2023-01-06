function [tempSol,opt] = solveNormal(results,opt)
% Syntax:
%
% tempSol = nb_dsge.solveNormal(results,opt)
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    opt = nb_defaultField(opt,'parser',[]);
    if ~nb_isempty(opt.parser) % Dealing with NB Toolbox (We may want to do this smarter in the future!!!)
        
        if ~isfield(opt.parser,'object')
            error([mfilename ':: The nb_dsge object must be stored in the parser property to be able to ',...
                             'solve the model when producing density forecast.'])
        end
        object  = opt.parser.object;
        param   = opt.parser.parameters;
        object  = assignParameters(object,'param',param,'value',results.beta);
        object  = solve(object);
        tempSol = object.solution;
        
    elseif ~isempty(opt.riseObject) % Dealing with RISE
        [tempSol,opt] = solveRISENormal(results,opt);
    else % Dealing with dynare
        try
            [tempSol,opt] = dsge.solveDynareNormal(results,opt);
        catch
            error([mfilename ':: This version of NB toolbox cannot find the state space ',...
                             'representation of models parsed and solved with Dynare.'])
        end
    end
        
    tempSol.class  = 'nb_dsge';
    tempSol.method = 'normal';
    
end

%==========================================================================
function [tempSol,opt] = solveRISENormal(results,opt)

    % Check if new calibration is assigned
    tempSol = struct; 
    model   = opt.riseObject;
    isInUse = model.parameters.is_in_use;
    check   = any(any(model.parameter_values(isInUse,:) ~= results.beta(isInUse,:)));
    if check
        model = nb_dsge.updateParams(model,results);
    end

    if isempty(opt.solve_initialization)
        opt.solve_initialization = 'zeros';
    end

    % Calling RISE to solve the model
    model = solve(model,...
        'fix_point_TolFun',     opt.fix_point_TolFun,...
        'fix_point_verbose',    opt.fix_point_verbose,...
        'fix_point_maxiter',    opt.fix_point_maxiter,...
        'lc_reconvexify',       opt.lc_reconvexify,...
        'steady_state_imposed', opt.steady_state_imposed,...
        'steady_state_unique',  opt.steady_state_unique,...
        'solve_initialization', opt.solve_initialization,...
        'solve_check_stability',opt.solve_check_stability);
    [A,C] = load_solution(model,'iov');
    if numel(A) == 1
        tempSol.A   = A{1};
        tempSol.B   = zeros(size(A{1},1),0); % No exogenous variables!
        tempSol.C   = full(C{1});
        tempSol.vcv = eye(size(C{1},2));
        tempSol.ss  = model.solution.ss{1};
    else  % Markov switching model
        numS = length(A);
        B    = cell(1,numS);
        vcv  = cell(1,numS);
        for ii = 1:numS
            B{ii}   = zeros(size(A{ii},1),0);
            vcv{ii} = eye(size(C{ii},2));
        end
        tempSol.A     = A;    
        tempSol.B     = B;
        tempSol.C     = C;
        tempSol.vcv   = vcv;
        tempSol.ss    = model.solution.ss;

        % For endoegnous switching models this is only the steady-state
        tempSol.Q     = model.solution.transition_matrices.Q; 

        % For exogenous switching models this is the same as tempSol.Q,
        % but for endogenous switching model this is a function of the
        % other variables of the model and parameters.
        tempSol.Qfunc   = prepare_transition_routine(model);
        tempSol.regimes = opt.riseObject.markov_chains.regime_names;

    end

    tempSol.endo   = sort(model.endogenous.name); % We have asked for the alphabetically ordered solution
    tempSol.exo    = {};
    tempSol.obs    = sort(model.observables.name);
    tempSol.res    = model.exogenous.name;
    opt.riseObject = model;

end
