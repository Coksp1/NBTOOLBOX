function [obj,shift,plotter] = createShift(obj,nSteps,variables,expression,output)
% Syntax:
%
% [obj,shift]         = createShift(obj,variables,expression,output)
% [obj,shift,plotter] = createShift(obj,variables,expression,output)
%
% Description:
%
% Remove trend/shift from variables and add them in a new database shift.
% 
%   Each element of the expression input specify on of the following:
% 
%   - How to demean the data or detrend data.
% 
%   - How to get the trend given a calculated gap. See the FGTS 
%     option below. 
% 
%   Functionalities:
% 
%   - {'constant',value} or {'constant',value} :
%  
%     With this option you can make the series stationary by subtracting a
%     constant over the whole timespan. This will also be the projection  
%     going forward. (Could also be a mathematical expression)
% 
%     Optional inputs: 
%
%     - 'cmavg'  : This input work the same as is the case for the 
%                 'hpfilter'. Cannot be used together with 'stdise'!
%
%     - 'adjout' : Using nb_adjout to to outlier replacement. Applied
%                  before 'cmavg' or 'stdise'. It is possible to add 3
%                  inputs to this option as well using the syntax;
%                  'adjout(threshold,tFlag,W)'. See the same inputs to the
%                  nb_ts.adjout method. Default is the same as for that 
%                  method for these inputs.
%
%     - 'stdise' : Standardise the series. Cannot be used together with
%                  'cmavg'!
%
%   - {'avg'} or {'avg',...} : 
% 
%     Subtract the mean from the dataseries. This will also be the 
%     projection going forward.
% 
%     Optional inputs: 'wfcst', 'whist' and 'cmavg'. These inputs work the 
%                      same as is the case for the 'hpfilter'. 
%
%   - {'mavg'} or {'mavg',backward,forward,...}:
%
%     Subtract the moving mean from the dataseries.
% 
%     Optional inputs: 'wfcst', 'whist' and 'cmavg'. These inputs work the 
%                      same as is the case for the 'hpfilter'.
%
%   - {'exponentialSmoother',weight} or {'exponentialSmoother',weight,...}:
%
%     Exponential smoother. See the exptrend function for more.
% 
%     Optional inputs:
% 
%     - Same as for the 'hpfilter' case.
%
%   - {'hpfilter',lambda} or {'hpfilter',lambda,...}:
% 
%     HP filter with lambda given by lambda (a number). Switch 'hpfilter'
%     to 'hpfilter1s' to do one-sided HP-filter.
%  
%     Optional inputs:
% 
%     - 'wfcst'
% 
%        When 'wfcst' is given, this function includes all the data
%        after the date given in the cell after this one to compute 
%        the hpfilter. See last option for more on de-trending sub- 
%        periods.
% 
%     - 'whist'
% 
%        When 'whist' is given, this function includes all the data 
%        before the date given in the cell before this one to 
%        compute the hpfilter. See last option for more on de-trending  
%        sub-periods. 
% 
%     Both 'wfcst' and 'whist' does nothing if the hpfilter is not
%     combined with other functions in a cell!
%
%     - 'randomWalk'       : Use a 20 periods projection of the level
%                            in the series by a random walk before
%                            filtering the series.
%
%     - 'randomwalkgrowth' : Use a 20 periods projection of the growth
%                            in the series by a random walk before
%                            filtering the series.
%
%     - 'cmavg'            : Apply the central moving average to the gap, 
%                            i.e. nb_mavg(gap,1,1).
%
%     - function_handle    : A function_handle that takes the time-series 
%                            of gap as it's only input.  
%                            E.g: @(x)nb_mavg(x,1,1)
% 
%  - {'bkfilter',low,high} or {'bkfilter',low,high,....} :
% 
%    Band pass filter removing all the freq. outside the frequencies  
%    given by low and high. Switch 'bkfilter' to 'bkfilter1s' to do 
%    one-sided band pass filter.
% 
%    Optional inputs:
% 
%    - Same as for the 'hpfilter' case. 
%
%  - {'linear'} or {'linear',....} :
% 
%    Apply the linear filter to the data.
% 
%    Optional inputs:
% 
%    - Same as for the 'hpfilter' case.
% 
%  - {'M2T','ar',trend,arCoeff} or 
%    {'M2T','ar',trend,arCoeff,trendStart,lambda} 
%    (M2T = Merge To Trend)
% 
%    If you don't want a constant trend in the future you can use 
%    this option. (Instead of {'end'}). This function will close  
%    the gap between the given growth rate in the trend, at the 
%    date given before this sub-period, and the growth rate given by
%    trend, with a AR process. Where the AR coefficient is given by
%    arCoeff. And it will return the level trend implied by this 
%    growth "path". 
%                               
%    - trend      : Must be a number with the long term growth rate in 
%                   the trend.
%
%    - arCoeff    : Must be a scalar number with the ar coefficient
% 
%    - trendStart : Must be a number with the starting value of the   
%                   growth rate in the trend. Can also be set to 
%                   'hpfilter'. In this case it starts out with the 
%                   growth rate of a hp-filter trend with lambda set
%                   by the lambda input. Optional.
%   
%    - lambda     : A scalar double with the lambda used for the hp-filter
%                   if trendStart is set to 'hpfilter'. Default is 3000.
%                   Optional.
%
%  - {'M2T','int',trend} 
% 
%    This function does the same as the one above, but it uses a 
%    linear growth "path" instead of the one implied by the AR 
%    process to close the "growth gap".
% 
%  - {'FGTS',expression} (FGTS = From Gap To Shift)
% 
%    If you have the gap but need the shift variable you can use 
%    this function. Where expression must be a string with the   
%    expression to evalute. I.e. the expression of data input which 
%    the gap was cumputed of. E.g. 'log(Var1)'.
%
% - {function_handle} or {function_handle,'whist','wfcst'}
%
%    Any function handle on the form; @(x,s)funcHandle(x,s), where x is the
%    time-series of a sub-period to detrend and s is the start date of x, 
%    as a nb_date object. The function_handle must return either one or 
%    two outputs. Both must be returned as double vectors with same size 
%    as the input x! The first output is the additive trend, while the 
%    second output is the multiplicative trend.
%
%    When adding trends back to forecasts in the function 
%    nb_forecast.createReportedVariables it is done in the order;
%    1. Mulitiply by multiplicative trend
%    2. Add the additive trend
% 
%    If the optional input 'whist' is given, than the full history before 
%    the current sub-period of the time-series is appended to x before the
%    function_handle is called, and if 'wfcst' is provided all observations
%    after the current sub-period is appended. In theses cases still only
%    the calculations of the trends inside the window of the sub-period 
%    is used!
%
%    Both 'wfcst' and 'whist' does nothing if the function_handle is not
%    combined with other functions in a cell!
% 
% - A cell where you give different ways to detrend data for 
%   different sub-periods. The cell must be given in the following way: 
% 
%   {{'constant',2},'2011Q2',{'int',2,3},'2012Q2',{'end'}}
% 
%   Where each odd cell element is representing the period up and 
%   including the date given as the even cell elements which 
%   follows. The cell given above will therefore subtract 2 up 
%   and including 2011Q2, and will substract the line starting at 
%   2 in 2011Q3 and ending at 3 in 2012Q2. From then on it will 
%   substract the last value given at 2012Q2 for all periods ahead.
%     
%   Options for each cell (up and including the date given as the 
%   next cell):
% 
%   - {'constant',value}          : as above
%
%   - {'avg'}                     : as above
% 
%   - {'hpfilter',lambda,...}     : as above
% 
%   - {'bkfilter',low,high,...}   : as above
% 
%   - {'M2T','ar',trend,arCoeff}  : as above
% 
%   - {'FGTS','expression'}       : as above
%
%   - {function_handle,...}       : as above
%
%   Options for the last sub-period (last cell element):
%
%   - {'end'}                     : Project the trend using a random walk.
%
%   - {'endgrowth'}               : Project the trend using a random walk
%                                   in the growth rate.
%
%   - {'M2T','ar',trend,arCoeff}  : as above
%
% Input:
% 
% - obj               : An object of class nb_ts
% 
% - nSteps            : Number of steps to extrapolate the shift variable
%
% - variables         : The variables to be removed a trend/shift. As a   
%                       cell array or a string.
% 
%                       Must have the same size as the 
%                       'expressions' input.
% 
% - expression        : The expressions of how to create the trend/shift 
%                       of all the variables.  
%
%                       As a cell array with the same size as the
%                       'variables' input.
%
%                       See the description of this method for the 
%                       supported de-trending methods.  
%
% - output            : If given as 'shift' the first output will be the
%                       shift output instead.
% 
% Output:
% 
% - obj     : A nb_ts object where the listed variables has been detrended.
%
% - shift   : A nb_ts object storing the trend/shift variables. All the
%             variables not included in the variables input will be given a
%             shift variable of zero.
%
% - plotter : A nb_graph_ts object that plots the de-trending of the data. 
%             Use the graphInfoStruct method or the
%             nb_graphInfoStructGUI class to produce the graphs.
%
%             Caution: If dealing with real-time data, only the last
%                      vintage is displayed.
%
% Examples: 
%
% obj = obj.createShift({'var1','var2',...},...
%       {{{'avg'},'2012Q1',{'end'}},{{'constant',2}},...});
%
% obj = obj.createShift({'var1','var2',...},...
%       {{{@(x)nanmean(x)},'2012Q1',{'end'}},{{'constant',2}},...});
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 5
        output = 'normal';
    end

    if ischar(expression)
        expression = cellstr(expression);
    end

    if ischar(variables)
        variables = cellstr(variables);
    end

    if length(variables) ~= length(expression)
        error(['You must provide as many variable names as the ',...
            'number of expressions you give'])
    end

    % Evaluate expressions
    startDate = obj.startDate;
    vars      = obj.variables;
    level     = obj.data;
    shift     = [zeros(size(obj.data));zeros(nSteps,obj.numberOfVariables,obj.numberOfDatasets)];
    outliers  = [zeros(size(obj.data));zeros(nSteps,obj.numberOfVariables,obj.numberOfDatasets)];
    shiftMult = [ones(size(obj.data));ones(nSteps,obj.numberOfVariables,obj.numberOfDatasets)];
    for ii = 1:length(expression)
        ind = find(strcmp(variables{ii},vars));
        try
            [shift(:,ind,:),shiftMult(:,ind,:),outliers(:,ind,:),FGTS] = ...
                interpretShift(level(:,ind,:),shift(:,ind,:),...
                shiftMult(:,ind,:),outliers(:,ind,:),expression{ii},...
                startDate,obj,nSteps);
        catch Err
            nb_error(['Error while interpreting the shift expression for ',...
                'the variables ' variables{ii} '.'],Err)
        end
        if FGTS
            level(:,ind,:) = level(:,ind,:) + shift(1:size(level,1),ind,:);
        end
        
    end
    shift    = shift + outliers;
    obj.data = level - shift(1:size(level,1),:,:);
    obj.data = obj.data ./ shiftMult(1:size(level,1),:,:);
    shift    = nb_ts([shift,shiftMult],'',obj.startDate,...
        [obj.variables,strcat(obj.variables,'_multshift')],obj.sorted);

    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        shift.links      = obj.links;
        obj              = obj.addOperation(@createShift,{nSteps,...
            variables,expression});
        shift.updateable = 1;
        shift            = shift.addOperation(@createShift,{nSteps,...
            variables,expression,'shift'});
        
    end
    
    if strcmpi(output,'shift')
        obj = shift;
    end
    
    if nargout > 2
        
        % Construct all variables
        %-------------------------------------------------------------
        shiftT = window(shift,'','',variables);
        objT   = window(obj,'','',variables);
        level  = objT + shiftT;
        gap    = addPostfix(objT,'_gap');
        trend  = addPostfix(shiftT,'_trend');
        if isRealTime(obj)
            numP  = gap.numberOfDatasets;
            fullD = [window(breakLink(gap),'','','',numP),...
                window(breakLink(level),'','','',numP),...
                window(breakLink(trend),'','','',numP)];
        else
            fullD = [gap,level,trend];
        end
        
        % Get the expression to be graphed
        %--------------------------------------------------------------
        vars       = level.variables;
        plottedVar = cell(1,length(vars)*2);
        for ii = 1:length(vars)
            plottedVar{ii*2 - 1} = ['[' vars{ii} ',' vars{ii} '_trend]'];
            plottedVar{ii*2}     = [vars{ii},'_gap'];
        end
        
        % Create the GraphStruct input to the nb_graph_ts class
        %----------------------------------------------------------
        GraphStruct = struct();
        for ii = 1:length(vars)
            field = strrep(vars{ii},' ','_');
            field = strrep(field,'æ','ae');
            field = strrep(field,'ø','oe');
            field = strrep(field,'å','aa');
            field = strrep(field,'Æ','Ae');
            field = strrep(field,'Ø','Oe');
            field = strrep(field,'Å','Aa');
            GraphStruct.(field) = {plottedVar{ii*2 - 1},  ...
                {'title', vars{ii}, 'colorOrder',{'black','red'},...
                 'legends',{'Raw Data','Trend'}}; plottedVar{ii*2},...
                {'title', vars{ii}, 'colorOrder',{'blue'},'legends',{'Gap'}}};
        end
        
        % Initilize nb_graph_ts object
        %----------------------------------------------------------
        plotter = nb_graph_init(fullD);
        plotter.set('GraphStruct',GraphStruct,'baseline',0);
        
    end
    
