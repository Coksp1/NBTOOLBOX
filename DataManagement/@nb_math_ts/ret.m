function obj = ret(obj,nlag,skipNaN)
% Syntax:
%
% obj = ret(obj)
% obj = ret(obj,nlag)
% obj = ret(obj,nlag,skipNaN)
%
% Description:
%
% Calculate return, using the formula: x(t)/x(t-lag) of all the
% timeseries of the nb_math_ts object.
% 
% Input:
% 
% - obj     : An object of class nb_math_ts
% 
% - nlag    : The number of lags in the return formula, 
%             default is 1.
%
% - skipNaN : - 1 : Skip nan while using the ret operator. (E.g.
%                   when dealing with working days.)
%
%             - 0 : Do not skip nan values. Default.
%
% Output:
% 
% - obj  : An nb_math_ts object with the calculated timeseries 
%          stored.
% 
% Examples:
%
% obj = ret(obj);
% obj = ret(obj,4);
%
% See also:
% nb_math_ts
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 3
        skipNaN = 0;
        if nargin < 2
            nlag = 1; 
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
                dataTTLag           = lag(dataTT(~isNaN),nlag);
                dataT(~isNaN,jj,ii) = dataTT(~isNaN)./dataTTLag;
                
            end
            
        end
        obj.data = dataT;
        
    else
    
        dataT    = obj.data;
        dataTLag = lag(dataT,nlag);
        obj.data = dataT./dataTLag;
        
    end
    
end
