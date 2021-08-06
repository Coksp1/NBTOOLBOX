classdef nb_waitbar5 < handle
% Description:
%
% A class for creating a window with two waiting bars
%
% Constructor:
%
%   gui = nb_waitbar5(parent,name,includeCancel,includePause)
% 
%   Input:
%
%   - parent        : An object of class nb_GUI.
%
%   - name          : A string with the name of the figure.
%
%   - includeCancel : 1 to include cancel button.
%
%   - includePause  : 1 to include pause button.
% 
%   Output:
% 
%   - gui           : A nb_waitbar5 object
% 
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    properties(SetAccess=protected)
         
        % Identify if cancel button have been pushed
        canceling       = 0;
        
        % Handle to the MATLAB figure
        figureHandle    = [];
        
        % Include cancel button
        includeCancel   = false;
        
        % Include pause button
        includePause    = false;
        
        % Name of figure, as a string.
        name            = '';
        
        % A nb_GUI object or empty
        parent          = []; 
        
        % Identify if cancel button have been pushed
        paused          = 0;
        
        % Set the visibility of the waitbar. 'on' or 'off'.
        visible         = 'on';
        
    end
        
    properties
        
        % Lock at a number of waiting bars
        lock            = [];
        
        % How often to update the status1 bar. Defualt is always, i.e. 1.
        note1           = 1;
        
        % How often to update the status2 bar. Defualt is always, i.e. 1.
        note2           = 1;
        
        % How often to update the status3 bar. Defualt is always, i.e. 1.
        note3           = 1;
        
        % How often to update the status4 bar. Defualt is always, i.e. 1.
        note4           = 1;
        
        % How often to update the status5 bar. Defualt is always, i.e. 1.
        note5           = 1;
        
        % Number of iteration max
        maxIterations1  = [];
        
        % Number of iteration max (second bar)
        maxIterations2  = [];
        
        % Number of iteration max (third bar)
        maxIterations3  = [];
        
        % Number of iteration max (fourth bar)
        maxIterations4  = [];
        
        % Number of iteration max (fifth bar)
        maxIterations5  = [];
        
        % Status of iteration
        status1         = 0;
        
        % Second status of iteration
        status2         = 0;
        
        % Third status of iteration
        status3         = 0;
        
        % Fourth status of iteration
        status4         = 0;
        
        % Fourth status of iteration
        status5         = 0;
        
        % Set the text of the window
        text1           = '';
        
        % Set the second text of the window
        text2           = '';
        
        % Set the third text of the window
        text3           = '';
        
        % Set the fourth text of the window
        text4           = '';
        
        % Set the fourth text of the window
        text5           = '';
        
    end
    
    properties(Access=protected)
       
        % Handle to the axes with the bar
        ax              = [];
        
        % Handle to the the text box
        textBox         = [];
        
        % Handle to the patch object
        patchHandle     = [];
        
        % Handle to the cancel button
        cancelButton    = [];
        
        % Handle to the cancel button
        pauseButton     = [];
        
    end
   
    methods
        
        function gui = nb_waitbar5(parent,name,includeCancel,includePause,visible)
        % Constructor
        
            if nargin < 5
                visible = 'on';
                if nargin < 4
                    includePause = false;
                    if nargin < 3
                        includeCancel = false;
                    end
                end
            end
            
            gui.parent        = parent;
            gui.name          = name;
            gui.includeCancel = includeCancel;
            gui.includePause  = includePause;
            gui.visible       = visible;
            makeGUI(gui);
            drawnow;
            
        end
        
        function set.status1(gui,value)
        % Update the waiting bar with the given value    
            
            if value > gui.maxIterations1 %#ok<MCSUP>
                value = gui.maxIterations1; %#ok<MCSUP>
            elseif value < 0
                value = 0;
            end
            gui.status1 = value;
            if rem(gui.status1,gui.note1) == 0 %#ok<MCSUP>
                updateBar(gui,1);
                drawnow;
            end
            
        end
        
        function set.status2(gui,value)
        % Update the waiting bar with the given value    
            
            if value > gui.maxIterations2 %#ok<MCSUP>
                value = gui.maxIterations2; %#ok<MCSUP>
            elseif value < 0
                value = 0;
            end
            gui.status2 = value;
            if rem(gui.status2,gui.note2) == 0 %#ok<MCSUP>
                updateBar(gui,2);
                drawnow;
            end
            
        end
        
        function set.status3(gui,value)
        % Update the waiting bar with the given value    
            
            if value > gui.maxIterations3 %#ok<MCSUP>
                value = gui.maxIterations3; %#ok<MCSUP>
            elseif value < 0
                value = 0;
            end
            gui.status3 = value;
            if rem(gui.status3,gui.note3) == 0 %#ok<MCSUP>
                updateBar(gui,3);
                drawnow;
            end
            
        end
        
        function set.status4(gui,value)
        % Update the waiting bar with the given value    
            
            if value > gui.maxIterations4 %#ok<MCSUP>
                value = gui.maxIterations4; %#ok<MCSUP>
            elseif value < 0
                value = 0;
            end
            gui.status4 = value;
            if rem(gui.status4,gui.note4) == 0 %#ok<MCSUP>
                updateBar(gui,4);
                drawnow;
            end
            
        end
        
        function set.status5(gui,value)
        % Update the waiting bar with the given value    
            
            if value > gui.maxIterations5 %#ok<MCSUP>
                value = gui.maxIterations5; %#ok<MCSUP>
            elseif value < 0
                value = 0;
            end
            gui.status5 = value;
            if rem(gui.status5,gui.note5) == 0 %#ok<MCSUP>
                updateBar(gui,5);
                drawnow;
            end
            
        end
        
        function set.maxIterations1(gui,value)
        % Update the waiting bar with the given value    
            
            if or(isnumeric(value) && numel(value) == 1,isempty(value))
                gui.maxIterations1 = value;
                updateGUI(gui);
                drawnow;
            end
            
        end
        
        function set.maxIterations2(gui,value)
        % Update the waiting bar with the given value    
            
            if or(isnumeric(value) && numel(value) == 1,isempty(value))
                gui.maxIterations2 = value;
                updateGUI(gui);
                drawnow;
            end
            
        end
        
        function set.maxIterations3(gui,value)
        % Update the waiting bar with the given value    
            
            if or(isnumeric(value) && numel(value) == 1,isempty(value))
                gui.maxIterations3 = value;
                updateGUI(gui);
                drawnow;
            end
            
        end
        
        function set.maxIterations4(gui,value)
        % Update the waiting bar with the given value    
            
            if or(isnumeric(value) && numel(value) == 1,isempty(value))
                gui.maxIterations4 = value;
                updateGUI(gui);
                drawnow;
            end
            
        end
        
        function set.maxIterations5(gui,value)
        % Update the waiting bar with the given value    
            
            if or(isnumeric(value) && numel(value) == 1,isempty(value))
                gui.maxIterations5 = value;
                updateGUI(gui);
                drawnow;
            end
            
        end
        
        function set.text1(gui,value)
        % Update the waiting bar with the given value    
            
            if ~ischar(value)
                error([mfilename 'The property must be set to a string'])
            end
            gui.text1 = value;
            updateText(gui,1);
            drawnow;
            
        end
        
        function set.text2(gui,value)
        % Update the waiting bar with the given value    
            
            if ~ischar(value)
                error([mfilename 'The property must be set to a string'])
            end
            gui.text2 = value;
            updateText(gui,2);
            drawnow;
            
        end
        
        function set.text3(gui,value)
        % Update the waiting bar with the given value    
            
            if ~ischar(value)
                error([mfilename 'The property must be set to a string'])
            end
            gui.text3 = value;
            updateText(gui,3);
            drawnow;
            
        end
        
        function set.text4(gui,value)
        % Update the waiting bar with the given value    
            
            if ~ischar(value)
                error([mfilename 'The property must be set to a string'])
            end
            gui.text4 = value;
            updateText(gui,4);
            drawnow;
            
        end
        
        function set.text5(gui,value)
        % Update the waiting bar with the given value    
            
            if ~ischar(value)
                error([mfilename 'The property must be set to a string'])
            end
            gui.text5 = value;
            updateText(gui,5);
            drawnow;
            
        end
        
        function deleteFirst(gui)
            
            if ~isvalid(gui)
                return
            end
            gui.maxIterations1 = [];
            
            maxIter = {gui.maxIterations2,gui.maxIterations3,gui.maxIterations4,gui.maxIterations5};
            ind     = cellfun(@isempty,maxIter);
            if all(ind)
                delete(gui);
            end
            
        end
     
        function deleteSecond(gui)
            
            if ~isvalid(gui)
                return
            end
            gui.maxIterations2 = [];
            
            maxIter = {gui.maxIterations1,gui.maxIterations3,gui.maxIterations4,gui.maxIterations5};
            ind     = cellfun(@isempty,maxIter);
            if all(ind)
                delete(gui);
            end
            
        end
        
        function deleteThird(gui)
            
            if ~isvalid(gui)
                return
            end
            gui.maxIterations3 = [];
            
            maxIter = {gui.maxIterations1,gui.maxIterations2,gui.maxIterations4,gui.maxIterations5};
            ind     = cellfun(@isempty,maxIter);
            if all(ind)
                delete(gui);
            end
            
        end
        
        function deleteFourth(gui)
            
            if ~isvalid(gui)
                return
            end
            gui.maxIterations4 = [];
            
            maxIter = {gui.maxIterations1,gui.maxIterations2,gui.maxIterations3,gui.maxIterations5};
            ind     = cellfun(@isempty,maxIter);
            if all(ind)
                delete(gui);
            end
              
        end
        
        function deleteFifth(gui)
            
            if ~isvalid(gui)
                return
            end
            gui.maxIterations5 = [];
            
            maxIter = {gui.maxIterations1,gui.maxIterations2,gui.maxIterations3,gui.maxIterations4};
            ind     = cellfun(@isempty,maxIter);
            if all(ind)
                delete(gui);
            end
              
        end
        
        function delete(gui)
            
            if ishandle(gui.figureHandle)
                delete(gui.figureHandle);
            end
              
        end
        
        function value = getNextAvailable(obj)
        % Syntax:
        %
        % value = getNextAvailable(obj)
        %
        % Description:
        %
        % Get next available wait bar.
        % 
        % Output:
        % 
        % - value : An integer between 0-5. If 0 it means that non of the
        %           five wait bars are available.
        %
        % Written by Kenneth Sæterhagen Paulsen

        % Copyright (c) 2021, Kenneth Sæterhagen Paulsen    
            
            if isempty(obj.maxIterations1)
                value = 1;
            elseif isempty(obj.maxIterations2)
                value = 2;
            elseif isempty(obj.maxIterations3)
                value = 3;
            elseif isempty(obj.maxIterations4)
                value = 4;
            elseif isempty(obj.maxIterations5)
                value = 5;
            else
                value = 0;
            end
            
        end
        
    end
    
    methods(Access=protected,Hidden=true)
        
        function updateGUI(gui)
            
            if ~gui.canceling && ~gui.paused
                
                maxIter  = {gui.maxIterations1,gui.maxIterations2,gui.maxIterations3,gui.maxIterations4,gui.maxIterations5};
                axT      = gui.ax;
                textBoxT = gui.textBox;
                patchT   = gui.patchHandle;
                ind      = cellfun(@isempty,maxIter);
                
                % Don't display bars that should not be shown
                set(axT(ind),'visible','off')
                set(textBoxT(ind),'visible','off')
                patchT = patchT(ind(1:length(patchT)));
                set(patchT(patchT~=0),'visible','off')
                
                % Find the coordinates of the plotted bars
                axT      = axT(~ind);
                textBoxT = textBoxT(~ind);
                scale    = 1;
                if isempty(gui.lock)
                    numOfAxes = length(axT);
                else
                    numOfAxes = gui.lock;
                end
                
                switch numOfAxes
                    case 1
                        
                        scale   = 1;
                        pos     = [0.2,0.4,0.6,0.1];
                        posText = [0.1,0.55,0.8,0.3];
                        fpos    = get(gui.figureHandle,'position');
                        fpos(4) = 20;
                        set(gui.figureHandle,'position',fpos)
                        nb_moveCenter(gui.figureHandle,nb_getCurrentMonitor());
                        
                    case 2
                        
                        scale   = 1;
                        pos     = [0.2,0.6,0.6,0.1;
                                   0.2,0.3,0.6,0.1];
                        posText = [0.1,0.75,0.8,0.1;
                                   0.1,0.45,0.8,0.1];
                        fpos    = get(gui.figureHandle,'position');
                        fpos(4) = 20;
                        set(gui.figureHandle,'position',fpos)
                        nb_moveCenter(gui.figureHandle,nb_getCurrentMonitor());
                        
                    case 3
                        
                        scale        = 3/2;
                        pos          = [0.2,0.6,0.6,0.1/scale];
                        pos          = pos(ones(3,1),:);
                        pos(1,2)     = 0.7; 
                        pos(2,2)     = 0.45; 
                        pos(3,2)     = 0.2;
                        posText      = [0.1,0.75,0.8,0.1/scale];
                        posText      = posText(ones(3,1),:);
                        posText(1,2) = 0.8; 
                        posText(2,2) = 0.55; 
                        posText(3,2) = 0.3;
                        fpos         = get(gui.figureHandle,'position');
                        fpos(4)      = 20*scale;
                        set(gui.figureHandle,'position',fpos)
                        nb_moveCenter(gui.figureHandle,nb_getCurrentMonitor());
                        
                    case 4
                        
                        scale        = 3/2;
                        pos          = [0.2,0.6,0.6,0.1/scale];
                        pos          = pos(ones(4,1),:);
                        pos(1,2)     = 0.77; 
                        pos(2,2)     = 0.57; 
                        pos(3,2)     = 0.37;
                        pos(4,2)     = 0.17;
                        posText      = [0.1,0.75,0.8,0.1/scale];
                        posText      = posText(ones(4,1),:);
                        posText(1,2) = 0.85; 
                        posText(2,2) = 0.65; 
                        posText(3,2) = 0.45;
                        posText(4,2) = 0.25;
                        fpos         = get(gui.figureHandle,'position');
                        fpos(4)      = 20*scale; 
                        set(gui.figureHandle,'position',fpos)
                        nb_moveCenter(gui.figureHandle,nb_getCurrentMonitor());
                        
                    case 5
                        
                        scale        = 1.75;
                        pos          = [0.2,0.6,0.6,0.1/scale];
                        pos          = pos(ones(5,1),:);
                        pos(1,2)     = 0.77; 
                        pos(2,2)     = 0.62; 
                        pos(3,2)     = 0.47;
                        pos(4,2)     = 0.32;
                        pos(5,2)     = 0.17;
                        posText      = [0.1,0.75,0.8,0.1/scale];
                        posText      = posText(ones(5,1),:);
                        posText(1,2) = 0.84; 
                        posText(2,2) = 0.69; 
                        posText(3,2) = 0.54;
                        posText(4,2) = 0.39;
                        posText(5,2) = 0.24;
                        fpos         = get(gui.figureHandle,'position');
                        fpos(4)      = 20*scale; 
                        set(gui.figureHandle,'position',fpos)
                        nb_moveCenter(gui.figureHandle,nb_getCurrentMonitor());
                        
                end
                
                if gui.includeCancel
                    cpos    = get(gui.cancelButton,'position');
                    cpos(4) = 0.1/scale;
                    cpos(2) = 0.1/scale;
                    set(gui.cancelButton,'position',cpos);
                end

                if gui.includePause
                    cpos    = get(gui.pauseButton,'position');
                    cpos(4) = 0.1/scale;
                    cpos(2) = 0.1/scale;
                    set(gui.pauseButton,'position',cpos);
                end
                
                for ii = 1:length(axT)
                    set(textBoxT(ii),'position',posText(ii,:))
                    set(axT(ii),'position',pos(ii,:))
                end
                
                % Display the wanted bars 
                set(axT,'visible','on')
                set(textBoxT,'visible','on')
  
            end
            
        end
        
        function updateBar(gui,index)
            
            if ~gui.canceling && ~gui.paused
                
                % Get the coordinates
                statusT = [gui.status1,gui.status2,gui.status3,gui.status4,gui.status5];
                maxIter = {gui.maxIterations1,gui.maxIterations2,gui.maxIterations3,gui.maxIterations4,gui.maxIterations5};
                tick    = statusT(index)/maxIter{index};
                x       = [0,tick,tick,0];
                y       = [0,0,1,1];
                
                try
                    oldPatch = gui.patchHandle(index);
                    set(oldPatch,'xData',x,'yData',y,'visible','on')
                catch %#ok<CTCH>
                    gui.patchHandle(index) = patch(x,y,[0.1725,0.4510,0.6000],...
                            'parent',   gui.ax(index),...
                            'clipping', 'off',...
                            'visible',  'on',...
                            'lineStyle','none');
                end

            end
            
        end
        
        function updateText(gui,index)
            
            textT = {gui.text1,gui.text2,gui.text3,gui.text4,gui.text5};
            if ~gui.canceling
                set(gui.textBox(index),'string',textT{index});
            end
            
        end
        
        varargout = makeGUI(varargin)
        
    end
    
end

