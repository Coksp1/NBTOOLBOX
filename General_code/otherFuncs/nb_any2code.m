function code = nb_any2code(input,varName,nestedLevel)
% Syntax:
%
% code = nb_any2code(input,varName)
%
% Description:
%
% Convert a MATLAB object to .m code.
% 
% Input:
% 
% - input       : A variable (not the name of the variable)
%
% - varName     : Name of the assign variable.
%
% - nestedLevel : Level of nesting of cell arrays and struct.
% 
% Output:
% 
% - code : A cellstr with the code.
%
% Examples:
%
% See also:
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

% Write any input variable to it represenative .m code
 
    if nargin < 3
        nestedLevel = 1;
        if nargin < 2
            varName = 'data';
        end
    end

    code = ''; 
    if isa(input,'nb_date')
        
        code = {[varName ' = ''' toString(input) ''';']};

    elseif isnumeric(input)

        if isscalar(input)

            if rem(input,floor(input)) == 0
                code = {[varName ' = ' int2str(input) ';']};
            else
                code = {[varName ' = ' num2str(input,'%0.16f') ';']};
            end

        else

            input   = num2str(input,'%0.16f,');
            dim1    = size(input,1);
            code    = cell(dim1,1);
            code{1} = [varName ' = ['];
            for mm = 1:dim1
                code{mm + 1} = [input(mm,:) ';'];
            end
            code{dim1 + 2} = '];';

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
            
end
