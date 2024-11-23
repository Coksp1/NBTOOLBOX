function obj = subAvg(obj,k,w)
% Syntax:
%
% obj = subAvg(obj,k)
% obj = subAvg(obj,k,w)
%
% Description:
%
% Will for the last k periods (including the present) calculate the
% cumulative sum and then divide by the amount of periods, which gives
% you the average over those periods.
%
% Input: 
%
% - obj : An object of class nb_math_ts.
%
% - k   : Lets you choose what frequency you want to calulate the
%         average over. As a double. E.g. 4 if you have quarterly data 
%         and want to calculate the average over the last 4 quarters.
% 
% Output:
% 
% - obj : An nb_math_ts object where the data are the average over 
%         the last k periods.
%
% Examples:
%
% obj = subAvg(obj,k)
%
%
% See also: 
% growth, q2y, pcn, subSum
%
% Written by Tobias Ingebrigtsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 3
        w = [];
    end
    obj.data = nb_subAvg(obj.data,k,w);

end
