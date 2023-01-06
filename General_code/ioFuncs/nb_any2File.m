function nb_any2File(filename,input,nestedLevel,numPrecision)
% Syntax:
%
% nb_any2File(filename,input)
% nb_any2File(filename,input,nestedLevel,numPrecision)
%
% Description:
%
% Write a NBTOOLBOX objects to file.
% 
% Input:
% 
% - filename    : Either a string with the name of the output file or
%                 file idenifier.
%
% - input       : A variable (not the name of the variable)
%
% - nestedLevel : Level of nesting of cell arrays and struct.
% 
% Output:
% 
% - code : A cellstr with the code.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    error('Not yet finished!')

    if nargin < 4
        numPrecision = '%bx';
        if nargin < 3
            nestedLevel = 1;
            if nargin < 2
                varName = 'data';
            end
        end
    end
    
    % Test the filename input
    %--------------------------------------------------------------
    if ischar(filename)
        
        ind = strfind(filename,'.');
        if isempty(ind)
            filename = [filename,'.m'];
        end
        writer  = fopen(filename,'w+');
        doClose = true;
        
    else
        writer  = filename;
        doClose = false;
    end

    % Write to file
    %---------------------------------------------------------------
    code = ''; 
    if isa(input,'nb_date')
        
        s  = size(input);
        ss = size(s,2);
        if ss > 4
            error([mfilename ':: This function only handles double with less than or equal to 4 pages.'])
        elseif ss == 2
            s = [s,1,1];
        elseif ss == 3
            s = [s,1];
        end
        
        if numel(input) == 1
            code = ['<' class(input) '><' toString(input) '>\n'];
        else
            code = ['<' class(input) '><' toString(input) '>\n'];
        end
        
    elseif isnumeric(input)

        
        if isscalar(input)
            
            code = '<d><';
            if rem(input,floor(input)) == 0
                code = [code int2str(input) '>'];
            else
                code = [code num2str(input,20) '>'];
            end

        else

            s  = size(input);
            ss = size(s,2);
            if ss > 4
                error([mfilename ':: This function only handles double with less than or equal to 4 pages.'])
            elseif ss == 2
                s = [s,1,1];
            elseif ss == 3
                s = [s,1];
            end
            
            code       = ['<d(' int2str(s(1)) ',' int2str(s(2)) ',' int2str(s(3)) ',' int2str(s(4)) ',' strrep(numPrecision,'%','%%') ')><'];
            input      = input(:);
            c          = num2str(input,numPrecision);
            c          = cellstr(c);
            c          = strtrim(c);
            c(1:end-1) = strcat(c(1:end-1),',');
            c          = c';
            c          = [c{:}];
            code       = [code, c, '>'];
            
        end

    elseif ischar(input)

        if size(input,1) == 1
            code = {[varName ' = ''' input ''';']};
        else

            dim1    = size(input,1);
            code    = cell(dim1,1);
            code{1} = [varName ' = ['];
            for mm = 1:dim1
                code{mm + 1} = ['''' input(mm,:) ''''];
            end
            code{dim1 + 2} = '];';

        end

    elseif isstruct(input)

        % Write code for each field. Could be nested.
        fields = fieldnames(input);
        nestedCode = {}; 
        for ii = 1:length(fields)

            temp       = nb_any2code(input.(fields{ii}),['structElement_' int2str(nestedLevel) '_' int2str(ii)],nestedLevel + 1);
            nestedCode = [nestedCode;temp];  %#ok<AGROW>

        end
        code = [code;nestedCode];

        % Write the code for the struct itself
        code = [code;{[varName ' = struct();']}];
        for ii = 1:length(fields)
            
            code = [code;{[varName '.' fields{ii} ' = structElement_' int2str(nestedLevel) '_' int2str(ii) ';']}]; %#ok<AGROW>
            
        end
        
    elseif iscell(input)

        % Write code for each element of the cell array (could be
        % nested)
        nestedCode = {}; 
        for ii = 1:length(input)

            temp       = nb_any2code(input{ii},['cellElement_' int2str(nestedLevel) '_' int2str(ii)],nestedLevel + 1);
            nestedCode = [nestedCode;temp];  %#ok<AGROW>

        end
        code = [code;nestedCode];

        % Write the code for the cell array itself
        str = [varName ' = {'];
        for ii = 1:length(input)
            
            element = ['cellElement_' int2str(nestedLevel) '_' int2str(ii)];
            if ii == 1
                str = [str, element]; %#ok<AGROW>
            else
                str = [str,',' element]; %#ok<AGROW>
            end
            
        end
        str  = [str,'};'];
        code = [code;{str}];
        
    elseif isa(input,'nb_ts') || isa(input,'nb_cs')

        code = toMFile(input,'',varName);

    end
    
    nb_cellstr2file(code,writer,false);
    
    if doClose 
        fclose(writer);
        fclose('all');
    end
            
end
