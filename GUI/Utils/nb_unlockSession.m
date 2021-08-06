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
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    l = load(file);
    l.userName = '';
    save(file,'-struct','l');

end
