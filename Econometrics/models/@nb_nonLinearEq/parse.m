function obj = parse(filename,varargin)
% Syntax:
%
% obj = nb_nonLinearEq.parse(filename,varargin)
%
% Description:
%
% Parse model file on the .nb format.
% 
% Input:
% 
% - filename : A string with the name of the model file with extension .nb.
% 
% Optional inputs:
%
% - 'macroProcessor' : See nb_nonLinearEq.help('macroProcessor').
%
% - 'macroVars'      : See nb_nonLinearEq.help('macroVars').
%
% - 'silent'         : See nb_nonLinearEq.help('silent').
%
% Output:
% 
% - obj : An object of class nb_nonLinearEq.
%
% See also:
% nb_nonLinearEq.template, nb_nonLinearEq.help
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    obj = nb_nonLinearEq();
    obj = set(obj,varargin{:});

    % Read the file
    [nbFile,file] = nb_model_parse.readFile(filename);
    
    % Macro processing
    if obj.options.macroProcessor
        [obj,nbFile] = parseMacro(obj,nbFile);
        if ~isempty(obj.options.macroWriteFile)
            nb_writePostMacroFile(nbFile,obj.options.macroWriteFile);
        end
    end
    
    % Parse model file
    if ~obj.options.silent
        tic;
        disp('Parsing the model using NB Toolbox: ')
    end
    
    parser      = nb_nonLinearEq.defaultParser();
    parser.file = file;
    try
        parser = parseFunction(parser,nbFile,1);
    catch Err
        throwAsCaller(Err);
    end
    
    % Check for parameter in use or not
    parser = checkParametersInUse(parser);
    if ~obj.options.silent
        notInUse = parser.parameters(~parser.parametersInUse);
        if ~isempty(notInUse)
            if ~obj.options.silent
                disp(['The following parameters are not part of the model: ' toString(notInUse)])
            end
        end
    end
    
    % Update option struct
    obj.options.constraints = parser.constraints;
    obj.options.equations   = parser.equations;
    obj.options.parameters  = parser.parameters;
    
    % Convert equations into a function handle
    parser = nb_nonLinearEq.eq2func(parser);
    
    % Assign to object
    obj.results.beta      = nan(length(parser.parameters),1);
    obj.estOptions.parser = parser;
    if ~obj.options.silent
        elapsedTime = toc;
        disp(['Finished in ' num2str(elapsedTime) ' seconds'])
    end
    
end

%==========================================================================
% SUB
%==========================================================================
function parser = parseFunction(parser,nbFile,lineNum)

    if size(nbFile,1) < lineNum
        return
    end

    next = nbFile{lineNum,1};
    if isempty(strtrim(next))
        lineNum = lineNum + 1;
        if size(nbFile,1) < lineNum
            return
        end
        next = nbFile{lineNum,1};
    end
    
    % Is it a endogenous block
    if strncmpi(next,'dependent',9)
        parser = parseVarBlock(parser,next(10:end),nbFile,lineNum,'dependent');
        return
    end
    
    % Is it a exogenous block
    if strncmpi(next,'varexo',6) 
        parser = parseVarBlock(parser,next(7:end),nbFile,lineNum,'exogenous');
        return
    elseif strncmpi(next,'exogenous',9)
        parser = parseVarBlock(parser,next(10:end),nbFile,lineNum,'exogenous');
        return
    end
    
    % Is it a parameter block
    if strncmpi(next,'parameters',10) 
        parser = parseVarBlock(parser,next(11:end),nbFile,lineNum,'parameters');
        return
    end
    
    % Is it the model block
    model = regexp(next,'^model;?','match');
    if ~isempty(model)
        parser = parseModelBlock(parser,next(size(model{1},2)+1:end),nbFile,lineNum,'','equations');
        return
    end
    
    % Is it the constraints block
    model = regexp(next,'^constraints;?','match');
    if ~isempty(model)
        parser = parseModelBlock(parser,next(size(model{1},2)+1:end),nbFile,lineNum,'','constraints');
        return
    end
    
    error([mfilename ':: ' parser.file ': syntax error, unrecognized expression. ' nb_newLine(2)...
          'Line ' int2str(nbFile{lineNum,2}) ': ' next])
    
end

%==========================================================================
function parser = parseVarBlock(parser,currentLine,nbFile,lineNum,type)

    % Loop empty lines
    if isempty(currentLine)
        lineNum = lineNum + 1;
        if size(nbFile,1) < lineNum 
            return
        end
        currentLine = nbFile{lineNum,1};
    end

    % Parse line
    [cont,matches,restOfLine] = isEndOfBlock(currentLine);
    parser.(type)             = [parser.(type), matches];
    if cont
        parser = parseVarBlock(parser,'',nbFile,lineNum,type);
    else
        if isempty(restOfLine)
            parser = parseFunction(parser,nbFile,lineNum + 1);
        else
            nbFile{lineNum,1} = restOfLine;
            parser            = parseFunction(parser,nbFile,lineNum);
        end
    end
    
