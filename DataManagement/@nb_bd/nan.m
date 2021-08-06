function obj = nan(start,obs,vars,pages,sorted)
% Syntax:
%
% obj = nb_bd.nan()
% obj = nb_bd.nan(start,obs,vars,pages,sorted)
%
% Description:
%
% Create an nb_bd object with all data set to nan. Notice, this might not
% make much sense as the raison d'être for this class is to strip NaNs from
% the data. The resulting object will be an empty nb_bd object, but with
% locations and indicator preserved in the object.
% 
% Input:
% 
% - start  : The start date of the created nb_bd object.
%
% - obs    : The number of observations of the created nb_bd object.
% 
% - vars   : Either a cellstr with the variables of the nb_bd
%            object, or a scalar with the number of variables of the
%            nb_bd object.
%
% - pages  : Number of pages of the nb_bd object.
%
% - sorted : true or false. Default is true.
%
% Output:
% 
% - obj   : An nb_bd object. 
%
% Examples:
%
% obj = nb_bd.nan();
% obj = nb_bd.nan('2012Q1',10,{'Var1','Var2','Var3'});
% obj = nb_bd.nan('2012Q1',2,2,10);
%
% See also:
% nb_bd, nb_bd.zeros, nb_bd.ones
%
% Written by Per Bjarne Bye

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
    
    % Get locations and indicator given the data
    [locations,indicator,~] = nb_bd.getLocInd(nan(obs,svars,pages));
    
    % Create nb_bd object with NaNs
    obj = nb_bd(nan(obs,svars,pages),'',start,vars,locations,indicator,sorted);

end
