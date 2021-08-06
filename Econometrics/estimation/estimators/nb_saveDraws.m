function pathToSave = nb_saveDraws(modelName,posterior) 
% Syntax:
%
% pathToSave = nb_saveDraws(modelName,posterior)
%
% Description:
%
% Save posterior draws to file, and return the saved location.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    pathToSave = nb_userpath('gui');
    if exist(pathToSave,'dir') ~= 7
        try
            mkdir(pathToSave)
        catch %#ok<CTCH>
            error('You are standing in a folder you do not have writing access to. Please switch folder!')
        end
    end
    pathToSave = [pathToSave,'\posteriorDraws_' nb_clock('vintagelong') '_' modelName '.mat'];
    save(pathToSave,'posterior');

end
