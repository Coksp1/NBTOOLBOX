function [variable,err] = nb_loadFromUserpath(filename)
% Syntax:
%
% variable       = nb_loadFromUserpath(filename)
% [variable,err] = nb_loadFromUserpath(filename)
%
% Description:
%
% Save a variable to the subfolder nb_GUI of the userpath folder.
% 
% Input:
% 
% - filename : Name of the created file.
% 
% Output:
%
% - variable : The variable load from the file.
%
% - err      : If nargout > 1 this give an non-empty char if an error
%              occured.
%
% See also:
% nb_save2Userpath
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    err        = '';
    variable   = [];
    pathToLoad = nb_userpath('gui');
    if exist(pathToLoad,'dir') ~= 7
        err = ['The file ' filename ' does not exist as the folder ' pathToLoad ' does not exist.'];
        if nargout == 1
            error(err);
        end
    end  
    try
        variable = nb_load([pathToLoad '\' filename],1);
    catch Err
        err = Err.message;
        if nargout == 1
            error(err);
        end
    end  

end
