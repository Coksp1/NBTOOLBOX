function deleted = nb_syncFolders(folder1,folder2)
% Syntax:
%
% nb_syncFolders(folder1,folder2)
%
% Description:
%
% Delete the folders and files in folder folder2, which are not in the 
% folder folder1
% 
% Input:
% 
% - folder1 : A string with the path of the folder.
%
% - folder2 : A string with the path of the folder.
%
% Output:
%
% - deleted : A cellstr with the deleted files and folders
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if exist(folder1,'file') == 2
        error([mfilename ':: The folder1 does not exist; ' folder1])
    end
    
    if exist(folder2,'file') == 2
        error([mfilename ':: The folder2 does not exist; ' folder2])
    end

    d1     = dir(folder1);
    ind1   = {d1.name};
    d2     = dir(folder2);
    ind2   = {d2.name};
    svn    = strcmpi('.svn',ind2);
    ind2   = ind2(~svn);
    indR   = ~ismember(ind2,ind1);
    isDir  = [d2.isdir];
    isDir  = isDir(~svn);
    remove = ind2(indR & ~isDir);
    remDir = ind2(indR & isDir);
    conDir = ind2(~indR & isDir);
    indDot = strcmpi('.',conDir) |  strcmpi('..',conDir);
    conDir = conDir(~indDot);
    
    % Delete files
    remove = strcat(folder2,'\',remove);
    if ~isempty(remove)
        delete(remove{:})
    end
    
    % Delete folders
    remDir = strcat(folder2,'\',remDir);
    for ii = 1:length(remDir)
        rmdir(remDir{ii},'s')
    end
    
    % Sync subfolders as well
    deletedSub = {};
    for ii = 1:length(conDir)
        deletedSub = nb_syncFolders([folder1,'\' conDir{ii}],[folder2,'\' conDir{ii}]);
    end

    deleted = [remove,remDir,deletedSub];
    
end
