function obj = nan(start,obs,vars,pages)
% Syntax:
%
% obj = nb_math_ts.nan(start,obs,vars,pages)
%
% Description:
%
% Create an nb_math_ts object with all data set to nan.
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
% Output:
% 
% - obj   : An nb_math_ts object. 
%
% Examples:
%
% obj = nb_math_ts.nan('2012Q1',2,2);
% obj = nb_math_ts.nan('2012Q1',2,2,10);
%
% See also:
% nb_math_ts
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

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
    
    if ~nb_isScalarInteger(vars)
        error([mfilename ':: The vars input must be a scalar integer.'])
    end
    
    % Generate random data
    data = nan(obs, vars, pages);
    
    % Return nb_ts object
    obj = nb_math_ts(data,start);
end
