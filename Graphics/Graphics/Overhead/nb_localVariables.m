function outString = nb_localVariables(localVariables,inString)
% Syntax:
%
% outString = nb_localVariables(localVariables,inString)
%
% Description:
%
% Finds the local variables used in a char or a cellstr, i.e.
% a word starting with %#, and substitutes it with the matching
% field of the localVariables input
% 
% Input:
% 
% - localVariables : A MATLAB struct or an nb_struct object.
%
% - inString       : A char or a cellstr.
% 
% Output:
% 
% - outString      : A char or a cellstr. (Will match the input)
%
% Written by Kenneth Sæterhagen Paulsen and Henrik Halvorsen Hortemo

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if isempty(inString) || ~isstruct(localVariables)
        outString = inString;
        return
    end
    
    inputIsChar = 0;
    if ischar(inString)
        inString  = cellstr(inString);
        inputIsChar = 1;
    elseif ~iscellstr(inString)
        error([mfilename ':: The inString input must be either a char or a cellstr.'])
    end
    
    % Do not match local functions
    pattern = '%#(?!obj\.)\S*[^.\s]';
    replaceFunc = @(input) replaceLocalVariable(localVariables, input); %#ok<NASGU>

    for i = 1:length(inString)
        inString{i} = regexprep(inString{i}, pattern, '${replaceFunc($0)}');
    end
    
    if inputIsChar
        inString = char(inString);
    end
    
    outString = inString;
    
end

function output = replaceLocalVariable(localVariables, str)
% Parse the local variable expression str

    variableName = regexp(str, '(?<=%#)[a-zA-Z0-9]+', 'match', 'once');

    % %#variable{4}
    dateFreq  = str2double(regexp(str, '(?<=\{)\S+(?=\})', 'match', 'once'));
    
    % %#variable[12]
    dateShift = str2double(regexp(str, '(?<=\[)\S+(?=\])', 'match', 'once'));
    
    % %#variable('pprnorsk')
    dateFormat = regexp(str, '(?<=\().+(?=\))', 'match', 'once');
    dateFormat = regexprep(dateFormat, '^''(.*?)''$', '$1');
    
    try    
        output = localVariables.(variableName);

        % Date modifications
        if ~isnan(dateFreq) || ~isnan(dateShift) || ~isempty(dateFormat)
            date = nb_date.date2freq(output);
            if ~isnan(dateShift)
                try
                    date = date + dateShift;
                catch Err
                    error([mfilename ':: Could add the number of periods to the given date; ' fFunc '. MATLAB error:: ' Err.message])
                end    
            end

            if ~isnan(dateFreq)
                try
                    date = date.convert(dateFreq);
                catch Err
                    error([mfilename ':: Could not convert the frequency of the date; ' fFunc '. MATLAB error:: ' Err.message])
                end    
            end
            
            % %#variable_
            dateCase = ~any(regexp(str, [variableName '_']));
            output = date.toString(dateFormat, dateCase);
        end
        
        if strcmp(str(end),')') && isempty(dateFormat)
            output = [output,')'];
        elseif size(str,2) > 1 && ~isempty(dateFormat)
            if strcmp(str(end-1:end),'))')
                output = [output,')'];
            end
        end

    catch %#ok<CTCH>
        output = str;
    end
    
    

end
