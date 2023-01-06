function obj = mle(x,dist)
% Syntax:
%
% obj = nb_distribution.mle(x,distribution)
%
% Description:
%
% Estimate a distribution using maximum likelihood estimator.
% 
% Input:
% 
% - x    : The assumed random observation of the distribution. As a
%          nobs x nvars double.
%
% - dist : A string with the distribution to match to the data.
%
%          The supported distributions are:
%          > 'ast'
%          > 'beta'
%          > 'chis' 
%          > 'constant'
%          > 'exp'
%          > 'f'
%          > 'gamma'
%          > 'invgamma'
%          > 'laplace'
%          > 'logistic'
%          > 'lognormal'
%          > 'normal'
%          > 't'
%          > 'uniform'
%          > 'wald'
%
%          Type <help nb_distribution.type> to get a description of the
%          of the different distributions.
%
% Output:
% 
% - obj : A 1 x nvars nb_distribution object array. 
%
% Examples:
%
% x   = randn(100,1);
% obj = nb_distribution.mle(x,'normal');
%
% See also:
% nb_distribution.estimate
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    nvar = size(x,2);
    if nvar > 1
        obj(1,nvar) = nb_distribution;
        for ii = 1:size(x,2)
            obj(1,ii) = mle(x(:,ii),dist);
        end
        return
    end

    dist = lower(dist);
    switch dist
        
        case 'ast'
            
            % Use a normal symmetric distribution as starting point
            a = mean(x,1);
            b = std(x,0,1);
            c = 0.5; % Does not have anything to say when d == e.
            d = 100;
            e = 100;
            
            % Do mle
            opt           = getOpt();
            opt.Algorithm = 'interior-point';
            LB            = [-inf;0;0;0;0];
            UB            = [inf;inf;1;inf;inf];
            [par,~,e]     = fmincon(@ast_lik,[a;b;c;d;e],[],[],[],[],LB,UB,[],opt,x); 
            nb_interpretExitFlag(e,'fmincon');
            obj = nb_distribution('type',dist,'parameters',{par(1),par(2),par(3),par(4),par(5)}); 
        
        case 'beta'
        
            if any(x>1) || any(x<0)
                error([mfilename ':: Observations outside domain of the beta distribution; [0,1]. Estimation failed.'])
            end
            
            % Method of moments initial values
            me  = mean(x,1);
            v   = var(x,0,1);
            t   = (me*(1 - me))/v;
            m0  = me*(t - 1);
            k0  = (1 - me)*(t - 1);
            s1  = sum(log(x));
            s2  = sum(log(1 - x));
            n   = size(x,1);
            
            % Find the mle
            opt     = getOpt();
            [x,l,e] = fsolve(@beta_lik,[m0,k0],opt,n,s1,s2);
            if (e < 0) % should never happen
                error([mfilename ':: mle estimation failed for the beta distribution.']);
            elseif eps(abs(l)) > opt.TolX
                error([mfilename ':: mle estimation failed for the beta distribution.']);
            end
            obj = nb_distribution('type',dist,'parameters',{x(1),x(2)}); 
            
        case 'chis'
            
            error([mfilename ':: mle is not supported for the CHI^2 distribution yet.'])
            
        case 'constant'
            
            m   = mean(x,1);
            obj = nb_distribution('type',lower(dist),'parameters',{m});    
            
        case 'exp'
        
            if any(x<0)
                error([mfilename ':: Observations outside domain of the exponential distribution; [0,inf]. Estimation failed.'])
            end
            
            obj = nb_distribution('type',dist,'parameters',{1/mean(x,1)});
            
        case 'f'
            
            error([mfilename ':: mle is not supported for the F-distribution yet.'])
            
        case 'gamma'
            
            if any(x<0)
                error([mfilename ':: Observations outside domain of the gamma distribution; [0,inf]. Estimation failed.'])
            end
            
            me      = mean(x,1);
            v       = var(x,0,1);
            m0      = v/me; % Method of moments estimator as initial value
            s       = log(me) - mean(log(x));
            opt     = getOpt();
            [m,l,e] = fzero(@gamma_lik, m0, opt, s);
            if (e < 0) % should never happen
                error([mfilename ':: mle estimation failed for the gamma distribution.']);
            elseif eps(abs(l)) > opt.TolX
                error([mfilename ':: mle estimation failed for the gamma distribution.']);
            end
            k   = me/m;
            obj = nb_distribution('type',dist,'parameters',{m,k});  
            
        case 'invgamma'
            
            if any(x<0)
                error([mfilename ':: Observations outside domain of the inverse gamma distribution; [0,inf]. Estimation failed.'])
            end
            
            me = mean(x,1);
            v  = var(x,0,1);
            n  = size(x,1);
            m0 = 2 + me^2/v;
            if m0 <= 2
                error([mfilename ':: Could not fit a inverse gamma distribution to the data.'])
            end
            t    = sum(x.^(-1));
            s    = - log(t) - sum(log(x))/n;
            tol  = eps;
            maxI = 1000;
            kk   = 0;
            m    = inf;
            while abs(m - m0) > tol || kk < maxI
                m  = nb_invpsi(log(n*m0) + s);
                m0 = m;
                kk = kk + 1;
            end
            
            if kk > maxI
                error([mfilename ':: mle estimation failed for the inverse gamma distribution.']);
            end
            k   = n*m/t;
            obj = nb_distribution('type',dist,'parameters',{m,k});
            
        case 'laplace'
            
            m   = mean(x,1);
            N   = size(x,1);
            k   = sum(abs(x - m))/N;
            obj = nb_distribution('type','laplace','parameters',{m,k});
            
        case 'logistic'
            
            % Start at mme estimates
            me  = mean(x,1);
            v   = var(x,0,1);
            n   = size(x,1);
            m0  = me;
            k0  = sqrt(3*v)/pi;
            
            % Do mle
            opt     = getOpt();
            [x,~,e] = fminsearch(@logistic_lik,[m0;k0],opt,n,me,x); 
            nb_interpretExitFlag(e,'fminsearch');
            obj = nb_distribution('type',dist,'parameters',{x(1),x(2)});
            
        case 'lognormal'
            
            if any(x<0)
                error([mfilename ':: Observations outside domain of the log-normal distribution; [0,inf]. Estimation failed.'])
            end
            
            n   = size(x,1);
            m   = sum(log(x))/n;
            k   = sqrt(sum((log(x) - m).^2)/n);
            obj = nb_distribution('type',dist,'parameters',{m,k});
            
        case 'normal'
            
            m   = mean(x,1);
            s   = std(x,0,1);
            obj = nb_distribution('type','normal','parameters',{m,s});
               
        case 't'
            
            % Start at mme estimates
            me  = mean(x,1);
            v   = var(x,0,1);
            k   = kurtosis(x,0,1);
            a0  = me;
            m0  = 6/k + 4;
            if m0 <= 4
                m0 = 4;
            end
            b0 = sqrt((v*(m0 - 2))/m0);
            
            % Do mle
            opt           = getOpt();
            opt.Algorithm = 'interior-point';
            LB            = [0;-inf;0];
            UB            = [inf;inf;inf];
            [par,~,e]     = fmincon(@t_lik,[m0;a0;b0],[],[],[],[],LB,UB,[],opt,x); 
            nb_interpretExitFlag(e,'fmincon');
            obj = nb_distribution('type',dist,'parameters',{par(1),par(2),par(3)});
            
        case 'uniform'
            
            param = [min(x),max(x)];
            obj   = nb_distribution('type',dist,'parameters',{param(1),param(2)});    
            
        case 'wald'
            
            if any(x<0)
                error([mfilename ':: Observations outside domain of the wald distribution; [0,inf]. Estimation failed.'])
            end
            
            m    = mean(x,1);
            kinv = sum(1./x - 1/m)/size(x,1);
            k    = 1/kinv;
            obj  = nb_distribution('type',dist,'parameters',{m,k});    
            
        otherwise
            
            error([mfilename ':: The mle estimator is not supported for the distribution ' dist])
            
    end
 
