function ret = isTimeseries(obj) 
% Syntax:
%
% ret = isTimeseries(obj)
%
% Description:
%
% Test if a nb_dataSource object is a time series object. 
% 
% Input:
% 
% - obj : An object of class nb_dataSource
% 
% Output:
% 
% - ret : true if object is of class nb_ts, otherwise false.
%         
% Written by Kenneth S. Paulsen 

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    ret = isa(obj,'nb_ts');

end
