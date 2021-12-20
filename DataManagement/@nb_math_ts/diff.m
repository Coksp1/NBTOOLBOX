function obj = diff(obj,lag,skipNaN)
% Syntax:
%
% obj = diff(obj)
% obj = diff(obj,lag)
% obj = diff(obj,lag,skipNaN)
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
% - lag     : The number of lags in the diff formula, 
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

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 3
        skipNaN = 0;
        if nargin < 2
            lag = 1; 
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
                dataT(~isNaN,jj,ii) = [nan(lag,1,1);diff(dataTT(~isNaN),lag)];
                
            end
            
        end
        obj.data = dataT;
        
    else
    
        obj.data = [nan(lag,obj.dim2,obj.dim3);diff(obj.data,lag,1)];
        
    end

end
