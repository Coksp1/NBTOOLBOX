function obj = doFilter(obj,b,a,cut)
% Syntax:
%
% obj = doFilter(obj,b,a,cut)
%
% Description:
%
% Filters the data in data with the filter described by vectors a and
% b to create the filtered data. The filter is a "Direct Form II 
% Transposed" implementation of the standard difference equation:
%
% a(1)*y(n) = b(1)*x(n) + b(2)*x(n-1) + ... + b(nb+1)*x(n-nb)
%           - a(2)*y(n-1) - ... - a(na+1)*y(n-na)
%
% If a(1) is not equal to 1, FILTER normalizes the filter
% coefficients by a(1).
%
% Caution: Supports leading and trailing nan values, but non in-sample
%          nan values.
% 
% Input:
% 
% - obj : A nb_math_ts object with size T x N x P.
%
% - b   : A double vector.
%
% - a   : A double vector.
% 
% - cut : true or false. If true the output series M first values are set
%         to nan, where M is max(length(a)-1,length(b)-1). Default is true.
% 
% Output:
% 
% - obj : A nb_math_ts object with size T x N x P. 
%
% See also:
%
% dist = nb_distribution('type','normal');
% obj  = nb_math_ts.rand('2000',10,2,2,dist)
%
% MA process with 2 terms;
% simMA = doFilter(obj,[0.2,0.1],1)
%
% AR process with lambda == 0.9;
% simAR = doFilter(obj,1,[1,-0.9])
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 4
        cut = true;
    end

    obj.data = nb_doFilter(obj.data,b,a,cut);

end
