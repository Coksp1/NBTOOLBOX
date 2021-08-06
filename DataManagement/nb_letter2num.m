function num = nb_letter2num(letter)
% Syntax:
%
% num = nb_letter2num(letter)
%
% Description:
%
% Convert from 'A', 'AA', 'AZZ' to a number. The letter must be in the set
% ['A','Z'].
% 
% Input:
% 
% - letter : A one line char with length from 1-3.
% 
% Output:
% 
% - num    : A number representing the letter combination.
%
% Examples:
%
% num1 = nb_letter2num('A')
% num2 = nb_letter2num('Z')
% num3 = nb_letter2num('AA')
% num4 = nb_letter2num('AZ')
% num5 = nb_letter2num('BA')
% num6 = nb_letter2num('AZZ')
% num7 = nb_letter2num('BAA')
% num8 = nb_letter2num('ZZZ')
%
% See also:
% nb_num2letter
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if ~nb_isOneLineChar(letter)
        error([mfilename ':: The letter input must be a one line char.'])
    end
    letter = upper(letter);
    len    = length(letter);
    if len == 0
        error([mfilename ':: The letter input cannot be empty.'])
    elseif len > 3
       error([mfilename ':: The letter input cannot have length > 3.'])
    end
    incr             = [676,26,1];
    n                = zeros(1,3);
    n(end-len+1:end) = letter - 64; 
    num              = sum(n.*incr);

end
