classdef nb_waitbar < handle
% Description:
%
% A class for reordering a cellstr.
%
% Constructor:
%
%   gui = nb_waitbar(parent,name,maxIter)
%   gui = nb_waitbar(parent,name,maxIter,includeCancel)
%   gui = nb_waitbar(parent,name,maxIter,includeCancel,includeTimeEst)
% 
%   Input:
%
%   - parent         : An object of class nb_GUI
%
%   - name           : A string with the name of the figure
%
%   - maxIter        : The maximum number of iterations to be displayed by 
%                      the waitbar.
%
%   - includeCancel  : Include cancel button.
%
%   - includeTimeEst : Include time estimate button.
% 
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    properties
        
        % Identify if cancel button have been pushed
        canceling       = 0;
        
        % Status of iteration
        status          = 0;
        
        % Set the text of the window
        text            = '';
        
    end
    
    properties (SetAccess=protected)
        
        % Handle to the MATLAB figure
        figureHandle    = [];
        
        % Name of figure, as a string.
        name            = '';
        
        % Number of iteration max
        maxIterations   = 0;
        
        % To be selected from. As a cellstr
        parent          = []; 
        
    end
    
    properties(Access=protected)
       
        % Handle to the axes with the 
        ax              = [];
        
        % Include timer or not
        includeTimer    = false;
        
        % Handle to the the text box
        textBox         = [];
        
        % Handle to the patch object
        patchHandle     = [];
        
        % Handle to the cancel button
        cancelButton    = [];
        
        % Handle to the text box of the time remaining
        timeEstTextBox  = [];
        
        % Timer         
        timer           = [];
        
        % Number of updates
        updates         = 0;
        
    end
   
    methods
        
        function gui = nb_waitbar(parent,name,maxIter,includeCancel,includeTimer)
        % Constructor
        
            if nargin < 5
                includeTimer = false;
                if nargin < 4
                    includeCancel = false;
                end
            end
            
            gui.parent        = parent;
            gui.name          = name;
            gui.maxIterations = maxIter;
            gui.includeTimer  = includeTimer;
            makeGUI(gui,includeCancel);
            drawnow;
            
        end
        
        function set.status(gui,value)
        % Update the waiting bar with the given value    
            
            if value > gui.maxIterations %#ok<MCSUP>
                value = gui.maxIterations; %#ok<MCSUP>
            elseif value < 0
                value = 0;
            end
            
            gui.status  = value;

            updateBar(gui);
            drawnow;
            
        end
        
        function set.text(gui,value)
        % Update the waiting bar with the given value    
            
            if ~(ischar(value) || iscellstr(value))
                error([mfilename ':: The property must be set to a string or cellstr'])
            end
            gui.text = value;
            
            updateText(gui);
            drawnow;
            
        end
        
        function delete(gui)
            
            if ishandle(gui.figureHandle)
                delete(gui.figureHandle);
            end
              
        end
        
    end
    
    methods(Access=protected,Hidden=true)
        
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
                
                % How many updates
                if gui.includeTimer
                    gui.updates = gui.updates + 1;
                    if gui.updates == 1
                        gui.timer = tic();
                    else
                        sec  = toc(gui.timer)/gui.status;
                        left = sec*(gui.maxIterations - gui.status);
                        set(gui.timeEstTextBox,'string',['Time remaining: ' char(duration([0, 0, left]))])
                    end
                end
                
            end
            
        end
        
        function updateText(gui)
            
            if ~gui.canceling
                set(gui.textBox,'string',gui.text);
            end
            
        end
        
        varargout = makeGUI(varargin)
        
    end
    
end

