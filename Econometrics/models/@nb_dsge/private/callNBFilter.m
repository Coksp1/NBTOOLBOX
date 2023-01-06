function [obj,out,data_nb_ts] = callNBFilter(obj,inputs)
% Syntax:
%
% [obj,out,data_nb_ts] = callNBFilter(obj,inputs)
%
% Description:
%
% Run filtering with NB model.
% 
% See also:
% nb_dsge.filter
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if ~issolved(obj)
        obj = solve(obj);
    end
    cleaned = cleanSolution(obj);
    
    % Harvey scale factor
    if isempty(inputs.kf_init_variance)
        inputs.kf_init_variance = 1;
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
    
    % Get solution
    A       = obj.solution.A;
    C       = cleaned.solution.C;
    [t,loc] = ismember(obj.observables.name,obj.endogenous.name);
    if any(~t)
        error([mfilename ':: Some of the decleared observables are not an endogneous variable of the model; ' toString(obj.observables.name(~t))])
    end
    nObs  = obj.observables.number;
    nEndo = length(obj.solution.endo);
    H     = nb_dsge.makeObservationEq(loc,nEndo);
    nRes  = length(cleaned.solution.res);
    if nObs > nRes
        error([mfilename ':: You have more observables (' int2str(nObs) ') than active shocks (' int2str(nRes) '). ',...
                         'Active shocks; ' toString(cleaned.solution.res)])
    end
    
    % Do the filtering
    breakPoint = false;
    if obj.options.stochasticTrend
        
        if ~isfield(obj.results,'logLikelihood') % Model is not estimated!
            % Secure that all the options are stored in the opt{ii}
            % struct passed to the nb_forecast function
            opt = createEstOptionsStruct(obj);
        else
            opt = obj.estOptions;
        end
        
        % Initilization
        if any(strcmpi(inputs.kf_method,{'diffuse','univariate'}))
            [~,~,~,~,P0,PINF0,failed] = nb_setUpForDiffuseFilter(H,A(:,:,1),C(:,:,1));
        else
            error([mfilename ':: When dealing with a DSGE model with stochastic trend you must ',...
                   'set ''kf_method'' to ''diffuse'' or ''univariate''.'])
        end
        x0 = obj.solution.ss(:,1);
        if failed
            if inputs.kf_warning
                warning([mfilename ':: Initial value of the one step forecast error covariance matrix could not be calculated. Use the identity matrix instead.'])
                P0 = eye(size(P0));
            else
                error([mfilename ':: Initial value of the one step forecast error covariance matrix could not be calculated.'])
            end
        end
        P0 = P0*inputs.kf_init_variance;
        
        % Do the filtering with break points
        if strcmpi(inputs.kf_method,'diffuse')
            [xf,xs,us,xu,uu,A,B,C,ss,p] = nb_kalmanSmootherDiffuseStochasticTrendDSGE(H,obj.solution,opt,obj.results,loc,x0,P0,PINF0,y,inputs.kf_kalmanTol);
        else % 'univariate'
            [xf,xs,us,xu,uu,A,B,C,ss,p] = nb_kalmanSmootherUnivariateStochasticTrendDSGE(H,obj.solution,opt,obj.results,loc,x0,P0,PINF0,y,inputs.kf_kalmanTol);     
        end
        breakPoint = true;
        
    elseif iscell(A)
        
        breakPoint = true;
        
        % Get the break dates
        if isempty(inputs.states)
            states = nb_dsge.getStatesOfBreakPoint(obj.parser,sDate,eDate);
        else
            periods = (eDate - sDate) + 1;
            if isscalar(inputs.states)
                states = inputs.states(ones(periods,1));
            else
                states = inputs.states;
                if ~nb_sizeEqual(states,[periods,1])
                    error([mfilename ':: The states input must be a ' int2str(periods) ' x 1 or 1 x x 1 double.'])
                end
            end
        end
        if all(states == states(1))
            % Only one state, so we use the standard Kalman filter.
            breakPoint = false;
            A          = A{states(1)};
            C          = C{states(1)};
        else
            % Initilization
            if any(strcmpi(inputs.kf_method,{'diffuse','univariate'}))
                [~,~,~,~,P0,PINF0,failed] = nb_setUpForDiffuseFilter(H,A{1},C{1});
            else
                CC          = C{1}*C{1}';
                [P0,failed] = nb_lyapunovEquation(A{1},CC);
            end
            x0 = obj.solution.ss{1};
            if failed
                if inputs.kf_warning
                    warning([mfilename ':: Initial value of the one step forecast error covariance matrix could not be calculated. Use the identity matrix instead.'])
                    P0 = eye(size(P0));
                else
                    error([mfilename ':: Initial value of the one step forecast error covariance matrix could not be calculated.'])
                end
            end
            P0 = P0*inputs.kf_init_variance;

            % Do the filtering with break points
            if strcmpi(inputs.kf_method,'diffuse')
                [xf,xs,us,xu,uu] = nb_kalmanSmootherDiffuseBreakPointDSGE(H,A,C,obj.solution.ss,loc,x0,P0,PINF0,y,inputs.kf_kalmanTol,states);
            elseif strcmpi(inputs.kf_method,'univariate')
                [xf,xs,us,xu,uu] = nb_kalmanSmootherUnivariateBreakPointDSGE(H,A,C,obj.solution.ss,loc,x0,P0,PINF0,y,inputs.kf_kalmanTol,states);    
            else
                [xf,xs,us,xu,uu] = nb_kalmanSmootherBreakPointDSGE(H,A,C,obj.solution.ss,loc,x0,P0,y,inputs.kf_kalmanTol,states);
            end
            
        end
        
    end
    
    if ~breakPoint
        
        % Remove steady-state
        if iscell(obj.solution.ss)
            ssObs = obj.solution.ss{states(1)}(loc);
        else
            ssObs = obj.solution.ss(loc);
        end
        y = bsxfun(@minus,y,ssObs);
        
        % Initilization
        if any(strcmpi(inputs.kf_method,{'diffuse','univariate'}))
            [~,~,~,x0,P0,PINF0,failed] = nb_setUpForDiffuseFilter(H,A,C);
        else
            CC          = C*C';
            x0          = zeros(nEndo,1);
            [P0,failed] = nb_lyapunovEquation(A,CC);
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
            [xf,xs,us,xu,uu] = nb_kalmanSmootherDiffuseDSGE(H,A,C,loc,x0,P0,PINF0,y,inputs.kf_kalmanTol);
        elseif strcmpi(inputs.kf_method,'univariate')
            [xf,xs,us,xu,uu] = nb_kalmanSmootherUnivariateDSGE(H,A,C,loc,x0,P0,PINF0,y,inputs.kf_kalmanTol);
        else
            if any(isnan(y(:)))
                [xf,xs,us,xu,uu] = nb_kalmanSmootherMissingDSGE(H,A,C,loc,x0,P0,y,inputs.kf_kalmanTol);
            else
                [xf,xs,us,xu,uu] = nb_kalmanSmootherDSGE(H,A,C,loc,x0,P0,y,inputs.kf_kalmanTol);
            end
        end
        
    end
    
    % Store to results
    out  = obj.results;
    vars = obj.solution.endo;
    if obj.options.stochasticTrend
        res  = obj.solution.res;
    else
        res  = cleaned.solution.res;
    end
    if isempty(inputs.variables)
        ind = true(size(vars));
    else
        ind = ismember(vars,inputs.variables);
    end
    
    % Add steady-state
    xs = xs(:,ind);
    xu = xu(:,ind);
    xf = xf(:,ind);
    if not(iscell(obj.solution.ss) && breakPoint) && ~obj.options.stochasticTrend
        if iscell(obj.solution.ss)
            ss = obj.solution.ss{1}(ind)';
        else
            ss = obj.solution.ss(ind)';
        end
        xs = bsxfun(@plus,xs,ss);
        xu = bsxfun(@plus,xu,ss);
        xf = bsxfun(@plus,xf,ss);
    end
    
    % Store to results
    out.smoothed.variables = struct('data',xs,'startDate',toString(sDate),'variables',{vars(ind)});
    out.smoothed.shocks    = struct('data',us,'startDate',toString(sDate),'variables',{res});
    out.filtered.variables = struct('data',xf,'startDate',toString(sDate),'variables',{vars(ind)});
    out.updated.variables  = struct('data',xu,'startDate',toString(sDate),'variables',{vars(ind)});
    out.updated.shocks     = struct('data',uu,'startDate',toString(sDate),'variables',{res});
    out.likelihood         = [];
    if obj.options.stochasticTrend
        
        % Store solution for analysis later
        obj.solution.A  = A;
        obj.solution.B  = B;
        obj.solution.C  = C;
        obj.solution.ss = ss';
        
        % Remove unchanged steady-state variables
        ssTest = bsxfun(@minus,ss,ss(1,:));
        indSS  = any(abs(ssTest) > 1e-8,1); 
        ss     = ss(2:end,indSS);
        varsSS = strcat(vars(indSS),'(ss)');
        if ~isempty(inputs.variables)
            ind    = ismember(varsSS,inputs.variables);
            varsSS = varsSS(ind);
            ss     = ss(:,ind);
        end
        
        % Remove unchanged parameters
        pTest = bsxfun(@minus,p,p(1,:));
        indP  = any(abs(pTest) > 1e-8,1); 
        p     = p(:,indP);
        pars  = obj.parameters.name(:)';
        pars  = pars(indP);
        if ~isempty(inputs.variables)
            ind  = ismember(pars,inputs.variables);
            pars = pars(ind);
            p    = p(:,ind);
        end
        
        out.smoothed.steadyState = struct('data',ss,'startDate',toString(sDate),'variables',{varsSS});
        out.smoothed.parameters  = struct('data',p,'startDate',toString(sDate),'variables',{pars});
        out.updated.steadyState  = struct('data',ss,'startDate',toString(sDate),'variables',{varsSS});
        out.updated.parameters   = struct('data',p,'startDate',toString(sDate),'variables',{pars});

    end
    
end
