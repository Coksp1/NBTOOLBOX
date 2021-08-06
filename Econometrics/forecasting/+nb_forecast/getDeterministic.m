function [X,exo] = getDeterministic(options,inputs,nSteps,exo,constant)
% Syntax:
%
% [X,exo] = nb_forecast.getDeterministic(options,inputs,nSteps,exo,constant)
%
% Description:
%
% Add deterministic exogenous vars to conditional information.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    X = nan(nSteps,0,inputs.nPeriods);
    if isfield(options,'constant') 
        if nargin < 5
            constant = options.constant;
        end
        if constant 
            exo = exo(2:end); 
            X   = [X,ones(nSteps,1,inputs.nPeriods)];
        end
    else
        ind = strcmpi('Constant',exo);
        if any(ind)
            exo = exo(~ind);
            X   = [X,ones(nSteps,1,inputs.nPeriods)]; 
        end
    end

    if isfield(options,'time_trend')
        time_trend = options.time_trend;
        if time_trend
            exo = exo(2:end); 
            if inputs.nPeriods == 1
                st  = inputs.startInd;
                tt  = st+1:st+nSteps;
                X   = [X,tt'];
            else
                st = inputs.startInd:inputs.endInd;
                tt = permute(nb_linespace(st+1,st+nSteps,nSteps),[2,3,1]);
                X  = [X,tt];
            end
        end
    end

    if isfield(options,'seasonalDummy')
        if ~isempty(options.seasonalDummy)
            [seasonals,freq] = nb_isQorM(options.dataStartDate);
            if seasonals
                exo          = exo(freq:end);
                seasVars     = strcat('Seasonal_',cellstr(int2str([1:freq-1]'))'); %#ok<NBRAK>
                [~,indS]     = ismember(seasVars,options.dataVariables);
                seasData     = options.data(:,indS); 
                seasData2Rep = seasData(end-freq+1:end,indS);
                seasData2Rep = repmat(seasData2Rep,[ceil(nSteps/freq),1]);
                seasData     = [seasData;seasData2Rep];
                seasData     = seasData(inputs.startInd:end,:);
                seasData     = nb_splitSample(seasData,nSteps);
                seasData     = seasData(:,:,1:inputs.nPeriods);
                X            = [X,seasData];
            end
        end
    end
    
    ind = strcmpi('easterDummy',exo);
    if any(ind)
        if nb_isQorM(options.dataStartDate)
            exo       = exo(~ind);
            indE      = strcmpi('easterDummy',options.dataVariables);
            dummyData = options.data(:,indE);
            startFcst = nb_dateplus(options.dataStartDate,size(options.data,1));
            temp      = nb_ts.rand(startFcst,nSteps,1,1);
            temp      = easterDummy(temp);
            dummyFcst = getVariable(temp,'easterDummy');
            dummyData = [dummyData;dummyFcst];
            dummyData = dummyData(inputs.startInd:end,:);
            dummyData = nb_splitSample(dummyData,nSteps);
            dummyData = dummyData(:,:,1:inputs.nPeriods);
            X         = [X,dummyData];
        end
    end
    
    ind = strncmpi('covidDummy',exo,10);
    if any(ind)
        exo = exo(~ind);
        X   = [X,zeros(nSteps,sum(ind),inputs.nPeriods)];
    end
    
    ind = strncmpi('timeDummy',exo,9);
    if any(ind)
        exo = exo(~ind);
        X   = [X,zeros(nSteps,sum(ind),inputs.nPeriods)];
    end

end
