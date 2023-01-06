function obj = diff(obj,lags,skipNaN)
% Syntax:
%
% obj = diff(obj)
% obj = diff(obj,lags)
% obj = diff(obj,lags,skipNaN)
%
% Description:
%
% Calculate diff, using the formula: x(t)-x(t-lag) of all the
% timeseries of the nb_math_ts object.
% 
% Input:
% 
% - obj     : An object of class nb_math_ts
% 
% - lags    : The number of lags in the diff formula, 
%             default is 1.
%
% - skipNaN : - 1 : Skip nan while using the diff operator. (E.g.
%                   when dealing with working days.)
%
%             - 0 : Do not skip nan values. Default.
%
% Output:
% 
% - obj  : An nb_math_ts object with the calculated timeseries stored.
% 
% Examples:
%
% obj = diff(obj);
% obj = diff(obj,4);
%
% See also:
% nb_math_ts
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 3
        skipNaN = 0;
        if nargin < 2
            lags = 1; 
        end
    end

    if skipNaN
    
        numPages = obj.dim3;
        numVars  = obj.dim2;
        dataT    = obj.data;
        for ii = 1:numPages
            
            for jj = 1:numVars
                
                dataTT              = dataT(:,jj,ii);
                isNaN               = isnan(dataTT);
                y                   = dataTT(~isNaN);
                dataT(~isNaN,jj,ii) = y - lag(y,lags);
                
            end
            
        end
        obj.data = dataT;
        
    else
        obj.data = obj.data - lag(obj.data,lags);      
    end

end
