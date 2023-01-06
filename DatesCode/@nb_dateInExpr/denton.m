function obj = denton(obj,~,k,~,~)
% Syntax:
%
% obj = denton(obj,z,k,type,d)
%
% Description:
%
% The Denton method of transforming a series from low to high frequency.
% 
% See Denton (1971), Adjustment of Monthly or Quarterly Series to Annual  
% Totals: An Approach Based on Quadratic Minimization.
%
% Input:
% 
% - obj  : A nb_dateInExpr object.
%
% - z    : Any
% 
% - k    : The number intra low frequency observations. If you have annual
%          data and want out quarterly data use 4.
%
% - type : Any
%
% - d    : Any
%
% Output:
% 
% - x    : A nb_dateInExpr object.
%
% See also:
% nb_ts.convert, nb_denton
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 3
        k = 4;
    end
     
    if obj.date.frequency == 1
        if ~ismember(k,[4,12])
            error([mfilename ':: The k input can only be 4 or 12 when dealing with yearly data'])
        end
        outFreq = k;
    elseif obj.date.frequency == 4
        if k ~= 3
            error([mfilename ':: The k input can only be 3 when dealing with quarterly data'])
        end
        outFreq = 12;
    else
        error([mfilename ':: The denton method is only supported for yearly or quarterly data.'])
    end
    obj = convert(obj,outFreq,[],'interpolateDate','end');

end
