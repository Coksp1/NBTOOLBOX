function [obj,trendObj] = detrend(obj,method)
% Syntax:
%
% [obj,trendObj] = detrend(obj,method)
%
% Description:
%
% Detrending nb_data object.
% 
% Input:
% 
% - obj    : As an nb_data object.
% 
% - method : Either {'linear'} or 'mean'.
%
% Output:
% 
% - obj    : As an nb_data object with the detrended data.
%
% Examples:
% 
% obj = detrend(obj,'linear');
%
% See also:
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 2
        method = 'linear';
    end
    
    switch lower(method)
        
        case 'linear'
    
            % Create a nobs*(nvar*npage)*1 matrix 
            dim1 = obj.numberOfObservations;
            dim2 = obj.numberOfVariables*obj.numberOfDatasets;
            dim3 = 1;
            dat  = reshape(obj.data,dim1,dim2,dim3);

            % Estimate the linear trend
            trendDummy = 1:obj.numberOfObservations;
            constant   = 1;
            beta       = nb_ols(dat,trendDummy',constant);
            const      = repmat(beta(2,:,:),dim1,1);
            beta       = repmat(beta(1,:,:),dim1,1);
            trendDummy = repmat(trendDummy',1,dim2);
            trend      = trendDummy.*beta + const;
            gap        = dat - trend;
            
            % Reshape the matrix back again
            trendObj      = obj;
            obj.data      = reshape(gap,dim1,obj.numberOfVariables,obj.numberOfDatasets);
            trendObj.data = reshape(trend,dim1,obj.numberOfVariables,obj.numberOfDatasets);
            
        case 'mean'
            
            trendObj      = obj;
            mData         = repmat(mean(obj.data,1),[obj.numberOfObservations,1,1]);
            obj.data      = obj.data - mData;
            trendObj.data = mData;
            
        otherwise
            
            error([mfilename ':: Unsupported detrending method ' method '.'])
            
    end
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@detrend,{method});
        
    end
    
end
