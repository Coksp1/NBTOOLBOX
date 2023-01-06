classdef nb_waitbar2 < handle
% Description:
%
% A class for creating a window with two waiting bars.
%
% Constructor:
%
%   gui = nb_waitbar(parent,name,includeCancel)
% 
%   Input:
%
%   - parent        : An object of class nb_GUI
%
%   - name          : A string with the name of the figure
%
%   - includeCancel : 1 to include cancel button
% 
%   Output:
% 
%   - gui           : A nb_waitbar2 object
% 
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    properties
        
        % Identify if cancel button have been pushed
        canceling       = 0;
        
        % Handle to the MATLAB figure
        figureHandle    = [];
        
        % Name of figure, as a string.
        name            = '';
        
        % Number of iteration max
        maxIterations   = [];
        
        % Number of iteration max (second bar)
        maxIterations2  = [];
        
        % To be selected from. As a cellstr
        parent          = []; 
        
        % Status of iteration
        status          = 0;
        
        % Second status of iteration
        status2         = 0;
        
        % Set the text of the window
        text            = '';
        
        % Set the second text of the window
        text2           = '';
        
    end
    
    properties(Access=protected)
       
        % Handle to the axes with the bar
        ax              = [];
        
        % Handle to the axes with the second bar
        ax2             = []; 
        
        % Handle to the the text box
        textBox         = [];
        
        % Handle to the the second text box
        textBox2        = [];
        
        % Handle to the patch object
        patchHandle     = [];
        
        % Handle to the second patch object
        patchHandle2    = [];
        
        % Handle to the cancel button
        cancelButton    = [];
        
    end
   
    methods
        
        function gui = nb_waitbar2(parent,name,includeCancel)
        % Constructor
        
            if nargin < 3
                includeCancel = false;
            end
            
            gui.parent = parent;
            gui.name   = name;
            makeGUI(gui,includeCancel);
            
        end
        
        function set.status(gui,value)
        % Update the waiting bar with the given value    
            
            if value > gui.maxIterations %#ok<MCSUP>
                value = gui.maxIterations; %#ok<MCSUP>
            elseif value < 0
                value = 0;
            end
            
            gui.status = value;
            
            updateBar(gui);
            drawnow;
            
        end
        
        function set.status2(gui,value)
        % Update the waiting bar with the given value    
            
            if value > gui.maxIterations2 %#ok<MCSUP>
                value = gui.maxIterations2; %#ok<MCSUP>
            elseif value < 0
                value = 0;
            end
            
            gui.status2 = value;
            
            updateBar2(gui);
            drawnow;
            
        end
        
        function set.maxIterations(gui,value)
        % Update the waiting bar with the given value    
            
            if isnumeric(value) && numel(value) == 1
                gui.maxIterations = value;
                updateGUI(gui);
                drawnow;
            end
            
        end
        
        function set.maxIterations2(gui,value)
        % Update the waiting bar with the given value    
            
            if isnumeric(value) && numel(value) == 1
                gui.maxIterations2 = value;
                updateGUI(gui);
                drawnow;
            end
            
        end
        
        function set.text(gui,value)
        % Update the waiting bar with the given value    
            
            if ~ischar(value)
                error([mfilename 'The property must be set to a string'])
            end
            gui.text = value;
            
            updateText(gui);
            drawnow;
            
        end
        
        function set.text2(gui,value)
        % Update the waiting bar with the given value    
            
            if ~ischar(value)
                error([mfilename 'The property must be set to a string'])
            end
            gui.text2 = value;
            
            updateText2(gui);
            drawnow;
            
        end
        
        function deleteFirst(gui)
            
            if isempty(gui.maxIterations2)
                delete(gui);
            else
                gui.maxIterations = [];
                updateGUI(gui);
                drawnow;
            end
              
        end
     
        function deleteSecond(gui)
            
            if isempty(gui.maxIterations)
                delete(gui);
            else
                gui.maxIterations2 = [];
                updateGUI(gui);
                drawnow;
            end
              
        end
        
        function delete(gui)
            
            if ishandle(gui.figureHandle)
                delete(gui.figureHandle);
            end
              
        end
        
    end
    
    methods(Access=protected,Hidden=true)
        
        function updateGUI(gui)
            
            if ~gui.canceling
                
                if isempty(gui.maxIterations2)
                    set(gui.textBox,'visible','on','position',[0.1,0.55,0.8,0.3])
                    set(gui.ax,'visible','on','position',[0.2,0.35,0.6,0.1])
                    set(gui.textBox2,'visible','off')
                    set(gui.ax2,'visible','off')
                elseif isempty(gui.maxIterations)
                    set(gui.textBox2,'visible','on','position',[0.1,0.55,0.8,0.3])
                    set(gui.ax2,'visible','on','position',[0.2,0.35,0.6,0.1])
                    set(gui.textBox,'visible','off')
                    set(gui.ax,'visible','off')
                else
                    set(gui.textBox,'visible','on','position',[0.1,0.75,0.8,0.1])
                    set(gui.ax,'visible','on','position',[0.2,0.6,0.6,0.1])
                    set(gui.textBox2,'visible','on','position',[0.1,0.45,0.8,0.1])
                    set(gui.ax2,'visible','on','position',[0.2,0.3,0.6,0.1])
                end
                
            end
            
        end
        
        function updateBar(gui)
            
            if ~gui.canceling
                oldPatch = gui.patchHandle; 

                % Plot the patch
                tick = gui.status/gui.maxIterations;
                x = [0,tick,tick,0];
                y = [0,0,1,1];
                gui.patchHandle = patch(x,y,[0.1725,0.4510,0.6000],...
                    'parent',       gui.ax,...
                    'clipping',     'on',...
                    'lineStyle',    'none');

                % Delete old patch
                if ishandle(oldPatch)
                    delete(oldPatch);
                end
            end
            
        end
        
        function updateBar2(gui)
            
            if ~gui.canceling
                
                oldPatch = gui.patchHandle2; 

                % Plot the patch
                tick = gui.status2/gui.maxIterations2;
                x    = [0,tick,tick,0];
                y    = [0,0,1,1];
                gui.patchHandle2 = patch(x,y,[0.1725,0.4510,0.6000],...
                    'parent',       gui.ax2,...
                    'clipping',     'on',...
                    'lineStyle',    'none');

                % Delete old patch
                if ishandle(oldPatch)
                    delete(oldPatch);
                end
                
            end
            
        end
        
        function updateText(gui)
            
            if ~gui.canceling
                set(gui.textBox,'string',gui.text);
            end
            
        end
        
        function updateText2(gui)
            
            if ~gui.canceling
                set(gui.textBox2,'string',gui.text2);
            end
            
        end
        
        varargout = makeGUI(varargin)
        
    end
    
end

