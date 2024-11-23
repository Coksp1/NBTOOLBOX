function f = truncated_cdf(x,dist,param,lb,ub)
% Syntax:
%
% f = nb_distribution.truncated_cdf(x,dist,param,lb,ub)
%
% Description:
%
% CDF of the truncated distribution
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
% Output:
% 
% - f : The CDF at the evaluated points, same size as x.
%
% See also:
% nb_distribution.truncated_pdf, nb_distribution.truncated_rand,
% nb_distribution.truncated_icdf
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    func = str2func(['nb_distribution.' dist '_cdf']);
    if isempty(lb)
        
        d         = func(ub,param{:});
        f         = func(x,param{:})./d;
        toHigh    = x > ub;
        f(toHigh) = 1;
        
    elseif isempty(ub)
        
        d        = 1 - func(lb,param{:});
        f        = (func(x,param{:}) - func(lb,param{:}))./d;
        toLow    = x <= lb;
        f(toLow) = 0;
        
    else
        
        d         = func(ub,param{:}) - func(lb,param{:});
        f         = (func(x,param{:}) - func(lb,param{:}))./d;
        toLow     = x <= lb;
        f(toLow)  = 0;
        toHigh    = x > ub;
        f(toHigh) = 1;
        
    end
    
end
