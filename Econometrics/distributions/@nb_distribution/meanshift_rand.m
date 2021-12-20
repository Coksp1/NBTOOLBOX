function draws = meanshift_rand(nrow,ncol,dist,param,lb,ub,ms)
% Syntax:
%
% draws = nb_distribution.meanshift_rand(nrow,ncol,dist,param,lb,ub,ms)
%
% Description:
%
% Draw random number from a mean shifted possibly truncated distribution.
% 
% Input:
% 
% - nrow  : Number of rows of the matrix drawn from the student-t 
%           distribution
%
% - ncol  : Number of columns of the matrix drawn from the student-t 
%           distrubution 
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
% - draws : A nrow x ncol matrix of random numbers from the mean shifted 
%           possibly truncated distribution.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if isempty(ub) && isempty(lb)
        func  = str2func(['nb_distribution.' dist '_icdf']);
        draws = func(rand(nrow,ncol)) + ms;
        return
    end

    func    = str2func(['nb_distribution.' dist '_icdf']);
    funcCDF = str2func(['nb_distribution.' dist '_cdf']);
    p       = rand(nrow,ncol);
    if ~isempty(lb) && ~isempty(ub)
        lb  = lb - ms;
        ub  = ub - ms;
        Flb = funcCDF(lb,param{:});
        d   = funcCDF(ub,param{:}) - Flb;
        pt  = p*d + Flb;
    elseif ~isempty(lb)
        lb  = lb - ms;
        Flb = funcCDF(lb,param{:});
        d   = 1 - funcCDF(lb,param{:});
        pt  = p*d  + Flb;
    else
        ub  = ub - ms;
        d  = funcCDF(ub,param{:});
        pt = p*d;
    end
    draws = func(pt,param{:}) + ms;
    
end
