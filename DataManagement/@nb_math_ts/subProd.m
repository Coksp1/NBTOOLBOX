function obj = subProd(obj,k,w)
% Syntax:
%
% obj = subProd(obj,k)
% obj = subProd(obj,k,w)
%
% Description:
%
% Calculates the cumulative product over the last k periods (including the
% present period).
% 
% Input:
% 
% - obj : An object of class nb_math_ts.
%
% - k   : Lets you choose what frequency you want to calulate the
%         cumulative product over. As a double. E.g. 4 if you have
%         quarterly data and want to calculate cumulative product over the
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
% obj = subProd(obj,k)
%
% See also:
%
% nb_math_ts.subAvg, nb_math_ts.subSum
% 
% Written by Tobias Ingebrigtsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 3
        w = [];
    end

    obj.data = nb_subProd(obj.data,k,w);
      
end