end

%==========================================================================
function [shift,shiftMult,outliers,FGTS] = interpretShift(level,shift,...
    shiftMult,outliers,expression,startDate,obj,nSteps)

    if isempty(expression)
        FGTS     = false;
        return
    end
    shift(:)     = nan; % Set to nan to not return trend of zeros.
    shiftMult(:) = nan; % Set to nan to not return multiplikative trend of ones.
    outliers(:)  = nan; % Set to nan to not return outliers of zeros.

    if ~iscell(expression)
        if ischar(expression)
            expression = cellstr(expression);
        elseif isa(expression,'function_handle')
            expression = {expression};
        else
            error(['Each element of the shift expressions input must be a ',...
                'cell, a one line char or a function_handle!'])
        end
    end
    
    
    if length(expression) > 1
        
        FGTS = false;
        ind  = 1;
        for ii = 1:2:length(expression)
            
            indS = ind;
            try
                date = expression{ii+1};
                if strcmpi(date,'endDate')
                    indE = nan(1,size(level,3));
                    for pp = 1:size(level,3)
                        indE(pp) = find(~isnan(level(:,:,pp)),1,'last');
                    end
                else
                    date = nb_date.toDate(date,startDate.frequency);
                    indE = (date - startDate) + 1; 
                end
            catch Err                
                if strcmpi(Err.identifier,'MATLAB:badsubscript')
                    indE = nan(1,size(level,3));
                    for pp = 1:size(level,3)
                        indE(pp) = find(~isnan(level(:,:,pp)),1,'last') + nSteps;
                    end
                else
                    rethrow(Err)
                end
            end
            
            expr = expression{ii};
            if ischar(expr)
                expr = cellstr(expr);
            elseif isa(expr,'function_handle')
                expr = {expr};
            elseif ~iscell(expr)
                error(['Each sub-element of the expressions input must be a ',...
                    'cell, a one line char or a function_handle!'])
            end
            inputs = expr(2:end);
            expr   = expr{1};
            ind    = indE + 1;
            if isscalar(indE)
            
                if indE < indS + 1
                    continue
                end
                [shift,shiftMult,outliers,FGTST] = interpretSub(indS,indE,level,...
                    shift,shiftMult,outliers,expr,inputs,obj);
                if indE == size(shift,1)
                    break
                end
                
            else
                if isscalar(indS)
                    indS = indS(1,ones(1,size(indE,2)));
                end
                for pp = 1:size(indE,2)
                    if indE(pp) < indS(pp) + 1
                        continue
                    end
                    [shift(:,:,pp),shiftMult(:,:,pp),outliers(:,:,pp),FGTST] = interpretSub(indS(pp),...
                        indE(pp),level(:,:,pp),shift(:,:,pp),shiftMult(:,:,pp),outliers(:,:,pp),...
                        expr,inputs,window(obj,'','','',pp));
                end
                
            end
            FGTS = FGTS || FGTST;
            
        end
        
    else

        expr = expression{1};
        if nb_isOneLineChar(expr) || isa(expr,'function_handle')
            expr = {expr};
        elseif ~iscell(expr)
            error(['Each sub-element of the expressions input must be a ',...
                'cell, a one line char or a function_handle!'])
        end
        inputs                          = expr(2:end);
        indS                            = 1;
        indE                            = size(shift,1);
        [shift,shiftMult,outliers,FGTS] = interpretSub(indS,indE,level,...
            shift,shiftMult,outliers,expr{1},inputs,obj);
        
    end

