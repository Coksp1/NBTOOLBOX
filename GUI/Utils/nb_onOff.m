function value = nb_onOff(condition)
% Syntax:
%
% value = nb_onOff(condition)
%
% Description:
%
% Append a new line to a char. If message is empty, a new line is not made!
% 
% Input:
% 
% - condition : Logical
% 
% Output:
% 
% - value     : 'on' if condition is true and 'off' otherwise.
%
% Written by Henrik Halvorsen Hortemo

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    value = nb_conditional(condition, 'on', 'off');
    
end
