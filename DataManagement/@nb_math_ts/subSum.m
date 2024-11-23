function obj = subSum(obj,k,w)
% Syntax:
%
% obj = subSum(obj,k)
% obj = subSum(obj,k,w)
%
% Description:
%
% Calculates the cumulative sum over the last k periods (including the
% present period).
% 
% Input:
% 
% - obj : An object of class nb_math_ts.
%
% - k   : Lets you choose what frequency you want to calulate the
%         cumulative sum over. As a double. E.g. 4 if you have
%         quarterly data and want to calculate the cumulative sum over the
%         last 4 quarters.
% 
% - w   : Weights applies to the k periods to sum over. Default is 
%         equal weights! As a double vector with length k.
%
% Output:
% 
% - obj : An object of class nb_math_ts.
%
%
% Examples:
%
% obj = subSum(obj,k)
%
% See also:
%
% nb_math_ts.subAvg, nb_math_ts.subProd
% 
% Written by Tobias Ingebrigtsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 3
        w = [];
    end

    obj.data = nb_subSum(obj.data,k,w);
      
end
