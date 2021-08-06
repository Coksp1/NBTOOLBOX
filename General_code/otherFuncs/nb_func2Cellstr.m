function str = nb_func2Cellstr(func)
% Syntax:
%
% str = nb_func2Cellstr(func)
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if ~ischar(func)
        str = func2str(func);
    else
        str = func;
    end
    str      = strsplit(str,';')';
    ind1     = strfind(str{1},'[');
    str{1}   = str{1}(ind1+1:end);
    str{end} = str{end}(1:end-1);

end