end

%==========================================================================
function f = gamma_lik(m,s)
    f = log(m) - psi(m) - s;
end

function f = beta_lik(x,n,s1,s2)
    f = [n*psi(x(1) + x(2)) - n*psi(x(1)) + s1;
         n*psi(x(1) + x(2)) - n*psi(x(2)) + s2];
end

function f = logistic_lik(x,n,me,data)
    f = -n*me/x(2) + n*x(1)/x(2) + n*log(x(2)) + 2*sum(log(1 + exp((data - x(1))/x(2)))); %-logLikelihood 
end

function f = skt_lik(x,data)
    location = x(1);
    scale    = x(2);
    shape    = x(3);
    dof      = x(4);
    
    
    term = log(1 + ((data - a).^2)/(b^2*m));
    f    = size(data,1)*log(sqrt(m)*b*beta(0.5,m/2)) + ((m + 1)/2)*sum(term); %-logLikelihood 
end

function f = t_lik(x,data)
    m    = x(1);
    a    = x(2);
    b    = x(3);
    term = log(1 + ((data - a).^2)/(b^2*m));
    f    = size(data,1)*log(sqrt(m)*b*beta(0.5,m/2)) + ((m + 1)/2)*sum(term); %-logLikelihood 
end

function f = ast_lik(x,data)
    indNeg = data <= x(1);
    nNeg   = sum(indNeg);
    nPos   = size(data,1) - nNeg;
    cstar  = nb_ast_cstar(x(3),x(4),x(5));
    Kd     = nb_ast_k(x(4));
    Ke     = nb_ast_k(x(5));
    f1     = (x(4)/2 + 0.5)*sum(log(1 + (1/x(4))*((data(indNeg) - x(1))/(2*cstar*x(2))).^2));
    f2     = (x(5)/2 + 0.5)*sum(log(1 + (1/x(5))*((data(~indNeg) - x(1))/(2*(1 - cstar)*x(2))).^2));
    f      = size(data,1)*log(x(2)) - nNeg*log(Kd*x(3)/cstar) - nPos*log(Ke*(1 - x(3))/(1 - cstar)) + f1 + f2; %-logLikelihood 
end

function opt = getOpt()

    tol = eps;
    opt = optimset('Display','off','MaxFunEvals',50000,...
                   'MaxIter',50000,'TolFun',tol,'TolX',tol);

end
