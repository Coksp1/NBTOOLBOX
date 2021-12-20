function [data,vintages] = getTS(obj,date,variables,calendar)

    if nargin < 4
        calendar = [];
        if nargin < 3 % Doc is inheritied from nb_connector.getTS
            variables = {};
            if nargin < 2
                date = '';
            end
        end
    end

    numSources = size(obj.funcs,2);
    datasets   = cell(1,numSources);
    vintages   = cell(1,numSources);
    vars       = cell(1,numSources);
    for ii = 1:numSources
       datasets{ii} = obj.funcs{ii}(); 
       if ~isa(datasets{ii},'nb_ts')
           error([mfilename ':: The function ' func2str(obj.funcs{ii}), ' must return a nb_ts object.'])
       elseif isempty(datasets{ii})
           error('getTS:emptyObjectReturned',['An empty object was returned by the function; ' func2str(obj.funcs{ii})])
       end
       vars{ii}     = datasets{ii}.variables{1};
       vintages{ii} = datasets{ii}.dataNames;
    end
    if ~isempty(variables)
        ind      = ismember(vars,variables);
        datasets = datasets(ind);
        vintages = vintages(ind); 
    end
    data = mergeContexts(datasets{:}); 
    
    % Do any of the data sources contain conditional info?
    condInfo = false(1,numSources);
    for ii = 1:numSources
        if ~isempty(datasets{ii}.userData)
            condInfo(ii) = true; 
        end
    end
    
    % Get the end dates of history for each context and source
    if any(condInfo)
       
        if numSources == 1
            data.userData = datasets{1}.userData;
        else
        
            endDateHist = nb_date.initialize(data.frequency,data.numberOfDatasets,data.numberOfVariables);
            for ii = 1:numSources

                if condInfo(ii)
                    endDateHistThis = datasets{ii}.userData;
                else
                    endDateHistThis = getRealEndDatePages(datasets{ii},'nb_date');               
                end
                contexts = datasets{ii}.dataNames;
                if size(data.dataNames{1},2) > size(contexts{1},2)
                    contexts = strcat(contexts,repmat('0',[1,size(data.dataNames{1},2) - size(contexts{1},2)]));
                end
                [~,loc]             = ismember(contexts,data.dataNames);
                endDateHist(loc,ii) = endDateHistThis;
                if loc(1) > 1
                    endDateHist(1:loc(1)-1,ii) = getRealEndDatePages(data,'nb_date','all',datasets{ii}.variables,1:loc(1)-1);
                end
                for tt = loc(1)+1:data.numberOfDatasets
                    if isempty(endDateHist(tt,ii))
                        endDateHist(tt,ii) = endDateHist(tt-1,ii);
                    end
                end

            end
            data.userData = endDateHist;

        end
        
    end
        
    if isa(calendar,'nb_calendar')
        % Here we remove all contexts not matching the calendar.
        finishD = nb_day(data.dataNames{end}(1:8));
        finish  = freqPlus(finishD,1,data.frequency);
        if nb_isOneLineChar(date)
            start = date;
        else
            start = '';
        end
        calendarDates = getCalendar(calendar,start,finish,data.dataNames,false);
        if size(data.dataNames{1},2) == 12
            % Contexts are on the format 'yyyymmddhhnn'
            append = '2359';
        elseif size(data.dataNames{1},2) == 14
            % Contexts are on the format 'yyyymmddhhnnss'
            append = '235959';
        else
            append = '';
        end
        if ~isempty(append)
            calendarDates = str2num(strcat(num2str(calendarDates),append));  %#ok<ST2NM>
        end
        indC = nb_calendar.getContextIndex(str2num(char(data.dataNames')),calendarDates);
        data = data(:,:,indC);  
        if any(condInfo)
            data.userData = data.userData(indC,:);
        end
        
        % Handle the vintages as well
        for ii = 1:size(obj.funcs,2)
            vintagesOne  = nb_convertContexts(vintages{ii});
            indexV       = nb_calendar.getContextIndex(vintagesOne,calendarDates);
            vintages{ii} = vintages{ii}(indexV); 
        end
    end
    
    if ~isempty(date)
        if nb_isOneLineChar(date)
            % Remove contexts that is before the wanted date.
            contexts = str2num(char(data.dataNames'));
            indC     = contexts > str2double(date);
            data     = data(:,:,indC);  
            for ii = 1:size(obj.funcs,2)
                vintagesOne  = str2num(char(vintages{ii}')); 
                indC         = vintagesOne > str2double(date);
                vintages{ii} = vintages{ii}(indC);
            end
        elseif iscellstr(date)
            indC = ~ismember(data.dataNames,date);
            data = data(:,:,indC); 
            for ii = 1:size(obj.funcs,2)
                vintagesOne  = str2num(char(vintages{ii}')); 
                indexV       = nb_calendar.getContextIndex(vintagesOne,str2num(char(date)));
                vintages{ii} = vintages{ii}(indexV);
            end
        end
    end
        
end
