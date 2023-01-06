function sol = stateSpaceTVP(par,estStruct)
% Syntax:
%
% sol = nb_dsge.stateSpaceTVP(par,estStruct)
%
% Description:
%
% Returns a state-space representation of a DSGE model.
%
% Observation equation:
% y(t) = H*x(t)
% 
% State equation:
% x(t) = A(t)*x(t-1) + B(t)*z(t) + C(t)*u(t)
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
%   > B       : B is impact of shock matrix.
%
%   > x       : The "a priori" state estimate (after the new measurement 
%               information is included).
%
%   > P       : Covariance of the state vector "a priori" estimate.
%
%   > Pinf    : Covariance of the state vector "a priori" estimate used
%               during diffuse steps.
%
%   > options : Same as the input options + the ss fields will be added.
%
%   > err     : A char with the error message. Empty if no error have
%               occured.
%
%   > ss      : The steady-state of the model.
%
% See also:
% nb_kalmanlikelihoodDSGE, nb_model_generic.estimate, nb_dsge.objective
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Assign current estimate
    beta                   = estStruct.beta;
    beta(estStruct.indPar) = par;

    % Solve main model (first regime)
    options = estStruct.options;
    periods = size(estStruct.timeVarying,2);
    if isempty(estStruct.options.parser.all_endogenous)
        nEndo   = length(estStruct.options.parser.endogenous);
        nExo    = length(estStruct.options.parser.exogenous);
        B       = nan(nEndo,0,periods); 
    else
        nEndo   = length(estStruct.options.parser.all_endogenous);
        nExo    = length(estStruct.options.parser.all_exogenous) - 1;
        B       = nan(nEndo,1,periods); % Constant term 
    end
    A       = nan(nEndo,nEndo,periods);
    C       = nan(nEndo,nExo,periods);
    ss      = nan(nEndo,periods);
    if options.solve_parallel
        
        beta = beta(:,ones(1,periods));
        for tt = 1:periods
            beta(estStruct.indTimeVarying,tt) = estStruct.timeVarying(:,tt);
        end
        
        err = cell(1,periods);
        parfor tt = 1:periods
            [Att,Btt,Ctt,~,stt,~,err{tt}] = nb_dsge.solveOneRegime(options,beta(:,tt));
            if isempty(err{tt})
                A(:,:,tt) = Att;
                B(:,:,tt) = Btt;
                C(:,:,tt) = Ctt;
                ss(:,tt)  = stt;
            end
        end
        if any(~cellfun(@isempty,err))
            err     = err(~cellfun(@isempty,err));
            sol.err = err{1}; % Just return the first error found
            return
        else
            sol.err = '';
        end
        
    else
    
        for tt = 1:periods
            beta(estStruct.indTimeVarying) = estStruct.timeVarying(:,tt);
            [Att,Btt,Ctt,~,sstt,~,sol.err]     = nb_dsge.solveOneRegime(options,beta);
            if ~isempty(sol.err)
                return
            end
            A(:,:,tt) = Att;
            B(:,:,tt) = Btt;
            C(:,:,tt) = Ctt;
            ss(:,tt)  = sstt;
        end
        
    end
    
    % Observation equation
    H = nb_dsge.makeObservationEq(estStruct.obsInd,size(A,1));
    
    % Initilization
    if any(strcmpi(estStruct.options.kf_method,{'diffuse','univariate'}))
        [~,~,~,x,P,sol.Pinf,fail] = nb_setUpForDiffuseFilter(H,A(:,:,1),C(:,:,1));
    else
        r        = size(A,1);
        x        = zeros(r,1);
        [P,fail] = nb_lyapunovEquation(A(:,:,1),C(:,:,1)*C(:,:,1)');
    end
    
    if fail
        if options.kf_warning
            warning('kf_warning:lyapunovFailed',[mfilename ':: Initial value of the one step forecast error covariance matrix could not be calculated. Use the identity matrix instead.'])
            P = eye(size(sol.P));
        else
            sol.err = 'Initial value of the one step forecast error covariance matrix could not be calculated.';
        end
    end
    
    if ~isempty(options.kf_init_variance)
        P = P*options.kf_init_variance;
    end
    
    % Wrap solution in a struct
    sol.A       = A;
    sol.B       = B;
    sol.C       = C;
    sol.H       = H;
    sol.x       = x;
    sol.P       = P;
    options.ss  = ss; % Used by the filter
    sol.options = options;
    sol.ss      = ss; % Used by the system priors
    
end
