function [options,freqMapping] = addLags(options)
% Syntax:
%
% [options,freqMapping] = nb_midasEstimator.addLags(options)
%
% Description:
%
% Add lags to right hand side of estimation equation.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    fixed       = options.modelSelectionFixed;
    exoNotFixed = options.exogenous(~fixed);
    nExo        = length(exoNotFixed);
    if isscalar(options.nLags)
        options.nLags = options.nLags(1,ones(1,nExo));
    elseif length(options.nLags) ~= nExo
        error(['The length of the nLags options must either be 1 or equal ',...
               'to the number of non-fixed exogenous variables (' int2str(nExo) ')'])
    end

    freqMapping          = struct();
    sDataDate            = nb_date.date2freq(options.dataStartDate);
    frequencyExoNotFixed = options.frequencyExo(~fixed);
    exoLag               = cell(nExo,max(options.nLags));
    for ii = 1:length(exoNotFixed)
        
        [testX,indX] = ismember(exoNotFixed(ii),options.dataVariables);
        if any(~testX)
            error([mfilename ':: Some of the exogenous variable are not found to be in the dataset; ' toString(options.exogenous(~testX))])
        end
        
        nLags = 0:options.nLags(ii);
        if isempty(frequencyExoNotFixed{ii}) || options.dataFrequency == frequencyExoNotFixed{ii}
            
            frequencyExoNotFixed{ii} = options.dataFrequency;
            
            % Same frequency as the data, so we just take normal lags!
            X                     = options.data(:,indX);
            Xlag                  = nb_mlag(X,options.nLags(ii),'varFast');
            options.data          = [options.data,Xlag];
            dataVarLag            = nb_cellstrlag(exoNotFixed(ii),options.nLags(ii),'varFast');
            options.dataVariables = [options.dataVariables, dataVarLag];
            
        else
            
            % Not same frequency as data so we need to get the location
            % of low freq in high. Then lag, and insert back again.
            periods  = size(options.data,1);
            freqName = ['freq', int2str(frequencyExoNotFixed{ii})];
            if isfield(freqMapping,freqName)
                mapping = freqMapping.(freqName);
            else
                [~,mapping]              = sDataDate.toDates(0:periods,'xls',frequencyExoNotFixed{ii},0);
                freqMapping.(freqName)   = mapping;
                mapping(mapping>periods) = [];
            end
            
            X                     = options.data(mapping,indX);
            Xlag                  = nb_mlag(X,options.nLags(ii),'varFast');
            XHighLag              = nan(periods,size(Xlag,2));
            XHighLag(mapping,:)   = Xlag;
            options.data          = [options.data, XHighLag];
            dataVarLag            = nb_cellstrlag(exoNotFixed(ii),options.nLags(ii),'varFast');
            options.dataVariables = [options.dataVariables, dataVarLag];
            
        end

        % Add lag postfix (If the variable already have a lag postfix we
        % append the number indicating that it is lag once more
        exoLag(ii,1:options.nLags(ii)) = nb_appendIndexes(strcat(exoNotFixed{ii},'_lag'),nLags(nLags>0))';
        
    end
    
    options.frequencyExo(~fixed) = frequencyExoNotFixed;
    exoLag                       = exoLag(:);
    index                        = ~cellfun(@isempty,exoLag);
    options.exogenous            = [options.exogenous,exoLag(index)'];
    
end
