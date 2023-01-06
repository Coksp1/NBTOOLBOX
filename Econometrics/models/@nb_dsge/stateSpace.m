function sol = stateSpace(par,estStruct)
% Syntax:
%
% sol = nb_dsge.stateSpace(par,estStruct)
%
% Description:
%
% Returns a state-space representation of a DSGE model.
%
% Observation equation:
% y(t) = H*x(t)
% 
% State equation:
% x(t) = A*x(t-1) + B*z(t) + C*u(t)
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
%   > options : Same as the input options + the ss fields will be added.
%
%   > err     : A char with the error message. Empty if no error have
%               occured.
%
%   > ss      : The steady-state of the model.
%
% See also:
% nb_kalmanLikelihoodMissingDSGE, nb_kalmanlikelihoodDSGE, 
% nb_model_generic.estimate, nb_dsge.objective
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    sol = struct();

    % Assign current estimate
    estStruct.beta(estStruct.indPar) = par;

    % Solve model
    options                                = estStruct.options;
    [sol.A,sol.B,sol.C,~,sol.ss,~,sol.err] = nb_dsge.solveOneRegime(options,estStruct.beta);
    if ~isempty(sol.err)
        return
    end
    
    if isfield(estStruct,'obsInd') % Are the model filtered?
        
        % Used by the filter
        options.ss = sol.ss(estStruct.obsInd); 
        
        % Observation equation
        sol.H = nb_dsge.makeObservationEq(estStruct.obsInd,size(sol.A,1));
    
        % Initilization
        if any(strcmpi(estStruct.options.kf_method,{'diffuse','univariate'}))
            [~,~,~,sol.x,sol.P,sol.Pinf,fail] = nb_setUpForDiffuseFilter(sol.H,sol.A,sol.C);
        else
            r            = size(sol.A,1);
            sol.x        = zeros(r,1);
            [sol.P,fail] = nb_lyapunovEquation(sol.A,sol.C*sol.C');
        end
        
        if fail
            if options.kf_warning
                warning('kf_warning:lyapunovFailed',[mfilename ':: Initial value of the one step forecast error covariance matrix could not be calculated. Use the identity matrix instead.'])
                sol.P = eye(size(sol.P));
            else
                sol.err = 'Initial value of the one step forecast error covariance matrix could not be calculated.';
            end
        end
        
        if ~isempty(options.kf_init_variance)
            sol.P = sol.P*options.kf_init_variance;
        end
        
    end
    sol.options = options;
    
end

