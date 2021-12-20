function obj = mstd(obj,backward,forward)
% Syntax:
%
% obj = mstd(obj,backward,forward)
%
% Description:
%
% Taking moving standard deviation of all the timeseries of the 
% nb_math_ts object
% 
% Input:
% 
% - obj      : An object of class nb_math_ts
% 
% - backward : Number of periods backward in time to calculate the 
%              moving std
% 
% - forward  : Number of periods forward in time to calculate the 
%              moving std
% 
% Output:
% 
% - obj      : An nb_math_ts object storing the calculated moving 
%              std
% 
% Examples: 
% 
% data   = nb_math_ts(rand(50,2)*3,'2011Q1');
% mstd10 = mstd(data,9,0); % (10 year moving std)
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    d = obj.data;
    n = nan(size(d));
    for ii = 1 + backward: size(d,1) - forward
        
        n(ii,:,:) = nanstd(d(ii - backward:ii + forward),0);
        
    end
    
    obj.data = n;
    
end
