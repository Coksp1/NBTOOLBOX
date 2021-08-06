function f = meanshift_pdf(x,dist,param,lb,ub,ms)
% Syntax:
%
% f = nb_distribution.meanshift_pdf(x,dist,param,lb,ub,ms)
%
% Description:
%
% PDF of the mean shifted possibly truncated distribution.
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
% - ms    : Mean shift parameter.
%
% Output:
% 
% - f : The PDF at the evaluated points, same size as x.
%
% See also:
% nb_distribution.meanshift_cdf, nb_distribution.meanshift_rand, 
% nb_distribution.meanshift_icdf
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Do the mean shift
    x = x - ms;
    if ~isempty(lb) || ~isempty(ub)
        lb = lb - ms;
        ub = ub - ms;
    end
    
    func    = str2func(['nb_distribution.' dist '_pdf']);
    funcCDF = str2func(['nb_distribution.' dist '_cdf']);
    if ~isempty(lb) && ~isempty(ub)
        d        = funcCDF(ub,param{:}) - funcCDF(lb,param{:});
        f        = func(x,param{:})./d;
        good     = x > lb & x <= ub;
        f(~good) = 0;
    elseif ~isempty(lb)
        d        = 1 - funcCDF(lb,param{:});
        f        = func(x,param{:})./d;
        good     = x > lb;
        f(~good) = 0;
    elseif ~isempty(ub)
        d        = funcCDF(ub,param{:});
        f        = func(x,param{:})./d;
        good     = x <= ub;
        f(~good) = 0;
    else
        f = func(x,param{:});
    end
    
end
