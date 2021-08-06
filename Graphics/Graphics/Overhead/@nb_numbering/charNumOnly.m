function s = charNumOnly(obj)
% Syntax:
%
% s = charOnly(obj)
%
% Description:
%
% Get the graph number represented by the nb_numbering object as a
% string on the format: '1.1' or '1.1a'.
%
% Input:
%
% - obj   : An object of class nb_numbering
% 
% Output:
%
% - s   : A string on the format '1.1' or '1.1a'.
%
% See also:
% char, charData, figNumAsCell
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    string = '';
    
    if obj.bigLetter
        numb = char(64 + obj.number);
    else
        numb = int2str(obj.number);
    end
    
    if ~isempty(obj.chapter)
        s = [string, int2str(obj.chapter), '.', numb];
    else
        s = [string, numb];
    end
    
    if obj.counter >= 1
        s = [s, lower(char(obj.letter))];
    end

end
