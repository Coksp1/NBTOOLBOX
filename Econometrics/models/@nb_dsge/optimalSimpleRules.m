function [obj,loss,osr_coeff,std_osr_coeff] = optimalSimpleRules(obj,simpleRules,varargin)
% Syntax:
%
% obj = optimalSimpleRules(obj,simpleRules)
% obj = optimalSimpleRules(obj,simpleRules,varargin)
% [obj,loss,osr_coeff,std_osr_coeff] = ...
%       optimalSimpleRules(obj,simpleRules,varargin)
%
% Description:
%
% Compute optimal simple rules given a loss function. The loss function
% can either be spesified in the model file or by the 
% nb_dsge.setLossFunction.
% 
% To set the discount factor of the optimizing authorities set the
% 'lc_discount' option. E.g. obj = set(obj,'lc_discount',0.99). This
% options can also be set in the model file, for more on this see DAG.pdf.
%
% Caution: The return object is solved with the optimized simple rules.
%
% Input:
% 
% - obj         : An object of class nb_dsge.
%
% - simpleRules : A char or cellstr array with the rules to maximize. 
%                 Each rule must have the instrument as its only left hand
%                 variable. E.g. 'i = lam1*pi + lam2*y' or 
%                 {'i = lam1*pi + lam2*y';'tau = lam3*pi + lam4*y'}. The
%                 lamX parameters are in this case the parameters that is
%                 optimized over.
%
% - type        : Either 'commitment' or 'discretion'. If 'discretion' 
%                 the interest rate rule can only respond to state
%                 variables! Default is 'commitment'.
%
% Optional inputs:
%
% - 'init'       : Initial values of the optimization routine. As a struct 
%                  with the fieldnames as the parameter names of the  
%                  simple rules and the fields as the initial values.
%
%                  Caution: If the parameters are declared in the model
%                           file (.nb file) you may use 
%                           nb_dsge.assignParameters before calling this 
%                           function instead, i.e. the calibration is used
%                           as the initial values.
%                  
% - 'lowerBound' : Sets the lower bound on the coefficients of the simple
%                  rules.
%
% - 'osr_type'   : Either 'commitment' or 'discretion'. If 'discretion' 
%                  the interest rate rule can only respond to state
%                  variables! Default is 'commitment'.
%
% - 'upperBound' : Sets the upper bound on the coefficients of the simple
%                  rules.
% 
% Else:
%
% - varargin : See the the set method.
% 
% Output:
% 
% - obj : An object of class nb_dsge. The model is solved with the 
%         optimized simple rule.
%
% Examples:
%
% obj = optimalSimpleRules(obj,'i = lam1*pi + lam2*y');
%
% See also:
% nb_dsge, nb_dsge.parse, nb_dsge.setLossFunction, 
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if numel(obj) > 1
        error([mfilename ':: This method only handles a scalar nb_dsge object.'])
    end

    if ~isNB(obj)
        error([mfilename ':: This method is only supported for models parsed with NB Toolbox parser.'])
    end
    
    if isBreakPoint(obj)
        error([mfilename ':: This method does not support models with break-points.'])
    end
    
    if ~isfield(obj.parser,'lossFunction')
        error([mfilename ':: The loss function must be specified. See the setLossFunction method, or include it in the model file.'])
    end
    
    % Parse optional inputs
    [lowerBound,varargin] = nb_parseOneOptional('lowerBound',[],varargin{:});
    [upperBound,varargin] = nb_parseOneOptional('upperBound',[],varargin{:});
    [init,varargin]       = nb_parseOneOptional('init',[],varargin{:});
    obj                   = set(obj,varargin{:});
    
    % Check for basic errors
    if obj.options.lc_discount > 1 || obj.options.lc_discount < 0
        error([mfilename ':: The ''lc_discount'' option must be between 0 and 1.'])
    end
    
    parser         = obj.parser;
    parser.optimal = false;
    if ~isfield(parser,'equationsParsed')
        error([mfilename ':: No model has been parsed or the number of ',...
            'equations are equal to the number of endogenous variables (so ',...
            'you cannot add another equation with the simple rule)! ',...
            'See the nb_dsge.parse method on how to parse the model file.'])
    end

    if ischar(simpleRules)
        simpleRules = cellstr(simpleRules);
    else
        if ~iscellstr(simpleRules)
            error([mfilename ':: The simpleRules input must be a cellstr or a char.'])
        else
            simpleRules = nb_rowVector(simpleRules);
        end
    end
    
    % Parse the simple rules
    tStart = tic();
    parser = nb_dsge.parseSimpleRules(parser,simpleRules);
    if size(parser.parameters,2) ~= size(obj.results.beta,1)
        % Some new parameters where added with the loss function
        obj.results.beta = [obj.results.beta;nan(size(parser.parameters,2) - size(obj.results.beta,1),1)];
    end
    
    % Assign the inital values for the simple rule coefficients  
    if ~isempty(init)
        if ~isstruct(init)
            error([mfilename ':: The ''init'' input must be a struct.'])
        end
        obj.parser = parser;
        obj        = assignParameters(obj,init);
        parser     = obj.parser;
    end

    % Initial check
    obj = checkModelEqs(obj);
    
    % Solve for the steady-state, here it is also tested for nan 
    % values of used parameters
    obj = checkSteadyState(obj);
    
    % Compute derivatives of the dynamic model, if not already calculated
    obj = derivative(obj);
    
    % Information used for optimization
    srInd       = ismember(parser.parameters,parser.simpleRulesParameters);
    srCoeffInit = obj.results.beta(srInd);
    if isempty(lowerBound)
        lb = -inf(size(srCoeffInit));
    else
        if ~isnumeric(lowerBound)
            error([mfilename ':: The ''lowerBound'' input must be numeric.'])
        end
        lowerBound = lowerBound(:);
        if size(lowerBound,1) ~= size(srCoeffInit,1)
            error([mfilename ':: The ''lowerBound'' input must be a ' int2str(size(srCoeffInit,1)) ' x 1 double, i.e. match '...
                             'the number of optimized simple rules coefficients.'])
        end
        lb = lowerBound;
    end
    if isempty(upperBound)
        ub = inf(size(srCoeffInit));
    else
        if ~isnumeric(upperBound)
            error([mfilename ':: The ''upperBound'' input must be numeric.'])
        end
        upperBound = upperBound(:);
        if size(lowerBound,1) ~= size(srCoeffInit,1)
            error([mfilename ':: The ''upperBound'' input must be a ' int2str(size(srCoeffInit,1)) ' x 1 double, i.e. match '...
                             'the number of optimized simple rules coefficients.'])
        end
        ub = upperBound;
    end
    
    if any(ub - lb < 0)
        error([mfilename ':: The ''lowerBound'' input cannot be greater than the ''upperBound'' input for any elements!'])
    end
    
    % Check for parameter uncertainty
    if any(parser.parametersIsUncertain)
        
        % Draw parameters
        draws    = obj.options.uncertain_draws;
        simParam = random(parser.parameterDistribution,draws)';
        indU     = parser.parametersIsUncertain;

        % Take derivative w.r.t to the variables for different draws
        paramSim = obj.results.beta(:,ones(1,draws));
        sol      = obj.solution(ones(1,draws),1);
        for ii = 1:draws
            paramSim(indU,ii) = simParam(:,ii);
            sol(ii)           = nb_dsge.derivativeNB(parser,sol(ii),paramSim(:,ii));
        end
        func     = @doOptimizationUncertain;
        solution = sol;
        
    else
        paramSim = obj.results.beta;
        func     = @doOptimization;
        solution = obj.solution;
    end
    
    % Optimize the coefficients of the simple rules
    if strcmpi(obj.options.osr_type,'discretion')
        [osr_coeff,loss,H,GAM,Hessian] = findDiscretionRules(obj,srCoeffInit,srInd,lb,ub,solution,paramSim,func);
    else
        [osr_coeff,loss,Hessian] = func(srCoeffInit,srInd,lb,ub,paramSim,parser,solution,obj.options);
    end
    
    % Find Hessian if not already found
    if isempty(Hessian)
        Hessian = nb_hessian(@(x)fh(x),osr_coeff);
    end

    % Get standard deviation of estimated parameters
    omega         = Hessian\eye(size(Hessian,1));
    std_osr_coeff = sqrt(diag(omega));
    if any(~isreal(std_osr_coeff))
        if obj.options.covrepair
            omega       = nb_covrepair(omega,false);
            std_osr_coeff = sqrt(diag(omega));
        else
            warning([mfilename ':: Standard error of paramters are not real, something went wrong...'])
        end
    end
    
    % Store to objects property results (as if they where estimated)
    obj.results.beta(srInd)     = osr_coeff;
    isEstimated                 = false(size(obj.results.beta,1),1);
    isEstimated(srInd)          = true;
    obj.results.isEstimated     = isEstimated;
    obj.results.estimationIndex = find(srInd);
    obj.results.sigma           = nan(0,1);
    obj.results.stdBeta         = std_osr_coeff;
    obj.results.omega           = omega;
    obj.results.loss            = loss;
    obj.results.initBeta        = srCoeffInit;
    
    % Set other results to be generic
    obj.results.includedObservations = nan;
    obj.results.elapsedTime          = toc(tStart);
    obj.estOptions.estimator         = 'nb_osr';
    obj.estOptions.parser            = parser;
    
    % Model need to be resolved
    obj.takenDerivatives  = false;
    obj.needToBeSolved    = true;
    
    % Provide the solution when dealing with optimized simple rules
    if strcmpi(obj.options.osr_type,'discretion') 
        % Discretionary solution
        obj.solution.jacobian = nb_dsge.solveSimpleRule(obj.parser,obj.solution,osr_coeff,srInd,obj.results.beta);
        [~,~,~,B]             = nb_dsge.jacobian2StructuralMatricesNB(obj.solution.jacobian,parser);
        obj.solution.A        = H;
        obj.solution.C        = -GAM\B;         
    else
        % Standard solution using Klein's algorithm
        [obj.solution.A,obj.solution.C,obj.solution.jacobian,err] = nb_dsge.solveSimpleRule(parser,obj.solution,osr_coeff,srInd,obj.results.beta);
        if ~isempty(err)
            error([mfilename ':: Model could not be solved with the inital values provided:: ' err])
        end
    end
    obj.solution.jacobian = sparse(obj.solution.jacobian);
    obj.solution.B        = nan(size(obj.solution.A,1),0);
    
    % Update other properties of the solution
    obj = fullSolution(obj);
    
    % Indicate that the model does not need to be re-solved
    obj.needToBeSolved   = false;
    obj.takenDerivatives = true;
    
