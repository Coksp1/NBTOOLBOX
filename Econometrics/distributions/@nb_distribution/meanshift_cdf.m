function f = meanshift_cdf(x,dist,param,lb,ub,ms)
% Syntax:
%
% f = nb_distribution.meanshift_cdf(x,dist,param,lb,ub,ms)
%
% Description:
%
% CDF of the mean shifted possibly truncated distribution.
% 
% Input:
% 
% - x     : The point to evaluate the cdf, as a double
%
% - dist  : The name of the underlying distribution as a string. Must be 
%           supported by the nb_distribution class.
%
% - param : A cell with the parameters of the selected distribution.
% 
% - lb    : Lower bound of the truncated distribution.
%
% - ub    : Upper bound of the truncated distribution.
%
% - ms    : Mean shift parameter.
%
% Output:
% 
% - f : The CDF at the evaluated points, same size as x.
%
% See also:
% nb_distribution.meanshift_pdf, nb_distribution.meanshift_rand,
% nb_distribution.meanshift_icdf
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    func = str2func(['nb_distribution.' dist '_cdf']);
    if isempty(lb) && isempty(ub)   
        f = func(x-ms,param{:});
    elseif isempty(lb)
        
        x         = x - ms;
        ub        = ub - ms;
        d         = func(ub,param{:});
        f         = func(x,param{:})./d;
        toHigh    = x > ub;
        f(toHigh) = 1;
        
    elseif isempty(ub)
        
        x        = x - ms;
        lb       = lb - ms;
        d        = 1 - func(lb,param{:});
        f        = (func(x,param{:}) - func(lb,param{:}))./d;
        toLow    = x <= lb;
        f(toLow) = 0;
        
    else
        
        x         = x - ms;
        ub        = ub - ms;
        lb        = lb - ms;
        d         = func(ub,param{:}) - func(lb,param{:});
        f         = (func(x,param{:}) - func(lb,param{:}))./d;
        toLow     = x <= lb;
        f(toLow)  = 0;
        toHigh    = x > ub;
        f(toHigh) = 1;
        
    end
    
end
