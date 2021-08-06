function plus(obj,num)
% Syntax:
%
% plus(obj)
%
% Description:
%
% Increment the nb_numbering object.
%
% Input:
%
% - obj : An object of class nb_numbering
%
% - num : Number of graphs ahead. As a scalar. Default is 1.
% 
% Output:
%
% - obj : The input object incremented with one number (or letter)
%
% Examples:
%
% See also:
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 2
        num = 1;
    end

    if obj.counter > 1

        obj.letter  = obj.letter + num;
        obj.counter = obj.counter + num;

    elseif obj.counter == 1

        obj.number  = obj.number + num;
        obj.counter = obj.counter + num;

    else

        obj.letter = 65;
        obj.number = obj.number + num;

    end

end
