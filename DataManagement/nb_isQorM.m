function [ind,frequency] = nb_isQorM(date)
% Syntax:
%
% [ind,frequency] = nb_isQorM(date)
%
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    ind1      = ~isempty(strfind(date,'Q'));
    ind2      = ~isempty(strfind(date,'K'));
    ind       = ind1 || ind2;
    frequency = 4;
    if not(ind)
        ind       = ~isempty(strfind(date,'M'));
        frequency = 12;
    end

end
