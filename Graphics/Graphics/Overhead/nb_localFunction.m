function outString = nb_localFunction(obj,inString)
% Syntax:
%
% outString = nb_localFunction(obj,inString)
%
% Description:
%
% Finds the local function used in a char or a cellstr, i.e.
% a word starting with %#obj., and substitutes it with the matching
% method of the provided object.
% 
% Input:
% 
% - obj       : A NB toolbox object.
%
% - inString  : A char or a cellstr.
% 
% Output:
% 
% - outString : A char or a cellstr. (Will match the input)
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if isempty(inString)
        outString = inString;
        return
    end

    if isa(obj,'nb_graph_adv')
        obj = obj.plotter;
    end
    if isprop(obj,'printing2PDF')
        printing2PDF = obj.printing2PDF;
    else
        printing2PDF = false;
    end
    
    indicator = 0;
    if ischar(inString)
        inString  = cellstr(inString);
        indicator = 1;
    elseif ~iscellstr(inString)
        error([mfilename ':: The inString input must be either a char or a cellstr.'])
    end
    
    trans = false;
    if size(inString,2) > 1
        inString = inString';
        trans    = true;
    end
    
    if ~indicator
        [inString,contractInd] = expandInput(inString);
    end
    
    h = findobj('type','figure','tag','nbtoolbox'); % Used for errors
    for ii = 1:length(inString)

        temp                                    = inString{ii};
        [fullFunc,funcs,freq,index,var,low,obs] = parseLocalFunction(temp);
        
        for jj = 1:size(funcs,2)
            
            fFunc = fullFunc{jj};
            lFunc = funcs{jj};      
            switch lower(lFunc)

                case 'timespan'
                    
                    if ~isa(obj,'nb_graph_ts') && ~isa(obj,'nb_table_ts')
                        continue
                    end
                    
                    try
                        out  = obj.timespan(obj.language,freq{jj});
                    catch Err 
                        if isempty(h)
                            error([mfilename ':: Error while trying to get the timespan of the graph; ' fFunc '. MATLAB error:: ' Err.message])
                        else
                           nb_errorWindow(['Error while interpreting the local function ' fFunc ' in the line; ' char(10) inString{ii}],Err) 
                        end
                    end
                    temp = strrep(temp,fFunc,out);
                    
                case 'realtimespan'
                    
                    if ~isa(obj,'nb_graph_ts') && ~isa(obj,'nb_table_ts')
                        continue
                    end
                    
                    try
                        out  = obj.realTimespan(obj.language,freq{jj});
                    catch Err
                        if isempty(h)
                            error([mfilename ':: Error while trying to get the timespan of the graph; ' fFunc '. MATLAB error:: ' Err.message])
                        else
                           nb_errorWindow(['Error while interpreting the local function ' fFunc ' in the line; ' char(10) inString{ii}],Err) 
                        end
                    end
                    temp = strrep(temp,fFunc,out);
                    
                case 'startgraph'

                    if ~isa(obj,'nb_graph_ts')
                        continue
                    end
                    
                    if isempty(var{jj})
                        date = obj.startGraph;
                    else
                        date = obj.DB.startDate;
                        try
                            varData = getVariable(obj.DB,var{jj});
                            ind     = find(isfinite(varData),1,'first') - 1;
                            date    = date + ind;
                        catch Err
                            if isempty(h)
                                error([mfilename ':: The variable you try to get the start date of is not graphed; ' fFunc])
                            else
                               nb_errorWindow(['Error while interpreting the local function ' fFunc ' in the line; ' nb_newLine(1) inString{ii}...
                                   nb_newLine(2), 'The variable you try to get the start date of is not graphed'],Err) 
                            end
                        end
                    end

                    if ~isempty(index{jj})
                        try
                            date = date + index{jj};
                        catch Err
                            if isempty(h)
                                error([mfilename ':: Could not add the number of periods to the given date; ' fFunc '. MATLAB error:: ' Err.message])
                            else
                               nb_errorWindow(['Error while interpreting the local function ' fFunc ' in the line; ' nb_newLine(1) inString{ii}...
                                   nb_newLine(2), 'Could not add the number of periods to the given date'],Err) 
                            end
                        end    
                    end

                    if ~isempty(freq{jj})
                        try
                            date = convert(date,freq{jj});
                        catch Err
                            if isempty(h)
                                error([mfilename ':: Could not convert the frequency of the date; ' fFunc '. MATLAB error:: ' Err.message])
                            else
                               nb_errorWindow(['Error while interpreting the local function ' fFunc ' in the line; ' nb_newLine(1) inString{ii}...
                                   nb_newLine(2), 'Could not convert the frequency of the date'],Err) 
                            end
                        end    
                    end

                    switch lower(obj.language)
                        case {'english','engelsk'}
                            out = date.toString('mprenglish');
                        otherwise
                            out = date.toString('pprnorsk');
                    end

                    if low{jj}
                        out(1) = lower(out(1));
                    end
                    
                    ind  = strfind(temp,fFunc);
                    if ~isempty(ind)
                        temp = [temp(1:ind(1)-1),out,temp(ind(1)+length(fFunc):end)];
                    end
                    
                case 'starttable'

                    if ~isa(obj,'nb_table_ts')
                        continue
                    end
                    
                    if isempty(var{jj})
                        date = obj.startTable;
                    else
                        date = obj.DB.startDate;
                        try
                            varData = getVariable(obj.DB,var{jj});
                            ind     = find(isfinite(varData),1,'first') - 1;
                            date    = date + ind;
                        catch Err
                            if isempty(h)
                                error([mfilename ':: The variable you try to get the start date of is not in the table; ' fFunc])
                            else
                               nb_errorWindow(['Error while interpreting the local function ' fFunc ' in the line; ' nb_newLine(1) inString{ii}...
                                   nb_newLine(2), 'The variable you try to get the start date of is not in the table'],Err) 
                            end
                        end
                    end

                    if ~isempty(index{jj})
                        try
                            date = date + index{jj};
                        catch Err
                            if isempty(h)
                                error([mfilename ':: Could not add the number of periods to the given date; ' fFunc '. MATLAB error:: ' Err.message])
                            else
                               nb_errorWindow(['Error while interpreting the local function ' fFunc ' in the line; ' nb_newLine(1) inString{ii}...
                                   nb_newLine(2), 'Could not add the number of periods to the given date'],Err) 
                            end
                        end    
                    end

                    if ~isempty(freq{jj})
                        try
                            date = convert(date,freq{jj});
                        catch Err
                            if isempty(h)
                                error([mfilename ':: Could not convert the frequency of the date; ' fFunc '. MATLAB error:: ' Err.message])
                            else
                               nb_errorWindow(['Error while interpreting the local function ' fFunc ' in the line; ' nb_newLine(1) inString{ii}...
                                   nb_newLine(2), 'Could not convert the frequency of the date'],Err) 
                            end
                        end    
                    end

                    switch lower(obj.language)
                        case {'english','engelsk'}
                            out = date.toString('mprenglish');
                        otherwise
                            out = date.toString('pprnorsk');
                    end

                    if low{jj}
                        out(1) = lower(out(1));
                    end
                    
                    ind  = strfind(temp,fFunc);
                    if ~isempty(ind)
                        temp = [temp(1:ind(1)-1),out,temp(ind(1)+length(fFunc):end)];    
                    end
                    
                case 'endgraph'

                    if ~isa(obj,'nb_graph_ts')
                        continue
                    end
                    
                    if isempty(var{jj})
                        date = obj.endGraph;
                    else
                        date = obj.DB.startDate;
                        try
                            varData = getVariable(obj.DB,var{jj});
                            ind     = find(isfinite(varData),1,'last') - 1;
                            date    = date + ind;
                        catch Err
                            if isempty(h)
                                error([mfilename ':: The variable you try to get the end date of is not graphed; ' fFunc])
                            else
                               nb_errorWindow(['Error while interpreting the local function ' fFunc ' in the line; ' nb_newLine(1) inString{ii}...
                                   nb_newLine(2), 'The variable you try to get the end date of is not graphed'],Err) 
                            end
                        end
                    end

                    if ~isempty(index{jj})
                        try
                            date = date + index{jj};
                        catch Err
                            if isempty(h)
                                error([mfilename ':: Could not add the number of periods to the given date; ' fFunc '. MATLAB error:: ' Err.message])
                            else
                               nb_errorWindow(['Error while interpreting the local function ' fFunc ' in the line; ' nb_newLine(1) inString{ii}...
                                   nb_newLine(2), 'Could not add the number of periods to the given date'],Err) 
                            end
                        end    
                    end

                    if ~isempty(freq{jj})
                        try
                            date = convert(date,freq{jj});
                        catch Err
                            if isempty(h)
                                error([mfilename ':: Could not convert the frequency of the date; ' fFunc '. MATLAB error:: ' Err.message])
                            else
                               nb_errorWindow(['Error while interpreting the local function ' fFunc ' in the line; ' nb_newLine(1) inString{ii}...
                                   nb_newLine(2), 'Could not convert the frequency of the date'],Err) 
                            end
                        end    
                    end

                    switch lower(obj.language)
                        case {'english','engelsk'}
                            out = date.toString('mprenglish');
                        otherwise
                            out = date.toString('pprnorsk');
                    end

                    if low{jj}
                        out(1) = lower(out(1));
                    end
                    
                    ind = strfind(temp,fFunc);
                    if ~isempty(ind)
                        temp = [temp(1:ind(1)-1),out,temp(ind(1)+length(fFunc):end)];
                    end
                    
                case 'endtable'

                    if ~isa(obj,'nb_table_ts')
                        continue
                    end
                    
                    if isempty(var{jj})
                        date = obj.endTable;
                    else
                        date = obj.DB.startDate;
                        try
                            varData = getVariable(obj.DB,var{jj});
                            ind     = find(isfinite(varData),1,'last') - 1;
                            date    = date + ind;
                        catch Err
                            if isempty(h)
                                error([mfilename ':: The variable you try to get the end date of is not in the table; ' fFunc])
                            else
                               nb_errorWindow(['Error while interpreting the local function ' fFunc ' in the line; ' nb_newLine(1) inString{ii}...
                                   nb_newLine(2), 'The variable you try to get the end date of is not in the table'],Err) 
                            end
                        end
                    end

                    if ~isempty(index{jj})
                        try
                            date = date + index{jj};
                        catch Err
                            if isempty(h)
                                error([mfilename ':: Could not add the number of periods to the given date; ' fFunc '. MATLAB error:: ' Err.message])
                            else
                               nb_errorWindow(['Error while interpreting the local function ' fFunc ' in the line; ' nb_newLine(1) inString{ii}...
                                   nb_newLine(2), 'Could not add the number of periods to the given date'],Err) 
                            end
                        end    
                    end

                    if ~isempty(freq{jj})
                        try
                            date = convert(date,freq{jj});
                        catch Err
                            if isempty(h)
                                error([mfilename ':: Could not convert the frequency of the date; ' fFunc '. MATLAB error:: ' Err.message])
                            else
                               nb_errorWindow(['Error while interpreting the local function ' fFunc ' in the line; ' nb_newLine(1) inString{ii}...
                                   nb_newLine(2), 'Could not convert the frequency of the date'],Err) 
                            end
                        end    
                    end

                    switch lower(obj.language)
                        case {'english','engelsk'}
                            out = date.toString('mprenglish');
                        otherwise
                            out = date.toString('pprnorsk');
                    end

                    if low{jj}
                        out(1) = lower(out(1));
                    end
                    
                    ind  = strfind(temp,fFunc);
                    if ~isempty(ind)
                        temp = [temp(1:ind(1)-1),out,temp(ind(1)+length(fFunc):end)];    
                    end
                    
                case 'hyphen'
                    
                    out  = '-';
                    ind  = strfind(temp,fFunc);
                    temp = [temp(1:ind(1)-1),out,temp(ind(1)+length(fFunc)+1:end)];
                    
                case 'dash'
                    
                    out  = char(173);
                    ind  = strfind(temp,fFunc);
                    temp = [temp(1:ind(1)-1),out,temp(ind(1)+length(fFunc)+1:end)];
                    
                case 'endash'
                    
                    out  = nb_dash('en-dash',printing2PDF);
                    ind  = strfind(temp,fFunc);
                    temp = [temp(1:ind(1)-1),out,temp(ind(1)+length(fFunc)+1:end)];
                    
                case 'emdash'
                    
                    out  = nb_dash('em-dash',printing2PDF);
                    ind  = strfind(temp,fFunc);
                    temp = [temp(1:ind(1)-1),out,temp(ind(1)+length(fFunc)+1:end)];
                    
                case 'observation'
                    
                    try
                        if isa(obj,'nb_graph_cs')
                            num = getVariable(obj.DB,var{ii},obs{ii});
                        elseif isa(obj,'nb_graph_data')
                            obsT = str2double(obs{ii});
                            num  = getVariable(obj.DB,var{ii},obsT,obsT);
                        else
                            num = getVariable(obj.DB,var{ii},obs{ii},obs{ii});
                        end
                    catch %#ok<CTCH>
                        continue
                    end
                    
                    if isempty(index{ii})
                        ind = 4;
                    else
                        ind = index{ii};
                    end
                    
                    switch ind
                        case 0
                            format = '%0.0f';
                        case 1
                            format = '%0.1f';
                        case 2
                            format = '%0.2f';
                        case 3
                            format = '%0.3f';
                        case 4 
                            format = '%0.4f';
                        case 5
                            format = '%0.5f';
                        case 6
                            format = '%0.6f';
                        otherwise
                            format = '%0.4f';
                    end
                    
                    out  = num2str(num,format);
                    ind  = strfind(temp,fFunc);
                    if ~isempty(ind)
                        temp = [temp(1:ind(1)-1),out,temp(ind(1)+length(fFunc)+1:end)];
                    end
                    
                otherwise
                    error('nb_localFunction:NotDefined',[mfilename ':: No local function ' lFunc ' for the class ' class(obj) '.'])
            end
           
        end
        inString{ii} = temp;
    end
    
    if trans
        inString = inString';
    end
    
    if indicator
        inString = char(inString);
    else
        inString = contractOutput(inString,contractInd);
    end
    
    outString = inString;
    
