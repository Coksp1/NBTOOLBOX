function nb_loadWithName(fileName,givenName,workSpace)
% Syntax:
%
% nb_loadWithName(fileName,givenName,workSpace)
%
% Description:
%
% Load one (first) MATLAB variable from a .mat file with the same name as 
% the filename or the givenName.
% 
% Input:
% 
% - fileName  : Name of the .mat file to load the MATLAB variable from.
% 
% - givenName : If you want to assign the loaded MATLAB variable with
%               another name then the fileName input this option may be
%               used.
%
% - workSpace : Which workspace to load the variable into. Either 'base'
%               (default) or 'caller'.
%
% Output:
% 
% - A MATLAB variable stored in the base workspace with the wanted name.
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 3
        workSpace = 'base';
    end

    [~,varName] = fileparts(fileName);
    l           = load(fileName);
    fields      = fieldnames(l);
    if length(fields) > 1
        warning('nb_loadWithName:MoreThanOneField','The loaded file stores mor than one field, only loads the first.')
    end
    loaded      = l.(fields{1});
    if nargin == 1
        if ~isvarname(varName)
            error([mfilename ':: The provided name of the file is not a valid name of a variable.'])
        end
        assignin(workSpace,varName,loaded);
    else
        if ~isvarname(givenName)
            error([mfilename ':: The given name is not a valid name of a variable.'])
        end
        assignin(workSpace,givenName,loaded);
    end
    
end
