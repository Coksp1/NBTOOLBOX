function obj = zeros(types,vars,pages)
% Syntax:
%
% obj = nb_cs.zeros()
% obj = nb_cs.zeros(types,vars,pages)
%
% Description:
%
% Create an nb_cs object with all set to 0.
% 
% Input:
% 
% - types : Either a cellstr with the types of the nb_cs
%           object, or a scalar with the number of types of the
%           nb_cs object.
% 
% - vars  : Either a cellstr with the variables of the nb_cs
%           object, or a scalar with the number of variables of the
%           nb_cs object.
%
% - pages : Number of pages of the nb_cs object.
%
% Output:
% 
% - obj   : An nb_cs object. 
%
% Examples:
%
% obj = nb_cs.zeros({'Type','Type2'},{'Var1','Var2'});
% obj = nb_cs.zeros(2,2);
% obj = nb_cs.zeros(2,2,10);
%
% See also:
% nb_cs
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 3
        pages = 1;
        if nargin < 2
            vars = 1;
            if nargin < 1
                types = 1;
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
    
    % Create random nb_cs object
    obj = nb_cs(zeros(stypes,svars,pages),'',types,vars);

end
