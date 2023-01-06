function s = char(obj,table)
% Syntax:
%
% s = char(obj,table)
%
% Description:
%
% Get the graph number represented by the nb_numbering object as a
% string on the format: 
%
% > 'norwegian' : 'Figur 1.1' or 'Figur 1.1a'.
%
% > 'english'   : 'Chart 1.1' or 'Chart 1.1a'.
%
% Input:
%
% - obj   : An object of class nb_numbering
%
% - table : Indicate if a table is numbered.
% 
% Output:
%
% - s   : A string on the format 'Figur 1.1', 'Figur 1.1a', 
%         'Chart 1.1', 'Chart 1.1a'. 
%
% See also:
% charData
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 2
        table = false;
    end
    
    if table
        
        if strcmpi(obj.language,'english') || strcmpi(obj.language,'engelsk')
            string = 'Table ';
        else
            string = 'Tabell ';
        end
        
    else
        
        if strcmpi(obj.language,'english') || strcmpi(obj.language,'engelsk')
            string = 'Chart ';
        else
            string = 'Figur ';
        end
        
    end
    
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
