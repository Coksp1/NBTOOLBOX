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
% - obj             : An object of class nb_ts
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
% - 'combine'       : If the nb_ts object consist of two or three
%                     pages (datasets) this option can be used to
%                     combine all the data i one table. Either 1
%                     or 0. Default is 0.
%
% - 'colors'        : Set it to 0 if the colored rows of the table
%                     should be turned off. Default is 1.
%
% - 'dateformat'    : Must be a string. 'default' is default. 
%
%                     > 'default' 
%                     > 'fame'    
%                     > 'xls'   
%                     > 'NBNorsk'   ('NBNorwegian')
%                     > 'NBEnglish' ('NBEngelsk')
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
% - 'language'      : Either 'english' (default) or 'norwegian' 
%                     ('norsk').
%
% - 'lookUpMatrix'  : 
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
%                     > 'horizontal' : The dates as columns
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
% - 'NaNrepl'       : Replaces NaN's in a table by chosen symbol.
%                     Give as string, can by empty. Default: 'NaN',
%                     i.e. no replacement.
%
% Output:
%
% - code            : A char with the tex code of the table
%
% Examples:
%
% obj  = nb_ts(rand(10,3),'','2012Q1',{'Var1','Var2','Var3'});
% code = obj.getCode(1)
%
% See also:
% nb_ts
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Parse the optional input
    %--------------------------------------------------------------
    caption       = '';
    combine       = 0;
    colors        = 1;
    dateFormat    = 'default';
    firstRowColor = 'nbblue';
    fontSize      = 'normalsize';
    justification = 'centering';
    language      = 'english';
    lookUpMatrix  = {};
    orientation   = 'vertical';
    precision     = '%3.2f';
    rotation      = '';
    rowColor1     = 'white';
    rowColor2     = 'black!8!white';
    rowColor3     = 'black!16!white';
    NaNrepl       = 'NaN';
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

                case 'dateformat'

                    if ischar(inputValue)
                        dateFormat = inputValue;
                    else
                        error([mfilename ':: The optional input ''' inputName ''' must be set to a string.'])
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
                                         'For more type help nb_ts.writeTex.'])
                    end

                case 'orientation'

                    if ischar(inputValue)
                        orientation = inputValue;
                    else
                        error([mfilename ':: The optional input ''' inputName ''' must be set to a string.'])
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

                case 'rowcolor3'

                    if ischar(inputValue)
                        rowColor3 = inputValue;
                    else
                        error([mfilename ':: The optional input ''' inputName ''' must be set to a string.'])
                    end  
                    
                case 'nanrepl'
                
                    if ischar(inputValue)
                        NaNrepl = inputValue;
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
        
        %----------------------------------------------------------
        % Combine data from different datasets in one table
        %----------------------------------------------------------
        code = char(code,'\r\n');
            
        if ~isempty(rotation)
            code = char(code,['\\begin{' lower(rotation) '}\r\n']);
        end
        
        code = char(code,'\r\n');

        if ~isempty(caption)
            code = char(code,'\\begin{table}\r\n');
        end

        code = char(code,'\\begin{center}\r\n');

        if ~isempty(caption)
            code = char(code,['\\caption{' caption '}\r\n']);
        end

        code = char(code,['\\' fontSize ' \r\n']);
        
        % Decide if the table should be vertical or horizontal
        %------------------------------------------------------
        if strcmpi(orientation,'horizontal')

            tabularStart = '\\begin{tabular}{| l | ';
            for ii=1:obj.numberOfObservations
                if ii == obj.numberOfObservations
                    tabularStart = [tabularStart 'c | }\r\n']; %#ok
                else
                    tabularStart = [tabularStart 'c']; %#ok
                end
            end
            code = char(code,tabularStart);

            code = char(code,'\\hline\r\n');

            % Fist row - The dates
            if colors 
                firstRow = [' \\rowcolor{' firstRowColor '} '];
            else
                firstRow = ' ';
            end

            dates = obj.startDate.toDates(0:obj.numberOfObservations - 1,dateFormat,obj.frequency);
            for ii= 1:obj.numberOfObservations
                date      = strtrim(dates{ii});
                firstRow  = [firstRow,' & \\textbf{' date '}']; %#ok
            end
            firstRow = [firstRow,'\\\\ \r\n'];  
            code     = char(code,firstRow);

            code = char(code,'\\hline\r\n');

            % Look up the variables
            [vars,numberOfLines] = nb_lookUpVariables(obj.variables,lookUpMatrix,language,'vector');
            
            % Write the data of each variable
            if obj.numberOfDatasets == 2

                for ii = 1:obj.numberOfVariables

                    for mm = 1:obj.numberOfDatasets

                        dataStr = num2str(obj.data(:,ii,mm),precision);
                        
                        if colors 
                            
                            if rem(mm,2) == 1
                                row = [' \\rowcolor{' rowColor1 '} \\textbf{' vars{ii}(1,:) '}'];
                            else
                                row = [' \\rowcolor{' rowColor2 '} '];
                            end
                            
                        else
                            
                            if rem(mm,2) == 1
                                row = [' \\textbf{' vars{ii}(1,:) '}'];
                            else
                                row = ' ';
                            end
                            
                        end

                        for jj = 1:obj.numberOfObservations
                            row = [row,' & ',dataStr(jj,:)]; %#ok
                        end
                        row  = [row '\\\\ \r\n']; %#ok
                        code = char(code,row);

                        if mm == 1

                            for gg = 2:numberOfLines(ii)

                                if colors
                                
                                    if rem(ii,2) == 1
                                        row = [' \\rowcolor{' rowColor1 '} '];
                                    else
                                        row = [' \\rowcolor{' rowColor2 '} '];
                                    end
                                    
                                else
                                    
                                    row = ' ';
                                    
                                end

                                var = vars{ii}(gg,:);
                                row = [row '\\textbf{' var '}']; %#ok
                                for jj = 1:obj.numberOfTypes
                                    row = [row,' & ']; %#ok
                                end
                                row  = [row '\\\\ \r\n']; %#ok
                                code = char(code,row);

                            end

                        end

                    end

                    code = char(code,'\\hline\r\n');

                end

            elseif obj.numberOfDatasets == 3

                for ii = 1:obj.numberOfVariables

                    for mm = 1:obj.numberOfDatasets

                        dataStr = num2str(obj.data(:,ii,mm),precision);

                        if colors
                        
                            if rem(mm,3) == 1
                                row = [' \\rowcolor{' rowColor1 '} \\textbf{' vars{ii}(1,:) '}'];
                            elseif rem(mm,3) == 2
                                row = [' \\rowcolor{' rowColor2 '} '];
                            else
                                row = [' \\rowcolor{' rowColor3 '} '];
                            end
                            
                        else
                            
                            if rem(mm,3) == 1
                                row = [' \\textbf{' vars{ii}(1,:) '}'];
                            else
                                row = ' ';
                            end
                            
                        end

                        for jj = 1:obj.numberOfObservations
                            row = [row,' & ',dataStr(jj,:)]; %#ok
                        end
                        row  = [row '\\\\ \r\n']; %#ok
                        code = char(code,row);

                        if mm == 1

                            for gg = 2:numberOfLines(ii)

                                if colors
                                
                                    if rem(ii,2) == 1
                                        row = [' \\rowcolor{' rowColor1 '} '];
                                    else
                                        row = [' \\rowcolor{' rowColor2 '} '];
                                    end
                                    
                                else
                                    
                                    row = ' ';
                                    
                                end

                                var = vars{ii}(gg,:);
                                row = [row '\\textbf{' var '}']; %#ok
                                for jj = 1:obj.numberOfObservations
                                    row = [row,' & ']; %#ok
                                end
                                row  = [row '\\\\ \r\n']; %#ok
                                code = char(code,row);

                            end

                        end

                    end

                    code = char(code,'\\hline\r\n');

                end

            elseif obj.numberOfDatasets == 1

                error([mfilename ':: When the ''combine'' input is used, the number of datasets cannot be 1.'])

            else

                error([mfilename ':: When the ''combine'' input is used, the number of datasets cannot exceed 3.'])

            end
            
        else
            
            tabularStart = '\\begin{tabular}{| l | ';
            for ii=1:obj.numberOfVariables
                if ii == obj.numberOfVariables
                    tabularStart = [tabularStart 'c | }\r\n']; %#ok
                else
                    tabularStart = [tabularStart 'c']; %#ok
                end
            end
            code = char(code,tabularStart);

            code = char(code,'\\hline\r\n');

            [vars,numberOfLines] = nb_lookUpVariables(obj.variables,lookUpMatrix,language,'scalar'); 

            % Fist row - The variable names
            for hh = 1:numberOfLines

                if colors
                    firstRow = [' \\rowcolor{' firstRowColor '} '];
                else
                    firstRow = ' ';
                end

                for ii= 1:obj.numberOfVariables
                    var      = vars{ii};
                    if size(var,1) >= hh
                        var      = strtrim(var(hh,:));
                        firstRow = [firstRow,' & \\textbf{' var '}']; %#ok
                    else
                        firstRow = [firstRow,' & ']; %#ok
                    end
                end
                firstRow = [firstRow,'\\\\ \r\n']; %#ok 
                code     = char(code,firstRow);

            end

            code = char(code,'\\hline\r\n');

            % Write the data of each date
            dates = obj.startDate.toDates(0:obj.numberOfObservations - 1,dateFormat,obj.frequency);
            if obj.numberOfDatasets == 2

                for ii = 1:obj.numberOfObservations

                    for mm = 1:obj.numberOfDatasets

                        dataStr = num2str(obj.data(ii,:,mm)',precision);

                        if colors
                        
                            if rem(mm,2) == 1
                                row = [' \\rowcolor{' rowColor1 '} \\textbf{' dates{ii} '}'];
                            else
                                row = [' \\rowcolor{' rowColor2 '} '];
                            end
                            
                        else
                            
                            if rem(mm,2) == 1
                                row = [' \\textbf{' dates{ii} '}'];
                            else
                                row = ' ';
                            end
                            
                        end

                        for jj = 1:obj.numberOfVariables
                            if isequal(strtrim(dataStr(jj,:)), 'NaN')
                                row = [row, ' & ', NaNrepl]; %#ok
                            else
                                row = [row,' & ',dataStr(jj,:)]; %#ok
                            end
                        end
                        row  = [row '\\\\ \r\n']; %#ok
                        code = char(code,row);

                    end

                    code = char(code,'\\hline\r\n');

                end

            elseif obj.numberOfDatasets == 3

                for ii = 1:obj.numberOfObservations

                    for mm = 1:obj.numberOfDatasets

                        dataStr = num2str(obj.data(ii,:,mm)',precision);

                        if colors
                        
                            if rem(mm,3) == 1
                                row = [' \\rowcolor{' rowColor1 '} \\textbf{' dates{ii} '}'];
                            elseif rem(mm,3) == 2
                                row = [' \\rowcolor{' rowColor2 '} '];
                            else
                                row = [' \\rowcolor{' rowColor3 '} '];
                            end
                            
                        else
                            
                            if rem(mm,3) == 1
                                row = [' \\textbf{' dates{ii} '}'];
                            else
                                row = ' ';
                            end
                            
                        end

                        for jj = 1:obj.numberOfVariables
                            if isequal(strtrim(dataStr(jj,:)), 'NaN')
                                row = [row, ' & ', NaNrepl]; %#ok
                            else
                                row = [row,' & ',dataStr(jj,:)]; %#ok
                            end
                        end
                        row  = [row '\\\\ \r\n']; %#ok
                        code = char(code,row);
                        
                    end

                    code = char(code,'\\hline\r\n');

                end

            elseif obj.numberOfDatasets == 1

                error([mfilename ':: When the ''combine'' input is used, the number of datasets cannot be 1.'])

            else

                error([mfilename ':: When the ''combine'' input is used, the number of datasets cannot exceed 3.'])

            end
            
        end

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
        
    else
        %----------------------------------------------------------
        % One table for each dataset
        %----------------------------------------------------------
        for ll = 1:obj.numberOfDatasets

            code = char(code,'\r\n');
            
            if ~isempty(rotation)
                code = char(code,['\\begin{' lower(rotation) '}\r\n']);
            end
            
            code = char(code,'\r\n');

            if ~isempty(caption)
                code = char(code,'\\begin{table}\r\n');
            end

            code = char(code,'\\begin{center}\r\n');

            if ~isempty(caption)
                code = char(code,['\\caption{' caption '}\r\n']);
            end

            code = char(code,['\\' fontSize ' \r\n']);

            % Decide if the table should be vertical or horizontal
            %------------------------------------------------------
            if strcmpi(orientation,'horizontal')
                
                tabularStart = '\\begin{tabular}{| l | ';
                for ii=1:obj.numberOfObservations
                    if ii == obj.numberOfObservations
                        tabularStart = [tabularStart 'c | }\r\n']; %#ok
                    else
                        tabularStart = [tabularStart 'c']; %#ok
                    end
                end
                code = char(code,tabularStart);

                code = char(code,'\\hline\r\n');
            
                % Fist row - The dates
                if colors
                    firstRow = [' \\rowcolor{' firstRowColor '} '];
                else
                    firstRow = ' ';
                end

                dates = obj.startDate.toDates(0:obj.numberOfObservations - 1,dateFormat,obj.frequency);
                for ii= 1:obj.numberOfObservations
                    date      = strtrim(dates{ii});
                    firstRow  = [firstRow,' & \\textbf{' date '}']; %#ok
                end
                firstRow = [firstRow,'\\\\ \r\n']; %#ok 
                code     = char(code,firstRow);

                code = char(code,'\\hline\r\n');

                % Look up the variables
                [vars,numberOfLines] = nb_lookUpVariables(obj.variables,lookUpMatrix,language,'vector'); 
                
                % Write the data of each variable
                for ii = 1:obj.numberOfVariables

                    dataStr = num2str(obj.data(:,ii,ll),precision);

                    if colors
                    
                        if rem(ii,2) == 1
                            row = [' \\rowcolor{' rowColor1 '} '];
                        else
                            row = [' \\rowcolor{' rowColor2 '} '];
                        end
                        
                    else
                        
                        row = ' ';
                        
                    end

                    var = vars{ii}(1,:);
                    row = [row '\\textbf{' var '}']; %#ok
                    for jj = 1:obj.numberOfObservations
                        row = [row,' & ',dataStr(jj,:)]; %#ok
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

                        var = vars{ii}(mm,:);
                        row = [row '\\textbf{' var '}']; %#ok
                        for jj = 1:obj.numberOfObservations
                            row = [row,' & ']; %#ok
                        end
                        row  = [row '\\\\ \r\n']; %#ok
                        code = char(code,row);

                    end

                end
                
            else
                
                tabularStart = '\\begin{tabular}{| l | ';
                for ii=1:obj.numberOfVariables
                    if ii == obj.numberOfVariables
                        tabularStart = [tabularStart 'c | }\r\n']; %#ok
                    else
                        tabularStart = [tabularStart 'c']; %#ok
                    end
                end
                code = char(code,tabularStart);

                code = char(code,'\\hline\r\n');
                
                % Look up the variables
                [vars,numberOfLines] = nb_lookUpVariables(obj.variables,lookUpMatrix,language,'scalar'); 

                % Fist row - The variable names
                for hh = 1:numberOfLines

                    if colors
                        firstRow = [' \\rowcolor{' firstRowColor '} '];
                    else
                        firstRow = ' ';
                    end

                    for ii= 1:obj.numberOfVariables
                        var      = vars{ii};
                        if size(var,1) >= hh
                            var      = strtrim(var(hh,:));
                            firstRow = [firstRow,' & \\textbf{' var '}']; %#ok
                        else
                            firstRow = [firstRow,' & ']; %#ok
                        end
                    end
                    firstRow = [firstRow,'\\\\ \r\n']; %#ok 
                    code     = char(code,firstRow);

                end

                code = char(code,'\\hline\r\n');

                % Write the data of each date
                dates = obj.startDate.toDates(0:obj.numberOfObservations - 1,dateFormat,obj.frequency);
                for ii = 1:obj.numberOfObservations

                    dataStr = num2str(obj.data(ii,:,ll)',precision);

                    if colors
                        
                        if rem(ii,2) == 1
                            row = [' \\rowcolor{' rowColor1 '} '];
                        else
                            row = [' \\rowcolor{' rowColor2 '} '];
                        end
                        
                    else
                        
                        row = ' ';
                        
                    end

                    date = dates{ii};
                    row = [row '\\textbf{' date '}']; %#ok
                    for jj = 1:obj.numberOfVariables
                        if isequal(strtrim(dataStr(jj,:)), 'NaN')
                            row = [row, ' & ', NaNrepl]; %#ok
                        else
                            row = [row,' & ',dataStr(jj,:)]; %#ok
                        end
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
    
    %code = char(code,'\\end{document}\r\n');
    
    if preamble
        code = char(code,'\\end{document}\r\n');
    end
    
end
