function [ss,pSolved,err,parser] = solveSteadyStateStatic(parser,options,pKnown,check,bgp)
% Syntax:
%
% [ss,pSolved,err,parser] = nb_dsge.solveSteadyStateStatic(parser,...
%                               options,pKnown,check,bgp)
%
% Description:
%
% Solve for the steady-state of a model with the NB Toolbox.
% 
% Input:
% 
% - parser  : See the parser property of the nb_dsge class.
%
% - options : See the estOptions property of the nb_dsge class.
%
% - pKnown  : A struct with the paramer names as fieldnames and the fields
%             stores the values.
%
% - check   : Set to true to check that all parameters has been assign a
%             value.
%
% - bgp     : The balanced growth path solution, empty if we are not 
%             dealing with a non-stationary model, otherwise a struct
%             with fields 'rates' and 'variables'.
%
% Output:
% 
% - ss      : A nEndo - nAux x 1 double with the steady-state of the 
%             model.
%
% - pSolved : A struct with the parameters solved for in the steady-state.
%             The names of the parameters as fieldnames and the fields 
%             stores the values.
%
% - err     : If you ask for this output the error message will be 
%             returned instead of thrown in this function.
%
% See also:
% nb_dsge.solveSteadyState
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 5
        bgp = [];
    end

    err     = '';
    pSolved = struct();
    
    % Default steady-state is just zeros
    if ~options.steady_state_solve && isempty(options.steady_state_file) && nb_isempty(options.steady_state_init)
        ss = options.steady_state_default(length(parser.endogenous),1);
        if check 
            pVals   = cell2mat(struct2cell(pKnown));
            isInUse = parser.parametersInUse;
            test    = isnan(pVals(isInUse));
            if any(test)
                param = fieldnames(pKnown);
                param = param(isInUse);
                error([mfilename ':: The following parameters have not been assign a value; ' toString(param(test))])
            end

        end
        return
    end

    if ~isempty(options.steady_state_file)
        
        if ischar(options.steady_state_file)
            options.steady_state_file = str2func(options.steady_state_file);
        end
            
        % Use steady-state file to either solve for the steady-state or 
        % provide initial conditions
        if isfield(options,'steady_state_obs')
            % Model is solved with stochastic trend, and the current value
            % is stored in the field steady_state_obs
            [ss,pSolved] = options.steady_state_file(parser,pKnown,options.steady_state_obs);
        else
            [ss,pSolved] = options.steady_state_file(parser,pKnown);
        end
        
        % If some of the steady-state values are provided in the 
        % steady_state_fixed we use them here
        if ~nb_isempty(options.steady_state_fixed)
            fixed  = fieldnames(options.steady_state_fixed);
            ssFile = fieldnames(ss);
            test   = ismember(fixed,ssFile);
            if any(test)
                warning('solveSteadyState:ssFileBeforeFixed',[mfilename ':: The steady_state_fixed options gave steady-state ',...
                        'values already provided by the steady_state_file. Proceed with using those from the steady_state_file ',...
                        'for the following variables; ' toString(fixed(test)) ]) 
            end
            ss = nb_structcat(ss,options.steady_state_fixed,'first'); 
        end
        
        if ~isempty(bgp)
            
            % Add the steady-state growth rates in the variables that are 
            % trending
            gVars   = parser.growthVariables;
            bgpVars = strcat(nb_dsge.growthPrefix,bgp.variables);
            rates   = bgp.rates;
            for ii = 1:length(gVars)
                if ~isfield(ss,gVars{ii})
                    ind            = strcmp(gVars{ii},bgpVars);
                    ss.(gVars{ii}) = rates(ind);
                end
            end
            
        end
        
        % Update the struct of parameter values
        p = nb_structcat(pKnown,pSolved,'last'); 
        
    else % Get initial values
        ss = options.steady_state_init;
        p  = pKnown;
    end
    
    % Convert struct storing the parameters to double
    pVals = cell2mat(struct2cell(p));
    
    % Check that the parameters have values
    if check 
        
        isInUse = parser.parametersInUse;
        test    = isnan(pVals(isInUse));
        if any(test)
            param = fieldnames(p);
            param = param(isInUse);
            error([mfilename ':: The following parameters have not been assign a value; ' toString(param(test))])
        end
        
    end
    
    % Change parameters and endogneous if the user has interchanged the
    % two
    if options.steady_state_solve 
        
        ssInit = nb_dsge.ssStruct2ssDouble(parser,ss,options.steady_state_default);
        if ~nb_isempty(options.steady_state_change)
            
            % Change the parameters and endogenous
            indParam                 = options.steady_state_change.indParam;
            indEndo                  = options.steady_state_change.indEndo;
            pVals                    = [pVals(~indParam);ssInit(indEndo)];
            parser.parametersChanged = [parser.parameters(~indParam),parser.endogenous(indEndo)];
            ssInit                   = [ssInit(~indEndo);pVals(indParam)];
            parser.endogenousChanged = [parser.endogenous(~indEndo),parser.parameters(indParam)];
            tempIsAuxiliary          = parser.isAuxiliary;
            parser.isAuxiliary       = [parser.isAuxiliary(~indEndo);false(sum(indParam),1)];
            parser.createStatic      = true;
            
        end
        
        if ~isempty(parser.parametersStatic)
            
            % Add initial condition for the parameters that are solved for
            % in the steady-state using the parameter(static) block
            indParam = ismember(parser.parameters,parser.parametersStatic);
            ssInit   = [ssInit;pVals(indParam)];
            pVals    = pVals(~indParam);
            
        end
        
        if parser.createStatic
            % Create the static function
            if isfield(parser,'stationaryEquations')
                eqs = parser.stationaryEquations;
                eqs = [eqs;parser.growthEquations];
            else
                eqs = parser.equations;
            end 
            [~,parser.staticFunction] = nb_dsge.eqs2funcSub(parser,eqs,1);
            parser.createStatic       = false;
        end
        
    end
    
    % Solve for the steady-state numerically
    if options.steady_state_solve
        
        % Solve the steady-state model numerically
        if nargout < 3
            [ss,err] = solveSteadyStateNumerically(parser,options,ssInit,pVals);
            if ~isempty(err)
                error(err);
            end
        else
            [ss,err] = solveSteadyStateNumerically(parser,options,ssInit,pVals);
            if ~isempty(err)
                return
            end
        end
        
        % Interchange steady-state of variables and parameter calibration
        if ~nb_isempty(options.steady_state_change)
            
            % Combine the steady-state of the endogenous variables
            indEndo      = options.steady_state_change.indEndo;
            nChanged     = length(options.steady_state_change.parameters);
            pInSS        = ss(end-nChanged+1:end);
            ssInParam    = pVals(end-nChanged+1:end);
            ss(~indEndo) = ss(1:end-nChanged);
            ss(indEndo)  = ssInParam;
            
            % Create a struct with the parameters solved for in the
            % steady-state calculations.
            pSolved = cell2struct(num2cell(pInSS),options.steady_state_change.parameters);
            
            % Delete some temporary fields
            parser             = rmfield(parser,{'endogenousChanged','parametersChanged'});
            parser.ssAuxiliary = tempIsAuxiliary;
            
        end
        
        % Get the values of the parameters that are declared to be solved
        % for
        if ~isempty(parser.parametersStatic)
              
            % Separate the endogenous and the parameters
            nChanged = length(parser.parametersStatic);
            pInSS    = ss(end-nChanged+1:end);
            ss       = ss(1:end-nChanged);
            
            % Create a struct with the parameters solved for in the
            % steady-state calculations.
            pSolved = cell2struct(num2cell(pInSS),parser.parametersStatic);
            
        end
        
    end

    % Assign the steady-state and fill in the steady-state values for the
    % auxiliary variables
    ss = nb_dsge.assignSteadyState(parser,ss);
    
