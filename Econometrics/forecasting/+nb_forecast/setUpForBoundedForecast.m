function inputs = setUpForBoundedForecast(nSteps,model,restrictions,inputs,nSim)
% Syntax:
%
% inputs = nb_forecast.setUpForBoundedForecast(nSteps,model,restrictions,inputs,nSim)
%
% Description:
%
% Prepare stuff for bounded forecast.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nb_isModelMarkovSwitching(model)
        error([mfilename ':: The bounds option is not yet supported for Markov-switching models.'])
    end

    % Create waitbar to use
    if nSim ~= 1
        if isfield(inputs,'waitbar')
           h = inputs.waitbar;
        else
            if isfield(inputs,'index')
                figureName = ['Bounded Forecast for Model ' int2str(inputs.index) ' of ' int2str(inputs.nObj)];
            else
                figureName = 'Bounded Forecast';
            end
            h = nb_waitbar5([],figureName,true);
            inputs.waitbar = h;
        end
        h.maxIterations3 = nSim;
    else
        if ~isfield(inputs,'waitbar')
            inputs.waitbar = [];
        end
    end
    
    % Interpret the bound input
    [inputs.bounds,indY] = nb_forecast.interpretRestrictions(inputs.bounds,model.endo,model.res);
    
    % Set up things for conditional forecasting to speed up the algorithm
    index    = restrictions.index;
    MUy      = transpose(restrictions.Y(:,:,index));
    MUs      = transpose(restrictions.E(:,:,index));
    MUx      = transpose(restrictions.X(:,:,index));
    [~,ncp]  = size(MUy);
    [ncvs,~] = size(MUs);
    maxiter  = max(nSteps,ncp);
    
    if isfield(model,'CE')
        C = model.CE;
    else
        C = model.C;
    end
    if iscell(C)
        numAnt = size(C{1},3);
        states = restrictions.states;
    else
        numAnt = size(C,3);
        states = ones(maxiter,1);
    end
    
    % Produce unconditional forecast
    if isa(MUx,'nb_distribution')
        MUx = mean(MUx);
    end
    [~,~,AA] = nb_forecast.uncondForecastEngine(zeros(length(model.endo),1),model.A,model.B,model.ss,[],MUx,states,[],maxiter);
    
    % Set up matrix that match shocks and conditional information
    [R,numCondShocksPer] = nb_forecast.buildShockRestrictions(AA,C,indY,ncvs,ncp,numAnt,states);
    OMG                  = R*R';
    
    % Vectorize the unconditional forecast (as we are using delta and not 
    % absolute the unconditional forecast are zero!)
    DYbar = zeros(size(R,1),1);
    
    % Store the results in a struct for later use
    solution.R                         = R;
    solution.OMG                       = OMG;
    solution.numberOfCondShocksPeriods = numCondShocksPer;
    solution.DYbar                     = DYbar;
    inputs.solution                    = solution;
     
end

%==========================================================================