end

%==========================================================================
function [shift,shiftMult,outliers,FGTS] = interpretSub(indS,indE,level,...
    shift,shiftMult,outliers,expression,inputs,obj)

    shiftMult(indS:indE,:,:) = 1;
    outliers(indS:indE,:,:)  = 0;
    shift(indS:indE,:,:)     = 0;
    FGTS                     = false;
    if isa(expression,'function_handle')
        [shift,shiftMult] = interpretFunctionHandle(indS,indE,level,...
            shift,shiftMult,expression,inputs,obj.startDate);
        return
    end

    switch lower(expression)      
        case 'avg'     
            shift = interpretAVG(indS,indE,level,shift,inputs);
        case 'bkfilter'
            shift = interpretFilter(indS,indE,level,shift,'bkfilter',inputs);  
        case 'bkfilter1s'
            shift = interpretFilter(indS,indE,level,shift,'bkfilter1s',inputs);      
        case {'constant','c'}
            
            cmavg  = false;
            stdise = false;
            adjout = false;
            if numel(inputs) == 1
                input = inputs{1};
            elseif numel(inputs) == 2 || numel(inputs) == 3
                input = inputs{1};
                for ii = 2:numel(inputs)
                    inputII = inputs{ii};
                    if strcmp(inputII,'cmavg')
                        cmavg = true;
                    elseif strcmp(inputII,'stdise')
                        stdise = true;
                    elseif strncmp(inputII,'adjout',6)    
                        adjout    = true;
                        threshold = 5;
                        tFlag     = 4;
                        W         = 5;
                        inpAdjout = inputII(7:end);
                        if ~isempty(inpAdjout)
                            inpAdjout = strrep(inpAdjout,'(','');
                            inpAdjout = strrep(inpAdjout,')','');
                            inpAdjout = strsplit(inpAdjout,',');
                            if size(inpAdjout,2) ~= 3
                                error('If you provide some optional inputs to the adjout option, you need to provide 3 of them! ''adjout(5,4,5)''');
                            end
                            threshold = str2double(inpAdjout{1});
                            tFlag     = str2double(inpAdjout{2});
                            W         = str2double(inpAdjout{3});
                        end
                    else
                        error(['Unsupported extra input to the shift ',...
                            'identifier ''constant''.'])
                    end
                end
            else
                error(['When the the shift identifier is ''constant'' it ',...
                    'must be given as {''constant'',input} or {''constant''',...
                    ',input,''cmavg''}, where input is a double.'])
            end
            
            if ~isnumeric(input) || ~isscalar(input)
                error(['When the the shift identifier is constant it ',...
                    'must be given as {''constant'',input}, where input is a double.'])
            end
            indEC     = min(size(level,1),indE);
            levelTemp = level(indS:indEC,:,:);
            if adjout
                levelTemp                = nb_adjout(level(indS:indEC,:,:),threshold,tFlag,W);
                outliers(indS:indEC,:,:) = level(indS:indEC,:,:) - levelTemp;
            end
            if cmavg && stdise
                error(['Cannot give ''stdise'' and ''cmavg'' at the same ',...
                    'time to the shift identifier ''constant''.'])
            end
            
            if cmavg
                gapTemp               = levelTemp - input;
                gapTemp               = nb_mavg(gapTemp,1,1);
                shift(indS:indEC,:,:) = shift(indS:indEC,:,:) + (levelTemp - gapTemp);
            elseif stdise
                if input ~= 0
                    error(['If you use the ''stdise'' option, you must set ',...
                        'the constant term to 0 (The input after ''constant'').'])
                end
                shift(indS:indE,:,:)     = shift(indS:indE,:,:) + mean(levelTemp,'omitnan');
                shiftMult(indS:indE,:,:) = shiftMult(indS:indE,:,:) * std(levelTemp,'omitnan');
            else
                shift(indS:indE,:,:) = shift(indS:indE,:,:) + input; 
            end
            
        case 'end'
            
            if indS == 1
                errror(['When the the shift identifier is ''end'' it ',...
                    'cannot be used for the first subperiod.'])
            end
            periods                  = indE - indS + 1;
            constant                 = shift(indS-1,:,:);
            constantMult             = shiftMult(indS-1,:,:);
            shift(indS:indE,:,:)     = constant(ones(1,periods),:,:);
            shiftMult(indS:indE,:,:) = constantMult(ones(1,periods),:,:);
            
        case 'endgrowth'
            
            if indS == 1
                errror(['When the the shift identifier is ''endGrowth'' it',...
                    ' cannot be used for the first subperiod.'])
            end
            periods              = indE - indS + 1;
            constant             = diff(shift(indS-2:indS-1,:,:),1,1);
            shift(indS:indE,:,:) = bsxfun(@plus, shift(indS-1,:,:), cumsum(constant(ones(1,periods),:,:)));
            
        case 'exponentialsmoother'
            shift = interpretFilter(indS,indE,level,shift,'exponentialsmoother',inputs); 
        case 'fgts'
            
            FGTS = true;
            if numel(inputs) == 1
                expr = inputs{1};
            else
                error(['When the the shift identifier is ''FGTS'' it must ',...
                    'be given as {''FGTS'',expression}, where expression ',...
                    'is a one line char array.'])
            end
            gap                  = level;
            obj                  = createVariable(obj,'level',expr);
            level                = double(keepVariables(obj,{'level'}));
            shift(indS:indE,:,:) = level(indS:indE,:,:) - gap(indS:indE,:,:);
            
        case 'int'
            
            if numel(inputs) == 2
                start  = inputs{1};
                finish = inputs{2};
            else
                errror(['When the the shift identifier is ''int'' it must ',...
                    'be given as {''int'',start,finish}, where start and ',...
                    'finish are doubles.'])
            end
            periods              = indE - indS + 1;
            d                    = (finish - start)/periods;
            shift(indS:indE,:,:) = (1:periods)*d + start;
            
        case 'hpfilter'
            shift = interpretFilter(indS,indE,level,shift,'hpfilter',inputs);
        case 'hpfilter1s'
            shift = interpretFilter(indS,indE,level,shift,'hpfilter1s',inputs);    
        case 'jump2trend'
            shift = J2T(indS,indE,level,shift,inputs);
        case 'linear'
            shift = interpretFilter(indS,indE,level,shift,'linear',inputs);
        case 'linear1s'
            shift = interpretFilter(indS,indE,level,shift,'linear1s',inputs); 
        case 'mavg'
            shift = interpretFilter(indS,indE,level,shift,'mavg',inputs);      
        case {'merge2trend','m2t'}
            shift = M2T(indS,indE,level,shift,inputs);
        otherwise
            error(['Unsupported shift expression ' expression])
    end