end

%==========================================================================
function [ss,err] = solveSteadyStateNumerically(parser,options,ssInit,pVals)

    ss        = ssInit;
    err       = '';
    ssInitAll = ssInit;

    % Get the problem to solve, i.e a function handle with the static
    % equations
    fHandle = parser.staticFunction;
    
    % Get the values of the exogenous variables in steady-state
    ssExo       = nb_dsge.getSteadyStateExo(parser,options);
    pAndExoVals = [pVals;ssExo];
    
    % Get the parameter vector to solve for in the end when doing homotopy
    if options.homotopyAlgorithm > 0 && ~isempty(options.homotopySetup)
        
        start  = [pVals;zeros(size(ssExo))];
        finish = pAndExoVals;
        hNames = options.homotopySetup(:,1);
        if isfield(parser,'parametersChanged')
            parAndVar = [parser.parametersChanged,parser.exogenous];
        else
            parAndVar = [parser.parameters,parser.exogenous];
        end
        
        [ind,loc] = ismember(hNames,parAndVar);
        if any(~ind)
            error([mfilename ':: The following parameters/variables given to the ''homotopySetup'' option are not part of ',...
                             'the model; ' toString(hNames(~ind))])
        end
        
        for ii = 1:size(options.homotopySetup,1)
            finish(loc(ii)) = options.homotopySetup{ii,2};
        end
        
    end
    
    % Any variables beeing fixed?
    if ~nb_isempty(options.steady_state_fixed) && ~options.steady_state_block
        [fHandle,ssInit,ssFixed,indFixed] = fixingVariablesAndReturnProblem(parser,options.steady_state_fixed,fHandle,ssInit);
        if strcmpi(options.solver,'csolve')
            error([mfilename ':: csolve does not handle non-square systems.'])
        end
    end
    
    % Test initial point
    test = ~isfinite(fHandle(ssInit,pAndExoVals,ssInitAll));
    if any(test)
        nanEqs = parser.equations(test);
        nanEqs = strcat(nanEqs,'\n');
        nanEqs = horzcat(nanEqs{:});
        err    = [mfilename ':: Solving the steady-state numerically:: The ',...
                  'following equations return nan at the initial point.\n\n' nanEqs];
        return
    end
    
    % Find the way to solve it and proceed
    solveFunc = options.solver;
    if ischar(solveFunc)
        solveFuncStr = solveFunc;
    else
        solveFuncStr = func2str(solveFunc);
    end
    if ~isfield(options,'steady_state_optimset')
        % Did not separate between estimation options and
        % steady-state solving options before...
        options.steady_state_optimset = options.optimset;
    end
    opt        = nb_getDefaultOptimset(options.steady_state_optimset,solveFuncStr);
    opt.silent = options.silent; % Sets if the homotopy steps should be silent or not.

    if options.steady_state_block
        
        if ~nb_isempty(options.steady_state_fixed)
            fixed = ismember(parser.endogenous(~parser.isAuxiliary),fieldnames(options.steady_state_fixed))';
        else
            fixed = false(length(parser.endogenous(~parser.isAuxiliary)),1);
        end
        endo = parser.endogenous(~parser.isAuxiliary);
        if ~isempty(parser.parametersStatic)
            fixed = [fixed;false(length(parser.parametersStatic),1)];
            endo  = [endo,parser.parametersStatic];
        end
        blocks = nb_blockDecompose(fHandle,ssInit,pAndExoVals,options.blockTol,fixed,ssInitAll);
        
        % Print decomp
        endoMain = endo(blocks.mVarsInd);  
        if sum(blocks.main) < length(endoMain)
            if ~options.silent
                displayBlockDecomposition(parser,blocks,endoMain);
            end
            if options.silent 
                extra = ' (Set ''silent'' option to false to display a list of suggestions).';
            else
                extra = '';
            end
            err = [mfilename ':: You need to fix the steady-state value for at least ' int2str(length(endoMain) - sum(blocks.main)) ...
                  ' of the variables listed above.' extra];
            return
        end
        
        % Update the values of the fixed variables
        ssInit = fixingVariables(parser,options.steady_state_fixed,ssInit);
        
        % Run blocks
        blockT  = {'prologue','main','epilogue'};
        bInd    = {'pVarsInd','mVarsInd','eVarsInd'};
        ss      = ssInit;
        nBlocks = length(blockT);
        for ii = 1:nBlocks
            
            % Get sub problem to solve
            [fHandleSub,ssInit,ssFSub] = getSubProblem(~blocks.(bInd{ii}),fHandle,ss,blocks.(blockT{ii}));
            
            % Test initial values
            test = ~isfinite(fHandleSub(ssInit,pAndExoVals,ssInitAll));
            if any(test)
                if ~options.silent
                    displayBlockDecomposition(parser,blocks,endoMain);
                end
                locBlock = find(blocks.(blockT{ii}));
                nanEqs   = parser.equations(locBlock(test));
                disp(nanEqs);
                err = [mfilename ':: Solving the steady-state numerically:: The equations ',...
                       'listed above return nan at the initial point.'];
            end
            
            % Call the solver
            if ii == 2 % Only homotopy for the main equations!
                
                if options.homotopyAlgorithm > 0
                    [ssSub,~,exitflag,homotopyErr] = nb_homotopy(options.homotopyAlgorithm,options.homotopySteps,...
                        start,finish,hNames,solveFunc,fHandleSub,ssInit,opt,ssInitAll);
                else
                    [ssSub,~,exitflag] = nb_solver(solveFunc,fHandleSub,ssInit,opt,pAndExoVals,ssInitAll);
                    homotopyErr        = '';
                end
                
            else
                [ssSub,~,exitflag] = nb_solver(solveFunc,fHandleSub,ssInit,opt,pAndExoVals,ssInitAll);
                homotopyErr        = '';
            end
            
            if exitflag < 1
                err = nb_interpretExitFlag(exitflag,solveFuncStr,[' The steady-state of the ' blockT{ii} ' of the model could not be solved for.'],homotopyErr);
                if ~options.silent
                    displayBlockDecomposition(parser,blocks,endoMain);
                    %disp(err)
                end
            else
                if ~options.silent
                    disp(['The steady-state of the ' blockT{ii} ' of the model is solved for.'])
                end
            end
            
            % Update the full vector 
            ss = assignPartOfSS(real(ssSub),ssFSub,~blocks.(bInd{ii}));
            
        end
            
    else % Not block
        
        if options.homotopyAlgorithm > 0
            [ss,~,exitflag,homotopyErr] = nb_homotopy(options.homotopyAlgorithm,options.homotopySteps,...
                start,finish,hNames,solveFunc,fHandle,ssInit,opt,ssInitAll);
        else
            [ss,~,exitflag] = nb_solver(solveFunc,fHandle,ssInit,opt,pAndExoVals,ssInitAll);
            homotopyErr     = '';
        end
        if exitflag < 1
            err = nb_interpretExitFlag(exitflag,solveFuncStr,' The steady-state of the model could not be solved for.',homotopyErr);
        end
        
    end

    if ~nb_isempty(options.steady_state_fixed) && ~options.steady_state_block
        ss = assignPartOfSS(real(ss),ssFixed,indFixed);
    end
    ss = real(ss);
    
