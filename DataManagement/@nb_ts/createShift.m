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
%   - How to get the trend given a calculate the gap. See the FGTS 
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
%     Optional inputs: 'cmavg'. These inputs work the same as is the
%                       case for the 'hpfilter'.
%
%   - {'avg'} or {'avg',...} : 
% 
%     Subtract the mean from the dataseries. Including short term
%     forecast. This will also be the projection going forward.
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
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

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
        error([mfilename ':: You must provide as many variable names as the number of expressions you give'])
    end

    % Evaluate expressions
    startDate = obj.startDate;
    vars      = obj.variables;
    level     = obj.data;
    shift     = [zeros(size(obj.data));zeros(nSteps,obj.numberOfVariables,obj.numberOfDatasets)];
    for ii = 1:length(expression)
        ind = find(strcmp(variables{ii},vars));
        try
            [shift(:,ind,:),FGTS] = interpretShift(level(:,ind,:),shift(:,ind,:),expression{ii},startDate,obj,nSteps);
        catch Err
            nb_error([mfilename ':: Error while interpreting the shift expression for the variables ' variables{ii} '.'],Err)
        end
        if FGTS
            level(:,ind,:) = level(:,ind,:) + shift(1:size(level,1),ind,:);
        end
        
    end
    obj.data = level - shift(1:size(level,1),:,:);
    shift    = nb_ts(shift,'',obj.startDate,obj.variables,obj.sorted);

    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        shift.links      = obj.links;
        obj              = obj.addOperation(@createShift,{nSteps,variables,expression});
        shift.updateable = 1;
        shift            = shift.addOperation(@createShift,{nSteps,variables,expression,'shift'});
        
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
            fullD = [window(breakLink(gap),'','','',numP),window(breakLink(level),'','','',numP),window(breakLink(trend),'','','',numP)];
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
            GraphStruct.(field) = {plottedVar{ii*2 - 1},  {'title', vars{ii}, 'colorOrder',{'black','red'},'legends',{'Raw Data','Trend'}};
                                   plottedVar{ii*2},{'title', vars{ii}, 'colorOrder',{'blue'},'legends',{'Gap'}}};
        end
        
        % Initilize nb_graph_ts object
        %----------------------------------------------------------
        plotter = nb_graph_init(fullD);
        plotter.set('GraphStruct',GraphStruct,'baseline',0);
        
    end
    
end

%==========================================================================
function [shift,FGTS] = interpretShift(level,shift,expression,startDate,obj,nSteps)

    if isempty(expression)
        FGTS     = false;
        return
    end
    shift(:) = nan; % Set to nan to not return trend of zeros.

    if ~iscell(expression)
        if ischar(expression)
            expression = cellstr(expression);
        else
            error('Each element of the shift expressions input must be a cell or a one line char!')
        end
    end
    
    
    if size(expression,2) > 1
        
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
            if ~iscell(expr)
                error('Each sub-element of the expressions input must be a cell!')
            end
            inputs = expr(2:end);
            expr   = expr{1};
            ind    = indE + 1;
            if isscalar(indE)
            
                if indE < indS + 1
                    continue
                end
                [shift,FGTST] = interpretSub(indS,indE,level,shift,expr,inputs,obj);
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
                    [shift(:,:,pp),FGTST] = interpretSub(indS(pp),indE(pp),level(:,:,pp),shift(:,:,pp),expr,inputs,window(obj,'','','',pp));
                end
                
            end
            FGTS = FGTS || FGTST;
            
        end
        
    else

        expr = expression{1};
        if nb_isOneLineChar(expr)
            expr = {expr};
        else
            if ~iscell(expr)
                error('Each sub-element of the expressions input must be a cell or a one line char!')
            end
        end
        inputs       = expr(2:end);
        indS         = 1;
        indE         = size(shift,1);
        [shift,FGTS] = interpretSub(indS,indE,level,shift,expr{1},inputs,obj);
        
    end

end

