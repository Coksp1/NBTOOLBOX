function code = nb_cell2latex(c,varargin)
% Syntax:
%
% code = nb_cell2latex(c,varargin)
%
% Description:
%
% Make latex table of one or more cellstr matrices. Please see the preamble
% for the packages needed to make the latex code work.
% 
% Input:
% 
% - c                   : A cellstr matrix.
%
% Optional input:
%
% - 'caption'           : Adds a caption to the table. Must be a 
%                         string.
%
%                         If the 'tables' input is given this input must be
%                         a cell array with same length as that input. (or
%                         empty)
%
% - 'colors'            : Set it to 0 if the colored rows of the table
%                         should be turned off. Default is 1.
%
% - 'columnOrientation' : A cellstr with size 1 x size(c,2). Eeach
%                         element must be either 'l', 'c', 'r', 'R{Xcm}',
%                         'C{Xcm}' or 'R{Xcm}'.
%
%                         If the 'tables' input is given this input must be
%                         a cell array with same length as that input. (or
%                         empty)                    
%
% - 'firstRowColor'     : A string with the color, e.g. 'blue','white',
%                         'black','blue!20!white'. Default is 'nbblue'.
%
% - 'fontSize'          : Sets the font size of the table. Either:
%
%                         'Huge', 'huge', 'LARGE', 'Large', 'large',
%                         'normalsize' (default), 'small', 
%                         'footnotesize', 'scriptsize','tiny'.
%
%                         Caution : This option is case sensitive.  
%
% - 'justification'     : Sets the justification of the caption of the
%                         table. Must be a string. 
%
%                         Either 'justified','centering' (default),
%                         'raggedright', 'RaggedRight', 'raggedleft'.
%
%                         Caution : This option is case sensitive.
%
% - 'language'          : Either 'english' (default) or 'norwegian' 
%                        ('norsk').
%
% - 'lookUpMatrix'      : 
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
% - 'preamble'      : Give 0 if you don't want to include the 
%                     preamble in the returned output. Default is
%                     to include the preamble, i.e. 1.
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
% - 'lineBreak'     : The maximum number of characters before line break.
%                     The line breaking take place at white spaces. Default
%                     is no line break.
%
% - 'maxRows'       : Maximum number of rows of a table in one page. If
%                     c has more rows than this number the table will start 
%                     over again in the next page. Default is [], i.e.
%                     tables will not be breaked even if not fit to one
%                     page.
%
% - 'space'         : Number of lines between multiple tables. Default
%                     is 5.
%
% - 'tables'        : A cell array with more cellstr matrices to produce
%                     latex tables of. Important for nice breaking of 
%                     many huge cell matrices. The c input will be
%                     discarded in this case.
%
% Output:
% 
% - code : A char with the code.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Parse the optional input
    %--------------------------------------------------------------
    inputs.caption           = '';
    inputs.colors            = 1;
    inputs.columnOrientation = {};
    inputs.firstRowColor     = 'nbblue';
    inputs.fontSize          = 'normalsize';
    inputs.justification     = 'centering';
    inputs.language          = 'english';
    inputs.lineBreak         = [];
    inputs.lookUpMatrix      = {};
    inputs.margins           = {};
    inputs.maxRows           = [];
    inputs.preamble          = false;
    inputs.rotation          = '';
    inputs.rowColor1         = 'white';
    inputs.rowColor2         = 'black!8!white';
    inputs.space             = 5;
    inputs.tables            = {};
    if ~isempty(varargin)
    
        if rem(size(varargin,2),2) ~= 0
            error([mfilename ':: The optional input must be given in ...,''inputName'',inputValue,... pairs. '...
                             'The number optional inputs are not even.'])
        end

        for ii = 1:2:size(varargin,2)

            inputName  = varargin{ii};
            inputValue = varargin{ii + 1};

            if ~ischar(inputName)
                error([mfilename ':: Every second input starting with the first optional input must be a string with '...
                                 'the ''inputName''. E.g. ''caption''.'])
            end

            switch lower(inputName)

                case 'caption'

                    if or(ischar(inputValue) || iscell(inputValue),isempty(inputValue))
                        inputs.caption = inputValue;
                    else
                        error([mfilename ':: The optional input ''' inputName ''' must be set to a string.'])
                    end

                case 'colors'

                    if isscalar(inputValue)
                        inputs.colors = inputValue;
                    else
                        error([mfilename ':: The optional input ''' inputName ''' must be set to a scalar.'])
                    end 
                    
                case 'columnorientation'

                    if or(iscell(inputValue) && isrow(inputValue),isempty(inputValue))
                        inputs.columnOrientation = inputValue;
                    else
                        error([mfilename ':: The optional input ''' inputName ''' must be set a cellstr matching the number of columns of c.'])
                    end     

                case 'firstrowcolor'

                    if ischar(inputValue)
                        inputs.firstRowColor = inputValue;     
                    else
                        error([mfilename ':: The optional input ''' inputName ''' must be set to a string.'])
                    end

                case 'fontsize'

                    if ischar(inputValue)
                        inputs.fontSize = inputValue;
                    else
                        error([mfilename ':: The optional input ''' inputName ''' must be set to a string.'])
                    end

                case 'justification'

                    if ischar(inputValue)
                        inputs.justification = inputValue;
                    else
                        error([mfilename ':: The optional input ''' inputName ''' must be set to a string.'])
                    end

                case 'language'

                    if ischar(inputValue)
                        inputs.language = inputValue;
                    else
                        error([mfilename ':: The optional input ''' inputName ''' must be set to a string.'])
                    end

                case 'linebreak'

                    if or(isnumeric(inputValue) && isscalar(inputValue),isempty(inputValue))
                        inputs.lineBreak = ceil(inputValue);
                    else
                        error([mfilename ':: The optional input ''' inputName ''' must be set to a scalar integer.'])
                    end    
                    
                case 'lookupmatrix'

                    if ischar(inputValue)
                        eval(inputValue);
                        inputs.lookUpMatrix = lookUpMatrix;
                    elseif iscell(inputValue)
                        inputs.lookUpMatrix = inputValue;
                    else
                        error([mfilename ':: The input after the ''lookUpMatrix'' input must be a string (filename) or a cell, with the '...
                                         'info on how to match a mnemonics with a variable description (both english and norwegian). '...
                                         'For more type help nb_ts.writeTex.'])
                    end    

                case 'margins'

                    if or(iscell(inputValue),isempty(inputValue))
                        inputs.margins = inputValue;
                    else
                        error([mfilename ':: The optional input ''' inputName ''' must be set to a cell.'])
                    end    
                    
                case 'maxrows'

                    if or(isnumeric(inputValue) && isscalar(inputValue),isempty(inputValue))
                        inputs.maxRows = ceil(inputValue);
                    else
                        error([mfilename ':: The optional input ''' inputName ''' must be set to a scalar integer.'])
                    end      
                    
                case 'preamble'

                    if islogical(inputValue) && isscalar(inputValue)
                        inputs.preamble = inputValue;
                    else
                        error([mfilename ':: The optional input ''' inputName ''' must be set to a logical.'])
                    end 
                    
                case 'rotation'

                    if ischar(inputValue)
                        inputs.rotation = inputValue;
                    else
                        error([mfilename ':: The optional input ''' inputName ''' must be set to a string.'])
                    end      

                case 'rowcolor1'

                    if ischar(inputValue)
                        inputs.rowColor1 = inputValue;
                    else
                        error([mfilename ':: The optional input ''' inputName ''' must be set to a string.'])
                    end

                case 'rowcolor2'

                    if ischar(inputValue)
                        inputs.rowColor2 = inputValue;
                    else
                        error([mfilename ':: The optional input ''' inputName ''' must be set to a string.'])
                    end 
                    
                case 'space'

                    if or(isnumeric(inputValue) && isscalar(inputValue),isempty(inputValue))
                        inputs.space = ceil(inputValue);
                    else
                        error([mfilename ':: The optional input ''' inputName ''' must be set to a scalar integer.'])
                    end    
                    
                case 'tables'
                    
                    if iscell(inputValue)
                        inputs.tables = inputValue;
                    else
                        error([mfilename ':: The optional input ''' inputName ''' must be set to a cell.'])
                    end 

                otherwise

                    error([mfilename ':: Unsupprted optional input ''' inputName '''.'])

            end

        end
        
    end
    
    if isempty(inputs.maxRows)
        inputs.maxRows = inf;
    end
    
    % Get the LaTeX code of the preamble
    %--------------------------------------------------------------
    if inputs.preamble
        code = nb_Presentation.getPreambleCode(inputs.language,inputs.justification,inputs.fontSize,'article');
        code = code(1:end-1,:);
        code = char(code,'\\usepackage{tabularx}\r\n');
        code = char(code,'\\newcolumntype{L}[1]{>{\\raggedright\\arraybackslash}p{#1}}\r\n');
        code = char(code,'\\newcolumntype{C}[1]{>{\\centering\\arraybackslash}p{#1}}\r\n');
        code = char(code,'\\newcolumntype{R}[1]{>{\\raggedleft\\arraybackslash}p{#1}}\r\n');
        code = char(code,'\r\n');
        if ~isempty(inputs.margins)
            if size(inputs.margins,2) ~= 4
                error([mfilename ':: The ''margins'' input must have size 1 x 4'])
            else
                m    = inputs.margins;
                code = char(code,'\\usepackage{geometry}\r\n');
                code = char(code,['\\geometry{left=' num2str(m{1,1}) 'cm,right=' num2str(m{2}) ...
                                  'cm,top=' num2str(m{1,3}) 'cm,bottom=' num2str(m{1,4}) 'cm}\r\n']);
                code = char(code,'\r\n');
            end
        end
        code = char(code,'\\begin{document}\r\n');
        code = char(code,'\r\n');
    else
        code = '';
    end

    % Get the LaTeX code of the table
    %--------------------------------------------------------------
    if ~isempty(inputs.tables)
        
        tables = inputs.tables;
        nTable = length(tables);
        colO   = inputs.columnOrientation;
        if isempty(colO)
            colO = cell(1,nTable);
        else
            if size(colO,2) ~= nTable
                error([mfilename ':: The ''columnOrientation'' input must be a cell array of same length as the ''tables'' input.'])
            end
        end
        cap = inputs.caption;
        if isempty(cap)
            cap = cell(1,nTable);
        else
            if size(cap,2) ~= nTable
                error([mfilename ':: The ''caption'' input must be a cell array of same length as the ''tables'' input.'])
            end
        end
        inputs = inputs(1,ones(nTable));
        left   = [];
        for ii = 1:nTable
            
            inputs(ii).columnOrientation = colO{ii};
            inputs(ii).caption           = cap{ii};
            
            % Write code of individual table
            [code,left] = writeOneTable(code,tables{ii},inputs(ii),left);
            
        end 
        
    else
        code = writeOneTable(code,c,inputs,[]);
    end

    % End document
    %--------------------------------------------------------------
    if inputs(end).preamble
        code = char(code,'\\end{document}\r\n');
    end

end

%==========================================================================
function [code,left] = writeOneTable(code,c,inputs,left)

    if isempty(left)
        left = inputs.maxRows;
    end
    if left < 4
        left = inputs.maxRows;
    end
    
    [s1,s2,s3] = size(c);
    if s3 > 1
        error([mfilename ':: The c input cannot have more than 1 page!'])
    end

    if isempty(inputs.columnOrientation)
        inputs.columnOrientation = repmat({'c'},[1,s2]);
    else
        if size(inputs.columnOrientation,2) ~= s2
            error([mfilename ':: the input ''columnOrientation'' must match the number of columns of the'...
                ' c input when the ''tables'' input is empty.'])
        end
    end

    colors = cell(s1,1);
    if inputs.colors
        colors{1}       = inputs.firstRowColor;
        colors(2:2:end) = {inputs.rowColor1};
        colors(3:2:end) = {inputs.rowColor2};
    end
    
    code      = startTable(code,inputs,true);
    [cRow,jj] = getNumRows(c(1,:),inputs);
    code      = writeOneRow(cRow,code,jj,colors{1},true,false);
    ii        = 2;
    while ii <= s1 
        [cRow,nn] = getNumRows(c(ii,:),inputs);
        if jj + nn > left
            code = finishTable(code,inputs);
            code = startTable(code,inputs,false);
            code = writeOneRow(cRow,code,nn,colors{ii},false,ii == s1);
            left = inputs.maxRows;
            jj   = nn;
        else
            code = writeOneRow(cRow,code,nn,colors{ii},false,ii == s1);
            jj   = jj + nn;
        end
        ii = ii + 1;
    end
    code = finishTable(code,inputs);
    
    % Report the number of lines left to use for a potential next table
    left = inputs.maxRows - jj - inputs.space;
    if left < 3
        left = inputs.maxRows;
    end
    
end

%==========================================================================
function code = startTable(code,inputs,first)

    if ~isempty(inputs.rotation)
        code = char(code,'\r\n');
        code = char(code,['\\begin{' lower(inputs.rotation) '}\r\n']);
    end
    
    code = char(code,'\r\n');
    
    if ~isempty(inputs.caption)
        code = char(code,'\\begin{table}[h]\r\n');
        code = char(code,'\r\n');
    end
    
    code = char(code,'\\begin{center}\r\n');
    
    if first
        if ~isempty(inputs.caption)
            code = char(code,'\r\n');
            code = char(code,['\\caption{' inputs.caption '}\r\n']);
        end
    end
    
    code = char(code,'\r\n');
    code = char(code,['\\' inputs.fontSize ' \r\n']);
    code = char(code,'\r\n');
    
    tabularStart = ['\\begin{tabular}{ ', inputs.columnOrientation{:} ,'}\r\n'];
    code         = char(code,tabularStart);

end

%==========================================================================
function code = finishTable(code,inputs)

    code = char(code,'\\end{tabular}\r\n');

    code = char(code,'\r\n');

    code = char(code,'\\end{center}\r\n');

    if ~isempty(inputs.caption)
        code = char(code,'\r\n');
        code = char(code,'\\end{table}\r\n');
    end

    if ~isempty(inputs.rotation)
        code = char(code,'\r\n');
        code = char(code,['\\end{' lower(inputs.rotation) '}\r\n']);
    end

    code = char(code,'\r\n');
    
end

%==========================================================================
function [cRow,numRows] = getNumRows(cRow,inputs)

    for ii = 1:size(cRow,2)
        cRow(ii) = nb_lookUpVariables(cRow(ii),inputs.lookUpMatrix,inputs.language,'scalar');
        cRow{ii} = nb_breakChar(cRow{ii},inputs.lineBreak);
    end
    numRows = cellfun(@(x)size(x,1),cRow);
    numRows = max(numRows);

end

%==========================================================================
function code = writeOneRow(cRow,code,numRows,color,bold,last)

    for ii = 1:numRows
        
        if isempty(color)
            row = ' ';
        else
            row = [' \\rowcolor{' color '} '];
        end
        
        for jj = 1:size(cRow,2)
            e = cRow{jj};
            try
                e = e(ii,:);
            catch %#ok<CTCH>
                e = '';
            end
            if jj ~= 1
                row = [row,' & '];  %#ok<AGROW>
            end
            if bold
                row = [row,'\\textbf{',e '}'];  %#ok<AGROW>
            else
                row = [row,e];  %#ok<AGROW>
            end
        end
        
        if last && ii == numRows
            row = [row ' \r\n'];  %#ok<AGROW>
        else
            row = [row '\\\\ \r\n']; %#ok<AGROW>
        end
        code = char(code,row);
        
    end
     

end