end

%==========================================================================
function parser = parseModelBlock(parser,currentLine,nbFile,lineNum,cont,type)

    % Loop empty lines
    if isempty(currentLine)
        lineNum = lineNum + 1;
        if size(nbFile,1) < lineNum 
            error([mfilename ':: ' parser.file ': syntax error, unexpected end of file. Forgot a ''end'' after declearing a model block? Line ' int2str(nbFile{end,2})])
        end
        currentLine = nbFile{lineNum,1};
    end

    % Parse line
    indSemi = strfind(currentLine,';');
    if isempty(indSemi)
        [isEnd,ind] = isEndOfModelBlock(currentLine);
        if isEnd
            if ~isempty(strtrim(cont))
                error([mfilename ':: ' parser.file ': syntax error, unexpected end of model block. Forgot a ; after an equation? Line ' int2str(nbFile{lineNum,2})])
            else
                nbFile{lineNum,1} = currentLine(ind:end);
                parser            = parseFunction(parser,nbFile,lineNum);
            end
            return    
        else
            parser = parseModelBlock(parser,'',nbFile,lineNum,[cont,currentLine],type);
            return
        end
    else
        if strncmpi(currentLine,'end;',4)
            if ~isempty(strtrim(cont))
                error([mfilename ':: ' parser.file ': syntax error, unexpected end of model block. Forgot a ; after an equation? Line ' int2str(nbFile{lineNum,2})])
            else
                nbFile{lineNum,1} = currentLine(5:end);
                parser            = parseFunction(parser,nbFile,lineNum);
            end
            return  
        else
            restOfLine  = currentLine(indSemi(end)+1:end); 
            currentLine = currentLine(1:indSemi(end)-1);
            currentLine = [cont, currentLine];
        end
    end
    matches       = regexp(currentLine,';','split');
    indKeep       = ~cellfun(@isempty,matches);
    matches       = matches(indKeep);
    matches       = strtrim(matches);
    matches       = regexprep(matches,'\[.+\]',''); 
    parser.(type) = [parser.(type); matches(:)];
    
    if strncmpi(restOfLine,'end',3)
        nbFile{lineNum,1} = restOfLine(4:end);
        parser            = parseFunction(parser,nbFile,lineNum);
        return
    else
        parser = parseModelBlock(parser,'',nbFile,lineNum,restOfLine,type);
        return
    end
     
end


%==========================================================================
function parser = checkParametersInUse(parser)

    param   = parser.parameters;
    paramS  = flip(sort(param),2); % We sort to make the longer parameter names to be found before shorter (e.g. beta2 before beta)
    matches = nb_dsge.getUniqueMatches(parser.equations,parser.dependent,parser.exogenous);
    inUse   = ismember(paramS,matches);
    
    parser.parametersInUse = inUse;
    parser.parameters      = paramS;
    
end

%==========================================================================
function [cont,matches,restOfLine] = isEndOfBlock(currentLine)

    cont    = true;
    indSemi = strfind(currentLine,';');
    if ~isempty(indSemi)
        cont        = false;
        restOfLine  = currentLine(indSemi(1)+1:end);
        currentLine = currentLine(1:indSemi(1)-1);
    else
        restOfLine = '';
    end
    matches = regexp(currentLine,'(\s|,)','split');
    indKeep = ~cellfun(@isempty,matches);
    matches = matches(indKeep); 
    types   = {'dependent','exogenous','varexo','parameters','model','constraints'};
    test    = ismember(lower(matches),types);
    if any(test)
        cont             = false;
        indStop          = find(test,1);
        matchesRest      = strcat(matches(indStop:end),',');
        matchesRest{end} = strrep(matchesRest{end},',','');
        restOfLine       = [matchesRest{:},restOfLine];
        matches          = matches(1:indStop-1);
    end
    
end

%==========================================================================
function [isEnd,ind] = isEndOfModelBlock(currentLine)

    isEnd = false;
    types = {'dependent','exogenous','varexo','parameters','model','end','constraints'};
    for ii = 1:length(types)
        ind = size(types{ii},2);
        if strncmpi(currentLine,types{ii},ind)
            isEnd = true;
            if ii == length(types)
                ind = 4;
            elseif ii == length(types) - 1
                ind = 12;
            else
                ind = 1;
            end
            break
        end
    end
    
end
