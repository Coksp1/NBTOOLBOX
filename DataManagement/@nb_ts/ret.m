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
% timeseries of the nb_ts object.
% 
% Input:
% 
% - obj     : An object of class nb_ts
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
% - obj  : An nb_ts object with the calculated timeseries stored.
% 
% Examples:
%
% obj = ret(obj);
% obj = ret(obj,4);
%
% See also:
% nb_ts
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 3
        skipNaN = 0;
        if nargin < 2
            nlag = 1; 
        end
    end

    if skipNaN
    
        numPages = obj.numberOfDatasets;
        numVars  = obj.numberOfVariables;
        dataT    = obj.data;
        for ii = 1:numPages
            
            for jj = 1:numVars
                
                dataTT              = dataT(:,jj,ii);
                isNaN               = isnan(dataTT);
                dataTTLag           = nb_lag(dataTT(~isNaN),nlag);
                dataT(~isNaN,jj,ii) = dataTT(~isNaN)./dataTTLag;
                
            end
            
        end
        obj.data = dataT;
        
    else
    
        dataT    = obj.data;
        dataTLag = nb_lag(dataT,nlag);
        obj.data = dataT./dataTLag;
        
    end
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@ret,{nlag,skipNaN});
        
    end

end
