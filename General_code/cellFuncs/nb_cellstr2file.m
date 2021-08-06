function nb_cellstr2file(string,filename,breakLine)
% Syntax:
%
% nb_cellstr2file(string,filename)
% nb_cellstr2file(string,filename,breakLine)
%
% Description:
%
% Write a cellstr to a file.
% 
% Input:
% 
% - string    : A cellstr or char array.
%
% - filename  : The name of the saved file. If the extension is not
%               provided the defualt is '.m'. 
%
%               Can also be a file identifier.
% 
% - breakLine : true || false. Add '\r\n' at the end of each line or not.
%               Default is true.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 3
        breakLine = true;
    end
    
    if ischar(string)
        string = cellstr(string);
    end

    % Test the filename input
    %--------------------------------------------------------------
    if ischar(filename)  
        if ~nb_contains(filename,'.')
            filename = [filename,'.m'];
        end
        writer  = fopen(filename,'w+');
        doClose = true; 
    else
        writer  = filename;
        doClose = false;
    end

    % Write the LaTeX code to the .tex file
    %--------------------------------------------------------------
    if breakLine
        string = strcat(string,'\r\n');
    end
    for ii = 1:length(string)
        fprintf(writer,string{ii});
    end
    
    if doClose 
        fclose(writer);
        fclose('all');
    end
    
end
