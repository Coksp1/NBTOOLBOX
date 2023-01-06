function err = lineError(nbFileLine,filename)
% Syntax:
%
% err = nb_dsge.lineError(nbFileLine,filename)
%
% Description:
%
% No doc provided.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin == 2
        err = ['Line ' int2str(nbFileLine) ' of file ' filename];
    else
        if size(nbFileLine,2) == 3
            err = ['Line ' int2str(nbFileLine{2}) ' of file ' nbFileLine{3}];
        else
            err = '';
        end
    end

end
