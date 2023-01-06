function niceNumber = findClosestNiceNumber(number,scaleNumber,up)
% Syntax:
%
% niceNumber = nb_plotHandle.findClosestNiceNumber(number,...
%                             scaleNumber,up)
%
% Description:
%
% A static method of the nb_plotHandle class.
%
% Find first "nice" number, used for deciding the y-axis limits 
% whenfindAxisMethod == 3 is used.
%
% Input:
%
% - number      : The given number to find a "nice" number close 
%                 to.
%
% - scaleNumber : The scal factor used. I.e. the precision of the
%                 algorithm.
%
% - up          : 1 if rounding up, 0 if rounding down.
% 
% Output:
%
% - niceNumber  : The number which is "nice" and close to the input
%                 number.
%
% Examples:
%
% See also:
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if scaleNumber > 1000

        scaleFactor = 1/1000;

    elseif scaleNumber > 100

        scaleFactor = 1/100;

    elseif scaleNumber > 10

        scaleFactor = 1/10;

    elseif scaleNumber > 1

        scaleFactor = 1;

    elseif scaleNumber > 0.1

        scaleFactor = 10;

    elseif scaleNumber > 0.01

        scaleFactor = 100;

    elseif scaleNumber > 0.001

        scaleFactor = 1000;

    else
        scaleFactor = 1;
    end

    if up

        niceNumber = ceil(number*scaleFactor)/scaleFactor;

    else

        niceNumber = floor(number*scaleFactor)/scaleFactor;

    end

end
