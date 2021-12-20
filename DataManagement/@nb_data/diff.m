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
% series of the nb_data object.
% 
% Input:
% 
% - obj     : An object of class nb_data
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
% - obj  : An nb_data object with the calculated series stored.
% 
% Examples:
%
% obj = diff(obj);
% obj = diff(obj,4);
%
% See also:
% nb_data
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
    
        numPages = obj.numberOfDatasets;
        numVars  = obj.numberOfVariables;
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
    
        obj.data = [nan(lag,obj.numberOfVariables,obj.numberOfDatasets);diff(obj.data,lag,1)];
        
    end
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@diff,{lag,skipNaN});
        
    end

end
