function irfData = irfPointStochTrend(modelObj,options,inputs)
% Syntax:
%
% irfData = nb_irfEngine.irfPointStochTrend(modelObj,options,inputs)
%
% Description:
%
% Produce point IRF of nb_dsge model with stochastic trend.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Get inputs
    periods        = inputs.periods;
    shocks         = inputs.shocks;
    unitRootShocks = modelObj.parser.unitRootOptions(:,2)';

    % Preallocate
    endo    = modelObj.dependent.name;
    all     = [modelObj.dependent.name,modelObj.unitRootVariables.name];
    res     = modelObj.exogenous.name;
    nShocks = length(shocks);
    nEndo   = length(endo);
    nAll    = length(all);
    E       = zeros(length(res),periods);
    Y       = zeros(nAll,periods + 1,nShocks);
    
    % Produce IRFs
    for jj = 1:nShocks

        indU = find(strcmp(shocks{jj},unitRootShocks));
        if ~isempty(indU) % Unit root shock
        
            param   = getParameters(modelObj,'struct','reverse');
            urOpt   = modelObj.parser.unitRootOptions(indU,:);
            lambda  = param.(urOpt{1});
            std     = param.(urOpt{3});
            g       = param.(modelObj.parser.unitRootGrowth{indU});
            dA      = nan(inputs.periods,1);
            dA(1)   = g*exp(std);
            for tt = 2:inputs.periods
                dA(tt) = g^(1-lambda)*dA(tt-1)^lambda;
            end
            init = modelObj.parser.unitRootState(indU);
            A    = init.*cumprod(dA);
            
            opt                  = modelObj.options;
            opt.parser           = modelObj.parser;
            Y(:,1,jj)            = [modelObj.solution.ss;opt.parser.unitRootState];
            opt.optimset.Display = 'off';
            for tt = 1:inputs.periods
               
                % Assign current level of unit root variable
                opt.parser.unitRootState(indU) = A(tt);
                
                % Solve for the steady state
                [ss,~,err] = nb_dsge.solveSteadyStateStatic(opt.parser,opt,param,false);
                if ~isempty(err)
                    error([mfilename ':: Could not solve model at period ' int2str(tt) ' of IRF to the shock ' shocks{jj} '. ',...
                                     'Error:: ' err])
                end
                Y(:,tt+1,jj) = ss;
                
            end
            
        else
            
            if ~isempty(inputs.y0)
                y0             = inputs.y0(:,end);
                Y(1:nEndo,1,:) = y0(:,:,ones(1,nShocks)); 
            end
        
            indS       = strcmpi(shocks{jj},res);
            ET         = E;
            ET(indS,1) = inputs.sign; % One standard deviation innovation  
            if any(indS)
                Y(1:nEndo,:,jj) = nb_computeForecast(A,B,C,Y(1:nEndo,:,jj),X,ET);
            else % This model does not have this shock
                Y(1:nEndo,:,jj) = nan(nEndo,periods + 1,1);
            end
            
        end

    end
    
    % Collect, normalize or transform IRFs
    irfData = nb_irfEngine.collect(options,inputs,Y,all,modelObj.results,ss);

end

% [A,C,~,ss,~,err] = nb_dsge.solveOneRegime(opt,beta);
% if ~isempty(err)
%     error([mfilename ':: Could not solve model at period ' int2str(tt) ' of IRF to the shock ' shocks{jj} '. ',...
%                      'Error:: ' err])
% end
