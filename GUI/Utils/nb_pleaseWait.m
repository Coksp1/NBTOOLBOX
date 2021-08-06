classdef nb_pleaseWait < handle
% Description:
%
% A class for making please wait window that can be used when running 
% heavy processes in a GUI.
%
% Superclasses:
%
% handle
%
% Constructor:
%
%   obj = nb_pleaseWait(type)
% 
%   Input:
%
%   - type : Give the type of painting to include in the window.
% 
%   Output:
% 
%   - obj : An object of class nb_pleaseWait.
% 
% See also: 
% nb_waitbar, nb_waitbar5
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    properties (SetAccess=protected)
        
        % Give the type of painting to include in the window.
        type            = 'spreadsheet';
        
    end
    
    properties (Access=protected)
       
        % Handle to the axes object.
        axesHandle      = [];
        
        % Handle to the figure object.
        figureHandle    = [];
        
        % The current iteration
        iteration       = 1;
        
        % Handles to the plot objects
        plotHandles     = [];
        
        % Indication on GUI beeing started up
        starting        = true;
        
        % Handle to the text displayed
        textHandle      = [];
        
        % Handle to the timer object
        timerHandle     = [];
        
        % Function handle on how to update the graphics.
        typeUpdate      = [];
        
    end
    
    methods
        
        function obj = nb_pleaseWait(type)
            if nargin > 0
                obj.type = type;
            end
            initialize(obj);
        end
        
        function close(obj)
        % Syntax:
        %
        % close(obj)
        %
        % Description:
        %
        % Close window represented by this object. Same as delete.
        % 
        % Input:
        % 
        % - obj : An object of class nb_pleaseWait.
        % 
        % Written by Kenneth Sæterhagen Paulsen
            delete(obj);
        end
        
        function delete(obj)
        % Syntax:
        %
        % delete(obj)
        %
        % Description:
        %
        % Close window represented by this object. Same as close.
        % 
        % Input:
        % 
        % - obj : An object of class nb_pleaseWait.
        % 
        % Written by Kenneth Sæterhagen Paulsen
            stop(obj.timerHandle);
            delete(obj.figureHandle);
        end
        
    end
    
    methods (Access=protected)
        
        function initialize(obj)
           
            switch lower(obj.type)
                case 'estimate'
                    obj.typeUpdate = @obj.estimateUpdate;
                case 'spreadsheet'
                    obj.typeUpdate = @obj.spreadsheetUpdate;
                otherwise
                    error([mfilename ':: Unssuported type ' obj.type])
            end
            
            % Create the graphical handles used by all "types"
            [obj.figureHandle,bgc] = nb_guiFigure([],'',[40 30 80 16],'modal','off',@obj.closeWindow);
            obj.axesHandle         = axes('parent',obj.figureHandle,'color',bgc,'xLim',[0,1],'yLim',[0,1],...
                                          'position',[0,0,1,1]);                         
            axis(obj.axesHandle,'off');
            obj.textHandle = text(0.5,0.3,'Please wait','HorizontalAlignment','center','verticalAlignment','middle'); 
            
            % Create timer object
            obj.timerHandle = timer('executionMode','fixedRate',...
                                    'period',       1,...
                                    'timerFcn',     @obj.update);
            start(obj.timerHandle);
            set(obj.figureHandle,'visible','on');
            
        end
        
        function update(obj,~,~)
           
