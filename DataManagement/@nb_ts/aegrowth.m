function obj = aegrowth(obj,percent)
% Syntax:
%
% obj = aegrowth(obj,percent)
%
% Description:
%
% Calculate exact annual growth, using the formula: 
% (x(t) - x(t-lag))/x(t-lag) of all the timeseries of the nb_ts 
% object.
% 
% Input:
% 
% - obj     : An object of class nb_ts
%
% - percent : Either 1 (in percent) or 0 (not in percent). 0 is 
%             default.
% 
% Output:
% 
% - obj  : An nb_ts object with the calculated timeseries stored.
% 
% Examples:
%
% obj = aegrowth(obj);
% obj = aegrowth(obj,1);
% 
% See also:
% agrowth, egrowth, growth
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if obj.frequency == 365
        error([mfilename ':: Unsupported function for daily data'])
    end
    
    lag      = obj.frequency;
    din      = obj.data;
    [~,c,p]  = size(din); 
    dout     = cat(1,nan(lag,c,p),(din(lag + 1:end,:,:)-din(1:end - lag,:,:))./din(1:end - lag,:,:));
    
    if percent
        dout = dout*100;
    end
    
    obj.data = dout;
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@aegrowth,{percent});
        
    end

end
