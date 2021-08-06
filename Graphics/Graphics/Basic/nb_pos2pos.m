function x = nb_pos2pos(x,oldPos,newPos,oldScale,newScale)
% Syntax:
%
% x = nb_pos2pos(x,oldPos,newPos,oldScale,newScale)
%
% Description:
%
% Convert the value x from the old units to the new units value.
% 
% Input:
% 
% - x        : Old value. As a double.   
%
% - oldPos   : Old positions. As a 1x2 double.
%
% - newPos   : New positions. As a 1x2 double.
% 
% - oldScale : New scale.Either 'normal' or 'log'.
%
% - newScale : Old scale. Either 'normal' or 'log'.
% 
% Output:
% 
% - x 
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 5
        newScale = 'normal';
        if nargin < 4
            oldScale = 'normal';
        end
    end


    if strcmpi(oldScale,'log') && strcmpi(newScale,'log')
        x    = log10(x);
        dold = diff(log10(oldPos));
        dnew = diff(log10(newPos));
        x    = (x - log10(oldPos(1)))*dnew/dold + log10(newPos(1));
        x    = 10.^(x);
    elseif strcmpi(oldScale,'log')
        x    = log10(x);
        dold = diff(log10(oldPos));
        dnew = diff(newPos);
        x    = (x - log10(oldPos(1)))*dnew/dold + newPos(1);
    elseif strcmpi(newScale,'log')
        x = (x - oldPos(1))*(diff(log10(newPos)))/(diff(oldPos)) + log10(newPos(1));
        x = 10.^(x);
    else
        dold = diff(oldPos);
        dnew = diff(newPos);
        x    = (x - oldPos(1))*dnew/dold + newPos(1);
    end

end