end

%==========================================================================
function shift = interpretAVG(indS,indE,level,shift,inputs)

    indEC = min(size(level,1),indE);
    indSC = indS;
    cmavg = false;
    for ii = 1:length(inputs)  
        switch lower(inputs{ii}) 
            case 'wfcst'
                indEC = size(level,1);
            case 'whist'
                indSC = 1;
            case 'cmavg'
                cmavg = true;
            otherwise
                errror(['When the the shift identifier is ''avg'' it must ',...
                    'be given as {''avg'',''wfcst'',''whist'',''cmavg''}, '...
                    'where the three last inputs are optional.'])
        end
    end

    if numel(inputs) > 3 
        errror(['When the the shift identifier is ''avg'' it must be given ',...
            'as {''avg'',''wfcst'',''whist'',''cmavg''}, '...
            'where the three last inputs are optional.'])
    end
    level = level(indSC:indEC,:,:);
    mData = mean(level,1,'omitnan');
    mData = mData(ones(1,indE - indS + 1),:,:);
    if cmavg
        gapTemp              = level(indS:indE,:,:) - mData;
        gapTemp              = nb_mavg(gapTemp,1,1);
        shift(indS:indE,:,:) = level(indS:indE,:,:) - gapTemp;
    else
        shift(indS:indE,:,:) = mData; 
    end

