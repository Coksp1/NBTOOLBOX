function message = nb_addMessage(message,newMessage)
% Syntax:
%
% message = nb_addMessage(message,newMessage)
%
% Description:
%
% Append a new line to a char. If message is empty, a new line is not made!
% 
% Input:
% 
% - message    : A char. May be empty
%
% - newMessage : A char.
% 
% Output:
% 
% - message    : A char.
%
% Written by Henrik Halvorsen Hortemo

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if isempty(message)
        message = newMessage;
    else
        message = char(message,newMessage);
    end
    
end
