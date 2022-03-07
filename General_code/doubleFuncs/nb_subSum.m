function xout = nb_subSum(xin,k)
% Syntax:
%
%  xout = nb_subSum(xin,k)
%
% Description:
%
% - Calculates the cumulative sum over the last k periods (including the
%   present period).
% 
% Input:
% 
% - xin     : A double of size r*s*p
%
% - k       : Lets you choose what frequency you want to calulate the
%             cumulative sum over. As a double. E.g. 4 if you have
%             quarterly data and want to calculate the sum over the
%             last 4 quarters.
%
% Output:
% 
% - xout     : A double.
%
% Examples:
%
% - xout = nb_subSum(xin,k)
%
% See also:
% nb_subAvg
%
% Written by Tobias Ingebrigtsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    [r,s,p] = size(xin);
    xout    = zeros(r,s,p);
    for j=1:k
        xout = xout + [nan(j-1,s,p);xin(1:end-j+1,:,:)];
    end
    
end
