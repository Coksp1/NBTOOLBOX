function [options,maxLags] = addExoLags(options,field)
% Syntax:
%
% [options,maxLags] = nb_estimator.addExoLags(options,field)
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    options.exogenousOrig = options.exogenous;
    lagOption             = options.(field);
    if iscell(lagOption)
                
        if length(options.exogenous) ~= length(lagOption)
            error([mfilename ':: The ''' field ''' option must have same length as the number of exogenous variables (' ...
                             int2str(length(options.exogenous)) ').'])
        end
            
        
        % Add lags to model
        exoOrig = options.exogenous;
        exo     = options.exogenous;
        allLags = cell(1,length(exo));
        for ii = 1:length(exo)
            
            if any(~nb_iswholenumber(lagOption{ii}))
                error([mfilename ':: Each element of the ''' field ''' option must be a vector of integers.'])
            end

            if isempty(lagOption{ii})
                options.exogenous = options.exogenous(~strcmp(exo{ii},options.exogenous));
            else
                
                if any(lagOption{ii} < 0)
                    error([mfilename ':: Each element of the ''' field ''' option (when cell) must be a vector of weakly positive integers ',...
                                     'for the exogenous variable nr. ' int2str(ii) '.'])
                end
                isNotZero = lagOption{ii} > 0;
                nLagsT    = lagOption{ii}(isNotZero);
                if ~isempty(nLagsT)
                    lag = regexp(exo{ii},'_lag(\d)','tokens');
                    if isempty(lag)
                        exoii = exo{ii};
                    else
                        lag    = lag{1}{1};
                        lagNum = str2double(lag);
                        exoii  = strrep(exo{ii},['_lag',lag],'');
                        nLagsT = nLagsT + lagNum;
                    end
                    allLags{ii} = nb_appendIndexes(strcat(exoii,'_lag'),nLagsT)';
                end
                if all(isNotZero)
                    % Remove contemporaneous exogenous variable if not 0 is included
                    options.exogenous = options.exogenous(~strcmp(exo{ii},options.exogenous));
                end

            end

        end

        % Add the lags to the estimation data for later
        [~,indX]              = ismember(exoOrig,options.dataVariables);
        X                     = options.data(:,indX);
        maxLags               = max(cell2mat(lagOption));
        Xlag                  = nb_mlag(X,maxLags,'varFast');
        exoLag                = nb_cellstrlag(exoOrig,maxLags,'varFast');
        options.data          = [options.data,Xlag];
        options.dataVariables = [options.dataVariables,exoLag];
        newLags               = nb_nestedCell2Cell(allLags);
        newLags               = newLags(~cellfun(@isempty,newLags));
        options.exogenous     = [options.exogenous,newLags];

    elseif any(lagOption > 0) 

        [~,indX]     = ismember(options.exogenous,options.dataVariables);
        X            = options.data(:,indX);
        Xlag         = nb_mlag(X,lagOption,'varFast');
        options.data = [options.data,Xlag];
        maxLags      = max(lagOption);

        exoLag                = nb_cellstrlag(options.exogenous,lagOption,'varFast');
        options.exogenous     = [options.exogenous,exoLag];
        options.dataVariables = [options.dataVariables, exoLag];
        
        if strcmpi(field,'exoLags')
            if isscalar(lagOption)
                options.exoLags = options.exoLags(1,ones(1,length(options.exogenousOrig)));
            end
        end

    end

end

