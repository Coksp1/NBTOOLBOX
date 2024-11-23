function dyn_ts_DB = todyn_ts(obj)
% Syntax:
%
% dyn_ts_DB = todyn_ts(obj)
%
% Description:
%
% Transform from an nb_ts object to an dyn_ts object
% 
% Input: 
% 
% - obj       : An object of class nb_ts
%   
% Output:
% 
% - dyn_ts_DB : An object of class dyn_ts
%               
% Examples:
% 
% dyn_ts_DB = obj.todyn_ts();
% 
% Written by Kenneth S. Paulsen       

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if obj.frequency > 12
        error([mfilename ':: dyn_ts class doesn''t support the frequency ' int2str(obj.frequency) '.'])
    end

    try
        dyn_ts_DB = dyn_ts(obj.startDate.toString(), obj.data, char(obj.variables));
    catch 
        error([mfilename ':: Could not transform to an dyn_ts object. Did not find the code for the dyn_ts class.'])
    end

end
