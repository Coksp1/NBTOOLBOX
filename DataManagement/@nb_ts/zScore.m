function obj = zScore(obj,dimension,shift,varargin)
% Syntax:
%
% obj = zScore(obj,outputType,dimension,varargin)
%
% Description:
%
% Calculate the Z-score of each timeseries. The result 
% will be an object of class nb_ts where all the non-nan 
% values of all the timeseries are beeing set to their Z-score.
% 
% The output can also be set to be a double or a nb_cs object 
% consisting of the Z-score values of the data.
% 
% Input:
% 
% - obj        : An object of class nb_ts
%
% - dimension  : The dimension to calcualate the zScore over. 
% 
% - shift      : Number of the last observations not to include in the 
%                calculations of the mean and standard deviation.
% 
% Optional input:
%
% - 'notHandleNaN' : Give this to not handle nan values.
% 
% Examples:
% 
% nb_tsObj = zScore(obj); 
%
% Written by Atle Loneland

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 3
        shift = 0;
        if nargin < 2
            dimension = 1;
        end
    end
    
    if (shift < 0 )
        error([mfilename ':: The input parameter shift must be positive.'])
    end
    
    notHandleNaN = nb_parseOneOptionalSingle('notHandleNaN',false,true,varargin{:});
       
    if (notHandleNaN) 
        n = (obj.data-mean(obj.data(1:end-shift,:,:),dimension))./std(obj.data(1:end-shift,:,:),0,dimension);
    else
        n = (obj.data-mean(obj.data(1:end-shift,:,:),dimension,'omitnan'))./std(obj.data(1:end-shift,:,:),0,dimension,'omitnan');
    end    
    
    obj.data = n;
    
    if obj.isUpdateable() 
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@zScore,[{dimension,shift},varargin]);
    end
    
end
