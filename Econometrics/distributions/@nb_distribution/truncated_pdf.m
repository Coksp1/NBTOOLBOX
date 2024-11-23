function f = truncated_pdf(x,dist,param,lb,ub)
% Syntax:
%
% f = nb_distribution.truncated_pdf(x,dist,param,lb,ub)
%
% Description:
%
% PDF of the truncated distribution
% 
% Input:
% 
% - x     : The point to evaluate the pdf, as a double
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
% - f : The PDF at the evaluated points, same size as x.
%
% See also:
% nb_distribution.truncated_cdf, nb_distribution.truncated_rand, 
% nb_distribution.truncated_icdf
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    func    = str2func(['nb_distribution.' dist '_pdf']);
    funcCDF = str2func(['nb_distribution.' dist '_cdf']);
    if ~isempty(lb) && ~isempty(ub)
        d        = funcCDF(ub,param{:}) - funcCDF(lb,param{:});
        f        = func(x,param{:})./d;
        good     = x > lb & x <= ub;
        f(~good) = 0;
    elseif ~isempty(lb) && isempty(ub)
        d        = 1 - funcCDF(lb,param{:});
        f        = func(x,param{:})./d;
        good     = x > lb;
        f(~good) = 0;
    else
        d        = funcCDF(ub,param{:});
        f        = func(x,param{:})./d;
        good     = x <= ub;
        f(~good) = 0;
    end
    
end
