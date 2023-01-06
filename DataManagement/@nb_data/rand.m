function obj = rand(start,obs,vars,pages,dist,sorted)
% Syntax:
%
% obj = nb_data.rand(start,obs,vars,pages,dist,sorted)
%
% Description:
%
% Create an nb_data object with all data set to random number.
% 
% Input:
% 
% - start  : The start obs of the created nb_data object. As an integer
%
% - obs    : The number of observation of the created nb_data object.
% 
% - vars   : Either a cellstr with the variables of the nb_data
%            object, or a scalar with the number of variables of the
%            nb_data object.
%
% - pages  : Number of pages of the nb_data object.
%
% - dist   : A nb_distribution object to draw from.
%
% - sorted : true or false. Default is true.
%
% Output:
% 
% - obj   : An nb_data object. 
%
% Examples:
%
% obj = nb_data.rand('1',10,{'Var1','Var2'});
% obj = nb_data.rand('2012Q1',2,2);
% obj = nb_data.rand('2012Q1',2,2,10,nb_distribution('type', 'normal'));
%
% See also:
% nb_data
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

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

    if nb_isScalarInteger(vars)
        
        svars = vars;
        vars = cell(1,svars); 
        for ii = 1:svars
            vars{ii} = ['Var',int2str(ii)];
        end
        
    elseif iscellstr(vars)
        svars = size(vars,2);
    else
        error([mfilename ':: The vars input must either be a double or a cellstr'])
    end
    
    % Generate random data
    data = dist.random(obs, svars*pages);
    data = reshape(data, obs, svars, pages);
    
    % Return nb_data object
    obj = nb_data(data,'',start,vars,sorted);

end
