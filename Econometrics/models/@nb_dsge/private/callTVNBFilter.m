function [out,data_nb_ts] = callTVNBFilter(obj,inputs)
% Syntax:
%
% [out,data_nb_ts] = callTVNBFilter(obj,inputs)
%
% Description:
%
% Run filtering with NB model with un-modeled time-varying parameters.
% 
% See also:
% nb_dsge.filter
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if ~issolved(obj)
        obj = solve(obj);
    end
    
    tvVars = obj.options.timeVarying;
    if ~iscellstr(tvVars)
        error([mfilename ':: The timeVarying option must be a cellstr.'])
    end
    indD = ismember(tvVars,obj.options.data.variables);
    if any(~indD)
        error([mfilename ':: The variables given by the timeVarying option must be contained in data option. The following are missing; ' toString(tvVars(~indD))])
    end
    tvp = window(obj.options.data,inputs.startDate,'',tvVars);
    tvp = window(tvp,'',getRealEndDate(tvp,'nb_date','all'));
    
    paramN = obj.parameters.name;
    indP   = ismember(tvVars,paramN);
    if any(~indP)
        error([mfilename ':: You have specified the following parameter as time varying, ' toString(tvVars(~indP)) ', but they are not declared as parameters of the model.'])
    end
    
    % Get the data to filter
    if isempty(obj.observables.name)
        error([mfilename ':: You need to declear the observables.'])
    end 
    data_nb_ts = window(obj.options.data,inputs.startDate,inputs.endDate,obj.observables.name);
    test       = hasVariable(data_nb_ts,obj.observables.name);
    if any(~test)
        error([mfilename ':: Some of the observables has not been given any data; ' toString(obj.observables.name(~test))])
    end
    data_nb_ts = reorder(data_nb_ts,obj.observables.name);
    y          = double(data_nb_ts)';
    sDate      = data_nb_ts.startDate;
    eDate      = data_nb_ts.endDate;
    
    % Get measurment equation
    [~,loc] = ismember(obj.observables.name,obj.parser.endogenous);
    nObs    = obj.observables.number;
    nEndo   = obj.dependent.number;
    nExo    = obj.exogenous.number;
    H       = nb_dsge.makeObservationEq(loc,nEndo);

    % Get the time-varying parameters supplied by the users
    if tvp.getRealStartDate('nb_date','all') > sDate
        error([mfilename ':: Start date of the timeVarying input (' tvp.getRealStartDate('default','all') ') cannot be after the start date of the filtering (' toString(sDate) ').'])
    end
    if tvp.endDate < eDate
        tvp = extrapolate(tvp,'',eDate);
    elseif tvp.endDate > eDate
        tvp = window(tvp,'',eDate); 
    end
    tvVars              = tvp.variables;
    tvpd                = double(tvp)';
    periods             = (eDate - sDate) + 1;
    A                   = nan(nEndo,nEndo,periods);
    C                   = nan(nEndo,nExo,periods);
    objT                = obj;
    objT.options.silent = true;
    for ii = 1:periods
        objT      = assignParameters(objT,'param',tvVars,'value',tvpd(:,ii));
        objT      = solveNB(objT);
        A(:,:,ii) = objT.solution.A;
        C(:,:,ii) = objT.solution.C;
    end
    
    % Clean solution of deactivated shocks
    ind  = any(C(:,:,1));
    C    = C(:,ind,:);
    nExo = size(C,2);
    if nObs > nExo
        error([mfilename ':: You have more observables (' int2str(nObs) ') than exogenous variables (' int2str(nExo) ').'])
    end

    % Remove steady-state
    y = bsxfun(@minus,y,obj.solution.ss(loc));

    % Initilization
    if any(strcmpi(inputs.kf_method,{'diffuse','univariate'}))
        [~,~,~,x0,P0,PINF0,failed] = nb_setUpForDiffuseFilter(H,A(:,:,1),C(:,:,1));
    else
        CC          = C(:,:,1)*C(:,:,1)';
        r           = size(A,1);
        x0          = zeros(r,1);
        [P0,failed] = nb_lyapunovEquation(A(:,:,1),CC);
    end
    if failed
        if inputs.kf_warning
            warning([mfilename ':: Initial value of the one step forecast error covariance matrix could not be calculated. Use the identity matrix instead.'])
            P0 = eye(size(P0));
        else
            error([mfilename ':: Initial value of the one step forecast error covariance matrix could not be calculated.'])
        end
    end
    P0 = P0*inputs.kf_init_variance;

    % Do the filtering
    if strcmpi(inputs.kf_method,'diffuse')
        [xf,xs,us] = nb_kalmanSmootherDiffuseTVPDSGE(H,A,C,loc,x0,P0,PINF0,y,inputs.kf_kalmanTol);
    elseif strcmpi(inputs.kf_method,'univariate')
        [xf,xs,us] = nb_kalmanSmootherUnivariateTVPDSGE(H,A,C,loc,x0,P0,PINF0,y,inputs.kf_kalmanTol);    
    else
        [xf,xs,us] = nb_kalmanSmootherTVPDSGE(H,A,C,loc,x0,P0,y,inputs.kf_kalmanTol);
    end
    
    % Store to results
    out  = obj.results;
    vars = obj.solution.endo;
    res  = obj.solution.res(ind);
    if isempty(inputs.variables)
        ind = true(size(vars));
    else
        ind = ismember(vars,inputs.variables);
    end
    ss = obj.solution.ss(ind)';
    xs = xs(:,ind);
    xs = bsxfun(@plus,xs,ss);
    xf = xf(:,ind);
    xf = bsxfun(@plus,xf,ss);
    
    out.smoothed.variables = struct('data',xs,'startDate',toString(sDate),'variables',{vars(ind)});
    out.smoothed.shocks    = struct('data',us,'startDate',toString(sDate),'variables',{res});
    out.filtered.variables = struct('data',xf,'startDate',toString(sDate),'variables',{vars(ind)});
    out.likelihood         = [];

end
