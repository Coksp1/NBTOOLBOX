function s = nb_breakChar(s,numChar)
% Syntax:
%
% s = nb_breakChar(s,numChar)
%
% Description:
%
% Break char so that size(s,2) <= numChar
% 
% Input:
% 
% - s      : A char.
%
%- numChar : An integer > 0.
% 
% Output:
% 
% - s      : A char.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if isempty(numChar)
        return
    end
    if isempty(s)
        return
    end

    s    = cellstr(s);
    spl  = regexp(s, '\s', 'split');
    spl  = [spl{:}];
    s    = spl(1);
    l    = size(s{1},2);
    line = 1;
    for ii = 2:length(spl)
        lt = size(spl{ii},2);
        if lt + l + 1 > numChar
            s{line+1} = spl{ii};
            line      = line + 1;
            l         = lt;
        else
            s{line} = [s{line},' ',spl{ii}];
            l       = l + lt + 1;
        end
    end
    s = char(s);
    
end
