function xout = nb_subAvg(xin,k,w)
% Syntax:
%
% xout = nb_subAvg(xin,k)
% xout = nb_subAvg(xin,k,w)
%
% Description:
%
% - Will for the last k periods (including the present) calculate the
%   cumulative (weighted) sum and then divide by the amount of periods, 
%   which gives you the (weighted) average over those periods.
%
% Input: 
%
% - xin : A double of size r*s*p.
%
% - k   : Lets you choose what frequency you want to calulate the
%         cumulative average over. As a double. E.g. 4 if you have
%         quarterly data and want to calculate the average over the
%         last 4 quarters.
% 
% - w   : Weights applies to the k periods to sum over. Default is 
%         equal weights! As a double vector with length k.
%
% Output:
% 
% - xout : A double. 
%
% Examples:
%
% xin  = rand(10,1);
% xout = nb_subAvg(xin,4)
% xout = nb_subAvg(xin,4,[0.1,0.4,0.4,0.1])
%
% See also: 
% nb_subSum
%
% Written by Tobias Ingebrigtsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 3
        w = [];
    end
    if isempty(w)
        w = ones(1,k);
    else
        if ~isnumeric(w)
            error('The input w must be a double vector.')
        end
        w = w(:);
        if size(w,1) ~= k
            error('The number of elements of w must match k!')
        end
    end

    [r,s,p] = size(xin);
    xout    = zeros(r,s,p);
    for j=1:k
        xout = xout + w(j)*[nan(j-1,s,p);xin(1:end-j+1,:,:)];
    end
    xout = xout/k;

end
