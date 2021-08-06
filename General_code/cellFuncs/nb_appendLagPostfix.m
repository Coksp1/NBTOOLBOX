function newNames = nb_appendLagPostfix(c,nLags)
% Syntax:
%
% newNames = nb_appendLagPostfix(c,nLags)
%
% Description:
% 
% Append '_lagX' postfix to a cellstr.
%
% Input:
% 
% - nLags : A cell. E.g. {1,2,4,8}
% 
% - c     : A cellstr.
%
% Output: 
% 
% - xout : A cellstr
%
% See also:
% nb_cellstrlag
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    newNames = {};
    for mm = 1:length(nLags)

        exoLags = nLags{mm};
        for jj = 1:size(exoLags,2)

            added = c{mm};
            ind   = regexp(added,'_lag[0-9]*$');
            extra = 0;
            if ~isempty(ind)

                extra = str2double(added(ind+4:end));
                if isnan(extra)
                    extra = 0;
                end
                added = added(1:ind-1);

            end
            if exoLags(jj) + extra > 0 
                added    = [added ,'_lag' int2str(exoLags(jj) + extra)]; %#ok<AGROW>
            end
            newNames = [newNames,added]; %#ok<AGROW>

        end

    end

end