end

%==========================================================================
function [ssAll,ssFixed,indFixed] = fixingVariables(parser,steady_state_fixed,ssInit)

    % Get the fixed variables
    steady_state_fixed = orderfields(steady_state_fixed);
    fixed              = fieldnames(steady_state_fixed);
    indFixed           = ismember(parser.endogenous(~parser.isAuxiliary),fixed);
    ssFixed            = cell2mat(struct2cell(steady_state_fixed));
    ssFixed            = flip(ssFixed,1);
    
    % If nan fill in from initial values (may come from a stead_state_file)
    useInit          = isnan(ssFixed);
    ssFInit          = ssInit(indFixed);
    ssFixed(useInit) = ssFInit(useInit);
    
    % Seperate out only the variables to solve for
    ssAll           = ssInit;
    ssAll(indFixed) = ssFixed;
    
end

%==========================================================================
function [fHandle,ssInit,ssFixed,indFixed] = fixingVariablesAndReturnProblem(parser,steady_state_fixed,fHandle,ssInit)

    % Fixing the variables
    [ssAll,ssFixed,indFixed] = fixingVariables(parser,steady_state_fixed,ssInit);
    ssInit                   = ssInit(~indFixed);
    
    % Create a function wrapper to be able to fix some of the variables
    fHandle = @(vars,pars,ss_init_vars)fixedFunc(vars,pars,ss_init_vars,fHandle,ssAll,~indFixed);
    
