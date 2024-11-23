function obj = adjout(obj,threshold,tFlag,W)
% Syntax:
%
% x = adjout(y,threshold,tFlag,W)
%
% Description:
%
% Outlier replacement using fraction of inverse quantile function. 
% 
% See online appendix "Factor Models and Structural Vector Autoregressions 
% in Macroeconomics" by Stock and Watson (2016). 
%
% Input:
% 
% - y         : A T x N x P nb_math_ts object. May include nan values.
%
% - threshold : Treshold to use for the outliers. Default is 5.
%
% - tFlag     : 0 > Replace with missing value
%               1 > Replace with maximum or minimum value
%               2 > Replace with median value
%               3 > Replace with local median (obs + or - W on each side)
%               4 > Replace with one-sided median (W preceding obs).
%                   Default.
% 
% - W         : The window of the replacement calculations. See the
%               tFlag == 3 or 4 for more. Default is 5.
%
% Output:
% 
% - x         : A T x N x P nb_math_ts object.
%
% See also:
% nb_adjout
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 4
        W = 5;
        if nargin < 3
            tFlag = 4;
            if nargin < 2
                threshold = 5;
            end
        end
    end

    obj.data = nb_adjout(obj.data,threshold,tFlag,W);

end
