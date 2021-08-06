function code = getCode(obj,preamble,varargin)
% Syntax:
%
% code = getCode(obj,preamble)
% code = getCode(obj,preamble,'inputName',inputValue,...)
%
% Description:
%
% Get the LaTeX code of a table representing the data of the object
%
% If the object consists of more pages (datasets) more tables will
% be created.
%
% Input:
% 
% - obj             : An object of class nb_cell
%
% - preamble        : Give 0 if you don't want to include the 
%                     preamble in the returned output. Default is
%                     to include the preamble, i.e. 1.
%
% Optional input:
%
% - 'caption'       : Adds a caption to the table. Must be a 
%                     string.
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
%    Caution  : This will act on both variables and types.
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
% Output:
%
% - code            : A char with the tex code of the table
%
% Examples:
%
% obj  = nb_cell({'Test',2; 'Test2', 3});
% code = obj.getCode(1)
%
% See also:
% nb_cell
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Parse the optional input
    %--------------------------------------------------------------
    caption       = '';
    combine       = 0;
    colors        = 1;
    firstRowColor = 'nbblue';
    fontSize      = 'normalsize';
    justification = 'centering';
    language      = 'english';
    lookUpMatrix  = {};
    precision     = '%3.2f';
    rotation      = '';
    rowColor1     = 'white';
    rowColor2     = 'black!8!white';
    
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

                    if ischar(inputValue)
                        caption = inputValue;
                    else
                        error([mfilename ':: The optional input ''' inputName ''' must be set to a string.'])
                    end

                case 'combine'

                    if isscalar(inputValue)
                        combine = inputValue;
                    else
                        error([mfilename ':: The optional input ''' inputName ''' must be set to a scalar.'])
                    end

                case 'colors'

                    if isscalar(inputValue)
                        colors = inputValue;
                    else
                        error([mfilename ':: The optional input ''' inputName ''' must be set to a scalar.'])
                    end    

                case 'firstrowcolor'

                    if ischar(inputValue)
                        firstRowColor = inputValue;     
                    else
                        error([mfilename ':: The optional input ''' inputName ''' must be set to a string.'])
                    end

                case 'fontsize'

                    if ischar(inputValue)
                        fontSize = inputValue;
                    else
                        error([mfilename ':: The optional input ''' inputName ''' must be set to a string.'])
                    end

                case 'justification'

                    if ischar(inputValue)
                        justification = inputValue;
                    else
                        error([mfilename ':: The optional input ''' inputName ''' must be set to a string.'])
                    end

                case 'language'

                    if ischar(inputValue)
                        language = inputValue;
                    else
                        error([mfilename ':: The optional input ''' inputName ''' must be set to a string.'])
                    end

                case 'lookupmatrix'

                    if ischar(inputValue)
                        eval(inputValue);
                    elseif iscell(inputValue)
                        lookUpMatrix = inputValue;
                    else
                        error([mfilename ':: The input after the ''lookUpMatrix'' input must be a string (filename) or a cell, with the '...
                                         'info on how to match a mnemonics with a variable description (both english and norwegian). '...
                                         'For more type help nb_cs.writeTex.'])
                    end 

                case 'precision'

                    if ischar(inputValue)
                        precision = inputValue;
                    else
                        error([mfilename ':: The optional input ''' inputName ''' must be set to a string.'])
                    end 

                case 'rotation'

                    if ischar(inputValue)
                        rotation = inputValue;
                    else
                        error([mfilename ':: The optional input ''' inputName ''' must be set to a string.'])
                    end        

                case 'rowcolor1'

                    if ischar(inputValue)
                        rowColor1 = inputValue;
                    else
                        error([mfilename ':: The optional input ''' inputName ''' must be set to a string.'])
                    end

                case 'rowcolor2'

                    if ischar(inputValue)
                        rowColor2 = inputValue;
                    else
                        error([mfilename ':: The optional input ''' inputName ''' must be set to a string.'])
                    end  

                otherwise

                    error([mfilename ':: Unsupprted optional input ''' inputName '''.'])

            end

        end
        
    end

    % Get the LaTeX code of the preamble
    %--------------------------------------------------------------
    if preamble
        code = nb_Presentation.getPreambleCode(language,justification,fontSize,'article');
    else
        code = '';
    end

    % Get the LaTeX code of the table
    %--------------------------------------------------------------
    if combine
        
        error('Setting the ''combine'' option to true is not supported for the nb_cell class.')
        
    else
        
        %----------------------------------------------------------
        % One table for each dataset
        %----------------------------------------------------------
        code = char(code,'\r\n');
            
        if ~isempty(rotation)
            code = char(code,['\\begin{' lower(rotation) '}\r\n']);
        end
    
        dim2     = size(obj,2) - 1;
        headers  = obj.cdata(1,2:end);
        rowDescr = obj.cdata(2:end,1);
        dim1     = size(obj,1) - 1;
        for ll = 1:obj.numberOfDatasets

            code = char(code,'\r\n');

            if ~isempty(caption)
                code = char(code,'\\begin{table}\r\n');
            end

            code = char(code,'\\begin{center}\r\n');

            if ~isempty(caption)
                code = char(code,['\\caption{' caption '}\r\n']);
            end

            code = char(code,['\\' fontSize ' \r\n']);
              
            % Vertical orientation
            tabularStart = '\\begin{tabular}{| l | ';
            for ii = 1:dim2
                if ii == dim2
                    tabularStart = [tabularStart 'c | }\r\n']; %#ok
                else
                    tabularStart = [tabularStart 'c']; %#ok
                end
            end
            code = char(code,tabularStart);

            code = char(code,'\\hline\r\n');

            % Look up the headers
            [vars,numberOfLines] = nb_lookUpVariables(headers,lookUpMatrix,language,'scalar'); 

            % Fist row - The variable names
            for hh = 1:numberOfLines

                if colors
                    firstRow = [' \\rowcolor{' firstRowColor '} '];
                else
                    firstRow = ' ';
                end

                for ii= 1:dim2
                    var = vars{ii};
                    if size(var,1) >= hh
                        var      = strtrim(var(hh,:));
                        var      = strrep(var,'_','\\_');
                        firstRow = [firstRow,' & \\textbf{' var '}']; %#ok
                    else
                        firstRow = [firstRow,' & ']; %#ok
                    end
                end
                firstRow = [firstRow,'\\\\ \r\n']; %#ok 
                code     = char(code,firstRow);

            end

            code = char(code,'\\hline\r\n');

            % Look up the types
            [typs,numberOfLines] = nb_lookUpVariables(rowDescr,lookUpMatrix,language,'vector');

            % Write the data of each type
            for ii = 1:dim1

                dataStr = cell(1,dim2);
                for vv = 2:dim2 + 1
                    if isnan(obj.data(ii+1,vv,ll))
                        dataStr(vv-1) = nb_lookUpVariables(obj.c(ii+1,vv,ll),lookUpMatrix,language,'vector');
                        dataStr(vv-1) = strrep(dataStr(vv-1),'_','\\_');
                    else
                        dataStr{vv-1} = num2str(obj.data(ii+1,vv,ll),precision);
                    end
                end
                
                if colors

                    if rem(ii,2) == 1
                        row = [' \\rowcolor{' rowColor1 '} '];
                    else
                        row = [' \\rowcolor{' rowColor2 '} '];
                    end

                else

                    row = ' ';

                end

                type = typs{ii}(1,:);
                type = strrep(type,'_','\\_');
                row  = [row '\\textbf{' type '}']; %#ok
                for jj = 1:dim2
                    row = [row,' & ',dataStr{jj}]; %#ok
                end
                row  = [row '\\\\ \r\n']; %#ok
                code = char(code,row);

                for mm = 2:numberOfLines(ii)

                    if colors

                        if rem(ii,2) == 1
                            row = [' \\rowcolor{' rowColor1 '} '];
                        else
                            row = [' \\rowcolor{' rowColor2 '} '];
                        end

                    else

                        row = ' ';

                    end

                    type = typs{ii}(mm,:);
                    type = strrep(type,'_','\\_');
                    row  = [row '\\textbf{' type '}']; %#ok
                    for jj = 1:dim2
                        row = [row,' & ']; %#ok
                    end
                    row  = [row '\\\\ \r\n']; %#ok
                    code = char(code,row);

                end

            end

            code = char(code,'\\hline\r\n');

            code = char(code,'\\end{tabular}\r\n');

            code = char(code,'\r\n');

            code = char(code,'\\end{center}\r\n');

            code = char(code,'\r\n');

            if ~isempty(caption)
                code = char(code,'\\end{table}\r\n');
            end
            
            if ~isempty(rotation)
                code = char(code,['\\end{' lower(rotation) '}\r\n']);
            end

        end
        
    end
    
    if preamble
        code = char(code,'\\end{document}\r\n');
    end
    
end
