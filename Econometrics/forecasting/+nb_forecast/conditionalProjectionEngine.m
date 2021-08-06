function [Emean,Xmean,states,solution] = conditionalProjectionEngine(Y0,A,B,CE,ss,Qfunc,nSteps,restrictions,solution) 
% Syntax:
%
% [Emean,Xmean,states,solution]...
%       = nb_forecast.conditionalProjectionEngine(Y0,A,...
%           B,CE,ss,Qfunc,nSteps,restrictions,solution)
%
% Description:
%
% Identify the shocks/residuals to meet the conditional restriction.
%
% See Kenneth Sæterhagen Paulsen (2010), "Conditional forecast in DSGE 
% models - A conditional copula approach".
%
% Implements the steps in section 3.1.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 5
        solution = struct;
    end
    
    if iscell(CE)
        [nEndo,nExo,numAntPer] = size(CE{1});
    else
        [nEndo,nExo,numAntPer] = size(CE);
    end
    
    % Extract the conditional information
    index             = restrictions.index;
    my                = transpose(restrictions.Y(:,:,index));
    me                = transpose(restrictions.E(:,:,index));
    mx                = transpose(restrictions.X(:,:,index));
    [nVarY,nCondPer]  = size(my);
    [~,nCondPerE]     = size(me);
    yRestID           = restrictions.indY;
    if isempty(mx)
        if iscell(B)
            mx = zeros(size(B{1},2),nCondPerE);
        else
            mx = zeros(size(B,2),nCondPerE);
        end
    end

    if numAntPer < 1
        error([mfilename,':: Number of anticipated periods cannot be less than 1'])
    end

    if numAntPer > nCondPer + 1
        error([mfilename,':: Number of anticipated cannot exceed the number of conditioning periods'])
    end

    if nVarY == 0
        numAntPer = 1;
        nCondPer  = 0;
    end
    
    % Maximum number of iterations forward
    nMax = max(nSteps,nCondPer);
    
    % Simpler algorithm is used for all models except DSGE
    if restrictions.kalmanFilter
        
        % Append history (Added in nb_forecast.prepareRestrictions)
        nObs                        = size(restrictions.YHist,2);
        myCond                      = nan(nObs,nSteps);
        myCond(restrictions.indY,:) = my;
        myAll                       = [restrictions.YHist', myCond];
        mxAll                       = [restrictions.XHist',mx];
        nHist                       = size(restrictions.YHist,1);
        
        % Here we use a Kalman filter approach
        statSpaceHandle = @()nb_forecast.getStateSpace(A,B,CE,nObs);
        [~,~,Emean]     = nb_kalmansmoother_missing(statSpaceHandle,myAll,mxAll);
        Xmean           = mx;
        Emean           = Emean(nHist+1:end,:)';
        states          = ones(nSteps,1);
        return
        
    elseif ~strcmpi(restrictions.class,'nb_dsge') %&& size(MUy,1) == size(MUs,1)
        
        % Here we use a much simpler algorithm, but we don't allow for
        % anticipated shocks. This is not a problem as most forward
        % looking models are solved with only one lag.
        if numAntPer > 1
            error([mfilename ':: Models which is not of class nb_dsge cannot be forecast with anticipated shocks.'])
        end
        if nb_isempty(solution)
            % Store other outputs needed for later
            solution.nEndo                      = nEndo;
            solution.nExo                       = nExo;
            solution.nMax                       = nMax;                      
            solution.numberOfAnticipatedPeriods = numAntPer;
            solution.numberOfCondShocksPeriods  = nCondPer + numAntPer;
        end
        
        Emean  = nb_identifyShocks(A,B,CE,Y0,mx,me,my,restrictions.indY);
        Xmean  = mx;
        states = ones(nSteps,1);
        return
        
    end
     
    % Produce unconditional forecast (i.e. no shocks), here we draw states
    % randomly as well
    if ~isempty(Qfunc)
        states = restrictions.states;
        PAI0   = restrictions.PAI0;
    elseif iscell(A) % Model with break points
        states = restrictions.states;
        PAI0   = [];
        if strcmpi(restrictions.condAssumption,'after')
            % In this case we need to apply an iterative algorithm
            uStates      = unique(states);
            nBreaks      = length(uStates);
            ShockHorizon = numAntPer - 1 + nMax;
            Emean        = nan(nExo,ShockHorizon);
            Xmean        = nan(size(mx,1),ShockHorizon);
            s            = 1;
            for ii = 1:nBreaks
                
                % Get current state
                currentS     = uStates(ii);
                breakPeriods = find(states == uStates(ii),1,'last') - s + 1;
                nMaxOne      = nMax - s + 1;
                currentS     = currentS(ones(1,nMaxOne),1);
                
                % Interpret conditional information in current regime
                [Eone,Xone] = subEngine(Y0,A,B,CE,ss,[],[],my,yRestID,mx,me,currentS,nMaxOne,numAntPer,solution,true);
                
                % Cut before next break-point
                Eone = Eone(:,1:breakPeriods + numAntPer - 1);
                Xone = Xone(:,1:breakPeriods);
                
                % Simulate this regime
                if ii ~= nBreaks
                    
                    % Simulate initial values for next iteration
                    Y = nb_forecast.condShockForecastEngine(Y0,A,B,CE,ss,[],Xone,Eone,currentS,[],breakPeriods);
                    
                    % Update inputs for next iteration
                    Y0 = Y(:,end);
                    my = my(:,breakPeriods+1:end);
                    mx = mx(:,breakPeriods+1:end);
                    me = me(:,breakPeriods+1:end);
                    
                end
                
                % Store result from this iteration
                % TODO: Anticipation is not treated correctly here!!!
                %       As the anticpated shock will change for each break,
                %       we need to store all iterations instead?
                if ii == nBreaks
                    % Return with anticipated shocks for last horizon
                    Emean(:,s:end) = Eone; 
                else
                    Emean(:,s:s + breakPeriods - 1) = Eone(:,1:breakPeriods);
                end
                Xmean(:,s:s + breakPeriods - 1) = Xone;
                s                               = s + breakPeriods;
                
            end
            return
        else
            % Assume we are in the initial regime when interpreting the
            % conditional information
            state0 = restrictions.state0;
            ss     = ss{state0};
            states = state0(ones(1,length(states)),1);
        end
    else
        states = ones(nMax,1);
        PAI0   = [];
    end
    [Emean,Xmean,states,solution] = subEngine(Y0,A,B,CE,ss,PAI0,Qfunc,my,yRestID,mx,me,states,nMax,numAntPer,solution,true);
    if iscell(A) % Model with break points
        if ~strcmpi(restrictions.condAssumption,'after')
            states = restrictions.states;
        end
    end
    
end

%==========================================================================
function [Emean,Xmean,states,solution] = subEngine(Y0,A,B,CE,ss,PAI0,Qfunc,my,yRestID,mx,me,states,nMax,numAntPer,solution,store) 

    [Yf,states,HH] = nb_forecast.uncondForecastEngine(Y0,A,B,ss,Qfunc,mx,states,PAI0,nMax);
    Yf             = Yf(:,2:end);
    
    % build restrictions on shocks i.e. genuine endogenous + pure shock restrictions
    [nEndo,nCondPer] = size(my);
    nExo             = size(me,1);
    if ~isfield(solution,'R') || ~isempty(Qfunc) 
        % Given that we redraw the states we always need to solw for the
        % R matrix again
        [R,numCondShocksPer] = nb_forecast.buildShockRestrictions(HH,CE,yRestID,nExo,nCondPer,numAntPer,states);
        %OMG                  = R*R';
    else
        R                = solution.R;
        %OMG              = solution.OMG;
        numCondShocksPer = solution.numberOfCondShocksPeriods;
    end
   
    % Uconditional distribution of endogenous and possibly shocks
    % over the forecast horizon:
    if isfield(solution,'DYbar')
        DYbar = solution.DYbar;
    else
        Yf                      = Yf(yRestID,1:nCondPer);
        [nVarY,nCondPer]        = size(Yf);
        DYbar                   = zeros(size(R,1),1);
        DYbar(1:nVarY*nCondPer) = Yf(:);
    end
    
    % Remove steady-state from conditional information, in the case of MS
    % or break-point model
    if ~iscell(ss) && ~isempty(ss)
        for tt = 1:length(states) 
            my(:,tt) = my(:,tt) - ss(yRestID);
        end
    end
    
    % Stack all conditional information in a vector
    Yc = [my(:);me(:)];

    % Removing the non-restricted observations
    %[Yc,OMG,Rclean,DYbar] = remove(Yc,{OMG},R,DYbar);
    [Yc,Rclean,DYbar] = remove(Yc,R,DYbar);

    % Check if conditional information is valid
    [numberOfRestrictions,cols] = size(Rclean);
    if rank(Rclean) ~= numberOfRestrictions
        error([mfilename,':: Check your restrictions or the shocks that should explain those restrictions.'])
    end
    dof = cols - numberOfRestrictions;
    if dof < 0
        error([mfilename,':: More restrictions than shocks. Not enough degrees of freedom to find a solution.'])
    end
    
    % Compute the shocks that needs to match the hard conditioning. 
    epsilon = Rclean\(Yc - DYbar);
    
    % Compute theoretical mean conditional forecasts
    Emean        = reshape(epsilon,nExo,[]);
    ShockHorizon = numAntPer - 1 + nMax;
    Emean        = Emean(:,1:ShockHorizon);
    Xmean        = mx;
   
    % Store matrices of the restrictions made
    if nb_isempty(solution) && store
        % Store other outputs needed for later (if ran in a loop)
        %solution.OMG                        = OMG;
        solution.R                          = R;
        solution.nEndo                      = nEndo;
        solution.nExo                       = nExo;
        solution.nMax                       = nMax;                      
        solution.numberOfAnticipatedPeriods = numAntPer;
        solution.numberOfCondShocksPeriods  = numCondShocksPer;
        solution.numberOfRestrictions       = numberOfRestrictions;
        solution.kk                         = size(R,2);
    end

end

%==========================================================================
function [meanVec,varargout] = remove(meanVec,varargin)

    holes            = isnan(meanVec);
    meanVec(holes,:) = [];
    varargout        = cell(1,length(varargin));
    for j = 1:length(varargin)
        
        V = varargin{j};
        if iscell(V) % If cell then it is the covariance matrix
            V = [V{:}];
            if ~isempty(V)
                varargout{j} = V(~holes,~holes);
            else
                varargout{j} = V;
            end
        else
            if ~isempty(V)
                V(holes,:)   = [];
            end
            varargout{j} = V;
        end
    end
    
end
