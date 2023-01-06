function sol = stateSpaceBreakPoint(par,estStruct)
% Syntax:
%
% sol = nb_dsge.stateSpaceBreakPoint(par,estStruct)
%
% Description:
%
% Returns a state-space representation of a break-point DSGE model.
%
% Observation equation:
% y = H*x(t)
% 
% State equation:
% x(t) = ss(t) + A(t)*(x(t-1) - ss(t)) + B(t)*z(t) + C(t)*u(t)
% 
% Where u ~ N(0,I) meaning u is gaussian noise with covariance I.
% 
% Input:
% 
% - par       : Current vector of the estimated parameters.
%
% - estStruct : See the nb_dsge.getObjectiveForEstimation method.
%
% Output:
% 
% - sol : A struct with the fields:
%
%   > H       : Observation matrix.
%
%   > A       : State transition matrix.
%
%   > B       : Constant term.
%
%   > C       : B is impact of shock matrix.
%
%   > x       : The "a priori" state estimate (after the new measurement 
%               information is included).
%
%   > P       : Covariance of the state vector "a priori" estimate.
%
%   > Pinf    : Covariance of the state vector "a priori" estimate used
%               during diffuse steps.
%
%   > options : Same as the input options + the states and ss fields will be 
%               added.
%
%   > err     : A char with the error message. Empty if no error have
%               occured.
%
%   > ss      : The steady-state of the model.
%
%   > states  : The states used for each step of the Kalman filter.
%
% See also:
% nb_kalmanlikelihoodDSGE, nb_model_generic.estimate, nb_dsge.objective
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Assign current estimate
    estStruct.beta(estStruct.indPar) = par(~estStruct.isBreakP & ~estStruct.isTimeOfBreakP);
    
    % Solve main model (first regime)
    options                     = estStruct.options;
    [Am,Bm,Cm,~,ss,JAC,sol.err] = nb_dsge.solveOneRegime(options,estStruct.beta);
    if ~isempty(sol.err)
        return
    end
    
    % Observation equation
    H = nb_dsge.makeObservationEq(estStruct.obsInd,size(Am,1));
    
    % Initilization
    if any(strcmpi(estStruct.options.kf_method,{'diffuse','univariate'}))
        [~,~,~,~,P,sol.Pinf,fail] = nb_setUpForDiffuseFilter(H,Am,Cm);
    else
        [P,fail] = nb_lyapunovEquation(Am,Cm*Cm');
    end
    
    if fail
        if options.kf_warning
            warning('kf_warning:lyapunovFailed',[mfilename ':: Initial value of the one step forecast error covariance matrix could not be calculated. Use the identity matrix instead.'])
            P = eye(size(P));
        else
            sol.err = 'Initial value of the one step forecast error covariance matrix could not be calculated.';
            return
        end
    end
    
    if ~isempty(options.kf_init_variance)
        P = P*options.kf_init_variance;
    end
    
    % Update the break point parameters
    breakPar = par(estStruct.isBreakP);
    if ~isempty(breakPar)
        estimated   = estStruct.estimated;
        nBreaks     = options.parser.nBreaks;
        breakPoints = options.parser.breakPoints;
        for ii = 1:nBreaks
            breakNames                  = strcat(breakPoints(ii).parameters,'_',toString(breakPoints(ii).date));
            ind                         = ismember(estimated,breakNames);
            breakPar                    = par(ind);
            [ind,loc]                   = ismember(breakNames,estimated(ind));
            breakPoints(ii).values(ind) = breakPar(loc);
        end
        options.parser.breakPoints = breakPoints;
    end
    
    % Solution after each break-point
    [A,B,C,~,ss,~,sol.err] = nb_dsge.solveBreakPoints(options,estStruct.beta,Am,Bm,Cm,Cm,ss,JAC); 
    options.ss             = ss;
    
    % Do we estimate the timing of the breaks?
    breakDates = par(estStruct.isTimeOfBreakP);
    if ~isempty(breakDates)
        
        % The dates of some break points are to be estimated
        estimated   = estStruct.estimated;
        nBreaks     = options.parser.nBreaks;
        breakPoints = options.parser.breakPoints;
        for ii = 1:nBreaks
            breakName            = strcat('break_',toString(breakPoints(ii).date));
            ind                  = strcmp(breakName,estimated);
            breakPoints(ii).date = breakPoints(ii).date + round(par(ind));
        end
        options.parser.breakPoints = breakPoints;
        
        % Get the states given the current dates of the breaks
        dataS            = nb_date.date2freq(options.dataStartDate);
        sDate            = dataS + (options.estim_start_ind - 1);
        eDate            = dataS + (options.estim_end_ind - 1);
        estStruct.states = nb_dsge.getStatesOfBreakPoint(options.parser,sDate,eDate);
        
    end
    options.states = estStruct.states;
    
    % Wrap solution in a struct
    sol.A       = A;
    sol.B       = B;
    sol.C       = C;
    sol.H       = H;
    sol.x       = ss{estStruct.states(1)};
    sol.P       = P;
    sol.options = options;
    sol.ss      = ss; 
    sol.states  = estStruct.states; 
     
end
