function [found,filePath,ext] = nb_validpath(filename,mode)
% Syntax:
%
% [found,filePath,ext] = nb_validpath(filename,mode)
%
% Description:
%
% Identify if the excel file with name filename is a valid excel file.
% 
% Input:
% 
% - filename : Must be a string containing a partial path ending 
%              in a file or directory name. May contain \  or /  
%              or \\. Extension may or may not be included. Tested
%              extensions are '.xls','.xlsx' or '.xlsm'.
%
% - mode     : Set to 'write' to prevent it looking for files on the matlab
%              path to locate the path if no path is given. Default is ''.
% 
% Output:
% 
% - found    : true if found, otherwise false.
%
% - filePath : A string with the full path of the file.
%
% - ext      : The file extension. Either '.xls','.xlsx' or '.xlsm'.
%
% See also:
% nb_xlsread, nb_xlswrite
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 2
        mode = '';
    end

    [path, file, ext] = fileparts(filename);
    if strncmp(path,'\\',2) && ~exist(path,'dir')
        path = [pwd,path(2:end)];
    end
    
    supported = {'.xlsx','.xls','.xlsm','.csv'};
    if isempty(ext)
        found = false;
        for ii = 1:3 
            [filePath,found] = locateFullPath(path,file,supported{ii},mode);
            if found
                break
            end
        end
        if found
            ext = supported{ii};
        else
            % If not found we return the defult extension, which
            % nb_xlswrite need
            filePath = strrep(filePath,'.xlsm','.xlsx');
            ext      = supported{1};
        end
    else
        if ~any(strcmpi(ext,supported))
            error([mfilename ':: Cannot read or write files with extension ' ext])
        end
        [filePath,found] = locateFullPath(path,file,ext,mode);
    end

end

%==========================================================================
function [filePath,found] = locateFullPath(path,file,ext,mode)

    fileWithExt = [file, ext];
    found       = true;
    if isempty(path)
        if strcmp(mode,'write')
            filePath = '';
        else
            filePath = which(fileWithExt);
        end
        if isempty(filePath)
            filePath = fullfile(pwd,fileWithExt);
            found    = fullPathExists(filePath);
        end
    else
        filePath = fullfile(path,fileWithExt);
        found    = fullPathExists(filePath);
    end

end

%==========================================================================
function found = fullPathExists(filePath)

    if exist(filePath,'file') == 2
        found = true;
    else
        found = false;
    end

end
