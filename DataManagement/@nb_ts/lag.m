function obj = lag(obj,periods,varargin)
% Syntax:
%
% obj = lag(obj,periods,varargin)
%
% Description:
%
% Lag the data of the object. The input periods decides for how 
% many periods.
% 
% Input:
% 
% - obj     : An object of class nb_ts
% 
% - periods : Lag the data with this number of periods. Default is
%             1 period.
%
% Optional input:
%
% - 'cut' : true (cut sample to fit old sample length) or false (append 
%           new observations). Default is true. 
% 
% Output:
% 
% - obj     : An nb_ts object where the data laged by number of 
%             periods given by the input periods.
% 
% Examples:
%
% obj = lag(obj,1);
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 2
        periods = 1;
    end
    cut     = nb_parseOneOptional('cut',true,varargin{:});
    newData = obj.data(1:end-periods,:,:);
    newData = [nan(periods,obj.numberOfVariables,obj.numberOfDatasets); newData];
    if cut
        if isRealTime(obj)
            newData(isnan(obj.data)) = nan;
        end
        obj.data = newData;
    else
        obj.data    = [newData;obj.data(end-periods+1:end,:,:)];
        obj.endDate = obj.endDate + periods;
    end
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@lag,[{periods},varargin]);
        
    end

end
