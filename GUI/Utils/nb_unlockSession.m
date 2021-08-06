function nb_unlockSession(file)
% Syntax:
%
% nb_unlockSession(file)
%
% Description:
%
% Unlock DAG session file. 
% 
% Input:
% 
% - file : Name of DAG session file to unlock. With or without full path.
%          As a string (1xN char).
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    l = load(file);
    l.userName = '';
    save(file,'-struct','l');

end
