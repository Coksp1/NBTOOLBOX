function [obj,parsed] = parse(obj,statements)
% Syntax:
%
% [obj,parsed] = parse(obj,statements)
%
% Description:
%
% Parse model file that utilizes the macro processing language.
% 
% Input:
% 
% - obj        : A vector of nb_macro objects.
%
% - statements : A N x 3 cell with the model file statements at the first 
%                column, the line number at the second and the filenames 
%                at the third column. 
%
%                Caution: This input can also be a N x 1 cell, but then the
%                         error messages will be less informative.
% 
% Output:
% 
% - parsed     : A Q x 3 (1) cellstr with the statements input cleeaned for
%                the macro processing language.
%
% See also:
% nb_macro.forEnd, nb_macro.ifElseEnd
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if isempty(statements)
        parsed = cell(size(statements));
        return
    end
    
    % Check for brooken lines with \\
    [r,c]  = size(statements);
    merged = cell(r,c);
    ii     = 1;
    num    = 1;
    while ii <= r
        
        kk    = ii;
        statm = statements{ii,1};
        while nb_contains(statements{kk,1},'\\')
            kk    = kk + 1;
            if kk > r
                error([mfilename ':: Reached the end of file without a line not ending with \\.'])
            end
            statm = [statm,statements{kk,1}]; %#ok<AGROW>
        end
        statements{ii,1} = strrep(statm,'\\','');
        merged(num,:)    = statements(ii,:);
        num              = num + 1;
        ii               = kk + 1;
        
    end
    statements = merged(1:num-1,:); % Remove empty lines at end
    
    % Parse @#define, @#if and @#for statements
    [r,c]  = size(statements);
    parsed = cell(r,c);
    kk     = 0;
    maxKK  = r;
    ii     = 1;
    while ii <= r
       
        line = statements{ii,1};
        if nb_contains(line,'@#define')
            obj = parseDefine(obj,statements(ii,:));
            ii  = ii + 1;
            continue 
        elseif nb_contains(line,'@#echo')
            disp(strtrim(strrep(strrep(line,'@#echo',''),'"','')))
            ii  = ii + 1;
            continue 
        elseif nb_contains(line,'@#error')
            error(strtrim(strrep(strrep(line,'@#error',''),'"','')))
            ii  = ii + 1;
            continue     
        end
        
        if nb_contains(line,'@#if')
            [obj,parsedStatements,jumped] = parseIf(obj,statements(ii:end,:));
            ii = ii + jumped;
        elseif nb_contains(line,'@#for')
            [obj,parsedStatements,jumped] = parseFor(obj,statements(ii:end,:));
            ii = ii + jumped;
        else
            parsedStatements = statements(ii,:);
            ii = ii + 1;
        end
        numLine = size(parsedStatements,1);
        kk      = kk + numLine;
        if kk > maxKK
            parsed = [parsed;cell(50,c)]; %#ok<AGROW>
            maxKK  = maxKK + 50;  
        end
        parsed(kk-numLine+1:kk,:) = parsedStatements;
        
    end
    
    parsed = parsed(1:kk,:);
    
    % Now we need to parse the statements enclosed in @{}
    for ii = 1:kk
        expressions = regexp(parsed{ii,1},'@\{.*\}','match');
        for jj = 1:length(expressions)
            expr    = expressions{jj};
            exprInt = strrep(expr,'@{','');
            exprInt = strrep(exprInt,'}','');
            if isempty(exprInt)
                value = '';
            else
                try
                    out = eval(obj,exprInt); %#ok<EVLC>
                catch
                    error(['Could not interpret the following expression; ' expr '.'])
                end
                value = nb_any2String(out.value);
            end
            parsed{ii,1} = strrep(parsed{ii,1},expr,value);
        end
    end

end

%==========================================================================
function macroVars = parseDefine(macroVars,nbFileLine)

    line   = nbFileLine{1};
    indDef = strfind(line,'@#define');
    if indDef ~= 1
       error([mfilename ':: The @#define macro must come first in the line it is used. ' nb_dsge.lineError(nbFileLine)]) 
    end
    
    line  = line(9:end);
    indEq = strfind(line,'=');
    if isempty(indEq)
        error([mfilename ':: The @#define macro must be followed by a declaration. ' nb_dsge.lineError(nbFileLine)]) 
    end
    varName = strtrim(line(1:indEq-1));
    if isempty(varName)
        error([mfilename ':: The @#define macro must assign the expression to a variable. ' nb_dsge.lineError(nbFileLine)])
    end
    if ~isvarname(varName)
        error([mfilename ':: The @#define macro must assign the expression to a variable. ' nb_dsge.lineError(nbFileLine)])
    end
    expression = line(indEq+1:end);
    try
        macroVars = define(macroVars,varName,expression);
    catch Err
        if strcmpi(Err.identifier,'nb_macro:define:alreadyDefined')
            error([Err.message ' ' nb_dsge.lineError(nbFileLine)]);
        else
            error(['A expression assign to a @#define macro did give an error; ' strrep(expression,';','') ':: ' Err.message '. ' nb_dsge.lineError(nbFileLine)]);
        end
    end
    
end