end

%==========================================================================
function shift = interpretFilter(indS,indE,level,shift,filter,inputs)

    if indE > size(level,1)
        level = [level;nan(indE - size(level,1),1,size(level,3))];
    end

    switch lower(filter)
        
        case 'exponentialsmoother'
            
            try
                weight = inputs{1};
            catch %#ok<CTCH>
                errror(['When the the shift identifier is ''' filter ''' ',...
                    'it must be given as {''' filter ''',weight,...}, '...
                    'where weight must be given. For more see the documentation.'])
            end
            maxInputs = 4;
            startOpt  = 2;
            errorExpr = ['{''' filter ''',weight,...}'];
        
        case {'hpfilter','hpfilter1s'}
            
            try
                lambda = inputs{1};
            catch %#ok<CTCH>
                errror(['When the the shift identifier is ''' filter ''' ',...
                    'it must be given as {''' filter ''',lambda,...}, '...
                    'where lambda must be given. For more see the documentation.'])
            end
            maxInputs = 4;
            startOpt  = 2;
            errorExpr = ['{''' filter ''',lambda,...}'];
            
        case {'bkfilter','bkfilter1s'}
            
            try
                lowestFreq = inputs{1};
            catch %#ok<CTCH>
                errror(['When the the shift identifier is ''' filter ''' ',...
                    'it must be given as {''' filter ''',lowestFreq,highestFreq,...}, '...
                    'where lowestFreq and highestFreq must be given. For ',...
                    'more see the documentation.'])
            end
            try
                highestFreq = inputs{2};
            catch %#ok<CTCH>
                errror(['When the the shift identifier is ''' filter ''' ',...
                    'it must be given as {''' filter ''',lowestFreq,highestFreq,...}, '...
                    'where lowestFreq and highestFreq must be given. For ',...
                    'more see the documentation.'])
            end
            maxInputs = 5;
            startOpt  = 3;
            errorExpr = ['{''' filter ''',lowestFreq,highestFreq,...}'];
            
        case {'linear','linear1s'}
            
            maxInputs = 3;
            startOpt  = 1;
            errorExpr = ['{''' filter ''',...}'];
            
        case 'mavg'
            
            try
                backward = inputs{1};
            catch %#ok<CTCH>
                errror(['When the the shift identifier is ''' filter ''' ',...
                    'it must be given as {''' filter ''',backward,forward,...}, '...
                    'where backward and forward must be given. For more ',...
                    'see the documentation.'])
            end
            try
                forward = inputs{2};
            catch %#ok<CTCH>
                errror(['When the the shift identifier is ''' filter ''' ',...
                    'it must be given as {''' filter ''',backward,forward,...}, '...
                    'where backward and forward must be given. For more ',...
                    'see the documentation.'])
            end
            maxInputs = 5;
            startOpt  = 3;
            errorExpr = ['{''' filter ''',backward,forward,...}'];
            
    end
    
    % Interpret optional inputs to the filters
    options = {0,indE,indS,false};
    options = interpretFilterOptions(options,inputs,startOpt,filter,level);
    options = interpretFilterOptions(options,inputs,startOpt+1,filter,level);
    options = interpretFilterOptions(options,inputs,startOpt+2,filter,level);
    fcst    = options{1};
    indEC   = options{2};
    indSC   = options{3};
    func    = options{4};
    if numel(inputs) > maxInputs 
        errror(['When the the shift identifier is ''' filter ''' it must ',...
            'be given as ' errorExpr '. For more see the documentation.'])
    end
    if and(fcst > 0, indE ~= indEC) 
        error(['The optional inputs to the ''' filter ''' command cannot ',...
            'include ''wfcst'' and ''ar'', ''argrowth'', ''randomWalk'' ',...
            'or ''randomWalkGrowth'' at the same time.'])
    end
    
    % Do forecasting if wanted
    if fcst > 0
        [level,indEC] = extrapolate(fcst,level,indS,indE);
    end
    
    % These function handle nan values!
    data = level(indSC:indEC,:,:);
    if all(isnan(data))
        error('The series only consists of NaN values.')
    end
    switch lower(filter)
        case 'exponentialsmoother'
            gap = data - nb_lag(exptrend(data,weight));
        case 'hpfilter'
            gap = hpfilter(data,lambda);
        case 'hpfilter1s'
            gap = hpfilter1s(data,lambda);    
        case 'bkfilter'
            gap = bkfilter(data,lowestFreq,highestFreq);
        case 'bkfilter1s'
            gap = bkfilter1s(data,lowestFreq,highestFreq);    
        case 'linear'
            gap = nb_linearFilter(data);
        case 'linear1s'
            gap = nb_linearFilter(data); 
        case 'mavg'
            gap = data - nb_mavg(data,backward,forward); 
    end
    if isa(func,'function_handle') % Support for any function handle
        try
            gap = func(gap);
        catch Err
            nb_error(['The function handle given to the shift ',...
                'identifier ''' filter ''' failed with error:'],Err);
        end
    elseif func % cmavg option is used.
        gap = nb_mavg(gap,1,1);
    end
    
    shift(indS:indE,:,:) = level(indS:indE,:,:) - gap(indS:indE,:,:);
    
end

%==========================================================================
function options = interpretFilterOptions(options,inputs,startOpt,filter,level)

    if numel(inputs) > startOpt - 1
        if strcmpi(inputs{startOpt},'wfcst')
            options{2} = size(level,1);
        elseif strcmpi(inputs{startOpt},'whist')
            options{3} = 1;
        elseif strcmpi(inputs{startOpt},'randomwalk')
            checkInput(options,filter);
            options{1} = 1;
        elseif strcmpi(inputs{startOpt},'randomwalkgrowth')
            checkInput(options,filter);
            options{1} = 2;
        elseif strcmpi(inputs{startOpt},'ar')
            checkInput(options,filter);
            options{1} = 3;   
        elseif strcmpi(inputs{startOpt},'argrowth')
            checkInput(options,filter);
            options{1} = 4;      
        elseif strcmpi(inputs{startOpt},'cmavg')
            options{4} = true; 
            if isa(filter,'function_handle')
                error(['The ''cmavg'' input is not supported as an ',...
                    'additional input to the function_handle; ' func2str(filter)])
            end
        elseif isa(inputs{startOpt},'function_handle') 
            options{4} = inputs{startOpt};
            if isa(filter,'function_handle')
                error(['A function_handle input is not supported as an ',...
                    'additional input to the function_handle; ' func2str(filter)])
            end
        else
            if isa(filter,'function_handle')
                error(['When the the shift identifier is a function_handle (',...
                    func2str(filter) ') optional inputs are ''wfcst'', ',...
                    '''whist'', ''ar'', ''argrowth'', ''randomWalk'', ',...
                    'and ''randomWalkGrowth''.'])
            else
                error(['When the the shift identifier is ''' filter ''' the ',...
                    'optional inputs are ''wfcst'', ''whist'', ''ar'', ',...
                    '''argrowth'', ''randomWalk'', ''randomWalkGrowth'' ',...
                    'and ''cmavg''.'])
            end
        end
    end

