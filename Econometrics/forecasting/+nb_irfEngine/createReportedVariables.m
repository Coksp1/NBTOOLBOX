function [Y,dep] = createReportedVariables(options,inputs,Y,dep,results,ss)
% Syntax:
%
% [Y,dep] = nb_irfEngine.createReportedVariables(options,inputs,y0,Y,...
%                           dep,results,ss)
%
% Description:
%
% Create reported variables based on simulated forecast.
% 
% See also:
% nb_irfEngine.collect
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    [nSteps,~,nShocks] = size(Y);
    nHistObs           = 10;
    
    % Get "historical" values
    switch lower(inputs.startingValues)
        case {'zero','zeros','steady_state','steadystate',''}
            yHist      = Y(1,:,:);                    % 1 x nVar x nShocks
            yHist      = yHist(ones(1,nHistObs),:,:); % This should be enough
            if strcmpi(options.class,'nb_dsge')
                startState = 1;
            end
        otherwise
            if strncmpi(inputs.startingValues,'steady_state',12) || strncmpi(inputs.startingValues,'steady_state',11)
                yHist = Y(1,:,:);                    % 1 x nVar x nShocks
                yHist = yHist(ones(1,nHistObs),:,:); % This should be enough
            else
                error([mfilename ':: The reporting property is not supported when ''startingValues'' options is set to ' inputs.startingValues])
            end
            if strcmpi(options.class,'nb_dsge')
                startState = regexp(inputs.startingValues,'(\d)','tokens');
                startState = str2double(startState{1}{1});
            end
    end
    data = [yHist;Y];
    
    % Some function such as igrowth uses other variables not inlcuded
    % in the model. Sets these to zero!
    variables = dep;
    if isfield(options,'dataVariables')
        ind       = ismember(options.dataVariables,variables);
        dVars     = options.dataVariables(~ind);
        nDVars    = length(dVars);
        data      = [data,zeros(nSteps+nHistObs,nDVars,nShocks)]; 
        variables = [variables,dVars];
    end
    
    if strcmpi(options.class,'nb_dsge')
        
        % Make it possible to use parameters in the case of a nb_dsge model
        variables = [variables,options.parser.parameters];
        beta      = results.beta';
        beta      = beta(ones(size(data,1),1),:,ones(size(data,3),1));
        data      = [data,beta];
        
        % Make it possible to use steady_state in the case of a nb_dsge 
        % model
        if iscell(ss)
            totPer   = size(data,1);
            per      = size(Y,1) - 1;
            startPer = totPer - per;
            states   = [startState(ones(startPer,1));inputs.states];
            ssData   = zeros(size(data,1),size(ss{1},1),size(data,3));
            for tt = 1:size(data,1)
                ssDataTT       = ss{states(tt)};
                ssDataTT       = ssDataTT(:,:,ones(size(data,3),1));
                ssData(tt,:,:) = ssDataTT;
            end
        else
            if size(ss,1) == size(Y,1)
                startPer = size(data,1) - size(Y,1);
                ssData   = [ss(ones(startPer,1),:,:);ss];
            else
                ssData = ss';
                ssData = ssData(ones(size(data,1),1),:,ones(size(data,3),1));
            end
        end
        variables = [variables,strcat('steady_state(',options.parser.endogenous,')')];
        data      = [data,ssData];
        
    end
    
    % Check each expressions
    reporting = inputs.reporting; 
    nNewVars  = size(reporting,1);
    newVarsD  = nan(nHistObs+nSteps,nNewVars,nShocks);
    for ii = 1:nNewVars
        
        expression = reporting{ii,2};
        try 
            newVarsD(:,ii,:) = nb_eval(expression,variables,data); 
        catch Err
            warning('nb_irfEngine:createReportedVariables:couldNotEvaluate',strrep(Err.message,'\','\\'));
        end 
        
        % To make it possible to use newly created variables in the 
        % expressions to come, we must append it in this way
        found = strcmp(reporting{ii,1},variables);
        if ~any(found)
            data      = [data,newVarsD(:,ii,:)]; %#ok<AGROW>
            variables = [variables,reporting{ii,1}]; %#ok<AGROW>
        else
            data(:,found,:) = newVarsD(:,ii,:);
        end
    end
    
    % Merge reported variables with model forecast
    Y   = [Y,newVarsD(nHistObs+1:end,:,:)];
    dep = [dep,reporting(:,1)'];
    
end
