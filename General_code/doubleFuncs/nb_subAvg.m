function xout = nb_subAvg(xin,k)
% Syntax:
%
% xout = nb_subAvg(xin,k)
%
% Description:
%
% - Will for the last k periods (including the present) calculate the
%   cumulative sum and then divide by the amount of periods, which gives
%   you the average over those periods.
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
% Output:
% 
% - xout : A double. 
%
% See also: 
% nb_subSum
%
% Written by Tobias Ingebrigtsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    [r,s,p] = size(xin);
    xout    = zeros(r,s,p);
    for j=1:k
        xout = xout + [nan(j-1,s,p);xin(1:end-j+1,:,:)];
    end
    xout = xout/k;

end