%==========================================================================
function [shift,FGTS] = interpretSub(indS,indE,level,shift,expression,inputs,obj)

    FGTS = false;
    switch lower(expression)      
        case 'avg'     
            shift = interpretAVG(indS,indE,level,shift,inputs);
        case 'bkfilter'
            shift = interpretFilter(indS,indE,level,shift,'bkfilter',inputs);  
        case 'bkfilter1s'
            shift = interpretFilter(indS,indE,level,shift,'bkfilter1s',inputs);      
        case {'constant','c'}
            
            if numel(inputs) == 1
                input = inputs{1};
                cmavg = false;
            elseif numel(inputs) == 2
                input = inputs{1};
                cmavg = true;
            else
                error([mfilename ':: When the the shift identifier is ''constant'' it must be given as {''constant'',input} or {''constant'',input,''cmavg''}, where input is a double.'])
            end
            
            if ~isnumeric(input) || ~isscalar(input)
                error([mfilename ':: When the the shift identifier is constant it must be given as {''constant'',input}, where input is a double.'])
            end
            if cmavg
                gapTemp              = level(indS:indE,:,:) - input;
                gapTemp              = nb_mavg(gapTemp,1,1);
                shift(indS:indE,:,:) = level(indS:indE,:,:) - gapTemp;
            else
                shift(indS:indE,:,:) = input; 
            end
            
        case 'end'
            
            if indS == 1
                errror([mfilename ':: When the the shift identifier is ''end'' it cannot be used for the first subperiod.'])
            end
            periods              = indE - indS + 1;
            constant             = shift(indS-1,:,:);
            shift(indS:indE,:,:) = constant(ones(1,periods),:,:);
            
        case 'endgrowth'
            
            if indS == 1
                errror([mfilename ':: When the the shift identifier is ''endGrowth'' it cannot be used for the first subperiod.'])
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
                error([mfilename ':: When the the shift identifier is ''FGTS'' it must be given as {''FGTS'',expression}, where expression is a one line char array.'])
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
                errror([mfilename ':: When the the shift identifier is ''int'' it must be given as {''int'',start,finish}, where start and finish are doubles.'])
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
            error([mfilename ':: Unsupported shift expression ' expression])
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
                errror(['When the the shift identifier is ''avg'' it must be given as {''avg'',''wfcst'',''whist'',''cmavg''}, '...
                    'where the three last inputs are optional.'])
        end
    end

    if numel(inputs) > 3 
        errror(['When the the shift identifier is ''avg'' it must be given as {''avg'',''wfcst'',''whist'',''cmavg''}, '...
                    'where the three last inputs are optional.'])
    end
    level = level(indSC:indEC,:,:);
    mData = nanmean(level,1);
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
                errror(['When the the shift identifier is ''' filter ''' it must be given as {''' filter ''',weight,...}, '...
                        'where weight must be given. For more see the documentation.'])
            end
            maxInputs = 4;
            startOpt  = 2;
            errorExpr = ['{''' filter ''',weight,...}'];
        
        case {'hpfilter','hpfilter1s'}
            
            try
                lambda = inputs{1};
            catch %#ok<CTCH>
                errror(['When the the shift identifier is ''' filter ''' it must be given as {''' filter ''',lambda,...}, '...
                        'where lambda must be given. For more see the documentation.'])
            end
            maxInputs = 4;
            startOpt  = 2;
            errorExpr = ['{''' filter ''',lambda,...}'];
            
        case {'bkfilter','bkfilter1s'}
            
            try
                lowestFreq = inputs{1};
            catch %#ok<CTCH>
                errror(['When the the shift identifier is ''' filter ''' it must be given as {''' filter ''',lowestFreq,highestFreq,...}, '...
                        'where lowestFreq and highestFreq must be given. For more see the documentation.'])
            end
            try
                highestFreq = inputs{2};
            catch %#ok<CTCH>
                errror(['When the the shift identifier is ''' filter ''' it must be given as {''' filter ''',lowestFreq,highestFreq,...}, '...
                        'where lowestFreq and highestFreq must be given. For more see the documentation.'])
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
                errror(['When the the shift identifier is ''' filter ''' it must be given as {''' filter ''',backward,forward,...}, '...
                        'where backward and forward must be given. For more see the documentation.'])
            end
            try
                forward = inputs{2};
            catch %#ok<CTCH>
                errror(['When the the shift identifier is ''' filter ''' it must be given as {''' filter ''',backward,forward,...}, '...
                        'where backward and forward must be given. For more see the documentation.'])
            end
            maxInputs = 5;
            startOpt  = 3;
            errorExpr = ['{''' filter ''',backward,forward,...}'];
            
    end
    
    % Interpret optional inputs to the filters
    options = {0,indE,indS,false};
    options = interpretFilterOptions(options,inputs,startOpt,filter);
    options = interpretFilterOptions(options,inputs,startOpt+1,filter);
    options = interpretFilterOptions(options,inputs,startOpt+2,filter);
    fcst    = options{1};
    indEC   = options{2};
    indSC   = options{3};
    func    = options{4};
    if numel(inputs) > maxInputs 
        errror(['When the the shift identifier is ''' filter ''' it must be given as ' errorExpr '. For more see the documentation.'])
    end
    if and(fcst > 0, indE ~= indEC) 
        error(['The optional inputs to the ''' filter ''' command cannot include ''wfcst'' and ''ar'', ''argrowth'', ''randomWalk'' or ''randomWalkGrowth'' at the same time.'])
    end
    
    % Do forecasting if wanted
    if fcst > 0
        [level,indEC] = extrapolate(fcst,level,indS,indE);
    end
    
    % These function handle nan values!
    data = level(indSC:indEC,:,:);
    if all(isnan(data))
        error([mfilename ':: The series only consists of NaN values.'])
    end
    switch lower(filter)
        case 'exponentialsmoother'
            gap = data - lag(exptrend(data,weight));
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
            nb_error(['The function handle given to the shift identifier ''' filter ''' failed with error:'],Err);
        end
    elseif func % cmavg option is used.
        gap = nb_mavg(gap,1,1);
    end
    
    shift(indS:indE,:,:) = level(indS:indE,:,:) - gap(indS:indE,:,:);
    
end

%==========================================================================
function options = interpretFilterOptions(options,inputs,startOpt,filter)

    if numel(inputs) > startOpt - 1
        if strcmpi(inputs{startOpt},'wfcst')
            options{2} = size(level,1);
        elseif strcmpi(inputs{startOpt},'whist')
            options{3} = 1;
        elseif strcmpi(inputs{startOpt},'randomwalk')
            checkInput(options);
            options{1} = 1;
        elseif strcmpi(inputs{startOpt},'randomwalkgrowth')
            checkInput(options);
            options{1} = 2;
        elseif strcmpi(inputs{startOpt},'ar')
            checkInput(options);
            options{1} = 3;   
        elseif strcmpi(inputs{startOpt},'argrowth')
            checkInput(options);
            options{1} = 4;      
        elseif strcmpi(inputs{startOpt},'cmavg')
            options{4} = true; 
        elseif isa(inputs{startOpt},'function_handle') 
            options{4} = inputs{startOpt};
        else
            errror(['When the the shift identifier is ''' filter ''' the optional inputs are ''wfcst'', '...
                    '''whist'', ''ar'', ''argrowth'', ''randomWalk'', ''randomWalkGrowth'' and ''cmavg''.'])
        end
    end

end

%==========================================================================
function checkInput(options)

    if options{1} ~= 0
        error(['The optional inputs to the ''' filter ''' command cannot include ''randomWalk'' and ''randomWalkGrowth'' at the same time.'])
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
        error('The method jump2trend needs two observations before the date given to calculate the trends growth rate')
    elseif startInd == endInd
        error('You are trying to set the trend outside the horizon of your data. Which is not possible.')
    end

    try
        trendGrowth = inputs{1}; % jump to this growth rate
    catch %#ok<CTCH>
        error('Wrong number of inputs are given to the jump2trend method.')
    end
    
    if strcmpi(trendGrowth,'avg')
        trendGrowth = nanmean(growth(level(1:indS-1,:,:),1),1);
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
        error('The method ''merge2trend'' needs two observations before the date given to calculate the growth rate of the trend')
    elseif indS == indE
        error('You ar trying to set the trend outside the horizon of your data. Which is not possible.')
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
                error('The arCoeff (input 3) input must be given to the ''merge2trend'' method.')
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
            error(['The first input to M2T could not be evaluated. The expression is: ' type])
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
