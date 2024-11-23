function data = getData(obj,zeroLowerBound)
% Syntax:
% 
% data = getData(obj,zeroLowerBound)
% 
% Description:
% 
% Get the data of the graph
% 
% Input:
% 
% - obj            : An object of class nb_graph_ts
%
% - zeroLowerBound : Zero lower bound the fan chart of the variables 
%                    'QUA_RNFOLIO' and 'QUA_RNFOLIO_LATESTMPR'.
% 
% Output:
%
% - data     : As an nb_ts object (return as nb_cs if datesToPlot is 
%              non-empty)
%
% Example:
% 
% data = obj.getData();
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 2
        zeroLowerBound = 1;  
    end

    if ~isempty(obj.datesToPlot)
       
        % Get the index of the plotted data
        vars    = obj.variablesToPlot;
        [~,ind] = ismember(vars,obj.DB.variables);
        datTP   = interpretDatesToPlot(obj,'string');
        dats    = obj.DB.dates;
        indD    = ismember(dats,datTP);
        dataT   = obj.DB.data(indD,ind);
        
        % Get the dates on the correct date fromat
        datTP = interpretDatesToPlot(obj,'object');
        for ii = 1:length(datTP)
            datTP{ii} = toString(datTP{ii},'xls');
        end
        
        % Return a nb_cs object
        data  = nb_cs(dataT,'',datTP,vars);
        return
        
    end

    % Get the plotted variables
    vars = obj.getPlottedVariables();
    if isempty(vars)
        data = nb_ts();
        return
    end

    % Get the start and end date
    startD = obj.startGraph;
    if startD < obj.DB.startDate
        startD = obj.DB.startDate;
    end

    finishD = obj.endGraph;
    if finishD > obj.DB.endDate
        finishD = obj.DB.endDate;
    end

    % Interpret the nanVariables input
    data      = obj.DB;
    data.data = removeObservations(obj,data.data);
    
    % Only include the plotted variables
    data = data.window(startD,finishD,vars,obj.page);
    data = reorder(data,vars);

    % Include the fan chart data, if included
    constructBands(obj);
    fanD     = obj.fanData;
    plotType = obj.plotType;
    if ~isempty(fanD) && strcmpi(plotType,'line')
        
        try
            
            variable   = fanD.variables{end};
            startDate  = fanD.startDate;
            fanD       = fanD.window('','',variable);
            fanD       = squeeze(fanD.data);
            if zeroLowerBound
                if strcmpi(variable,'QUA_RNFOLIO') || strcmpi(variable,'QUA_RNFOLIO_LATESTMPR')
                    % Here we need to remove the band
                    % which is below zero.
                    isNegative       = fanD < 0;
                    fanD(isNegative) = 0;
                end
            end
            
            if strcmpi(obj.fanMethod,'graded')
                % Get the simulation names
                textPer = nb_appendIndexes('Sim',1:length(obj.fanDatasets.dataNames))';
            else
                % Get the percentile names
                num     = length(obj.fanPercentiles);
                if size(fanD,2) == num*2
                
                    textPer = cell(1,num*2); 
                    for ii = 1:num

                        number = obj.fanPercentiles(ii);
                        number = num2str(number);
                        loc    = strfind(number,'.');
                        number = number(loc + 1:end);
                        if size(number,2) == 1
                            number = [number '0']; %#ok
                        end
                        textPer{ii}       = ['Lower ' number '%'];
                        textPer{num + ii} = ['Upper ' number '%'];

                    end
                    
                else
                    textPer = nb_appendIndexes('Sim',1:length(obj.fanDatasets.dataNames))';
                end
            end
            fanD    = nb_ts(fanD,'',startDate,textPer);
            fanD    = fanD.window(startD,finishD);
            data    = data.merge(fanD);
            
        catch Err %#ok<CTCH>
            error([mfilename ':: It is not possible to add fan charts around two variables at the same time.'])
        end
        
    end

end


