function [test,pval,res] = mincerZarnowitzTest(obj,precision)
% Syntax:
%
% [test,pval,res] = mincerZarnowitzTest(obj,precision)
%
% Description:
%
% Do the Mincer-Zarnowitz test for bias in the recursive forecast.
% 
% Input:
% 
% - obj       : An object of class nb_model_group. You need to call the 
%               combineForecast method first!
% 
% - precision : The precision of the printed result. As a string. Default
%               is '%8.6f'.
%
% Output:
% 
% - test    : A nb_ts object with the test statistic. As a 
%             nHor x nModel x nVar nb_ts object.
%
% - pval    : A nb_ts object with the p-values of the test. As a 
%             nHor x nModel x nVar nb_ts object.
%
% - res     : A char with the printout of the test.
%
% See also:
% nb_model_generic.combineForecast
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin<2
        precision = '';
    end

    obj      = obj(:);
    forecast = {obj.forecastOutput};
    nobj     = size(forecast,1);
    names    = {obj.name};
    
    % Get the unique forecasted variables
    vars = cell(1,nobj);
    nHor = nan(1,nobj);
    for ii = 1:nobj
        
        if nb_isempty(forecast{ii})
            name = names{ii};
            error([mfilename ':: You need to produce forecast using one of the forecast functions for the model with name ' name])
        end
        
        vars{ii} = forecast{ii}.variables;
        nHor(ii) = size(forecast{ii}.data,1);        
        if isempty(names{ii})
            names{ii} = ['Model' int2str(ii)];
        end
        
    end
    allVars  = unique(nb_nestedCell2Cell(vars));
    nAllVars = length(allVars);
    maxHor   = max(nHor);
    
    % Do the test for each model
    test = nan(maxHor,nAllVars,nobj);
    pval = nan(maxHor,nAllVars,nobj);
    for ii = 1:nobj

        if length(forecast{ii}.start) < 10
            error([mfilename ':: Too few recursive periods selected to use the Mincer-Zarnowitz test.'])
        end
        
        % Get the actual data to evaluate against
        start    = nb_date.date2freq(forecast{ii}.start{1});
        finish   = nb_date.date2freq(forecast{ii}.start{end-1});
        histData = getHistory(obj,vars{ii});
        try
            histData = reorder(histData,vars{ii});
        catch %#ok<CTCH>
            error([mfilename ':: Could not get the historical data on all the variables of the model group.'])
        end
        actual = window(histData,start,finish);
 
        % Get the forecast
        forecastData = forecast{ii}.data;
        forecastData = forecastData(:,:,end,1:end-1); % Get mean/median forecast
        forecastData = permute(forecastData,[4,2,1,3]);
        
        % Order things properly
        nVar = length(vars{ii});
        for hh = 1:nHor(ii)
            forecastData(:,:,hh) = [nan(hh-1,nVar);forecastData(1:end-hh+1,:,hh)]; 
        end
        
        % Do the test
        [testM,pvalM] = nb_mincerZarnowitz(actual,forecastData);

        % Align it with the rest
        [~,indV]                 = ismember(vars{ii},allVars);
        test(1:nHor(ii),indV,ii) = testM;
        pval(1:nHor(ii),indV,ii) = pvalM;
        
    end
    
    % Report the results
    testM = permute(test,[1,3,2]);
    test  = nb_ts(testM,allVars,'1',names);
    pvalM = permute(pval,[1,3,2]);
    pval  = nb_ts(pvalM,allVars,'1',names);    
    
    if nargout > 2
        
        if isempty(precision)
            precision = '%8.6f';
        else
            if ~ischar(precision)
                error([mfilename ':: The precision input must be of the type %8.6f.'])
            end
            precision(isspace(precision)) = '';
            if ~strncmp(precision(1),'%',1)||~all(isstrprop(precision([2,4]),'digit'))||...
               ~isstrprop(precision(end),'alpha')
                error([mfilename ':: The precision input must be of the type %8.6f.'])
            end
        end
        
        % Print results
        res    = sprintf('Test: %s','Mincer-Zarnowitz Test');
        res    = char(res,sprintf('Null hypothesis: %s','There are no bias in the forecast'));
        res    = char(res,sprintf('%s',nb_clock('gui')));
        res    = char(res,'');
        
        % Sample
        res = char(res,'Samples:');
        res = char(res,'');
        t   = cell(nobj,2);
        for ii = 1:nobj
            t{ii,1} = [names{ii} ' :'];
            t{ii,2} = [forecast{ii}.start{1} ' - ' forecast{ii}.start{end}];
        end
        res = char(res,cell2charTable(t));
        res = char(res,'');
        
        allHor = 1:maxHor;
        allHor = cellstr(int2str(allHor'));
        for ii = 1:nAllVars
            
            table                = repmat({' '},[3 + nHor*2,1 + nobj]);
            table{1,1}           = allVars{ii};
            table{3,1}           = 'Horizon';
            table(3,2:end)       = names;
            table(4:2:end,2:end) = nb_double2cell(testM(:,:,ii),precision);
            table(5:2:end,2:end) = nb_double2cell(pvalM(:,:,ii),precision);
            table(4:2:end,1)     = allHor;
            table(5:2:end,1)     = repmat({'(P-Value)'},[nHor,1]);
            tableAsChar          = cell2charTable(table);
            res                  = char(res,tableAsChar);
            res                  = char(res,'');
            
        end
        
    end
    
end
