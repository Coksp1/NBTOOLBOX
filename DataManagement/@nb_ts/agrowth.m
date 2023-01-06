function obj = agrowth(obj,percent)
% Syntax:
%
% obj = agrowth(obj,percent)
%
% Description:
%
% Calculate approx annual growth, using the formula: 
% log(x(t))-log(x(t-lag) of all the timeseries of the nb_ts object.
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
% obj = agrowth(obj);
% obj = agrowth(obj,1);
% 
% See also:
% aegrowth, egrowth, growth
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if obj.frequency == 365
        error([mfilename ':: Unsupported function for daily data'])
    end
    
    lag      = obj.frequency;
    din      = obj.data;
    din      = log(din);
    [~,c,p]  = size(din); 
    dout     = cat(1,nan(lag,c,p),din(lag+1:end,:,:)-din(1:end-lag,:,:));
    
    if percent
        dout = dout*100;
    end
    
    obj.data = dout;
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@agrowth,{percent});
        
    end
    
end