end

%==========================================================================
function [osr_coeff,loss,H,GAM,Hessian] = findDiscretionRules(obj,srCoeffInit,srInd,lb,ub,solution,paramSim,func)

    parser   = obj.parser;
    options  = obj.options;
    sol      = obj.solution;

    % If discretion, only rules responding to state variable is 
    % possible
    jacobian          = full(obj.solution.jacobian);
    [Alead,A0,Alag,B] = nb_dsge.jacobian2StructuralMatricesNB(jacobian,parser);
    nRules            = parser.numSimpleRules;
    nEqs              = size(Alead);
    numLeads          = sum(abs(Alead(nEqs-nRules+1:nEqs,:)) > 0,2);  
    num0              = sum(abs(A0(end,:)) > 0,2);
    if any(numLeads > 0)
        error([mfilename ':: The discretionary rule can only depend on state variables.'])
    end
    if any(num0 > 1)
        error([mfilename ':: The discretionary rule can only depend on state variables.'])
    end

    % Get initial value of the problem
    tol          = options.fix_point_TolFun;
    maxIter      = options.fix_point_maxiter;
    rcondTol     = options.rcondTol;
    nEndo        = length(parser.endogenous);
    H0           = zeros(nEndo,nEndo);
    param        = obj.results.beta; % Calibration and inital values
    [H,~,failed] = nb_dsge.solveInnerFixedPoint(Alead,A0,Alag,H0,tol,rcondTol,maxIter);
    if ~failed
        H = H0;  
    end 
    
    % The fixed point problem
    failed           = false;
    crit             = inf;
    iter             = 0;
    osr_coeff        = srCoeffInit;
    notSilent        = ~obj.options.silent;
    dampening        = options.fix_point_dampening;
    diffH            = zeros(size(H0));
    parser.firstStep = true;
    [solution.C]     = deal(B);
    while crit > tol

        H0                  = H0 + dampening*diffH; 
        [solution.A]        = deal(H0);
        [osr_coeff,loss]    = func(osr_coeff,srInd,lb,ub,paramSim,parser,solution,options);
        jacobian            = nb_dsge.solveSimpleRule(parser,sol,osr_coeff,srInd,param);
        [Alead,A0,Alag]     = nb_dsge.jacobian2StructuralMatricesNB(jacobian,parser);
        GAM                 = (Alead*H0 + A0);
        H                   = -GAM\Alag;
        diffH               = H - H0;
        crit                = max(abs(diffH(:))); % Maximum distance of any single element as criteria
        iter                = iter + 1;
        if iter > maxIter || failed
            failed = true;
            break
        end

        if notSilent
            disp(['Loss at iteration ' int2str(iter) ' is ' num2str(loss)])
        end

    end
    
    if failed 
        error([mfilename ':: Maximum number of iteration reached for the fixed point of the problem. No solution found.'])
    end
    
    % We have now found the correct solution fot A (H), and no we also
    % update C according to the simple rules.
    parser.firstStep         = false;
    [solution.A]             = deal(H);
    ind                      = abs(srCoeffInit - osr_coeff) > tol;
    srCoeffInit2             = srCoeffInit;
    srCoeffInit2(ind)        = osr_coeff(ind);
    [osr_coeff,loss,Hessian] = func(srCoeffInit2,srInd,lb,ub,param,parser,solution,options);  
        
end

%==========================================================================
function [osr_coeff,loss,Hessian] = doOptimization(srCoeffInit,srInd,lb,ub,param,parser,solution,options)

    opt                      = nb_getDefaultOptimset(options.optimset,options.optimizer);
    fh                       = @(x)nb_dsge.solveAndCalculateLoss(x,srInd,param,parser,solution,options);
    [osr_coeff,loss,Hessian] = nb_callOptimizer(options.optimizer,fh,srCoeffInit,lb,ub,opt,':: Finding the optimal simple rule failed.');
 
end

%==========================================================================
function [osr_coeff,loss,Hessian] = doOptimizationUncertain(srCoeffInit,srInd,lb,ub,paramSim,parser,sol,options)
% Optimize the expected loss

    opt                      = nb_getDefaultOptimset(options.optimset,options.optimizer);
    fh                       = @(x)nb_dsge.solveAndCalculateLossUncertain(x,srInd,paramSim,parser,sol,options);
    [osr_coeff,loss,Hessian] = nb_callOptimizer(options.optimizer,fh,srCoeffInit,lb,ub,opt,':: Finding the optimal simple rule under uncertainty failed.');

    
end

