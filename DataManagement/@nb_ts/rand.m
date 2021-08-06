function obj = rand(start,obs,vars,pages,dist,sorted)
% Syntax:
%
% obj = nb_ts.rand(start,obs,vars,pages,dist,sorted)
%
% Description:
%
% Create an nb_ts object with all data set to random number.
% 
% Input:
% 
% - start  : The start date of the created nb_ts object.
%
% - obs    : The number of observation of the created nb_ts object.
% 
% - vars   : Either a cellstr with the variables of the nb_ts
%            object, or a scalar with the number of variables of the
%            nb_ts object.
%
% - pages  : Number of pages of the nb_ts object.
%
% - dist   : A nb_distribution object to draw from.
%
% - sorted : true or false. Default is true.
%
% Output:
% 
% - obj   : An nb_ts object. 
%
% Examples:
%
% obj = nb_ts.rand('1',10,{'Var1','Var2'});
% obj = nb_ts.rand('2012Q1',2,2);
% obj = nb_ts.rand('2012Q1',2,2,10,nb_distribution('type','normal'));
%
% See also:
% nb_ts
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 6
        sorted = true;
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
    end
    
    if iscellstr(vars)
        svars = size(vars,2);
    elseif isscalar(vars) && isnumeric(vars)
        svars = vars;
        vars  = strcat('Var',strtrim(cellstr(int2str([1:svars]')))); %#ok<NBRAK>    
    else
        error([mfilename ':: The vars input must either be a double or a cellstr'])
    end
    
    % Generate random data
    data = dist.random(obs, svars*pages);
    data = reshape(data, obs, svars, pages);
    
    % Return nb_ts object
    obj = nb_ts(data,'',start,vars,sorted);
end
