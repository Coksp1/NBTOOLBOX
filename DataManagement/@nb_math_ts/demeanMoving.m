function obj = demeanMoving(obj,backward,forward)
% Syntax:
%
% obj = demeanMoving(data,backward)
% obj = demeanMoving(data,backward,forward)
%
% Description:
%
% - Demeans data with a moving average process.
%
% Input:
% 
% - obj      : A nb_math_ts object
%
% - backward : Number of periods backward in time to calculate the 
%              moving average
% 
% - forward  : Number of periods forward in time to calculate the 
%              moving average
% 
% Output:
% 
% - obj      : A nb_math_ts object.
%
% See also:
% nb_math_ts.demean
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 3
        forward = 0;
    end
    obj = obj./mavg(obj,backward,forward);
    
end
