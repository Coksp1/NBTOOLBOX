function s = charSlide(obj)
% Syntax:
%
% s = charSlide(obj)
%
% Description:
%
% Get the slide number represented by the nb_numbering object as a
% string on the format: 'Slide 1.1' or 'Slide 1.1a' in english and
% 'Lysbilde 1.1' or 'Lysbilde 1.1a' på norsk.
%
% Input:
%
% - obj : An object of class nb_numbering
% 
% Output:
%
% - s   : A string on the format 'Slide 1.1' or 'Slide 1.1a' in 
%         english and 'Lysbilde 1.1' or 'Lysbilde 1.1a' på norsk. 
%
% Examples:
%
% See also:
% char
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if obj.bigLetter
        numb = char(64 + obj.number);
    else
        numb = int2str(obj.number);
    end

    if ~isempty(obj.chapter)
        if strcmpi(obj.language,'english') || strcmpi(obj.language,'engelsk')
            s = ['Slide ' int2str(obj.chapter) '.' numb];
        else
            s = ['Lysbilde ' int2str(obj.chapter) '.' numb];
        end
    else    
         if strcmpi(obj.language,'english') || strcmpi(obj.language,'engelsk')
            s = ['Slide ' numb];
        else
            s = ['Lysbilde ' numb];
        end
    end
    
    if obj.counter >= 1
        s = [s lower(char(obj.letter))];
    end
    
end
