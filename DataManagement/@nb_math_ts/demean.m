function obj = demean(obj,dim)
% Syntax:
%
% obj = demean(data,dim)
%
% Description:
%
% - Demeans data along the dimension you choose.
%
% Input:
% 
% - obj  : A nb_math_ts object
%
% - dim  : A double corresponding to the dimension you want to take the
%          average over. Default is 1.
%
% Output:
% 
% - obj  : A nb_math_ts object.
%
% See also:
% sgrowth, subAvg. 
%
% Written by Tobias Ingebrigtsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 2
        dim = [];
    end
    obj.data = nb_demean(obj.data,dim);
    
end
