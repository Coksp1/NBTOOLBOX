function nb_error(message,Err)
% Syntax:
%
% nb_error(message,Err)
%
% Description:
%
% Add extra message to a Matlab MException object.
% 
% Input:
% 
% - message : A string
%
% - Err     : Matlab MException object
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    report = getReport(Err);
    try
        error('nb_error:ThisIsAGeneralError','%s',[sprintf([message,'\n\nOriginal error message: \n']),report]);
    catch Err2
        newErr = struct('identifier','nb_error:ThisIsAGeneralError',...
                    'message', [sprintf([message,'\n\nOriginal error message: \n']), report],...
                    'stack',   Err2.stack(2));
        error(newErr);
    end
    
%     try
%         error(message)
%     catch addedErr
%         Err = addCause(Err,addedErr);
%     end
%     rethrow(Err)

end
