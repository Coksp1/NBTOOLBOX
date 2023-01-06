function nb_copyfile(from,to,format)
% Syntax:
%
% nb_copyfile(from,to,format)
% 
% Description:
% 
% Copy a file to a new location
% 
% Input:
% 
% - from      : The full path name of the copied file. As a string.
% 
% - to        : The full path name of the new location of the file. 
%               (Including the file name). As a string.
% 
% - format    : > 'text'    : A normal file is copied.
%
%               > otherwise : A .mat file is copied.
% 
% Examples:
% 
% nb_copyfile('C:\docs\test.txt', 'C:\newfile.txt', 'text')
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen


    if nargin < 3
        format = 'text';
    end

    % Need to get the file name (without the path and extension)
    %----------------------------------------------------------------------
    index1 = strfind(from,'\');
    if isempty(index1) 
        index1 = 0;
    end
    
    index2 = strfind(from,'.');
    if isempty(index2) 
        error([mfilename ':: The input ''orgFile'' must include a extension.'])
    end
    
    if exist(from,'file') == 0
        error([mfilename ':: Did not find the file in the file path ' from ])
    end
    
    orgFileName = from(1,index1(end) + 1:index2(1) - 1);
    orgPath     = from(1,1:index1(end) - 1);
    orgExt      = from(1,index2(1):end);
    
    if ~isempty(orgPath)
        parent = cd(orgPath);
    end
    
    % Open the original file for reading
    %----------------------------------------------------------------------
    if strcmpi(format,'text')
        
        try
            oldFile = fopen([orgFileName orgExt]);
        catch Err

            if ~isempty(orgPath)
                cd(parent);
            end

            rethrow(Err);

        end
        
    else
        
        oldFile = load([orgFileName orgExt]);
        
    end
        
    
    if ~isempty(orgPath)
        cd(parent);
    end
    
    index1 = strfind(to,'\');
    if isempty(index1) 
        index1 = 0;
    end
    
    index2 = strfind(to,'.');
    if isempty(index2) 
        error([mfilename ':: The input ''newFile'' must include a extension.'])
    end
    
    newFileName = to(1,index1(end) + 1:index2(1) - 1);
    newPath     = to(1,1:index1(end) - 1);
    newExt      = to(1,index2(1):end);

    if ~isempty(newPath)
        
        if exist(newPath,'dir') == 0
            mkdir(newPath);
        end
        parent = cd(newPath);
        
    end
    
    % Open a new file for writing
    %----------------------------------------------------------------------
    if strcmpi(format,'text')
         
        try
            newFile = fopen([newFileName newExt],'w+');    
        catch Err

            if ~isempty(newPath)
                cd(parent);
            end
            if ~isempty(oldFile)
                fclose(oldFile);
                fclose('all');
            end

            rethrow(Err)

        end
        
        while ~feof(oldFile)
        
            line    = fgetl(oldFile);
            line    = strrep(line,'\','\\');
            line    = strrep(line,'%','%%');
            fprintf(newFile,[line '\r\n']);

        end

        fclose(newFile);
        fclose(oldFile);
        fclose('all');
        
    else
        
        save(newFileName,'-struct','oldFile')
        
    end

    
    if ~isempty(newPath)
        cd(parent);
    end


end
