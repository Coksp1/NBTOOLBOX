function message = nb_createErrorMessage(message,Err)
% Syntax:
%
% message = nb_createErrorMessage(help,Err)
%
% Description:
%
% Append your own error message with the MATLAB error stack tree
% 
% Input:
% 
% - message : Your own message as a char. May consist of multiple rows.
%
% - Err     : A MException object. Caught by catch!
% 
% Output:
% 
% - message : The full message added the MATLAB error stack tree.
%
% Examples:
%
% See also:
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if isempty(message)
        message = getReport(Err,'extended','hyperLinks','off');
    else
        message = [message,nb_newLine(2), getReport(Err,'extended','hyperLinks','off')];
    end
    
end
