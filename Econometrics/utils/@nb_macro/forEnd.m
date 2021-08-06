function [obj,statement] = forEnd(obj,forVar,looped,forStatements)
% Syntax:
%
% [obj,statement] = forEnd(obj,forVar,looped,forStatements)
%
% Description:
%
% Running an @#for @#endfor block in the macro processing language.
% 
% Input:
% 
% - obj           : A vector of nb_macro objects storing the macro 
%                   variables.
%
% - forVar        : A one line char with the name of the for loop variable.
% 
% - looped        : Either a one line char or a scalar nb_macro object.
%
% - forStatements : The statments in the body of the @#for loop, as a N x
%                   cellstr.
% 
% Output:
% 
% - statement     : A Q x 1 cellstr with the parsed version of the model
%                   file statements.
%
% See also:
% nb_macro.ifElseEnd, nb_macro.parse
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nb_isOneLineChar(looped)
        try
            looped = eval(obj,looped); %#ok<EVLC>
        catch
            error('nb_macro:forEnd:loop',['Could not interpret the statement to loop; ' looped '.'])
        end
    elseif ~isa(looped,'nb_macro')
        error('nb_macro:forEnd:loop','Could not interpret the statement to loop.')
    end
    
    % Get the stuff to loop
    value = looped.value;
    if ischar(value)
        value = cellstr(value');
    elseif isnumeric(value)
        value = strtrim(cellstr(num2str(round(value)')));
    elseif islogical(value)
        value = strtrim(cellstr(num2str(value')));
    end
    
    % Run the loop
    forVar    = strtrim(forVar);
    numLoops  = length(value);
    statement = cell(numLoops,1);
    for ii = 1:numLoops
        parsedForSt      = forStatements;
        parsedForSt(:,1) = strrep(parsedForSt(:,1),['@{',forVar,'}'],value{ii});
        statement{ii}    = parsedForSt;
    end
    statement = vertcat(statement{:});
    
    % Parse the resulting statements (may be a double loop, or an @#if
    % in there)
    [obj,statement] = parse(obj,statement);

end
