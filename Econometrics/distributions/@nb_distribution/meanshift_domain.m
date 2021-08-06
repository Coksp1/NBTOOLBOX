function domain = meanshift_domain(dist,param,lb,ub,ms)
% Syntax:
%
% f = nb_distribution.meanshift_domain(dist,param,lb,ub,ms)
%
% Description:
%
% Get the domain of the mean shifted possibly truncated distribution.
% 
% Inputs:
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
% - domain : A 1x2 double with the lower and upper limits of the domain.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    func   = str2func(['nb_distribution.' dist '_domain']);
    domain = func(param{:});
    domain = domain + ms;
    if ~isempty(ub)
        domain(1,2) = ub;
    end
    if ~isempty(lb)
        domain(1,1) = lb;
    end
    
end