end

%==========================================================================
% SUB
%==========================================================================
function [lFuncs,funcs,freq,index,var,lower,obs] = parseLocalFunction(string)

    lFuncs = regexp(string,'%#obj._*[A-Za-z]+[\{\d+\}]*[\[-*\d+\]]*[\([\w\.]+\)]*','match');

    % Get the functions and its inputs
    funcs = lFuncs;
    freq  = lFuncs;
    index = lFuncs;
    var   = lFuncs;
    obs   = lFuncs;
    lower = lFuncs;
    for vv = 1:length(lFuncs)
        
        lFunc = lFuncs{vv};
        lFunc = lFunc(1,7:end);

        ind1 = strfind(lFunc,'{');
        ind2 = strfind(lFunc,'(');
        ind3 = strfind(lFunc,'[');
        ind  = [ind1,ind2,ind3];
        if isempty(ind)
            funcs{vv} = lFunc;
            funcs{vv} = strrep(funcs{vv},'.','');
            funcs{vv} = strtrim(funcs{vv});
        else
            ind       = min(ind);
            funcs{vv} = lFunc(1:ind-1);
        end
        
        ind4 = strfind(lFunc,'_');
        if isempty(ind4)
            lower{vv}  = 0;
            lFuncs{vv} = '%#obj.';
        else
            if ind4(1) == 1
                lower{vv}  = 1;
                funcs{vv}  = funcs{vv}(2:end);
                lFuncs{vv} = '%#obj._';
            else
                lower{vv}  = 0;
                lFuncs{vv} = '%#obj.';
            end
        end
        lFuncs{vv} = [lFuncs{vv} funcs{vv}];
        
        freqT = regexp(lFunc,'\{\d+\}','match');
        if isempty(freqT)
            freq{vv} = [];
        else
            freqT      = freqT{1};
            freq{vv}   = round(str2double(freqT(2:end-1)));
            lFuncs{vv} = [lFuncs{vv} freqT];
        end
        
        indexT = regexp(lFunc,'\[-*\d+\]','match');
        if isempty(indexT)
            index{vv} = [];
        else
            indexT     = indexT{1};
            index{vv}  = round(str2double(indexT(2:end-1)));
            lFuncs{vv} = [lFuncs{vv} indexT];
        end

        varT = regexp(lFunc,'\([^()]*\)','match');
        if length(varT) == 2
            obsT       = varT{1};
            obs{vv}    = obsT(2:end-1);
            varTT      = varT{2};
            var{vv}    = varTT(2:end-1);
            lFuncs{vv} = [lFuncs{vv}, obsT, varTT];
        else
            obs{vv} = [];
            if isempty(varT)
                var{vv} = [];
            else
                varT       = varT{1};
                var{vv}    = varT(2:end-1);
                lFuncs{vv} = [lFuncs{vv} varT];
            end
        end
        
    end
        
end

%==========================================================================
function [outString,contractInd] = expandInput(inString)

    outString   = {};
    contractInd = [];
    for ii = 1:length(inString)
        temp        = cellstr(inString{ii});
        outString   = [outString;temp]; %#ok<AGROW>
        contractInd = [contractInd;ones(length(temp),1)*ii]; %#ok<AGROW>
    end

end

%==========================================================================
function outString = contractOutput(inString,contractInd)

    ind       = unique(contractInd);
    outString = cell(numel(ind),1);
    for ii = ind'
        outString{ii} = char(inString(ind(ii) == contractInd));
    end
    
end
