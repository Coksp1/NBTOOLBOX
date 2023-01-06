function bool = nb_compareCell2TXT(cell,file)
% Syntax:
%
% nb_compareCell2TXT(cell,file)
%
% Description:
%
% Check to see if the cell is equal to the contents of the .TXT file. This 
% function assumes that the .TXT file has be written by nb_cellstr2file. 
% 
% Input:
% 
% - cell      : A cellstr.
%
% - filename  : The name of the saved file with the full path. 
% 
% - breakLine : true || false. Add '\r\n' at the end of each line or not.
%               Default is true.
%
% Ouput:
%
% - bool : Logical. True if contents (and formatting) is equal. False if
%          they are different. Will also return false if file cannot be 
%          opened / found. 
%
% Written by Per Bjarne Bye

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if size(cell,2) > size(cell,1)
        cell = cell';
    end
    
    bool = true;
    
    if ~isfile(file)
        % file does not exist
        bool = false;
        return
    else
        fid = fopen(file);
    end
    
    try
        ctr = 0; % counter for cell index
        while true
           line = fgetl(fid);
           
           % No more lines in file
           if line == -1  
               break
           % More lines in file, but no more in cell array
           elseif ctr > size(cell,1)
               bool = false;
               break
           end
           ctr = ctr + 1;
           if any(line ~= cell{ctr})
               bool = false;
               break
           end
           
        end
        fclose(fid);
    catch
        fclose(fid);
        bool = false;
        return
    end
    
    % Need to check if we got to end of cell array (know we reached eof in
    % while loop)
    if ctr < length(cell)
        bool = false;
    end
    
end
