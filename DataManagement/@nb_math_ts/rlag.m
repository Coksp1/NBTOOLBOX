function obj = rlag(obj,lags,periods)
% Syntax:
%
% obj = rlag(obj,lags)
% obj = rlag(obj,lags,periods)
%
% Description:
%
% Roll a pattern in the data forward with a given lag. 
% 
% Input:
% 
% - obj      : An object of class nb_math_ts
%
% - lags     : The number of lags
% 
% - periods  : The extrapolated periods. The end date of the object will
%              be the current end date plus these number of periods. Be
%              aware that trailing nan values in the data will be filled in
%              for even if periods == 0, which is the default.
%  
% Output:
% 
% - obj      : An object of class nb_math_ts
%
% Examples:
%
% obj1 = nb_math_ts([1,1;2,2;3,3;4,4;1,nan],'2012Q1');
% obj2 = rlag(obj1,4,0);
% obj2 = rlag(obj1,4,3);
%
% See also:
% nb_rlag
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 3
        periods = 0;
    end

    if obj.dim3 > 1
        error('This method is not supported for an object with more than 1 page.')
    end
    
    d = [obj.data;nan(periods,obj.dim2)];
    for ii = 1:obj.dim2
    
        isFinite     = isfinite(obj.data(:,ii));
        first        = find(isFinite,1,'last');
        last         = (obj.endDate - obj.startDate) + 1;
        per          = last - first + periods;
        if per ~= 0
            xin                    = obj.data(first-lags+1:first,ii);
            xout                   = nb_rlag(xin,lags,lags+per);
            d(first-lags+1:end,ii) = xout;
        end
        
    end
    
    obj.data    = d;
    obj.endDate = obj.startDate + (size(d,1) - 1); 

end
