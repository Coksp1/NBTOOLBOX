function obj = rand(start,obs,vars,pages,dist,sorted)
% Syntax:
%
% obj = nb_bd.rand(start,obs,vars,pages,dist,sorted)
%
% Description:
%
% Create an nb_bd object with all data set to a random number.
% 
% Input:
% 
% - start  : The start date of the created nb_bd object.
%
% - obs    : The number of observation of the created nb_bd object.
% 
% - vars   : Either a cellstr with the variables of the nb_bd
%            object, or a scalar with the number of variables of the
%            nb_bd object.
%
% - pages  : Number of pages of the nb_bd object.
%
% - dist   : A nb_distribution object to draw from.
%
% - sorted : true or false. Default is true.
%
% Output:
% 
% - obj   : An nb_bd object. 
%
% Examples:
%
% obj = nb_ts.rand('1',10,{'Var1','Var2'});
% obj = nb_ts.rand('2012Q1',2,2);
% obj = nb_ts.rand('2012Q1',2,2,10,nb_distribution('type','normal'));
%
% See also:
% nb_bd
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
    
    % Get locations and indicator given the data
    [locations,indicator,~] = nb_bd.getLocInd(data);
    
    % Return nb_ts object
    obj = nb_bd(data,'',start,vars,locations,indicator,sorted);
end
