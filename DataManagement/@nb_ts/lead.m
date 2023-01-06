function obj = lead(obj,periods,varargin)
% Syntax:
%
% obj = lead(obj,periods,varargin)
%
% Description:
%
% Lead the data of the object. The input periods decides for how 
% many periods.
% 
% Input:
% 
% - obj     : An object of class nb_ts
% 
% - periods : Lead the data with this number of periods. Default is
%             1 period.
% 
% Optional input:
%
% - 'cut'   : true (cut sample to fit old sample length) or false (append 
%             new observations at the start). Default is true. 
%
% Output:
% 
% - obj     : An nb_ts object where the data leaded by number of 
%             periods given by the input periods.
% 
% Examples:
%
% obj = lead(obj,1);
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 2
        periods = 1;
    end

    cut     = nb_parseOneOptional('cut',true,varargin{:});
    newData = obj.data(1 + periods:end,:,:);
    newData = [newData ; nan(periods,obj.numberOfVariables,obj.numberOfDatasets)];
    if cut
        if isRealTime(obj)
            newData(isnan(obj.data)) = nan;
        end
        obj.data = newData;
    else
        obj.data     = [obj.data(1:periods,:,:);newData];
        obj.startDate = obj.startDate - periods;
    end
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@lead,{periods});
        
    end

end
