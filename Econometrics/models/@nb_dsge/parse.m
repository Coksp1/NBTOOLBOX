function obj = parse(filename,varargin)
% Syntax:
%
% obj = nb_dsge.parse(filename,varargin)
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
% (Most relevant to parsing)
%
% - 'macroProcessor' : See nb_dsge.help('macroProcessor').
%
% - 'macroVars'      : See nb_dsge.help('macroVars').
%
% - 'silent'         : See nb_dsge.help('silent').
%
% Output:
% 
% - obj : An object of class nb_dsge.
%
% See also:
% nb_dsge.solve, nb_dsge.help
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    ind = cellfun(@(x)isa(x,'nb_dsge'),varargin);
    if any(ind) % Used by reparse!
        obj      = varargin{ind};
        varargin = varargin(~ind);
    else
        obj = nb_dsge();
    end
    obj    = set(obj,varargin{:});
    silent = obj.options.silent;
    
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
    if ~silent
        tic;
        disp('Parsing the model using NB Toolbox: ')
    end
    
    parser          = nb_dsge.getDefaultParser();
    parser.discount = {};
    parser.file     = file;
    try
        parser = parseFunction(parser,nbFile,1);
    catch Err
        throwAsCaller(Err);
    end
    if ~isempty(parser.discount)
        obj.options.discount = [parser.discount{:}];
    end
    parser = rmfield(parser,'discount');
    
    % Simple tests 
    if ~isempty(parser.static)
        
        if parser.staticLoc(1) < 1
           error([mfilename ':: The first equation of the model file cannot be tagged as static!']) 
        end
        staticUnique = unique(parser.staticLoc);
        if length(staticUnique) ~= length(parser.staticLoc)
            
            staticErr = {};
            for ii = 1:length(staticUnique)
               if sum(staticUnique(ii) == parser.staticLoc) > 1
                   staticErr = [staticErr;parser.equations{staticUnique(ii)}]; %#ok<AGROW>
               end
            end
            staticErr = strcat(staticErr,'\n');
            staticErr = horzcat(staticErr{:});
            error('nb_dsge:parse:staticEqs',[mfilename ':: The above listed equations has been provided more than one static equation.\n\n' staticErr],'')
            
        end
        
    end
    
    if ~isempty(parser.growth)
        
        if parser.growthLoc(1) < 1
           error([mfilename ':: The first equation of the model file cannot be tagged as growth!']) 
        end
        growthUnique = unique(parser.growthLoc);
        if length(growthUnique) ~= length(parser.growthLoc)
            
            growthErr = {};
            for ii = 1:length(growthUnique)
               if sum(growthUnique(ii) == parser.growthLoc) > 1
                   growthErr = [growthErr;parser.equations{growthUnique(ii)}]; %#ok<AGROW>
               end
            end
            growthErr = strcat(growthErr,'\n');
            growthErr = horzcat(growthErr{:});
            error('nb_dsge:parse:growthEqs',[mfilename ':: The above listed equations has been provided more than one growth equation.\n\n' growthErr],'')
            
        end
        
    end
    
    % Check that all symbolic expression are declared.
    endo  = [parser.endogenous, parser.unitRootVars, parser.obs_endogenous];
    exo   = [parser.exogenous, parser.obs_exogenous, 'Constant'];
    eqs   = [parser.equations; parser.obs_equations];
    check = nb_dsge.getUniqueMatches(eqs,parser.parameters,exo,endo);
    if ~isempty(check) 
        ind   = ismember(check,strcat(endo,nb_dsge.steadyStateInitPostfix));
        check = check(~ind);
        if any(ind)
            parser.steadyStateInitUsed = true;
        end
        if ~isempty(parser.unitRootVars)
            ind   = ismember(check,strcat(nb_dsge.growthPrefix,parser.unitRootVars));
            check = check(~ind);
        end
        if ~isempty(check) 
            check = strcat(check','\n');
            check = horzcat(check{:});
            error('nb_dsge:parse',[mfilename ':: The following variables/parameters are not defined in the model file:\n\n' check],'')
        end
    end
    
    % Is the model file using the steady_state_first function?
    found = nb_contains(eqs,'steady_state_first(');
    if any(found)
        parser.steadyStateFirstUsed = true;
    end
    
    % Test for duplications
    testForDuplication(parser,'endogenous');
    testForDuplication(parser,'exogenous');
    testForDuplication(parser,'parameters');
    testForDuplication(parser,'unitRootVars');
    
    % Test for multiple declarations
    testForMultipleDeclarations(parser,'parameters','endogenous');
    testForMultipleDeclarations(parser,'parameters','exogenous');
    testForMultipleDeclarations(parser,'parameters','unitRootVars');
    testForMultipleDeclarations(parser,'exogenous','endogenous');
    testForMultipleDeclarations(parser,'exogenous','unitRootVars'); 
    testForMultipleDeclarations(parser,'endogenous','unitRootVars');
     
    % Check that the observables are also declared as a endogenous 
    % variable
    endo = [parser.endogenous, parser.obs_endogenous];
    ind  = ismember(parser.observables,endo);
    if any(~ind)
        error([mfilename ':: The observable variable(s) '  toString(parser.observables(~ind)) ' is/are not (a) '...
                         'endogenous variable(s).'])
    end
    
    % Sort break-points
    if parser.nBreaks > 1
        dates              = {parser.breakPoints.date};
        dates              = cellfun(@toString,dates,'uniformOutput',false);
        [~,sortInd]        = sort(dates);
        parser.breakPoints = parser.breakPoints(sortInd);
    end
    
    % Remove equality signs
    parser.equations = nb_model_parse.removeEquality(parser.equations);
    if ~isempty(parser.static)
        parser.static = nb_model_parse.removeEquality(parser.static);
    end
    if ~isempty(parser.growth)
        parser.growth = nb_model_parse.removeEquality(parser.growth);
    end
    if ~isempty(parser.staticEquations)
        parser.staticEquations = nb_model_parse.removeEquality(parser.staticEquations);
    end
    if ~isempty(parser.obs_equations)
        parser.obs_equations = nb_model_parse.removeEquality(parser.obs_equations);
    end
    
    % Check for parameter in use or not
    parser = checkParametersInUse(parser);
    
    % Interpret simple rules (Must be before nb_dsge.getLeadLag)
    if isfield(parser,'simpleRules')
        if isempty(parser.simpleRules)
            error([mfilename ':: If you use the simpleRules block, you need to provide a least one rule!'])
        end
        parser.optimalSimpleRule = true;
        parser.optimal           = false;
        parser                   = nb_dsge.parseSimpleRules(parser,parser.simpleRules);
    else
        parser.optimalSimpleRule = false;
    end
    
    % Get lead/ lag incidence
    parser = nb_dsge.getLeadLag(parser);
    if ~isempty(parser.obs_equations)
        parser = nb_dsge.getLeadLagObsModel(parser);
    else
        parser.all_endogenous = parser.endogenous;
        parser.all_exogenous  = parser.exogenous;
    end
    
    % Interpret loss function (Must be after nb_dsge.getLeadLag)
    if isfield(parser,'lossFunction')
        parser.optimal = true;
        parser         = nb_dsge.parseLossFunction(parser,parser.lossFunction);
    else
        parser.optimal = false;
    end
    
    % Give warning on parameters not in use.
    if ~silent
        notInUse = parser.parameters(~parser.parametersInUse);
        if ~isempty(notInUse)
            if ~silent
                disp(['The following parameters are not part of the model: ' toString(notInUse)])
            end
        end
    end
    
    % Now we need to convert the equation into a function handle
    numEndo     = size(parser.endogenous,2);
    numEq       = size(parser.equationsParsed,1);
    runEqs2Func = true;
    if ~isempty(parser.unitRootVars) || parser.steadyStateInitUsed
        runEqs2Func = false;
    else
        if parser.optimal
            if numEndo <= numEq
                runEqs2Func = false;
            end   
        else
            if numEndo > numEq
                runEqs2Func = false;
            end
            if numEndo < numEq
                runEqs2Func = false;
            end
        end
    end
    if runEqs2Func
        parser = nb_dsge.eqs2func(parser);
        parser = rmfield(parser,'equationsParsed');
    end
    
    % Create nb_dsge object
    obj = updateObject(obj,parser);
    if parser.optimal
        obj.options.lc_discount   = parser.lc_discount;
        obj.options.lc_commitment = parser.lc_commitment;
        parser                    = rmfield(parser,{'lc_discount','lc_commitment'});
    end
    parser                   = rmfield(parser,{'observables'});
    obj.estOptions.parser    = parser;
    obj.estOptions.parser    = rmfield(obj.estOptions.parser,{'reporting'});
    obj.estOptions.estimType = 'bayesian';
    obj                      = assignSSAndParam(obj);
    
    % Have the reporting block been used?
    if ~nb_isempty(parser.reporting)
        rep = nb_struct2cellarray(parser.reporting,'matrix');
        rep = [rep,cell(size(rep,1),1)];
        obj = set(obj,'reporting',rep);
    end
    
    if ~silent
        elapsedTime = toc;
        disp(['Finished in ' num2str(elapsedTime) ' seconds'])
    end
    
end

%==========================================================================
% SUB
%==========================================================================
function obj = assignSSAndParam(obj)

    if ~nb_isempty(obj.estOptions.parser.parameterization)
        obj = assignParameters(obj,obj.estOptions.parser.parameterization);
    end
    if ~nb_isempty(obj.estOptions.parser.steady_state_model)
        obj = set(obj,'steady_state_init',obj.estOptions.parser.steady_state_model);
    end
    obj.estOptions.parser = rmfield(obj.estOptions.parser,{'parameterization','steady_state_model'});

end

%==========================================================================
function testForDuplication(parser,type)

    if ~isempty(parser.(type))
        if strcmpi(type,'parameters')
            string = 'parameters';
        elseif strcmpi(type,'unitrootvars')
            string = 'unit root variables';
        else
            string = [type, ' variables'];
        end
        isDup = nb_duplicated(parser.(type));
        if isDup
            [~,dup] = nb_duplicated(parser.(type));
            error([mfilename ':: The following ' string ' where duplicated in the model file; ' toString(dup)])
        end
    end
    
end

%==========================================================================
function testForMultipleDeclarations(parser,type1,type2)

    ind = ismember(parser.(type1),parser.(type2));
    if any(ind)
        if strcmpi(type1,'parameters')
            string1 = 'parameter';
        elseif strcmpi(type1,'unitrootvars')
            string1 = 'unit root variable';
        else
            string1 = [type1, ' variable'];
        end
        if strcmpi(type2,'parameters')
            string2 = 'parameter';
        elseif strcmpi(type2,'unitrootvars')
            string2 = 'unit root variable';
        else
            string2 = [type2, ' variable'];
        end
        multiple = parser.(type1);
        error([mfilename ':: The ' type1 ' '  toString(multiple(ind)) ' are both declared '...
                         'as a ' string1 ' and as a ' string2 '.'])
    end
    
end

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
    if strncmpi(next,'var',3) && ~(strncmpi(next,'varexo',6) || strncmpi(next,'varobs',6))
        parser = parseVarBlock(parser,next(4:end),nbFile,lineNum,'endogenous');
        return
    elseif strncmpi(next,'endogenous',10)
        parser = parseVarBlock(parser,next(11:end),nbFile,lineNum,'endogenous');
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
    
    % Is it a unit root variables
    if strncmpi(next,'unitrootvars',12) 
        parser = parseVarBlock(parser,next(13:end),nbFile,lineNum,'unitRootVars');
        return
    end
    
    % Is it a parameters(static) block
    if strncmpi(next,'parameters(static)',18) 
        parser = parseVarBlock(parser,next(19:end),nbFile,lineNum,'parametersStatic');
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
        parser = parseModelBlock(parser,'equations',next(size(model{1},2)+1:end),nbFile,lineNum,'');
        return
    end
    
    % Is it the static block
    model = regexp(next,'^static;?','match');
    if ~isempty(model)
        parser = parseModelBlock(parser,'staticEquations',next(size(model{1},2)+1:end),nbFile,lineNum,'');
        return
    end
    
    % Is it a observables block
    if strncmpi(next,'observables',11) 
        parser = parseVarBlock(parser,next(12:end),nbFile,lineNum,'observables');
        return
    elseif strncmpi(next,'varobs',6) 
        parser = parseVarBlock(parser,next(7:end),nbFile,lineNum,'observables');
        return
    end
    
    % Parameterization block?
    if strncmpi(next,'parameterization',16)
        ind = 17;
        if strncmp(next(ind:end),';',1)
            ind = ind + 1;
        end
        parser = parseAssignmentBlock(parser,next(ind:end),nbFile,lineNum,'parameterization','');
        return
    end
    
    % Steady state block?
    if strncmpi(next,'steady_state_model',18)
        ind = 19;
        if strncmp(next(ind:end),';',1)
            ind = ind + 1;
        end
        parser = parseAssignmentBlock(parser,next(ind:end),nbFile,lineNum,'steady_state_model','');
        return
    end
    
    % Break point block
    if strncmpi(next,'breakPoint',10) 
        
        parser.nBreaks = parser.nBreaks + 1;
        currentLine    = next(11:end);
        indOpen        = strfind(currentLine,'{');
        indClose       = strfind(currentLine,'}');
        if or(isempty(indOpen) && ~isempty(indClose),~isempty(indOpen) && isempty(indClose))
            error([mfilename ':: ' parser.file ': syntax error. The date input to the breakPoint command must be enclosed with {}! Line ' int2str(nbFile{lineNum,2})])
        elseif ~isempty(indOpen) && ~isempty(indClose)
            date = currentLine(indOpen+1:indClose-1);
            try
                date = nb_date.date2freq(date);
            catch
                error([mfilename ':: ' parser.file ': syntax error. The date input to the breakPoint command must be a date on the correct format! See nb_date.date2freq. Line ' int2str(nbFile{lineNum,2})])
            end
            if isempty(parser.breakPoints)
                parser.breakPoints = struct('parameters',{{}},'values',[],'date',date);
            else
                
                % Check that the break dates are unique 
                dates = {parser.breakPoints.date};
                dates = cellfun(@toString,dates,'uniformOutput',false);
                ind   = strcmp(toString(date),dates);
                if any(ind)
                   error([mfilename ':: ' parser.file ': syntax error.  The added break point cannot happend on the same time as another break (' toString(date) '). Line ' int2str(nbFile{lineNum,2})])
                end
                
                % Append
                parser.breakPoints(parser.nBreaks)      = nb_dsge.createDefaultBreakPointStruct();
                parser.breakPoints(parser.nBreaks).date = date;
                
            end
            currentLine = strtrim([currentLine(1:indOpen-1),currentLine(indClose+1:end)]);
        else
            error([mfilename ':: ' parser.file ': syntax error. The date input to the breakPoint command must be enclosed with {}! Line ' int2str(nbFile{lineNum,2})])
        end
        parser = breakPointBlock(parser,currentLine,nbFile,lineNum);
        return
        
    end
    
    % Is it a optimal policy block?
    if strncmpi(next,'planner_objective',17) 
        
        currentLine = next(18:end);
        indOpen     = strfind(currentLine,'{');
        indClose    = strfind(currentLine,'}');
        if or(isempty(indOpen) && ~isempty(indClose),~isempty(indOpen) && isempty(indClose))
            error([mfilename ':: ' parser.file ': syntax error. Optional inputs to the planner_objective command must be enclosed with {}! Line ' int2str(nbFile{lineNum,2})])
        elseif ~isempty(indOpen) && ~isempty(indClose)
            options     = currentLine(indOpen+1:indClose-1);
            parser      = interpretLossOptions(parser,options);
            currentLine = strtrim([currentLine(1:indOpen-1),currentLine(indClose+1:end)]);
        end
        parser = parsePlannerObjectiveBlock(parser,currentLine,nbFile,lineNum,'');
        return
        
    end
    
    % Is it a unit root block?
%     if strncmpi(next,'unitroot',8)
%         parser = parseUnitRootBlock(parser,next(9:end),nbFile,lineNum,'unitRoot','');
%         return
%     end
    
    % Is it a reporting block?
    if strncmpi(next,'reporting',9) 
        parser = parseReportingBlock(parser,next(10:end),nbFile,lineNum,'reporting','');
        return      
    end
    
    % Is it the constraints block?
    model = regexp(next,'^constraints;?','match');
    if ~isempty(model)
        parser = parseModelBlock(parser,'constraints',next(size(model{1},2)+1:end),nbFile,lineNum,'');
        return
    end
    
    % Is it the obs_endogenous block?
    if strncmpi(next,'obs_endogenous',14)
        parser = parseVarBlock(parser,next(15:end),nbFile,lineNum,'obs_endogenous');
        return
    end
    
    % Is it the obs_exogenous block?
    if strncmpi(next,'obs_exogenous',13)
        parser = parseVarBlock(parser,next(14:end),nbFile,lineNum,'obs_exogenous');
        return
    end

    % Is it the observation model block?
    model = regexp(next,'^obs_model;?','match');
    if ~isempty(model)
        parser = parseModelBlock(parser,'obs_equations',next(size(model{1},2)+1:end),nbFile,lineNum,'');
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
    [cont,matches,restOfLine] = isEndOfBlock(currentLine,true);
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
function parser = parseModelBlock(parser,type,currentLine,nbFile,lineNum,cont)

    % Loop empty lines
    if isempty(currentLine)
        lineNum = lineNum + 1;
        if size(nbFile,1) < lineNum 
            return
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
            parser = parseModelBlock(parser,type,'',nbFile,lineNum,[cont,currentLine]);
            return
        end
    else
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
            restOfLine  = currentLine(indSemi(end)+1:end); 
            currentLine = currentLine(1:indSemi(end)-1);
            currentLine = [cont, currentLine];
        end
    end
    
    nEqs            = length(parser.equations);
    matches         = regexp(currentLine,';','split');
    indKeep         = ~cellfun(@isempty,matches);
    matches         = matches(indKeep);
    matches         = strtrim(matches);
    types           = regexp(matches,'^\[.+\]','match'); % Looking for [static] tag
    indEmpty        = cellfun(@isempty,types);
    types(indEmpty) = {{''}};
    types           = [types{:}];
    staticInd       = nb_contains(types,'static');
    growthInd       = nb_contains(types,'growth');
    discountInd     = nb_contains(types,'discount');
    matches         = regexprep(matches,'\[.+\]',''); % Remove all other optional options to equations which is supported in dynare
    matchesDyn      = matches(~(staticInd | growthInd));
    parser.(type)   = [parser.(type); matchesDyn(:)];
    if discountInd
        if ~strcmpi(type,'equations')
            error([mfilename ':: You can only use the [discount=num] syntax in the model block. Line ' int2str(nbFile{lineNum,2})])
        end
        eqInd = strfind(types{1},'=');
        if isempty(eqInd)
            error([mfilename ':: ' parser.file ': syntax error. = must be added after discount. Correct syntax is ',...
                             '[discount=num]. Line ' int2str(nbFile{lineNum,2})])
        end
        bracketInd  = strfind(types{1},']');
        discount    = types{1}(eqInd+1:bracketInd-1);
        discountNum = str2double(discount);
        if ~isnan(discountNum)
            discount = '';
        end
        eqNum           = size(parser.(type),1);
        parser.discount = [parser.discount,{struct('eq',eqNum,'value',discountNum,'name',discount)}];
    end
    
    if any(staticInd)
        if ~strcmpi(type,'equations')
            error([mfilename ':: You can only use the [static] syntax in the model block. Line ' int2str(nbFile{lineNum,2})])
        end
        staticLoc        = nEqs + find(staticInd) - 1;
        matchesStatic    = matches(staticInd);
        parser.static    = [parser.static; matchesStatic(:)];
        parser.staticLoc = [parser.staticLoc;staticLoc(:)];
    end
    
    if any(growthInd)
        if ~strcmpi(type,'equations')
            error([mfilename ':: You can only use the [growth] syntax in the model block. Line ' int2str(nbFile{lineNum,2})])
        end
        growthLoc        = nEqs + find(growthInd) - 1;
        matchesGrowth    = matches(growthInd);
        parser.growth    = [parser.growth; matchesGrowth(:)];
        parser.growthLoc = [parser.growthLoc;growthLoc(:)];
    end
    
    if strncmpi(restOfLine,'end',3)
        nbFile{lineNum,1} = restOfLine(4:end);
        parser            = parseFunction(parser,nbFile,lineNum);
        return
    else
        parser = parseModelBlock(parser,type,'',nbFile,lineNum,restOfLine);
        return
    end
     
end

%==========================================================================
function parser = parseAssignmentBlock(parser,currentLine,nbFile,lineNum,type,cont)

    % Loop empty lines
    if isempty(currentLine)
        lineNum = lineNum + 1;
        if size(nbFile,1) < lineNum 
            return
        end
        currentLine = nbFile{lineNum,1};
    end

    % Parse line
    [ret,parser,restOfLine,currentLine] = parseLine(parser,currentLine,nbFile,lineNum,type,cont,@parseAssignmentBlock);
    if ret
        return
    end
    
    % Parse the assignment of a parameter
    if strcmp(type,'parameterization')
        tag = 'parameter';
    else
        tag = 'variable';
    end
    
    out = strtrim(regexp(currentLine,'[,=]','split'));
    if size(out,2) < 2 || size(out,2) > 2
        error([mfilename ':: ' parser.file ': The ' tag ' ' out{1} ' must be assign a (and only one!) scalar number with use of either',...
                         ' '','' or ''='' in the ' type ' block. E.g. name [,=] value;. Line ' int2str(nbFile{lineNum,2})])
    end
    out{2} = str2double(out{2});
    if isnan(out{2})
        error([mfilename ':: ' parser.file ': The ' tag ' ' out{1} ' must be assign a scalar number in ',...
                         'the ' type ' block. Line ' int2str(nbFile{lineNum,2})])
    end
    try
        parser.(type).(out{1}) = out{2};
    catch
        error([mfilename ':: ' parser.file ': The ' tag ' ' out{1} ' is not a valid ' tag ' name (used in the ',...
                         type ' block). Line ' int2str(nbFile{lineNum,2})])
    end
    
    % Continue parsing the parameterization block?
    parser = parseAssignmentBlock(parser,'',nbFile,lineNum,type,restOfLine);
 
end

%==========================================================================
function parser = parseUnitRootBlock(parser,currentLine,nbFile,lineNum,type,cont)

    % Loop empty lines
    if isempty(currentLine)
        lineNum = lineNum + 1;
        if size(nbFile,1) < lineNum 
            return
        end
        currentLine = nbFile{lineNum,1};
    end

    % Parse line
    [ret,parser,restOfLine,currentLine] = parseLine(parser,currentLine,nbFile,lineNum,type,cont,@parseUnitRootBlock);
    if ret
        return
    end
    
    % Parse the unit root settings
    tag = 'variable';
    out = strtrim(regexp(currentLine,',','split'));
    if size(out,2) ~= 5
        error([mfilename ':: ' parser.file ': The ' tag ' ' out{1} ' must be given unit root settings with the ',...
                         'following syntax: name, growthRate, AR coeff, exogenous, stdError; ',...
                         'Line ' int2str(nbFile{lineNum,2})])
    end
    [name,growthRate,ARcoeff,distr,std] = deal(out{:});
    unitRootEq             = ['log(D_Z_' name ') - (1-' ARcoeff ')*log(' growthRate ') - ' ARcoeff '*log(D_Z_' name '(-1)) - ' std '*' distr];  
    parser.unitRoot        = [parser.unitRoot;unitRootEq];
    parser.unitRootGrowth  = [parser.unitRootGrowth;growthRate];
    parser.unitRootVars    = [parser.unitRootVars,name];
    parser.unitRootOptions = [parser.unitRootOptions;{ARcoeff,distr,std}];
    
    % Continue parsing the reporting block?
    parser = parseUnitRootBlock(parser,'',nbFile,lineNum,type,restOfLine);

end

%==========================================================================
function parser = parseReportingBlock(parser,currentLine,nbFile,lineNum,type,cont)

    % Loop empty lines
    if isempty(currentLine)
        lineNum = lineNum + 1;
        if size(nbFile,1) < lineNum 
            return
        end
        currentLine = nbFile{lineNum,1};
    end

    % Parse line
    [ret,parser,restOfLine,currentLine] = parseLine(parser,currentLine,nbFile,lineNum,type,cont,@parseReportingBlock);
    if ret
        return
    end
    
    % Parse the reporting equation
    tag = 'variable';
    out = strtrim(regexp(currentLine,'[,=]','split'));
    if size(out,2) < 2 || size(out,2) > 2
        error([mfilename ':: ' parser.file ': The ' tag ' ' out{1} ' must be assign a (and only one!) equation with use of either',...
                         ' '','' or ''='' in the ' type ' block. E.g. name [,=] equation;. Line ' int2str(nbFile{lineNum,2})])
    end
    try
        parser.(type).(out{1}) = out{2};
    catch
        error([mfilename ':: ' parser.file ': The ' tag ' ' out{1} ' is not a valid ' tag ' name (used in the ',...
                         type ' block). Line ' int2str(nbFile{lineNum,2})])
    end
    
    % Continue parsing the reporting block?
    parser = parseReportingBlock(parser,'',nbFile,lineNum,type,restOfLine);

end

%==========================================================================
function parser = breakPointBlock(parser,currentLine,nbFile,lineNum)

    % Loop empty lines
    if isempty(currentLine)
        lineNum = lineNum + 1;
        if size(nbFile,1) < lineNum 
            error([mfilename ':: ' parser.file ': syntax error, unexpected end of file. Forgot a ; after declearing a ' type ' block? Line ' int2str(nbFile{lineNum,2})])
        end
        currentLine = nbFile{lineNum,1};
    end
    
    % Optional inputs
    if nb_contains(currentLine,'{') || nb_contains(currentLine,'{')
        error([mfilename ':: ' parser.file ': syntax error, unexpected { or }. The date input to the breakPoint command must come on ',...
                         'the same line as the command? Line ' int2str(nbFile{lineNum,2})])
    end

    % Parse line
    [cont,matches,restOfLine]                     = isEndOfBlock(currentLine,false);
    parser.breakPoints(parser.nBreaks).parameters = [parser.breakPoints(parser.nBreaks).parameters, matches];
    if cont
        parser = breakPointBlock(parser,'',nbFile,lineNum);
    else
        parser.breakPoints(parser.nBreaks).values = nan(size(parser.breakPoints(parser.nBreaks).parameters));
        if isempty(restOfLine)
            parser = parseFunction(parser,nbFile,lineNum + 1);
        else
            nbFile{lineNum,1} = restOfLine;
            parser            = parseFunction(parser,nbFile,lineNum);
        end
    end
 
end

%==========================================================================
function parser = parsePlannerObjectiveBlock(parser,currentLine,nbFile,lineNum,cont)

    % Loop empty lines
    if isempty(currentLine)
        lineNum = lineNum + 1;
        if size(nbFile,1) < lineNum 
            error([mfilename ':: ' parser.file ': syntax error, unexpected end of file. Forgot a '';'' after using the planner_objective command? Line ' int2str(nbFile{lineNum,2})])
        end
        currentLine = nbFile{lineNum,1};
    end
    
    % Optional inputs
    if nb_contains(currentLine,'{') || nb_contains(currentLine,'{')
        error([mfilename ':: ' parser.file ': syntax error, unexpected { or  }. The optional inputs to the planner_objective command must come on ',...
                         'the same line as the command! Line ' int2str(nbFile{lineNum,2})])
    end
    
    % Parse line
    indSemi = strfind(currentLine,';');
    if isempty(indSemi)
        parser = parsePlannerObjectiveBlock(parser,'',nbFile,lineNum,[cont,currentLine]);
        return
    else
        restOfLine  = currentLine(indSemi(end)+1:end); 
        currentLine = currentLine(1:indSemi(end)-1);
        currentLine = [cont, currentLine];
    end
    parser.lossFunction = currentLine;    
    nbFile{lineNum,1}   = restOfLine;
    parser              = parseFunction(parser,nbFile,lineNum);
    return
     
end

%==========================================================================
function parser = interpretLossOptions(parser,options)

    % Default
    parser.lc_discount   = 0.99;
    parser.lc_commitment = 0;
    
    % Parse options
    options  = regexp(options,',','split');
    options  = regexp(options,'=','split');
    options  = strtrim([options{:}]);
    nOptions = length(options);
    if rem(nOptions,2) ~= 0
        error([mfilename ':: The optional inputs given to the planner_objective command must come in pairs (separated by =).'])
    end
    for ii = 1:2:length(options)
    
        optionName  = lower(options{ii});
        optionValue = options{ii+1};
        switch optionName
            case 'discount'
                optionValue = str2double(optionValue);
                if isnan(optionValue)
                    error([mfilename ':: The planner_objective input ' optionName ' must be convertable to a number.'])
                end
                if optionValue >= 1 || optionValue <= 0
                     error([mfilename ':: The planner_objective input ' optionName ' must be (strictly) between 0 and 1.'])
                end
                fieldName = 'lc_discount';
            case 'commitment'
                optionValue = str2double(optionValue);
                if isnan(optionValue)
                    error([mfilename ':: The planner_objective input ' optionName ' must be convertable to a number.'])
                end
                if optionValue > 1 || optionValue < 0
                     error([mfilename ':: The planner_objective input ' optionName ' must be between 0 and 1.'])
                end
                fieldName = 'lc_commitment';
            case 'optimalstatic'
                fieldName = 'optimalstatic';
            otherwise
                error([mfilename ':: The planner_objective command does not take an input ' optionName '.'])
        end
        parser.(fieldName) = optionValue;
        
    end
    
end

%==========================================================================
function parser = checkParametersInUse(parser)

    param   = parser.parameters;
    paramS  = flip(sort(param),2); % We sort to make the longer parameter names to be found before shorter (e.g. beta2 before beta)
    matches = nb_dsge.getUniqueMatches(parser.equations,parser.endogenous,parser.exogenous);
    if ~isempty(parser.static)
        matchesS = nb_dsge.getUniqueMatches(parser.static,parser.endogenous,parser.exogenous);
        matches  = [matches,matchesS];
    end
    if ~isempty(parser.obs_equations)
        all_endogenous = [parser.endogenous,parser.obs_endogenous];
        all_exogenous  = [parser.exogenous,parser.obs_exogenous,'Constant'];
        matchesObs     = nb_dsge.getUniqueMatches(parser.obs_equations,all_endogenous,all_exogenous);
        matches        = [matches,matchesObs];
    end
    inUse                        = ismember(paramS,matches);
    parser.parametersInUse       = inUse;
    parser.parameters            = paramS;
    parser.parametersIsUncertain = false(size(paramS));
    
end

%==========================================================================
function [ret,parser,restOfLine,currentLine] = parseLine(parser,currentLine,nbFile,lineNum,type,cont,func)

    ret     = false;
    indSemi = strfind(currentLine,';');
    if isempty(indSemi)
        [contin,matches,restOfLine] = isEndOfBlock(currentLine,false);
        if ~contin
            if ~isempty(matches)
                error([mfilename ':: ' parser.file ': syntax error, unexpected end of ' type ' block. Forgot a ; after an assignment? Line ' int2str(nbFile{lineNum,2})])
            else
                nbFile{lineNum,1} = restOfLine;
                parser            = parseFunction(parser,nbFile,lineNum);
            end
            ret = true;
            return    
        else
            parser = func(parser,'',nbFile,lineNum,type,[cont,currentLine]);
            ret    = true;
            return
        end
    else
        restOfLine  = currentLine(indSemi(end)+1:end); 
        currentLine = currentLine(1:indSemi(end)-1);
        currentLine = [cont, currentLine];
    end
    
end

%==========================================================================
function [cont,matches,restOfLine] = isEndOfBlock(currentLine,type)

    if type
        % Remove name tag as in RISE; varName "nameOfVar"
        currentLine = regexprep(currentLine,'"[\w\(][^"]*[\w\)]"','');
        % Remove name tag as in Dynare; varName $nameOfVar$
        currentLine = regexprep(currentLine,'\$[\w{][^$]*[\w}]\$','');
        currentLine = regexprep(currentLine,'/\*\d+\*/','');
        currentLine = regexprep(currentLine,'\(long_name.+\)','');
    end

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
    types   = getBlocks();
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
    types = [getBlocks(),{'end;','end'}];
    for ii = 1:length(types)
        ind = size(types{ii},2);
        if regexp(currentLine,['^' types{ii} '(?!\S)']) 
            isEnd = true;
            if ii == length(types) - 1
                ind = 5;
            elseif ii == length(types)
                ind = 4;
            else
                ind = 1;
            end
            break
        end
    end
    
end

%==========================================================================
function types = getBlocks()
    
    types = {'endogenous','var','exogenous','varexo','parameters',...
             'parameterization','observables','varobs','planner_objective',...
             'breakpoint','model','steady_state_model','reporting',...
             'unitrootvars','obs_endogenous','obs_exogenous',...
             'obs_model'};

end