function obj = uncumdiff(obj,initialValues)
% Syntax:
%
% obj = uncumdiff(obj,initialValues)
%
% Description:
%
% Construct indicies based on initial values and timeseries wich 
% represent the series cumulative growth. Inverse cumulative diff, i.e. 
% the inverse method of the cumdiff method of the nb_math_ts class
% 
% Input:
% 
% - obj               : An object of class nb_math_ts
% 
% - InitialValues     : A nb_math_ts object with a bigger window than obj,
%                       or a scalar or a double with the initial 
%                       values of the indicies. Must be of the same 
%                       size as the number of variables of the 
%                       nb_math_ts object. If not provided 100 is 
%                       default.
% 
% Output:
% 
% - Output            : An nb_math_ts object with the indicies.
% 
% Examples:
%
% obj = uncumdiff(obj);
% obj = uncumdiff(obj,100);
% obj = uncumdiff(obj,[78,89]);
% 
% See also
% nb_math_ts.cumdiff, nb_math_ts.diff
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 2
        initialValues = [];
    end

    [d0,t] = checkInverseMethodsInput(obj,initialValues,[],false);
    if t == 1  
        obj.data = nb_uncumdiff(obj.data,d0,true);
    else
        d                   = obj.data(t:end,:,:);
        d                   = nb_uncumdiff(d,d0,true);
        obj.data(1:t-1,:,:) = initialValues.data(1:t-1,:,:);
        obj.data(t:end,:,:) = d;
    end

end
