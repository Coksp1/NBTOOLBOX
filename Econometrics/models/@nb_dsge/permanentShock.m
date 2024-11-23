function [sim,plotter,ssTable] = permanentShock(obj,varargin)
% Syntax:
%
% [sim,plotter,ssTable] = permanentShock(obj,varargin)
%
% Description:
%
% 
% 
% Input:
% 
% - obj : An object of class nb_dsge.
%
% Optional input:
%
% - 'algo'               : Either 'breakPoint' or 'perfectForesight',
%                          default is 'perfectForesight'.
%
% - 'delta'              : Give true, if you want to run the delta on the
%                          shock hitting, not hitting. This can be utilized
%                          to explore the differences in IRFs from shocks
%                          when initial values are different from the
%                          initial steady-state. I.e. when using the 
%                          'initVal' input. Default is false.
%
%                          Caution: This option is not accepted for 'algo'
%                                   set to 'breakPoint'.
%
% - 'periods'            : See the 'periods' input to the perfectForesight
%                          method.
%
% - 'steady_state_block' : See nb_dsge.help('steady_state_block'). Default
%                          is to use the current value of the 
%                          'steady_state_block'. Default is true.
%
% - 'steady_state_exo'   : The exogenous innovations that are subject to a 
%                          permanent shock. See 
%                          nb_dsge.help('steady_state_exo') for the format
%                          of this input. Must be provided!
% 
% - All the inputs to the nb_dsge.perfectForesight method except; 
%   'endVal', 'exoVal' and 'periods'. Inputs like 'initVal' and 
%   'stochInitVal' will have no impact when 'algo' is set to 
%   'breakPoint'.
%
% Output:
% 
% - sim     : See the doc of the same output from the 
%             nb_dsge.perfectForesight method.
%
% - plotter : See the doc of the same output from the 
%             nb_dsge.perfectForesight method.
%
% - ssTable : A nEndo x 3 nb_cs object with the old steady state, new 
%             steady steady state and the difference.
%
% See also:
% nb_dsge.getEndVal, nb_dsge.perfectForesight, nb_dsge.checkSteadyState,
% nb_dsge.addBreakPoint
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if ~obj.options.silent
        t = tic;
    end

    % Parse options
    [periods,varargin]            = nb_parseOneOptional('periods',150,varargin{:});
    [steady_state_exo,varargin]   = nb_parseOneOptional('steady_state_exo',[],varargin{:});
    [steady_state_block,varargin] = nb_parseOneOptional('steady_state_block',true,varargin{:});
    [algo,varargin]               = nb_parseOneOptional('algo',true,varargin{:});
    [delta,varargin]              = nb_parseOneOptional('delta',false,varargin{:});

    if strcmpi(algo,'breakPoint')
        
        if delta
            error([mfilename ':: Cannot set the ''delta'' input to true if',...
                             ' ''algo'' is set to ''breakPoint''.'])
        end

        % Parse out inputs that need to be done outside IRF method
        [addEndVal,varargin] = nb_parseOneOptional('addEndVal',true,varargin{:});
        
        % Set block option
        obj = set(obj,...
            'steady_state_block', steady_state_block);

        % Add break point
        obj = addBreakPoint(obj,...
            {},[],'2000Q1',...
            'steady_state_exo', steady_state_exo);
        obj = solve(obj);
        
        % Remove some options that may be used in perfect foresight
        [~,varargin] = nb_parseOneOptional('blockDecompose',true,varargin{:});
        [~,varargin] = nb_parseOneOptional('initVal',true,varargin{:});
        [~,varargin] = nb_parseOneOptional('stochInitVal',true,varargin{:});
        
        % IRFs
        [~,~,plotterB] = irf(obj,...
                    'periods',periods,...
                    'shocks',{'states'},...
                    'states',ones(periods,1)*2,... % Switch to state 2
                    'startingValues','steady_state(1)',... % Start in state 1
                    varargin{:});

        % This is to get it on the same format as is returned by the
        % perfectForesight method.
        dataTS = plotterB.getData();
        sim    = dataTS.tonb_data(0);
        sim    = rename(sim,'variables','*_states','');
        
        % Append end value
        if addEndVal
            ss         = getSteadyState(obj);
            endVal     = cell2struct(ss(:,3),ss(:,1));
            endValData = nb_data(cell2mat(ss(:,3))','',periods+1,ss(:,1)');
            sim        = merge(sim,endValData);
        end
        
        % Create plotter object
        plotter = nb_graph_data(sim);
        plotter.set('startGraph',0,'parameters',getParameters(obj,'struct'));
        
        % Remove ss if 'plotSS' is set to true
        if size(sim,3) > 1
            sim = sim(:,:,1);
        end
                
    else % Perfect foresight
        
        % Check initial steady-state
        obj = checkSteadyState(obj);

        % Solve for the end point
        endVal = getEndVal(obj,...
            'steady_state_block',   steady_state_block,...
            'steady_state_exo',     steady_state_exo);

        % Specify the shock process
        shocks    = fieldnames(steady_state_exo);
        nShocks   = length(shocks);
        shockData = ones(1,nShocks);
        for ii = 1:nShocks
            shockData(ii) = steady_state_exo.(shocks{ii});
        end
        exoVal = nb_data(shockData(ones(periods,1),:),'',1,shocks);
        if delta
            % When doing delta, the shock does not hit in the alternative
            exoValDelta = nb_data(zeros(periods,nShocks),'',1,shocks);
        end

        % Perfect foresight solver
        if delta
            % If 'stochInitVal' is used we know need twice as many
            % simulations
            stochInitVal = nb_parseOneOptional('stochInitVal',false,varargin{:});
            if stochInitVal
                [draws,varargin] = nb_parseOneOptional('draws',500,varargin{:});
                waitbar          = nb_waitbar([],'Solve...',draws*2);
                varargin         = [varargin,{'waitbar',waitbar,'draws',draws}];
            end
        end
        [sim,plotter,distr] = perfectForesight(obj,...
            'endVal',endVal,...
            'exoVal',exoVal,...
            'periods',periods,...
            varargin{:});
        if delta
            
            % Solve for the path in the case that no shock hits
            endValDelta    = getSteadyState(obj,{},'struct');
            [alt,~,altDistr] = perfectForesight(obj,...
                'endVal',endValDelta,...
                'exoVal',exoValDelta,...
                'periods',periods,...
                varargin{:});
            
            % Calculate the delta, and add inital steady-state back again
            ss   = getSteadyState(obj,sim.variables,'double')';
            name = getModelNames(obj);
            name = name{1};
            if stochInitVal
                fanDiff    = distr - altDistr;
                fanDiff    = callfun(fanDiff,'func',@(x)bsxfun(@plus,x,ss));
                sim        = callstat(fanDiff,@(x)mean(x,3),'name',name);
                plotter.DB = sim;
                plotter.set('fanDatasets',fanDiff);
            else
                sim        = sim - alt;
                sim        = callfun(sim,'func',@(x)bsxfun(@plus,x,ss));
                plotter.DB = sim;
            end
             
        end
        
    end
    
    % Steady-state table
    if nargout > 2
        if strcmpi(algo,'breakPoint')
            ss = getSteadyState(obj,'','double');
        else
            initSS      = getSteadyState(obj,'','double');
            endValTable = cell2mat(struct2cell(endVal));
            ss          = [initSS,endValTable];
        end
        ssTable = nb_cs(ss,'Steady state',obj.dependent.name,{'InitVal','EndVal'},false);
        if ~isempty(obj.reporting)
            ssTable = createType(ssTable,obj.reporting(:,1)',obj.reporting(:,2)');
        end
        ssTable = sortTypes(ssTable);
        ssTable = createVariable(ssTable,'Diff','EndVal - InitVal');
        ssTable = createVariable(ssTable,'Change (%)','100*(EndVal - InitVal)/InitVal');
    end
    
    if ~obj.options.silent
        elapsedTime = toc(t);
        disp(['Total computation time: ' num2str(elapsedTime) ' seconds'])
        disp(' ')
    end

end