%==========================================================================
function [macroVars,statements,jumped] = parseIf(macroVars,nbFileLine)

    line  = nbFileLine{1,1};
    indIf = strncmp(strtrim(line),'@#if',4);
    if ~indIf
       error([mfilename ':: The @#if(|def|ndef) macro must come first in the line it is used. ' nb_dsge.lineError(nbFileLine(1,:))]) 
    end
    if strncmp(line,'@#ifndef',8)
        % Test if the macro variable is not defined
        condition = strrep(line,'@#ifndef','');
        condition = strtrim(condition);
        condition = nb_macro('__XXX',~any(strcmp(condition,{macroVars.name})));
    elseif strncmp(line,'@#ifdef',7)
        % Test if the macro variable is defined
        condition = strrep(line,'@#ifdef','');
        condition = strtrim(condition);
        condition = nb_macro('__XXX',any(strcmp(condition,{macroVars.name})));
    else
        condition = strrep(line,'@#if','');
    end
    
    % Find locations of outer if statements
    N       = size(nbFileLine,1);
    ii      = 2;
    open    = 1;
    locElse = [];
    while ii <= N

        lineIter = nbFileLine{ii,1};
        
        indIf = strfind(strtrim(lineIter),'@#if');
        if ~isempty(indIf)
            if indIf ~= 1
               error([mfilename ':: The @#if(|def|ndef) macro must come first in the line it is used. ' nb_dsge.lineError(nbFileLine(ii,:))]) 
            end
            open = open + 1;
        end
        
        indElse = strfind(strtrim(lineIter),'@#else');
        if ~isempty(indElse)
            if indElse ~= 1
               error([mfilename ':: The @#else macro must come first in the line it is used. ' nb_dsge.lineError(nbFileLine(ii,:))]) 
            end
            lineIter = strrep(lineIter,'@#else','');
            lineIter = strtrim(lineIter);
            if ~isempty(lineIter)
                error([mfilename ':: The @#else macro must come alone in the line it is used. ' nb_dsge.lineError(nbFileLine(ii,:))]) 
            end
            if open == 1
                locElse = ii;
            end
        end
        
        indEndIf = strfind(strtrim(lineIter),'@#endif');
        if ~isempty(indEndIf)
            if indEndIf ~= 1
               error([mfilename ':: The @#endif macro must come first in the line it is used. ' nb_dsge.lineError(nbFileLine(ii,:))]) 
            end
            lineIter = strrep(lineIter,'@#endif','');
            lineIter = strtrim(lineIter);
            if ~isempty(lineIter)
                error([mfilename ':: The @#endif macro must come alone in the line it is used. ' nb_dsge.lineError(nbFileLine(ii,:))]) 
            end
            open = open - 1;
            if open == 0
                break
            end
        end
        ii = ii + 1;
        
    end
    
    if ii > N
        error([mfilename ':: The @#if macro block must be ended with a @#endif. ' nb_dsge.lineError(nbFileLine(1,:))]) 
    end
    jumped = ii;
    
    % Get the true and false statements of the if block
    if isempty(locElse)
        % No else
        statementTrue = nbFileLine(2:ii-1,:);
        statmentFalse = cell(0,size(nbFileLine,2));
    else
        statementTrue = nbFileLine(2:locElse-1,:);
        statmentFalse = nbFileLine(locElse+1:ii-1,:);
    end
    
    % Run the @#if block 
    try
        [macroVars,statements] = ifElseEnd(macroVars,condition,statementTrue,statmentFalse);
    catch Err
        if strcmpi(Err.identifier,'nb_macro:ifElseEnd:condition')
            error([mfilename ':: ' Err.message ' ' nb_dsge.lineError(nbFileLine(1,:))]) 
        else
            rethrow(Err);
        end
    end
    
end

%==========================================================================
function [macroVars,statements,jumped] = parseFor(macroVars,nbFileLine)

    line   = nbFileLine{1,1};
    indFor = strfind(line,'@#for');
    if indFor ~= 1
       error([mfilename ':: The @#for macro must come first in the line it is used. ' nb_dsge.lineError(nbFileLine(1,:))]) 
    end
    
    line      = strrep(line,'@#for','');
    splitLine = regexp(line,' in ','split');
    if length(splitLine) == 1
        error([mfilename ':: After the @#for macro you must assign the variable to loop by using an in statement. ' nb_dsge.lineError(nbFileLine(1,:))]) 
    end
    forVar = splitLine{1};
    looped = splitLine{2};
    
    % Find locations of outer if statements
    N       = size(nbFileLine,1);
    ii      = 2;
    open    = 1;
    while ii <= N

        lineIter = nbFileLine{ii,1};
        
        indFor = strfind(lineIter,'@#for');
        if ~isempty(indFor)
            if indFor ~= 1
               error([mfilename ':: The @#for macro must come first in the line it is used. ' nb_dsge.lineError(nbFileLine(ii,:))]) 
            end
            open = open + 1;
        end
        
        indEndFor = strfind(lineIter,'@#endfor');
        if ~isempty(indEndFor)
            if indEndFor ~= 1
               error([mfilename ':: The @#endfor macro must come first in the line it is used. ' nb_dsge.lineError(nbFileLine(ii,:))]) 
            end
            lineIter = strrep(lineIter,'@#endfor','');
            lineIter = strtrim(lineIter);
            if ~isempty(lineIter)
                error([mfilename ':: The @#endfor macro must come alone in the line it is used. ' nb_dsge.lineError(nbFileLine(ii,:))]) 
            end
            open = open - 1;
            if open == 0
                break
            end
        end
        ii = ii + 1;
        
    end

    if ii > N
        error([mfilename ':: The @#for macro block must be ended with a @#endfor. ' nb_dsge.lineError(nbFileLine(1,:))]) 
    end
    jumped = ii;
    
    % Get the looped statements of the @#for block
    forStatements = nbFileLine(2:ii-1,:);
    
    % Run the @#for block 
    try
        [macroVars,statements] = forEnd(macroVars,forVar,looped,forStatements);
    catch Err
        if strcmpi(Err.identifier,'nb_macro:forEnd:loop')
            error([mfilename ':: ' Err.message ' ' nb_dsge.lineError(nbFileLine(1,:))]) 
        else
            rethrow(Err); 
        end
    end
    
end