end

%==========================================================================
function checkInput(options,filter)

    if isa(filter,'function_handle')
        extra = ['function_handle ' func2str(filter)];
    else
        extra = ['''' filter ''' command'];
    end
    if options{1} ~= 0
        error(['The optional inputs to the ' extra '  cannot ',...
            'include ''randomWalk'' and ''randomWalkGrowth'' at the same time.'])
    end

end

%==========================================================================
function [level,indEC] = extrapolate(fcst,level,indS,indE)

    if fcst == 1
        temp      = level(indE,:,:);
        appData   = temp(ones(1,20),:,:);
        level     = [level(indS:indE,:,:); appData];
    elseif fcst == 2
        temp      = level(indS:indE,:,:);
        Growth    = 1 + egrowth(temp(end-4:end,:,:),1);
        mGrowth   = mean(Growth(2:end,:,:),1);
        mGrowth   = mGrowth(ones(1,20),:,:);
        start     = temp(end,:,:);
        start     = start(ones(1,20),:,:);
        appData   = start.*cumprod(mGrowth,1);
        level     = [temp; appData];
    elseif any(fcst == [3,4])
        
        % Forecast using a automatically selected AR(p) model
        estData = level(indS:indE,:,:);
        level   = [level;nan(20,1,size(level,3))];
        data    = nb_ts(estData,'','1','Var1');
        for ii = 1:size(level,3)
           
            m = nb_arima(...
                'algorithm',   'hr',...
                'criterion',   'sic',...
                'data',        data(:,:,ii),...
                'dependent',   {'Var1'},...
                'integration', double(fcst == 4),... 
                'MA',          0);
            m                 = estimate(m);
            m                 = solve(m);
            m                 = forecast(m,20,'varOfInterest','Var1');
            level(end-19:end) = double(getForecast(m));
            
        end
        
    end
    
    indEC = indE + 20;

end

%==========================================================================
function shift = J2T(indS,indE,level,shift,inputs)
%{
Jump to trend function. This uses the actual data as the starting 
% value for the projections of the trend. syntax; 
{'J2T','3.75/400'} 
{'J2T','avg'} 
%}

    if startInd < 3 
        error(['The method jump2trend needs two observations before the ',...
            'date given to calculate the trends growth rate'])
    elseif startInd == endInd
        error(['You are trying to set the trend outside the horizon ',...
            'of your data. Which is not possible.'])
    end

    try
        trendGrowth = inputs{1}; % jump to this growth rate
    catch %#ok<CTCH>
        error('Wrong number of inputs are given to the jump2trend method.')
    end
    
    if strcmpi(trendGrowth,'avg')
        trendGrowth = mean(growth(level(1:indS-1,:,:),1),1,'omitnan');
    end    

    % Now we use the end point of the actual series and project the
    % trend with the constant trend growth
    periods              = indE - indS + 1;
    trendGrowth          = trendGrowth(ones(1,periods),:,:);
    shift(indS:indE,:,:) = level(indS-1,:,:) + cumsum(trendGrowth,1);

end

%==========================================================================
function shift = M2T(indS,indE,level,shift,inputs)
%{
Merge to trend function: syntax; 
{'merge2trend','ar','3.75/400',0.8}
{'merge2trend','int','3.75/400'}
%}

    try
        type        = inputs{1}; % 'int' or 'ar'
        growthCoeff = inputs{2}; % merging to this growth rate, can also be 'avg'
    catch %#ok<CTCH>
        error('Wrong number of inputs are given to the merge2trend method.')
    end
    arCoeff        = [];
    try arCoeff    = inputs{3}; catch; end %#ok<CTCH>
    startTrend     = [];
    try startTrend = inputs{4}; catch; end %#ok<CTCH>
    lambda         = 3000;
    try lambda     = inputs{5}; catch; end %#ok<CTCH>

    if indS < 3 
        error(['The method ''merge2trend'' needs two observations before ',...
            'the date given to calculate the growth rate of the trend'])
    elseif indS == indE
        error(['You ar trying to set the trend outside the horizon ',...
            'of your data. Which is not possible.'])
    end
    
    if strcmpi(growthCoeff,'avg')
        growthCoeff = (level(indS-1,:,:) - level(1,:,:))./(indS-1);
    end

    if strcmpi(startTrend,'hpfilter')
        startTrend = level(1:indS-1,:,:) - hpfilter(level(1:indS-1,:,:),lambda);
        startTrend = startTrend(indS-1) - startTrend(indS-2);
    end
    
    switch lower(type)

        case 'ar'

            if isempty(arCoeff)
                error(['The arCoeff (input 3) input must be given to ',...
                    'the ''merge2trend'' method.'])
            end
            
            % if type 'ar', merging to the growth rate given by 
            % growthCoeff with a ar process with coefficient 
            % given by this parameter
            if isempty(startTrend)
                gr_shift = AutoRegressive(shift,growthCoeff,arCoeff,indS,indE,0);
            else
                gr_shift = AutoRegressive(startTrend,growthCoeff,arCoeff,indS,indE,'start');
            end
            shift(indS:indE,:,:) = shift(indS-1,:,:) + cumsum(gr_shift,1);

        case 'int'

            if isempty(startTrend)
                startTrend = shift(indS-1,:,:) - shift(indS-2,:,:); % due to log approximated growth
            end
            gr_shift             = LinearInterpolation(startTrend,growthCoeff,indE - indS + 2);
            shift(indS:indE,:,:) = shift(indS-1,:,:) + cumsum(gr_shift(2:end,:,:),1); % The gr_shift(1) is the same as the last observation in history, and doesn't want that. 

        otherwise
            error(['The first input to M2T could not be evaluated. ',...
                'The expression is: ' type])
    end

end

%==========================================================================
function shift = AutoRegressive(startValue,endValue,arCoeff,indS,indE,type)
%{
Close the gap between (log approx.) startValue and endValue, with a AR 
process. Where the AR coefficient is given by arCoeff.
%}

    if strcmpi(type,'start')
        start = startValue;
    else
        if type
            % merge from last level in already calculated shift
            start = startValue(indS-1,:,:);
        else
            % merge from last growth rate in already calculated shift
            start = startValue(indS-1,:,:) - startValue(indS-2,:,:);
        end
    end
    per     = indE - indS + 1;
    gap     = start - endValue;
    gap     = gap(ones(1,per),:,:);
    t       = [1:indE - indS + 1]';  %#ok<NBRAK>
    t       = t(:,:,ones(1,size(gap,3)));
    arCoeff = arCoeff(ones(1,per),:,ones(1,size(gap,3)));
    shift   = gap.*(arCoeff.^t) + endValue;

end

%==========================================================================
function shift = LinearInterpolation(startValue,endValue,diff)
%{
Linearly interpolate to values given by startValue and endValue,
over a period given by diff.
%}

    shiftGrowthRate = (endValue - startValue)/(diff-1);
    shift           = nan(diff,1,size(startValue,3));
    for jj = 1:diff 
        shift(jj,:,:) = startValue + shiftGrowthRate*(jj-1); % due to log approximated growth
    end
    
end

%==========================================================================
function [shift,shiftMult] = interpretFunctionHandle(indS,indE,level,...
                    shift,shiftMult,funcHandle,inputs,startDate)

    if indE > size(level,1)
        level = [level;nan(indE - size(level,1),1,size(level,3))];
    end

    maxInputs = 3;
    startOpt  = 1;
    errorExpr = ['{''' func2str(funcHandle) ''',...}'];

    % Interpret optional inputs to the filters
    options = {0,indE,indS,false};
    options = interpretFilterOptions(options,inputs,startOpt,funcHandle,level);
    options = interpretFilterOptions(options,inputs,startOpt+1,funcHandle,level);
    options = interpretFilterOptions(options,inputs,startOpt+2,funcHandle,level);
    fcst    = options{1};
    indEC   = options{2};
    indSC   = options{3};
    if numel(inputs) > maxInputs 
        errror(['When providing a function_handle it must be given as ',...
            errorExpr '. For more see the documentation.'])
    end
    if and(fcst > 0, indE ~= indEC) 
        error(['The optional inputs when providing a function_handle cannot ',...
            'include ''wfcst'' and ''ar'', ''argrowth'', ''randomWalk'' ',...
            'or ''randomWalkGrowth'' at the same time.'])
    end
    
    % Do forecasting if wanted
    if fcst > 0
        [level,indEC] = extrapolate(fcst,level,indS,indE);
    end
    
    % These function handle nan values!
    data = level(indSC:indEC,:,:);
    if all(isnan(data))
        error('The series only consists of NaN values.')
    end
    
    % Call function handle
    try 
        [shiftTemp,shiftMultTemp] = funcHandle(data,startDate + (indSC - 1));
    catch 
        try
            shiftTemp     = funcHandle(data,startDate + (indSC - 1));
            shiftMultTemp = ones(size(data));
        catch
            error(['Could not call the function_handle; ',...
                func2str(funcHandle), ' on a double vector.'])
        end
    end

    % Check shift output
    if ~(isnumeric(shiftTemp) && isvector(shiftTemp))
        error(['The first output of the function_handle; ',...
            func2str(funcHandle), ' is not a double vector.'])
    end
    shiftTemp = shiftTemp(:);
    if size(shiftTemp,1) ~= size(data,1)
        error(['The first output of the function_handle; ',...
            func2str(funcHandle), ' is not a double vector with the ',...
            'same length as the input (' int2str(size(shiftTemp,1)) ' vs ',...
            int2str(size(data,1)) ').'])
    end

    % Check shift multiplier output
    if ~(isnumeric(shiftMultTemp) && isvector(shiftMultTemp))
        error(['The second output of the function_handle; ',...
            func2str(funcHandle), ' is not a double vector.'])
    end
    shiftMultTemp = shiftMultTemp(:);
    if size(shiftMultTemp,1) ~= size(data,1)
        error(['The second output of the function_handle; ',...
            func2str(funcHandle), ' is not a double vector with the ',...
            'same length as the input (' int2str(size(shiftMultTemp,1)) ' vs ',...
            int2str(size(data,1)) ').'])
    end

    shift(indS:indE,:,:)     = shiftTemp(indS:indE,:,:);
    shiftMult(indS:indE,:,:) = shiftMultTemp(indS:indE,:,:);
    
end
