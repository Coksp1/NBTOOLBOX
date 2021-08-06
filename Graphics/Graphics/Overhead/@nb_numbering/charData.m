function s = charData(obj)
% Syntax:
%
% s = charData(obj)
%
% Description:
%
% Get the graph number represented by the nb_numbering object as a
% string on the format: 'Data 1.1' or 'Data 1.1a'.
%
% Input:
%
% - obj : An object of class nb_numbering
% 
% Output:
%
% - s   : A string on the format 'Data 1.1' or 'Data 1.1a'. 
%
% Examples:
%
% See also:
% char
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if obj.bigLetter
        numb = char(64 + obj.number);
    else
        numb = int2str(obj.number);
    end

    if ~isempty(obj.chapter)
        s = ['Data' int2str(obj.chapter) '.' numb];
    else
        s = ['Data' numb];
    end
    
    if obj.counter >= 1
        s = [s lower(char(obj.letter))];
    end

end
