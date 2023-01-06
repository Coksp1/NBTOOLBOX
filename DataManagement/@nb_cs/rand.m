function obj = rand(types,vars,pages,dist)
% Syntax:
%
% obj = nb_cs.rand(types,vars)
% obj = nb_cs.rand(types,vars,pages)
%
% Description:
%
% Create a random nb_cs object
% 
% Input:
% 
% - types : Either a cellstr with the types of the random nb_cs
%           object, or a scalar with the number of types of the
%           random nb_cs object.
% 
% - vars  : Either a cellstr with the variables of the random nb_cs
%           object, or a scalar with the number of variables of the
%           random nb_cs object.
%
% - pages : Number of pages of the random nb_cs object.
%
% - dist  : A nb_distribution object to draw from.
%
% Output:
% 
% - obj   : An nb_cs object. 
%
% Examples:
%
% obj = nb_cs.rand({'Type','Type2'},{'Var1','Var2'});
% obj = nb_cs.rand(2,2);
% obj = nb_cs.rand(2,2,10,nb_distribution('type','normal'));
%
% See also:
% nb_cs
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 4
        dist = nb_distribution('type', 'uniform');
        if nargin < 3
            pages = 1;
            if nargin < 2
                vars = 1;
                if nargin < 1
                    types = 1;
                end
            end
        end
    end
    
    if isscalar(vars)
        
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
    
    if isnumeric(types)
        
        stypes = types;
        types = cell(1,stypes); 
        for ii = 1:stypes
            types{ii} = ['Type',int2str(ii)];
        end
        
    elseif iscellstr(types)
        stypes = size(types,2);
    else
        error([mfilename ':: The vars input must either be a double or a cellstr'])
    end
    
    % Generate random data
    data = dist.random(stypes, svars*pages);
    data = reshape(data, stypes, svars, pages);
    
    % Return random nb_cs object
    obj = nb_cs(data,'',types,vars);

end
