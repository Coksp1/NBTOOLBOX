function letter = nb_num2letter(num)
% Syntax:
%
% letter = nb_num2letter(num)
%
% Description:
%
% Convert a number to a letter. Must be a postive integer in [1,18278].
% 
% Input:
% 
% - num    : A number representing the letter combination.
% 
% Output:
% 
% - letter : A one line char with length from 1-3.
%
% Examples:
%
% l1 = nb_num2letter(nb_letter2num('A'))
% l2 = nb_num2letter(nb_letter2num('Z'))
% l3 = nb_num2letter(nb_letter2num('AA'))
% l4 = nb_num2letter(nb_letter2num('AZ'))
% l5 = nb_num2letter(nb_letter2num('BA'))
% l6 = nb_num2letter(nb_letter2num('AZZ'))
% l7 = nb_num2letter(nb_letter2num('BAA'))
% l8 = nb_num2letter(nb_letter2num('ZZZ'))
%
% See also:
% nb_num2letter
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if ~nb_isScalarInteger(num)
        error([mfilename ':: The num input must be a scalar integer'])
    elseif num < 1 || num > 18278
        error([mfilename ':: The num input must be a scalar integer in the set [1,18278]'])
    end
    letters    = nan(1,3);
    letters(2) = conditional(rem(num,676), 676);
    letters(3) = conditional(rem(letters(2),26), 26);
    letters(1) = (num - letters(2))/676;
    if all(letters(2:3) == 26) && ~(letters(1) == 0)
        letters(1) = letters(1) - 1;
    else
        letters(2) = (letters(2) - letters(3))/26;
    end
    i          = letters == 0;
    letters(i) = [];
    lets       = 'A':'Z';
    letter     = lets(letters);

end

function value = conditional(value,num)
    value(value==0) = num;
end
