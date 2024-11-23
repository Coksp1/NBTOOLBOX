function y = nb_doFilter(x,b,a,cut)
% Syntax:
%
% y = nb_doFilter(x,b,a)
% y = nb_doFilter(x,b,a,cut)
%
% Description:
%
% Filters the data in vector x with the filter described by vectors a and
% b to create the filtered data y. The filter is a "Direct Form II 
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
% - obj : A double with size T x N x P.
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
% - obj : A double with size T x N x P. 
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 4
        cut = true;
    end

    M = max(length(a)-1,length(b)-1);
    y = x;
    for ii = 1:size(x,2)
        for jj = 1:size(x,3)

            d = x(:,ii,jj);
            i = ~isnan(d);
            s = find(i,1,'first');
            if isempty(s)
                % All missing, in this case just return nan
                continue;
            end
            e = find(i,1,'last');
            if ~any(i(s:e))
                % Missing in-sample, in this case just return nan
                y(:,ii,jj) = nan;
                continue;
            end
            y(s:e,ii,jj) = filter(b,a,d(s:e));

            if cut
                y(s:s+M-1,ii,jj) = nan;
            end

        end
    end

end
