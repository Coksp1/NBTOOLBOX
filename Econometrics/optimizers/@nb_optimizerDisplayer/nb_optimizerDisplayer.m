classdef nb_optimizerDisplayer < handle
% Description:
%
% A class you can use to display the progress during optimization, i.e. 
% you can pass the method handle
%
% @(x,optVal,state)obj.update(x,optVal,state)
%
% to the OutputFcn option to the optimizer you use. Here obj must be an
% object of class nb_optimizerDisplayer.
%
% Superclasses:
%
% handle
%
% Constructor:
%
%   obj = nb_optimizerDisplayer(varargin)
% 
%   Input:
%
%   - See the set method.
% 
%   Output:
% 
%   - obj : An object of class nb_optimizerDisplayer.
% 
% See also: 
% fmincon, fminunc, fminsearch, nb_fmin
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    properties (Dependent=true)
        
        % Give the names of each element in x. Must be set to a cellstr.
        % If generic names will be assign, i.e. {'x1','x2',...}.
        %
        % See also formatDone or formatIter on how to use the names in
        % print out.
        %
        % Caution: Must either be empty or has the same length as the
        %          number of values in x.
        names                   = {};
        
    end

    properties
        
        % Format of printed output when the optimaizer has converged. The 
        % first input is the function value and the second input is step 
        % length measured as the norm of the change in the x-values. Then
        % the x-values will be given as the next inputs, i.e. each element
        % of x will be pasted as a separate input in the order they
        % are in the vector x. At last each element of the names property
        % will be pasted as a separate input.
        %
        % E.g: 
        % 'Optimal value found: f(x): %1$20.6f   x: %3$20.6f\n' (Scalar)
        % 'Optimal value found: %5$s: %3$20.6f %6$s: %4$20.6f\n' (Two)
        % 'Optimal value found: f(x): %1$20.6f\n' (Multivariate)
        %
        % If empty default print out is used.
        %
        % Caution: Give a multi-lined char to print it one more lines.
        formatDone              = '';
        
        % Format of printed output for each stored iteration of the  
        % optimization. The first input is  the iteration count, the second  
        % input is the function value and the third input is step length
        % measured as the norm of the change in the x-values. Then the
        % x-values will be given as the next inputs, i.e. each element
        % of x will be pasted as a separate input in the order they
        % are in the vector x. At last each element of the names property
        % will be pasted as a separate input.
        %
        % E.g: 
        % 'Iter: %1$13d  f(x): %2$20.6f   x: %4$20.6f\n' (Scalar)
        % 'Iter: %1$13d  f(x): %6$s: %4$20.6f %7$s: %5$20.6f\n' (Two)
        % 'Iter: %1$13d  f(x): %2$20.6f\n' (Multivariate)
        %
        % If empty default print out is used.
        %
        % Caution: Give a multi-lined char to print it one more lines.
        formatIter              = '';
        
        % Set to true to include a stop button in the figure when the 
        % type property is set to 'text'.
        includeStop             = false;
        
        % Set to true to include a time left in the figure when the 
        % type property is set to 'text'.
        includeTime             = false;
        
        % This property sets the number of steps between the notification
        % of the optimizer current value.
        notifyStep              = 1;
        
        % Maximum number of iterations to store. Default is to store all.
        % Minimum is 2.
        storeMax                = inf;
        
        % Set the type of reporting;
        % > 'text'      : The reporting displayed as text in a window.
        % > 'command'   : The reporting displayed as text in the command
        %                 window
        % > 'graph'     : The reporting displayed as a graph in a window.
        % > 'textgraph' : The reporting displayed as text and a graph in a
        %                 window.
        type                    = 'command';
        
        % The used norm for calculating the step length. Default is the
        % 2-norm.
        usedNorm                = 2;
        
    end

    properties (SetAccess=protected)
        
        % The handle to the axes object where the iterations values are
        % plotted. 
        axesHandle              = [];
        
        % The handle to the figure where the optimization iterations are
        % displayed. 
        figureHandle            = [];
        
        % Storing the function values at each iteration. See the iteration
        % property for which iteration that has been stored.
        fval                    = [];
        
        % The handle to the line object with the plotted iterations. 
        plotHandle              = [];
        
        % The size of the problem to solve.
        problemSize             = [];
        
        % Stores the step length between each stored iteration. See the
        % usedNorm property for more on how it is measured. 
        stepLength              = [];
        
        % Will be set to true if the stop button of the display is
        % pushed.
        stopped                 = false;
        
        % The handle to the uicontrol object where the optimization 
        % iterations are displayed. 
        textBoxHandle           = [];
        
        % Storing the iteration count of the stored values of x and fval
        % properties.
        iteration               = [];
        
        % Storing the x-values at each iteration. See the iteration
        % property for which iteration that has been stored.
        x                       = [];
          
    end
    
    properties (Access=protected)
       
        % A function handle storing the method called when reporting
        % an error in the notifyError method.
        errorFunction           = [];
        
        % A function handle storing the method called when the optimizer
        % has converged.
        doneFunction            = [];
        
        % Property that stores info about the names property being set.
        namesInternal           = {};
        
        % A function handle storing the method called when the optimizer
        % has finished a iteration (May skip some iteration due to the
        % notifyStep property not being 1).
        updateFunction          = [];
        
        % Handle to the uicontrol object that displayes the time spent.
        timeControl             = [];
        
        % A timer object used to display time spent when includeTime is set
        % to true.
        timer                   = [];
        
    end
    
    methods
        
        function obj = nb_optimizerDisplayer(varargin)
            
            set(obj,varargin{:});
             
        end
        
        function set.formatDone(obj,propertyValue)
       
            if ~ischar(propertyValue)
                error([mfilename ':: The formatDone property must be assign a char.'])
            end
            obj.formatDone = propertyValue;
            
        end
        
        function set.formatIter(obj,propertyValue)
       
            if ~ischar(propertyValue)
                error([mfilename ':: The formatIter property must be assign a char.'])
            end
            obj.formatIter = propertyValue;
            
        end
        
        function set.includeStop(obj,propertyValue)
       
            if ~nb_isScalarLogical(propertyValue)
                error([mfilename ':: The includeStop property must be assign a scalar logical.'])
            end
            obj.includeStop = propertyValue;
            
        end
        
        function set.includeTime(obj,propertyValue)
       
            if ~nb_isScalarLogical(propertyValue)
                error([mfilename ':: The includeTime property must be assign a scalar logical.'])
            end
            obj.includeTime = propertyValue;
            
        end
        
        function propertyValue = get.names(obj)
       
            if isempty(obj.namesInternal)
                nams          = 1:obj.problemSize;
                nams          = strtrim(cellstr(int2str(nams')));
                propertyValue = strcat('x',nams);
            else
                propertyValue = obj.namesInternal;
                if ~isempty(obj.problemSize)
                    if obj.problemSize ~= length(propertyValue)
                        error([mfilename ':: The names property must have length ' int2str(obj.problemSize) ', but has length ' int2str(length(obj.namesInternal)) '.'])
                    end
                end
            end
           
        end
        
        function set.names(obj,propertyValue)
       
            if ~iscellstr(propertyValue)
                error([mfilename ':: The names property must be assign a cellstr.'])
            end
            obj.namesInternal = propertyValue;
            
        end
        
        function set.notifyStep(obj,propertyValue)
       
            if ~nb_isScalarInteger(propertyValue)
                error([mfilename ':: The notifyStep property must be assign a scalar integer greater than 0.'])
            end
            if propertyValue < 1
                error([mfilename ':: The notifyStep property must be assign a scalar integer greater than 0.'])
            end
            obj.notifyStep = propertyValue;
            
        end
        
        function set.storeMax(obj,propertyValue)
       
            if ~nb_isScalarInteger(propertyValue)
                error([mfilename ':: The storeMax property must be assign a scalar integer greater than 1.'])
            end
            if propertyValue < 2
                error([mfilename ':: The storeMax property must be assign a scalar integer greater than 1.'])
            end
            obj.storeMax = propertyValue;
            
        end
        
        function set.type(obj,propertyValue)
       
            if ~ischar(propertyValue)
                error([mfilename ':: The type property must be assign a char.'])
            end
            if ~ismember(lower(propertyValue),{'text','command','graph','textgraph'})
                error([mfilename ':: Unsupported type ' propertyValue])
            end
            obj.type = propertyValue;
            
        end
        
        function set.usedNorm(obj,propertyValue)
       
            if ~nb_isScalarInteger(propertyValue)
                error([mfilename ':: The usedNorm property must be assign a scalar integer greater than 0.'])
            end
            if propertyValue < 1
                error([mfilename ':: The usedNorm property must be assign a scalar integer greater than 0.'])
            end
            obj.usedNorm = propertyValue;
            
        end
        
        function set(obj,varargin)
        % Syntax:
        %
        % set(obj,varargin)
        %
        % Description:
        %
        % Set properties of the object using 'propertyName', propertyValue
        % pairs.
        % 
        % Written by Kenneth Sæterhagen Paulsen
            
            if size(varargin,1) && iscell(varargin{1})
                varargin = varargin{1};
            end
            
            if rem(length(varargin),2) ~= 0
                error([mfilename ':: The ''propertyName'', propertyValue inputs must come in pairs.'])
            end
            
            for jj = 1:2:size(varargin,2)

                if ischar(varargin{jj})

                    propertyName  = lower(varargin{jj});
                    propertyValue = varargin{jj + 1};
                    switch propertyName
                        case 'formatdone'
                            obj.formatDone = propertyValue;
                        case 'formatiter'
                            obj.formatIter = propertyValue;
                        case 'includestop'
                            obj.includeStop = propertyValue;
                        case 'includetime'
                            obj.includeTime = propertyValue;    
                        case 'names'
                            obj.namesInternal = propertyValue;
                        case 'notifystep'
                            obj.notifyStep = propertyValue;
                        case 'storemax'
                            obj.storeMax = propertyValue;
                        case 'type'
                            obj.type = propertyValue;
                        case 'usednorm'
                            obj.usedNorm = propertyValue;
                        otherwise
                            error([mfilename ':: Bad property name; ' propertyName])
                    end

                end

            end
        
        end
        
        function stop = update(obj,x,optVal,state,varargin)
        % Syntax:
        %
        % stop = update(obj,x,optVal,state,varargin)
        %
        % Description:
        %
        % The method you need to pass to the OutputFcn as a function handle
        % on the form @(x,optVal,state)obj.update(x,optVal,state).
        % 
        % Input:
        % 
        % - obj    : An object of class nb_optimizerDisplayer
        %
        % - x      : The point computed by the algorithm at the current 
        %            iteration 
        %  
        % - optVal : Structure containing data from the current iteration.
        %
        % - state  : The current state of the algorithm ('init', 
        %            'interrupt', 'iter', or 'done')
        % 
        % Output:
        % 
        % - stop   : Always return false.
        %
        % Written by Kenneth Sæterhagen Paulsen    
        
            stop = false;
            x    = nb_rowVector(x);
            
            switch state
                case 'iter'
                    
                    if optVal.iteration > 1 
                        
                        if rem(optVal.iteration,obj.notifyStep) == 0
                        
                            % Store results
                            store(obj,x,optVal);

                            % Update reporting
                            obj.updateFunction(obj);
                            
                        end
                        
                    elseif optVal.iteration == 1  % Always report first iteration
                        
                        if isempty(obj.updateFunction)
                            initialize(obj,x);
                        end
                        
                        % Store results
                        store(obj,x,optVal);
                        
                        % Update reporting
                        obj.updateFunction(obj);
                        
                    elseif optVal.iteration == 0
                        initialize(obj,x);
                    end
                    
                case 'done'
                    
                    if rem(optVal.iteration,obj.notifyStep) ~= 0
                        % Store results
                        store(obj,x,optVal);
                        
                        % Update reporting
                        obj.updateFunction(obj);
                    end
                    obj.doneFunction(obj,x,optVal);
                   
                case 'init'
                    
                    initialize(obj,x);
                    
                otherwise
            end
            
        end
        
        function notifyError(obj,err)
        % Syntax:
        %
        % notifyError(obj,err)
        %
        % Description:
        %
        % Call to notify about errors occuring optimization or solving.
        % 
        % Input:
        % 
        % - obj    : An object of class nb_optimizerDisplayer
        %
        % - err    : The error message to display.
        % 
        % Written by Kenneth Sæterhagen Paulsen    
        
            obj.errorFunction(obj,err)
            
        end
        
        function s = saveobj(obj)           
            s = struct(obj); 
        end
        function s = struct(obj) 
            s = struct('class',         'nb_optimizerDisplayer',...
                       'formatDone',    obj.formatDone,...
                       'formatIter',    obj.formatIter,...
                       'includeStop',   obj.includeStop,...
                       'includeTime',   obj.includeTime,...
                       'namesInternal', {obj.namesInternal},...
                       'notifyStep',    obj.notifyStep,...
                       'storeMax',      obj.storeMax,...
                       'type',          obj.type,...
                       'usedNorm',      obj.usedNorm,...
                       'fval',          obj.fval,...
                       'stepLength',    obj.stepLength,...
                       'iteration',     obj.iteration,...
                       'x',             obj.x); 
        end
        
        
        
    end
    
    methods (Static=true)
        
        function obj = loadobj(s)
            obj = nb_optimizerDisplayer.unstruct(s);
        end
        function obj = unstruct(s)
            obj   = nb_optimizerDisplayer;
            s     = rmfield(s,'class');
            props = fieldnames(s);
            for ii = 1:length(props)
                obj.(props{ii}) = s.(props{ii});
            end
        end
        
    end
    
    methods(Access=protected)
        
        function initialize(obj,x)
            
            obj.problemSize = length(x);
            if isempty(obj.formatDone)
                if isscalar(x)
                    obj.formatDone = 'Optimal value found: f(x): %1$20.6f   x: %3$20.6f';
                else
                    maxL    = max(max(cellfun(@(x)size(x,2),obj.names)),4);
                    maxS    = int2str(maxL);
                    extra   = '';
                    if maxL > 4
                        extra = ' ';
                        extra = extra(:,ones(1,maxL-4));
                    end
                    formatD = ['Optimal values found:\nf(x)' extra ': %1$20.6f'];
                    numX    = length(x);
                    if numX < 10
                        for ii = 1:numX
                            formatD = char(formatD,['%' int2str(2 + numX + ii) '$-' maxS 's: %' int2str(2 + ii) '$20.6f']);
                        end
                    end
                    obj.formatDone = formatD;
                end
                obj.formatDone = strcat(obj.formatDone,'\n');
                if size(obj.formatDone,1) > 1
                    formatD        = strtrim(cellstr(obj.formatDone)');
                    obj.formatDone = [formatD{:}];
                end
            end
            
            if isempty(obj.formatIter)
                if isscalar(x)
                    obj.formatIter = 'Iter: %1$13d  f(x): %2$20.6f   x: %4$20.6f';
                else
                    obj.formatIter = 'Iter: %1$13d  f(x): %2$20.6f   x-change: %3$20.6f';
                end
                obj.formatIter = strcat(obj.formatIter,'\n');
                if size(obj.formatIter,1) > 1
                    formatI        = strtrim(cellstr(obj.formatIter)');
                    obj.formatIter = [formatI{:}];
                end
            end
            
            % Create GUI
            switch lower(obj.type)
                case 'text'
                    textCreate(obj);
                case 'command'
                    commandCreate(obj);
                case 'graph'
                    graphCreate(obj);
                case 'textgraph'
                    textGraphCreate(obj);
            end
            
        end
        
        function store(obj,x,optVal)
            
            if length(obj.x) ~= length(x)
                % New problem to solve...
                obj.iteration  = [];
                obj.x          = [];
                obj.fval       = [];
                obj.stepLength = [];
            end
            
            obj.iteration  = [obj.iteration; optVal.iteration];
            obj.x          = [obj.x; x];
            obj.fval       = [obj.fval; optVal.fval];
            if size(obj.x,1) == 1 
                obj.stepLength = 0;
            else
                obj.stepLength = [obj.stepLength; norm(obj.x(end,:)-obj.x(end-1,:),obj.usedNorm)];
            end
            
            if size(obj.x,1) > obj.storeMax
                obj.iteration  = obj.iteration(2:end);
                obj.x          = obj.x(2:end,:);
                obj.fval       = obj.fval(2:end);
                obj.stepLength = obj.stepLength(2:end);
            end
            
        end
    
        function commandCreate(obj)
            
            obj.updateFunction = @(obj)commandUpdate(obj);
            obj.doneFunction   = @(obj,x,optVal)commandDone(obj,x,optVal);
            obj.errorFunction  = @(obj,err)commandError(obj,err);
            
        end
        
        function commandUpdate(obj)
            
            xCell = num2cell(obj.x(end,:));
            fprintf(obj.formatIter,obj.iteration(end),obj.fval(end),obj.stepLength(end),xCell{:},obj.names{:});
            
        end
        
        function commandDone(obj,x,optVal)
            
            if size(obj.x,1) < 2
                stepLen = nan;
            else
                stepLen  = norm(obj.x(end,:)-obj.x(end-1,:),obj.usedNorm);
            end
            xCell = num2cell(x);
            disp(' ');
            fprintf(obj.formatDone,optVal.fval,stepLen,xCell{:},obj.names{:});
            disp(' ');
            
        end
        
        function commandError(~,err)
            
            disp(' ');
            fprintf(err);
            disp(' ');
                    
        end
        
        function graphCreate(obj)
            
            obj.figureHandle = nb_guiFigure([],'Optimization',[50, 40, 120, 20],'normal','on');
            obj.axesHandle   = nb_axes('parent',obj.figureHandle,'position',[0.1,0.1,0.8,0.8]);
            obj.plotHandle   = nb_line(1,nan,...
                'parent',   obj.axesHandle,...
                'cData',   'blue');
            set(obj.figureHandle,'visible','on');
            
            obj.updateFunction = @(obj)graphUpdate(obj);
            obj.doneFunction   = @(obj,x,optVal)graphDone(obj,x,optVal);
            obj.errorFunction  = @(obj,err)commandError(obj,err);
            
        end
        
        function graphUpdate(obj)
            
            if size(obj.x,2) == 1
                set(obj.plotHandle,'xData',obj.x,'yData',obj.fval);
            else
                set(obj.plotHandle,'xData',obj.iteration,'yData',obj.fval);
            end
            
        end
        
        function graphDone(obj,x,optVal)
            
            if size(obj.x,2) == 1
                nb_line(x,optVal.fval,'cData','blue','lineStyle','none','marker','x','parent',obj.axesHandle);
            end
            
        end
        
        function textCreate(obj)
            
            if obj.includeStop
                yStart = 0.12;
                yHight = 0.84;
            else
                yStart = 0.04;
                yHight = 0.92;
            end
            
            obj.figureHandle = nb_guiFigure([],'Optimization',[50, 40, 120, 20],'normal','on');
            obj.textBoxHandle = nb_scrollbox(nb_constant.LISTBOX,...
                'fontName', 'fixedWidth',...
                'max',      100,...
                'parent',   obj.figureHandle,...
                'position', [0.04,yStart,0.92,yHight]);
            
            if obj.includeStop
                buttonYSize = 0.05; 
                buttonXSize = 0.15; 
                uicontrol(nb_constant.BUTTON,...
                          'callback',   @obj.stopCallback,...
                          'position',   [0.5 - buttonXSize/2, yStart/2 - buttonYSize/2, buttonXSize, buttonYSize],...
                          'string',     'Stop',...
                          'parent',     obj.figureHandle);
            end
            if obj.includeTime
                obj.timer       = tic();
                buttonYSize     = 0.05; 
                buttonXSize     = 0.15; 
                obj.timeControl = uicontrol(nb_constant.LABEL,...
                    'position',   [0.75 - buttonXSize/2, yStart/2 - buttonYSize/2, buttonXSize, buttonYSize],...
                    'string',     ['Time spent: ' getTime(obj)],...
                    'parent',     obj.figureHandle);
            end
            set(obj.figureHandle,'visible','on');
            
            obj.updateFunction  = @(obj)textUpdate(obj);
            obj.doneFunction    = @(obj,x,optVal)textDone(obj,x,optVal);
            obj.errorFunction   = @(obj,err)textError(obj,err);
            
        end
        
        function stopCallback(obj,~,~) 
            obj.stopped = true;
        end
        
        function textUpdate(obj)
            
            xCell    = num2cell(obj.x(end,:));
            progress = sprintf(obj.formatIter,obj.iteration(end),obj.fval(end),obj.stepLength(end),xCell{:},obj.names{:});
            progress = strtrim(strsplit(progress,'\n'));
            progress = char(progress(1:end-1)');
            string   = get(obj.textBoxHandle,'string');
            string   = char(progress,string);
            set(obj.textBoxHandle,'string',string);
            if obj.includeTime
                set(obj.timeControl,'String',['Time spent: ' getTime(obj)]);
            end
            drawnow;
            
        end
        
        function textDone(obj,x,optVal)
            
            if size(obj.x,1) > 1
                stepLen = norm(obj.x(end,:)-obj.x(end-1,:),obj.usedNorm);
            else
                stepLen = 0; 
            end
            if numel(optVal.fval) > 1
                % Solvers!
                fValue = max(optVal.fval);
            else
                fValue = optVal.fval;
            end
            
            xCell    = num2cell(x);
            stopText = sprintf(obj.formatDone,fValue,stepLen,xCell{:},obj.names{:});
            stopText = strtrim(strsplit(stopText,'\n'));
            stopText = char(stopText(1:end-1)');
            stopText = char(stopText,'');
            string   = get(obj.textBoxHandle,'string');
            string   = char(stopText,string);
            set(obj.textBoxHandle,'string',string);
                    
        end
        
        function textError(obj,err)
            
            stopText = char(err);
            stopText = char(stopText,'');
            string   = get(obj.textBoxHandle,'string');
            string   = char(stopText,string);
            set(obj.textBoxHandle,'string',string);
                    
        end
        
        function textGraphCreate(obj)
            
            obj.figureHandle = nb_guiFigure([],'Optimization',[50, 40, 120, 40],'normal','on');
            obj.axesHandle   = nb_axes('parent',obj.figureHandle,'position',[0.1,0.05,0.8,0.4]);
            obj.plotHandle   = nb_line(1,nan,...
                'parent',   obj.axesHandle,...
                'cData',   'blue');
            obj.textBoxHandle = nb_scrollbox(nb_constant.LISTBOX,...
                'fontName', 'fixedWidth',...
                'max',      100,...
                'parent',   obj.figureHandle,...
                'position', [0.04,0.54,0.92,0.42]);
            set(obj.figureHandle,'visible','on');
            
            obj.updateFunction = @(obj,x)textGraphUpdate(obj);
            obj.doneFunction   = @(obj,x,optVal)textGraphDone(obj,x,optVal);
            obj.errorFunction  = @(obj,err)textError(obj,err);
            
        end
        
        function textGraphUpdate(obj)
            
            textUpdate(obj);
            graphUpdate(obj);
            
        end
        
        function textGraphDone(obj,x,optVal)
            
            textDone(obj,x,optVal);
            graphDone(obj,x,optVal);
                    
        end
        
        function c = getTime(obj)
            durat = duration([0, 0, toc(obj.timer)]);
            if hours(durat) > 1
                durat.Format = 'hh:mm';
            else
                durat.Format = 'mm:ss';
            end
            c = char(durat);
        end
        
    end
    
end
