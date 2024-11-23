function [options,maxLags] = addECMlags(options,fixed)
% Syntax:
%
% [options,maxLags] = nb_ecmEstimator.addECMlags(options,fixed)
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    maxLags = 0;
    if iscell(options.nLags)

        % Add lags to model
        rhsOrig = options.rhs;
        rhsNF   = options.rhs(~fixed);
        allLags = cell(1,length(rhsNF));
        for ii = 1:length(rhsNF)
            if any(~nb_iswholenumber(options.nLags{ii}))
                error([mfilename ':: Each element of the nLags option must be a vector of integers.'])
            end

            if isempty(options.nLags{ii})
                options.rhs = options.rhs(~strcmp(rhsNF{ii},options.rhs));
            else

                if ii == length(rhsNF)

                    if any(options.nLags{ii} < 1)
                        error([mfilename ':: Each element of the nLags option (when cell) must be a vector of strictly positive integers ',...
                                         'for the dependent variable (i.e. last element).'])
                    end
                    isNotOne    = options.nLags{ii} > 1;
                    diffDep     = regexprep(rhsNF{ii},'_lag1$','');
                    nLagsT      = options.nLags{ii}(isNotOne);
                    if ~isempty(nLagsT)
                        allLags{ii} = nb_appendIndexes(strcat(diffDep,'_lag'),nLagsT)';
                    end
                    if all(isNotOne)
                        % Remove diff_y_lag1 variable if not 1 is included
                        options.rhs = options.rhs(~strcmp(rhsNF{ii},options.rhs));
                    end

                else

                    if any(options.nLags{ii} < 0)
                        error([mfilename ':: Each element of the nLags option (when cell) must be a vector of weakly positive integers ',...
                                         'for the endogenous variable nr. ' int2str(ii) '.'])
                    end
                    isNotZero = options.nLags{ii} > 0;
                    nLagsT    = options.nLags{ii}(isNotZero);
                    if ~isempty(nLagsT)
                        allLags{ii} = nb_appendIndexes(strcat(rhsNF{ii},'_lag'),nLagsT)';
                    end
                    if all(isNotZero)
                        % Remove diff_X variable if not 0 is included
                        options.rhs = options.rhs(~strcmp(rhsNF{ii},options.rhs));
                    end

                end

            end

        end

        % Add the lags to the estimation data for later
        [~,indX]              = ismember(rhsOrig,options.dataVariables);
        X                     = options.data(:,indX);
        XNotF                 = X(:,~fixed);
        maxLags               = max(cell2mat(options.nLags));
        Xlag                  = nb_mlag(XNotF,maxLags,'varFast');
        exoLag                = nb_cellstrlag(rhsOrig(~fixed),maxLags,'varFast');
        options.data          = [options.data,Xlag];
        options.dataVariables = [options.dataVariables,exoLag];
        newLags               = nb_nestedCell2Cell(allLags);
        newLags               = newLags(~cellfun(@isempty,newLags));
        options.rhs           = [options.rhs,newLags];

    elseif any(options.nLags > 0) 

        [~,indX]     = ismember(options.rhs,options.dataVariables);
        X            = options.data(:,indX);
        XNotF        = X(:,~fixed);
        Xlag         = nb_mlag(XNotF,options.nLags,'varFast');
        options.data = [options.data,Xlag];
        maxLags      = max(options.nLags);

        % Add lag postfix (If the variable already have a lag postfix 
        % we append the number indicating that it is lag once more)
        noLagDep = true;
        if options.nLags(end) ~= 0
            options.nLags(end) = options.nLags(end) - 1;
            noLagDep           = false;
        end

        exoLag = nb_cellstrlag(options.rhs(~fixed),options.nLags,'varFast');
        if noLagDep
            options.rhs = options.rhs(1:end-1);
        end
        options.rhs           = [options.rhs,exoLag];
        options.dataVariables = [options.dataVariables, exoLag];

    end

end
