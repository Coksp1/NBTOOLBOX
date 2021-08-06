function err = lineError(nbFileLine,filename)
% Syntax:
%
% err = nb_dsge.lineError(nbFileLine,filename)
%
% Description:
%
% No doc provided.
%
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

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
