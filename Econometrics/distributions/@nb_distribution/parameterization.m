function [obj, params] = parameterization(me,v,dist,lb,ub,s,k,mo)
% Syntax:
%
% obj = nb_distribution.parameterization(m,v,dist)
% obj = nb_distribution.parameterization(m,v,dist,lb,ub)
% obj = nb_distribution.parameterization(m,v,dist,lb,ub,s,k,mo)
%
% Description:
%
% Back out the hyperparameters given some moments.
% 
% Supported distribution:
% > Mean only: 'chis', 'constant', 'exp'
% > Variance only: 't' (1 parameter family)
% > Mean and variance only: 'beta', 'f', 'gamma', 'invgamma', 'laplace', 
%   'logistic', 'lognormal', 'normal', 'uniform', 'wald'
% > Mean, variance and kurtosis: 't' (3 parameter family)
% > Mean, variance, skewness and kurtosis: 'skt'
% > Mean, mode and variance: 'tri'
% > Mode and variance (Set mean (me input) to []): 'gamma'
%
% Input:
% 
% - me   : Mean of the distribution.
%
% - v    : Variance of the distribution.
%
% - dist : A string with the distribution to match to the data.
%
%          See description for the supported distributions.
%
% - lb   : Lower bound of the distribution. Default is no lower bound.
%
% - ub   : Upper bound of the distribution. Default is no upper bound.
% 
% - s    : Skewness of the distribution.
%
% - k    : Kurtosis of the distribution.
%
% - mo   : Mode of the distribution.
%
% Output:
% 
% - obj    : A nb_distribution object.
%
% - params : The hyperparameters as a cell array
%
% Examples:
%
% x           = randn(100,1);
% obj         = nb_distribution.parameterization(x,'normal');
% [~, params] = nb_distribution.parameterization(x,'normal');
%
% See also:
% nb_distribution.estimate
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 8
        mo = [];
        if nargin < 7
            k = [];
            if nargin < 6
                s = [];
                if nargin < 5
                    ub = [];
                    if nargin < 4
                        lb = [];
                    end
                end
            end
        end
    end
    
    dist = lower(dist);
    if strcmp(dist,'inv_gamma')
        dist = 'invgamma';
    end
    
    switch dist

        case 'beta'

            if me>1 || me<0
                error([mfilename ':: Mean is outside domain of the beta distribution; [0,1]. Parametrization failed.'])
            end

            t   = (me*(1 - me))/v;
            m   = me*(t - 1);
            k   = (1 - me)*(t - 1);

            params = {m, k};

        case 'chis'

            if me<0
                error([mfilename ':: Mean is outside domain of the chi-squared distribution; [0,inf]. Parametrization failed.'])
            end

            params = {me};

        case 'constant'

            params = {me};     

        case 'exp'

            if me<0
                error([mfilename ':: Mean is outside domain of the exponential distribution; [0,inf]. Parametrization failed.'])
            end

            params = {1 / me}; 

        case 'f'

            if me<0
                error([mfilename ':: Mean is outside domain of the F-distribution; [0,inf]. Parametrization failed.'])
            end

            k = 2*me/(me - 1); 
            if k <= 4
                error([mfilename ':: Could not fit a F-distribution to the mean and variance.'])
            end

            vv  = ((k - 2)^2*(k - 4)*v)/(2*k^2);
            m   = (k - 2)/(vv - 1);

            params = {m, k};

        case 'gamma'

            if isempty(me) && ~isempty(mo)
                k = (-mo + sqrt(mo^2 + 4*v))/2;
                m = mo/k + 1;
                if m < 1
                    error([mfilename ':: The mode is not defined for shape parameter less then 1 for the gamma distribution. Parametrization failed.'])
                end
            elseif ~isempty(me)
                if me<0
                    error([mfilename ':: Mean is outside domain of the gamma distribution; [0,inf]. Parametrization failed.'])
                end
                m   = me^2/v;
                k   = v/me;
            else
                error([mfilename ':: Either the me or mo input must be non-empty. Parametrization failed.'])
            end
            params = {m, k};

        case 'invgamma'

            if me<0
                error([mfilename ':: Mean is outside domain of the inverse gamma distribution; [0,inf]. Parametrization failed.'])
            end

            if v == inf
                m = 2;
            else
                m = 2 + me^2/v;
                if m <= 2
                    error([mfilename ':: Could not fit a inverse gamma distribution to the mean and variance.'])
                end
            end
            k   = me*(m - 1);

            params = {m, k};
            
        case 'laplace'
            
            m = me;
            k = sqrt(v/2);
            
            params = {m, k};

        case 'logistic'

            m   = me;
            k   = sqrt(3*v)/pi;

            params = {m, k};

        case 'lognormal'

            if me<0
                error([mfilename ':: Mean is outside domain of the lognormal distribution; [0,inf]. Estimation failed.'])
            end

            me2 = v + me^2; % E[x^2]
            k   = sqrt(log(me2)- 2*log(me));
            m   = log(me) - (k^2)/2;

            params = {m, k};

        case 'normal'

            params = {me, sqrt(v)};

        case 't'

            if nargin < 7
                
                m = 2*v/(v-1);
                if m <= 2
                    error([mfilename ':: Could not fit a student-t distribution to the mean and variance, '...
                                     'as the variance is not defined for the given parameterization.'])
                end
                params = {m};
                
            else
                
                a = me;
                m = 6/k + 4;
                if m <= 4
                    error([mfilename ':: Could not fit a student-t distribution to the mean, variance and kurtosis, '...
                                     'as the variance is not defined for the given parameterization.'])
                end
                b = sqrt((v*(m - 2))/m);
                params = {m,a,b};
                
            end
            
        case 'tri'
            
            if isempty(mo)
                error([mfilename ':: To find a parametrization of the ''tri'' distribution you need to set the mo input.'])
            end
            start   = [-10;10];
            opt     = nb_getOpt();
            [x,~,e] = fminsearch(@triMME,start,opt,mo,me,v); 
            nb_interpretExitFlag(e,'fminsearch');
            params = num2cell([x;mo]');
            
        case 'skt'
            
            if isempty(s)
                error([mfilename ':: To find a parametrization of the ''skt'' distribution you need to set the s input.'])
            end
            if isempty(k)
                error([mfilename ':: To find a parametrization of the ''skt'' distribution you need to set the k input.'])
            end
            if k <= 3
                % We are dealing with the skewed normal
                [location,scale,shape] = mme_skn(me,v,s);
                x                      = [location,scale,shape,inf];
            else
                % Use skew normal estimates as start values 
                [location,scale,shape] = mme_skn(me,v,s);
                start                  = [location,scale,shape,8];
                [x,~,e]                = fmincon(@sktMME,start,[],[],[],[],[],[],[],nb_getOpt(),me,v,s,k); 
                nb_interpretExitFlag(e,'fmincon');
            end
            params = num2cell(x);    

        case 'uniform'

            me2 = v + me^2; % E[x^2]
            m   = me - sqrt(3)*sqrt(me2 - me^2);
            k   = me + sqrt(3)*sqrt(me2 - me^2);

            params = {m, k};

        case 'wald'

            if me<0
                error([mfilename ':: Meani is outside domain of the wald distribution; [0,inf]. Parametrization failed.'])
            end

            m   = (v*me)^(1/3);

            params = {m, me};

        otherwise

            error('parametrization:unsupportedDistribution',[mfilename ':: Parametrization is not supported for a distribution of type ' dist])

    end
    
    % Truncated distribution. We just use the ordinary distribution moments
    % as starting values!
    if ~isempty(lb) || ~isempty(ub) % Two-sided or one-sided truncation
        
        start   = cell2mat(params)';
        opt     = nb_getOpt();
        funcM   = @nb_distribution.truncated_mean;
        funcV   = @nb_distribution.truncated_variance;
        [x,~,e] = fminsearch(@truncMME,start,opt,funcM,funcV,me,v,lb,ub,dist); 
        nb_interpretExitFlag(e,'fminsearch');
        params = num2cell(x');
        
    end
        
    obj = nb_distribution('type',dist,'parameters',params);
    if ~isempty(lb) 
        set(obj,'lowerBound',lb);
    end
    if ~isempty(ub)
        set(obj,'upperBound',ub);
    end
    
end

function f = truncMME(x,funcM,funcV,me,v,lb,ub,dist)

    param = num2cell(x');
    m1    = funcM(dist,param,lb,ub);
    v1    = funcV(dist,param,lb,ub);
    f     = sum(abs([m1-me,v1-v]));

end

function f = triMME(x,mo,me,v)

    param = num2cell([x;mo]');
    m1    = nb_distribution.tri_mean(param{:});
    v1    = nb_distribution.tri_variance(param{:});
    if x(1) > x(2) || x(1) > mo || x(2) < mo
        f = inf;
    else
        f = sum(abs([m1-me,v1-v]));
    end

end

function [location,scale,shape] = mme_skn(me,v,s)

    s_abs     = abs(s);
    k1        = s_abs^(2/3);
    k2        = ((4 - pi)/2)^(2/3);
    delta_abs = sqrt((pi/2)*(k1/(k1 + k2)));
    delta     = sign(s)*delta_abs;
    shape     = delta/sqrt(1 - delta^2);
    scale     = sqrt(v/(1 - (2*delta^2)/pi));
    location  = me - scale*delta*sqrt(2/pi);

end

function f = sktMME(x,me,v,s,k)

    if (x(2) <= 0)
        f = 1000;
        return
    end
    
    param = num2cell(x);
    m1    = nb_distribution.skt_mean(param{:});
    v1    = nb_distribution.skt_variance(param{:});
    s1    = nb_distribution.skt_skewness(param{:});
    k1    = nb_distribution.skt_kurtosis(param{:});
    f     = sum(abs([10*(m1-me),10*(v1-v),s1-s,k1-k]));
    if isnan(f)
        f = 1000;
    end

end
