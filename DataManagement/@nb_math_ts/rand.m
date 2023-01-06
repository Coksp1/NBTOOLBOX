function obj = rand(start,obs,vars,pages,dist)
% Syntax:
%
% obj = nb_math_ts.rand(start,obs,vars,pages,dist)
%
% Description:
%
% Create an nb_math_ts object with all data set to random number.
% 
% Input:
% 
% - start : The start date of the created nb_math_ts object.
%
% - obs   : The number of observation of the created nb_math_ts object.
% 
% - vars  : A scalar with the number of variables of the nb_math_ts 
%           object.
%
% - pages : Number of pages of the nb_math_ts object.
%
% - dist  : A nb_distribution object to draw from.
%
% Output:
% 
% - obj   : An nb_math_ts object. 
%
% Examples:
%
% obj = nb_math_ts.rand('2012Q1',2,2);
% obj = nb_math_ts.rand('2012Q1',2,2,10,nb_distribution('type','normal'));
%
% See also:
% nb_math_ts
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 5
        dist = nb_distribution('type', 'uniform');
        if nargin < 4
            pages = 1;
            if nargin < 3
                vars = 1;
                if nargin < 2
                    obs = 1;
                    if nargin < 1
                        start = 1;
                    end
                end
            end
        end
    end
    
    if ~nb_isScalarInteger(vars)
        error([mfilename ':: The vars input must be a scalar integer.'])
    end
    
    % Generate random data
    data = dist.random(obs, vars*pages);
    data = reshape(data, obs, vars, pages);
    
    % Return nb_math_ts object
    obj = nb_math_ts(data,start);
end
