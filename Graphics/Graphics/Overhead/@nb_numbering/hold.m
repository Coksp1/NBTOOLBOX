function hold(obj,text)
% Syntax:
%
% hold(obj,text)
%
% Description:
%
% Hold the normal graph numbering an start numbering with letters
% instead. I.e Figur 1.1a, Figur 1.1b,....
%
% Input:
%
% - obj  : An object of class nb_numbering
%
% - text : Either 'on' or 'off'
% 
% Output:
%
% - obj : The input object of class nb_numbering set to on hold.
%
% Examples:
%
% See also:
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if strcmp(text,'on')
        obj.counter   = 1;
        obj.letter    = 65;
    else
        obj.counter   = 0;
    end

end
