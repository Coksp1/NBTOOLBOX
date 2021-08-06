function x = truncated_icdf(p,dist,param,lb,ub)
% Syntax:
%
% x = nb_distribution.truncated_icdf(p,dist,param,lb,ub)
%
% Description:
%
% Returns the inverse of the cdf at p of the truncated distribution
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
% Output:
% 
% - x : A double with the quantile at each element of p of the truncated
%       distribution
%
% See also:
% nb_distribution.truncated_cdf, nb_distribution.truncated_rand, 
% nb_distribution.truncated_pdf
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    func    = str2func(['nb_distribution.' dist '_icdf']);
    funcCDF = str2func(['nb_distribution.' dist '_cdf']);
    if isempty(ub)
        Flb = funcCDF(lb,param{:});
        d   = 1 - funcCDF(lb,param{:});
        xt  = p*d  + Flb;
    elseif isempty(lb)
        d  = funcCDF(ub,param{:});
        xt = p*d;
    else
        Flb = funcCDF(lb,param{:});
        d   = funcCDF(ub,param{:}) - Flb;
        xt  = p*d + Flb;
    end
    x = func(xt,param{:});
    
end
