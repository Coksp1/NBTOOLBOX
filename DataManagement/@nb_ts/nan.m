function obj = nan(start,obs,vars,pages,sorted)
% Syntax:
%
% obj = nb_ts.nan()
% obj = nb_ts.nan(start,obs,vars,pages,sorted)
%
% Description:
%
% Create an nb_ts object with all data set to nan.
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
% - sorted : true or false. Default is true.
%
% Output:
% 
% - obj   : An nb_ts object. 
%
% Examples:
%
% obj = nb_ts.nan('1',10,{'Var1','Var2'});
% obj = nb_ts.nan('2012Q1',2,2);
% obj = nb_ts.nan('2012Q1',2,2,10);
%
% See also:
% nb_ts
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 5
        sorted = true;
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
    
    % Create random nb_cs object
    obj = nb_ts(nan(obs,svars,pages),'',start,vars,sorted);

end