end

%==========================================================================
function [fHandle,ssInit,ssFixed] = getSubProblem(indFixed,fHandle,ssInit,indEq)

    % Get steady-state values og fixed variables
    ssFixed = ssInit(indFixed);
    
    % Seperate out only the variables to solve for
    ssAll  = ssInit;
    ssInit = ssInit(~indFixed);
    
    % Get equations of the sub-system only
    fHandleStr      = func2str(fHandle);
    fHandleStr      = split(fHandleStr,';');
    fHandleStr{1}   = strrep(fHandleStr{1},'@(vars,pars,ss_init_vars)[','');
    fHandleStr{end} = strrep(fHandleStr{end},']','');
    fHandleStr      = fHandleStr(indEq);
    fHandleStr      = strcat(fHandleStr,';');
    fHandleStr{end} = strrep(fHandleStr{end},';','');
    fHandleStr      = strcat('@(vars,pars,ss_init_vars)[',fHandleStr{:},']');
    fHandle         = str2func(fHandleStr);
    
    % Create a function wrapper to be able to fix some of the variables
    fHandle = @(vars,pars,ss_init_vars)fixedFunc(vars,pars,ss_init_vars,fHandle,ssAll,~indFixed);
    
end

%==========================================================================
function fVal = fixedFunc(vars,pars,ss_init_vars,fHandle,ssAll,indNotFixed)

    ssAll(indNotFixed) = vars;
    fVal               = fHandle(ssAll,pars,ss_init_vars);

