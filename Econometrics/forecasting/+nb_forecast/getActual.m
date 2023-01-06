function actual = getActual(options,inputs,model,nSteps,dep,startFcst,split)
% Syntax:
%
% actual = nb_forecast.getActual(options,inputs,model,nSteps,dep,startFcst,split)
%
% Description:
%
% Get historical data to compare forecast with.
% 
% See also:
% nb_forecast
%
% Written by Kenneth Sæterhagen Paulsen 

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 7
        split = true;
    end

    if strcmpi(options(end).class,'nb_mfvar')
        % The MF-VAR state variable has not historical values to compare 
        % to and are removed. 
        indR = ismember(dep,model.endo);
        dep  = dep(~indR);
    end

    if isfield(inputs,'compareTo')
        
        % With the compareTo option we allow the user to decide which
        % variables to compare each variable to (must be part of models
        % data of course)
        compareTo = inputs.compareTo;
        if ~isempty(compareTo)
            if rem(length(compareTo),2) ~= 0
                error([mfilename ':: The compareTo input must come in pairs.'])
            end
            old        = compareTo(1:2:end);
            new        = compareTo(2:2:end);
            [test,loc] = ismember(old,dep);
            if any(~test)
                error([mfilename ':: The following variable is not part of the model, ' toString(old(~test)) ', which is given to the compareTo input.'])
            end
            test2 = ismember(new,options(end).dataVariables);
            if any(~test2)
                error([mfilename ':: The following variable is not part of the data of the model, ' toString(new(~test2)) ', which is given as every '...
                                 'second element, starting with the second element, to the compareTo input.'])
            end
            dep(loc) = new;
        end
        
    end
    
    [~,indD] = ismember(dep,options(end).dataVariables);
    numDep   = length(dep);
    if strcmpi(model.class,'nb_midas')
    
        if numel(options) == 1 || isempty(inputs.compareToRev)
            % Get final revision
            data = options(end).data;
            data = data(options.mappingDep,indD);
            data = data(startFcst(1,1:end-1),:);
            data = [data;nan(1,numDep)];
            if split
                actual = nb_splitSample(data,nSteps);
            else
                actual = data;
            end
        else
            % Get choosen revision
            compToRev = inputs.compareToRev;
            periods   = numel(options);
            actual    = nan(nSteps,numel(indD),periods);
            numRec    = length(options);
            for ii = 1:periods-compToRev
                ind  = options(ii).end_low + options(ii).increment:options(ii).increment:options(ii).end_low + nSteps*options(ii).increment;
                for hh = 1:size(ind,2)
                    if ii+compToRev+hh-1 <= numRec
                        actual(hh,:,ii) = options(ii+compToRev+hh-1).data(ind(hh),indD);
                    end
                end
            end
            if ~split
                actual = revSplit(actual);
            end
        end
        
    elseif strcmpi(model.class,'nb_mfvar')
        
        if numel(options) == 1 || isempty(inputs.compareToRev)
            % Get final revision
            data          = nan(size(startFcst,2)-1,size(indD,2));
            indDA         = indD ~= 0; % Some variables we may not have data on (i.e. unobserved variables)
            data(:,indDA) = options(end).data(startFcst(1,1:end-1),indD(indDA));
            data          = [data;nan(1,numDep)];
            if split
                actual = nb_splitSample(data,nSteps);
            else
                actual = data;
            end
        else
            % Get choosen revision
            data    = nan(size(startFcst,2)-1,size(indD,2));
            indDA   = indD ~= 0; % Some variables we may not have data on (i.e. unobserved variables)
            locVars = indD(indDA);
            for vv = 1:length(locVars)

                dataVar = options(end).data(startFcst(1,1:end-1),locVars(vv));
                loc     = find(~isnan(dataVar));
                kk      = 1;
                for pp = 1:size(loc,1)
                    ind  = startFcst(1,1) + loc(pp) - 1;
                    left = inputs.compareToRev;
                    while left > 0
                        if ~isnan(options(kk).data(ind,locVars(vv)))
                            dataVar(loc(pp)) = options(kk).data(ind,locVars(vv));
                            left             = left - 1;
                        else
                            kk = kk + 1;
                            if kk > length(options)
                                break
                            end
                        end
                    end
                end
                data(:,vv) = dataVar;

            end

            data = [data;nan(1,numDep)];
            if split
                actual = nb_splitSample(data,nSteps);
            else
                actual = data;
            end
                
        end
        
    else % All other models
        
        if numel(options) == 1 || isempty(inputs.compareToRev)
            % Get final revision
            data          = nan(size(startFcst,2)-1,size(indD,2));
            indDA         = indD ~= 0; % Some variables we may not have data on (i.e. unobserved variables)
            data(:,indDA) = options(end).data(startFcst(1,1:end-1),indD(indDA));
            data          = [data;nan(1,numDep)];
            if split
                actual = nb_splitSample(data,nSteps);
            else
                actual = data;
            end
        else
            % Get choosen revision
            compToRev = inputs.compareToRev;
            periods   = numel(options);
            actual    = nan(nSteps,size(indD,2),periods);
            indDA     = indD ~= 0; % Some variables we may not have data on (i.e. unobserved variables)
            numRec    = length(options);
            for ii = 1:periods-compToRev
                ind  = options(ii).estim_end_ind + 1:options(ii).estim_end_ind + nSteps;
                for hh = 1:size(ind,2)
                    if ii+compToRev+hh-1 <= numRec
                        actual(hh,indDA,ii) = options(ii+compToRev+hh-1).data(ind(hh),indD(indDA));
                    end
                end
            end
            if ~split
                actual = revSplit(actual);
            end
        end
        
    end

end

%==========================================================================
function actual = revSplit(actualSplit)

    nPeriods = size(actualSplit,3);
    nVars    = size(actualSplit,2);
    actual   = nan(nPeriods,nVars);
    for ii = 1:nPeriods
        actual(ii,:) = actualSplit(1,:,ii);
    end

end
