function ci = confidenceInterval(distribution, alpha)
% Syntax:
%
% ci = confidenceInterval(distribution, alpha)
%
% Description:
%
% Calculate confidence/probability interval
% 
% Input:
% 
% - distribution : A nb_distribution object
%
% - alpha        : Significance value. Default is 0.05;
% 
% Output:
% 
% - ci           : A nobj x 2 double storing the confidence/probability 
%                  intervals.
%
% See also:
% nb_distribution.icdf
%
% Written by Henrik Halvorsen Hortemo

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 2
        alpha = 0.05;
    end
    ci = distribution.icdf([alpha/2, 1 - alpha/2]);
    if numel(distribution) > 1
        ci = ci';
    end
          
end