%             if obj.starting
%                 if obj.iteration == 2 % Wait 2 second to initialize...
%                     set(obj.figureHandle,'visible','on');
%                     obj.iteration = 1;
%                     obj.starting  = false;
%                 else
%                     obj.iteration = obj.iteration + 1;
%                     return
%                 end
%             end
            
            % Update test handle
            if obj.iteration == 4
                string = 'Please wait';
            else
                string = get(obj.textHandle,'string');
                string = [string,'.'];
            end
            set(obj.textHandle,'string',string);
            obj.typeUpdate();
            
        end
        
        function spreadsheetUpdate(obj)
           
            if obj.iteration > 4
                obj.iteration = 1;    
            end
            
            x1 = [0.35, 0.2, 0.2, 0.35, 0.35, 0.5, 0.5, 0.35];
            y1 = [0.6,  0.6, 0.8, 0.8,  0.6,  0.6, 0.8, 0.8];
            x2 = [0.2,0.5];
            y2 = [0.7,0.7];
            x3 = [0.2,0.5];
            y3 = [0.75,0.75];
            x4 = [0.2,0.5];
            y4 = [0.65,0.65];
            x5 = [0.275,0.275];
            y5 = [0.6,0.8];
            x6 = [0.425,0.425];
            y6 = [0.6,0.8];
            switch obj.iteration
                case 1
                    delete(obj.plotHandles);
                case 2
                    x1 = x1 + 0.3;
                    x2 = x2 + 0.3;
                    x3 = x3 + 0.3;
                    x4 = x4 + 0.3;
                    x5 = x5 + 0.3;
                    x6 = x6 + 0.3;
                case 3
                    y1 = y1 - 0.2;
                    y2 = y2 - 0.2;
                    y3 = y3 - 0.2;
                    y4 = y4 - 0.2;
                    y5 = y5 - 0.2;
                    y6 = y6 - 0.2;
                case 4
                    x1 = x1 + 0.3;
                    x2 = x2 + 0.3;
                    x3 = x3 + 0.3;
                    x4 = x4 + 0.3;
                    x5 = x5 + 0.3;
                    x6 = x6 + 0.3;
                    y1 = y1 - 0.2;
                    y2 = y2 - 0.2;
                    y3 = y3 - 0.2;
                    y4 = y4 - 0.2;
                    y5 = y5 - 0.2;
                    y6 = y6 - 0.2;
            end
            lHandle1        = line(x1,y1,'parent',obj.axesHandle);
            lHandle2        = line(x2,y2,'parent',obj.axesHandle);
            lHandle3        = line(x3,y3,'parent',obj.axesHandle);
            lHandle4        = line(x4,y4,'parent',obj.axesHandle);
            lHandle5        = line(x5,y5,'parent',obj.axesHandle);
            lHandle6        = line(x6,y6,'parent',obj.axesHandle);
            obj.plotHandles = [obj.plotHandles,lHandle1,lHandle2,lHandle3,lHandle4,lHandle5,lHandle6];
            obj.iteration   = obj.iteration + 1;
            
        end
        
        function estimateUpdate(obj)
            
            if obj.iteration > 4
                obj.iteration = 1;    
            end
            
            switch obj.iteration
                case 1
                    delete(obj.plotHandles);
                    x               = [0.2,0.8,0.8,0.2,0.2];
                    y               = [0.4,0.4,0.8,0.8,0.4];
                    lHandle         = line(x,y,'parent',obj.axesHandle);
                    obj.plotHandles = [obj.plotHandles,lHandle];
                case 2
                    x               = 0.2 + rand(10,1)*0.6;
                    y               = 0.4 + rand(10,1)*0.4;
                    lHandle         = line(obj.axesHandle,x,y,'lineStyle','none','marker','x','color',[205 140 65]/255);
                    obj.plotHandles = [obj.plotHandles,lHandle];
                case 3
                    x               = [0.22,0.78];
                    y               = [0.57,0.63];
                    lHandle         = line(x,y,'parent',obj.axesHandle,'lineStyle',':','color',[34 89 120]/255);
                    obj.plotHandles = [obj.plotHandles,lHandle];
                case 4
                    lHandle         = text(0.3,0.7,'\beta = 0.1','interpreter','tex','parent',obj.axesHandle);
                    obj.plotHandles = [obj.plotHandles,lHandle];
            end 
            obj.iteration = obj.iteration + 1;            
            
        end
        
        function closeWindow(obj,~,~)
            % This is to prevent user being able to close the window!
            delete(obj);
        end
        
    end
    
    methods (Static=true)
       
        
        
    end
    
end

