function x = meanshift_icdf(p,dist,param,lb,ub,ms)
% Syntax:
%
% x = nb_distribution.meanshift_icdf(p,dist,param,lb,ub,ms)
%
% Description:
%
% Returns the inverse of the CDF of the mean shifted possibly truncated 
% distribution.
% 
% Input:
% 
% - p     : A vector of probabilities
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
% - x : A double with the quantile at each element of p of the truncated
%       distribution
%
% See also:
% nb_distribution.meanshift_cdf, nb_distribution.meanshift_rand, 
% nb_distribution.meanshift_pdf
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if isempty(ub) && isempty(lb)
        func = str2func(['nb_distribution.' dist '_icdf']);
        x    = func(p,param{:}) + ms;
        return
    end

    func    = str2func(['nb_distribution.' dist '_icdf']);
    funcCDF = str2func(['nb_distribution.' dist '_cdf']);
    if isempty(ub)
        lb  = lb - ms;
        Flb = funcCDF(lb,param{:});
        d   = 1 - funcCDF(lb,param{:});
        xt  = p*d  + Flb;
    elseif isempty(lb)
        ub  = ub - ms;
        d  = funcCDF(ub,param{:});
        xt = p*d;
    else
        lb  = lb - ms;
        ub  = ub - ms;
        Flb = funcCDF(lb,param{:});
        d   = funcCDF(ub,param{:}) - Flb;
        xt  = p*d + Flb;
    end
    x = func(xt,param{:}) + ms;
    
end