end

%==========================================================================
function ss = assignPartOfSS(ssNotFixed,ssFixed,indFixed)

    ss            = nan(length(indFixed),1);
    ss(~indFixed) = ssNotFixed;
    ss(indFixed)  = ssFixed;

end

%==========================================================================
function displayBlockDecomposition(parser,blocks,endoMain)

    % Get static equations
    eqs = nb_dsge.getStaticEquations(parser.equations,parser);
    
    % Equation not used
    if ~isempty(blocks.emptyEquations)   
        disp(' ')
        disp(['The following ' int2str(sum(blocks.emptyEquations)) ' equations provide no information in solving the steady-state.'])
        disp('You may want provide the steady-state equation that represent it')
        disp('using the [static] expr; syntax.')
        disp('-------------------------------------------------------------------')
        disp(' ')
        disp(char(eqs(blocks.emptyEquations)))
    end

    % Prologue
    if any(blocks.prologue) 
        disp(' ')
        disp(['The prologue consists of the following ' int2str(sum(blocks.prologue)) ' equations'])
        disp(['in ' int2str(sum(blocks.pVarsInd)) ' variables.'])
        disp('-------------------------------------------------------------------')
        disp(' ')
        for ii = 1:blocks.iterations
            ind = blocks.prologue;
            ind(blocks.pIteration ~= ii) = false;
            disp(char(eqs(ind)))
        end
    end

    % Epilogue
    if any(blocks.epilogue) 
        disp(' ')
        disp(['The epilogue consists of the following ' int2str(sum(blocks.epilogue)) ' equations'])
        disp(['in ' int2str(sum(blocks.eVarsInd)) ' variables.'])
        disp('-------------------------------------------------------------------')
        disp(' ')
        for ii = 1:blocks.iterations
            ind = blocks.epilogue;
            ind(blocks.eIteration ~= ii) = false;
            disp(char(eqs(ind)))
        end
    end

    % The problem to solve numerically
    disp(' ')
    disp(['The problem to solve is then the following ' int2str(sum(blocks.main)) ' equations'])
    disp(['in ' int2str(length(endoMain)) ' variables.'])
    disp('-------------------------------------------------------------------')
    disp(' ') 
    disp(char(eqs(blocks.main)))

    % The variables to solve for
    disp(' ')
    disp('The variables to solve for')
    disp('-------------------------------------------------------------------')
    disp(char(sort(endoMain)'))
    disp(' ')

end
