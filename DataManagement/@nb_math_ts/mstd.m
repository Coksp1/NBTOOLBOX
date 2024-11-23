function obj = mstd(obj,backward,forward,flag)
% Syntax:
%
% obj = mstd(obj,backward,forward)
% obj = mstd(obj,backward,forward,flag)
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
% - flag     : If set to true the periods that does not have enough
%              observations forward or backward should be set to nan.
%              Default is true.
%
% Output:
% 
% - obj      : An nb_math_ts object storing the calculated moving 
%              std
% 
% Examples: 
% 
% data   = nb_math_ts(rand(50,2)*3,'2011Q1');
% mstd10 = mstd(data,9,0); % (10 quarters moving std)
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 4
        flag = true;
    end

    isNaN = isnan(obj.data);
    if any(isNaN(:))
        obj.data = nb_nanmstd(obj.data,backward,forward,flag);
    else
        obj.data = nb_mstd(obj.data,backward,forward,flag);
    end
    
end
