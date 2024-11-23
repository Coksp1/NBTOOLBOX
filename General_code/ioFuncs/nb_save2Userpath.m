function nb_save2Userpath(filename,variable) %#ok<INUSD>
% Syntax:
%
% nb_save2Userpath(filename,variable)
%
% Description:
%
% Save a variable to the subfolder nb_GUI of the userpath folder.
% 
% Input:
% 
% - filename : Name of the created file.
% 
% - variable : The variable to save to the file.
%
% See also:
% nb_loadFromUserpath
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    pathToSave = nb_userpath('gui');
    if exist(pathToSave,'dir') ~= 7
        try
            mkdir(pathToSave)
        catch %#ok<CTCH>
            error(['You are standing in a folder you do not have writing access to (' pathToSave '). Please switch user path!'])
        end
    end  
    saveND = [pathToSave '\' filename];
    save(saveND,'variable');
    
end
