function writeTex(obj,filename,varargin)
% Syntax:
%
% writeTex(obj,filename)
% writeTex(obj,filename,'inputName',inputValue,...)
%
% Description:
%
% Writes the object data to a LaTeX table saved to a .tex file.
%
% If the object consists of more pages (datasets) more tables will
% be created.
%
% Input:
% 
% - obj      : An object of class nb_data
%
% - filename : The name of the saved .tex file. With or without the
%              extension.
%
% Optional input:
%
% - 'caption'       : Adds a caption to the table. Must be a 
%                     string.
%
% - 'combine'       : If the nb_data object consist of two or three
%                     pages (datasets) this option can be used to
%                     combine all the data i one table. Either 1
%                     or 0. Default is 0.
%
% - 'colors'        : Set it to 0 if the colored rows of the table
%                     should be turned off. Default is 1.
%
% - 'firstRowColor' : A string with the color, e.g. 'blue','white',
%                     'black','blue!20!white'. Default is 'nbblue'.
%
% - 'fontSize'      : Sets the font size of the table. Either:
%
%                     'Huge', 'huge', 'LARGE', 'Large', 'large',
%                     'normalsize' (default), 'small', 
%                     'footnotesize', 'scriptsize','tiny'.
%
%                     Caution : This option is case sensitive.  
%
% - 'justification' : Sets the justification of the caption of the
%                     table. Must be a string. 
%
%                     Either 'justified','centering' (default),
%                     'raggedright', 'RaggedRight', 'raggedleft'.
%
%                     Caution : This option is case sensitive.
%
% - language        : Either 'english' (default) or 'norwegian' 
%                     ('norsk').
%
% - lookUpMatrix    : 
%
%    Sets how the given mnemonics (variable names) should map to 
%    different languages. Must be cell array on the form:
%
%    {'mnemonics1','englishDescription1','norwegianDescription1';
%     'mnemonics2','englishDescription2','norwegianDescription2'};
%
%    Or a .m file name, as a string. The .m file must include
%    (and only include) what follows:
%
%    lookUpMatrix = {
%
%     'mnemonics1','englishDescription1','norwegianDescription1';
%     'mnemonics2','englishDescription2','norwegianDescription2'};
%
%    Be aware : Each of the given description can be multi-lined
%               char, which will result in multi-line text of the
%               table.
%
% - 'orientation'   : The orientation of the table. Either:
%
%                     > 'horizontal' : The obs as columns
%                     > 'vertical'   : The types as columns
%
% - 'precision'     : Sets the precision of the numbers in the 
%                     table. Must be a string. Default is '%3.2f'.
%                     I.e. two decimals.
%
% - 'rotation'      : The rotation of the table in LaTeX. Either:
%
%                     > 'sidewaystable' : A sideways table
%                     > 'landscape'     : Rotate the whole page
%                     > ''              : No rotation
%
% - 'rowColor1'     : Color of every second row of the table 
%                     starting  from the second row. Same options 
%                     as was the case for the 'firstRowColor' 
%                     option.
%
% - 'rowColor2'     : Color of every second row of the table 
%                     starting  from the third row. Same options 
%                     as was the case for the 'firstRowColor' 
%                     option.
%
% - 'rowColor3'     : Color of every third row of the table 
%                     starting from the fourth row. Only an option
%                     in combination with the 'combine' input set 
%                     to 1 and that the nb_ts object has 3 pages. 
%                     Same options as was the case for the  
%                     'firstRowColor' option.
%
% Output:
%
% A saved .tex file with the LaTeX table
%
% Examples:
%
% obj = nb_ts(rand(10,3),'',1,{'Var1','Var2','Var3'});
% obj.writeTex('test')
%
% See also:
% nb_data
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Test the filename input
    %--------------------------------------------------------------
    if ischar(filename)
        
        ind = strfind(filename,'.');
        if isempty(ind)
            filename = [filename,'.tex'];
        else
            if ~strcmpi(filename(ind+1:end),'tex')
                error([mfilename ':: The file extension must be .tex, but is .' filename(ind+1:end)])
            end
        end
        
    else
        error([mfilename ':: The input filename must be a string.'])
    end

    % Get LaTeX code of table
    %--------------------------------------------------------------
    code = obj.getCode(1,varargin{:});
    
    % Write the LaTeX code to the .tex file
    %--------------------------------------------------------------
    writer = fopen(filename,'w+');
    for ii = 1:size(code,1)

        fprintf(writer,strtrim(code(ii,:)));
        
    end
    
    fclose(writer);
    fclose('all');
    
end
