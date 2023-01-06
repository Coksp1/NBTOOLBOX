classdef nb_buttonPanel < handle
% Description:
%
% A class for creating a button panel. Big buttons are added on the
% left in the panel, and when pushed on it switches between the visible 
% right side panel. The right hand side panel is of class nb_rowPanel.
%
% Constructor:
%
%   obj = nb_buttonPanel(varargin)
% 
%   Input:
%
%   - parent   : A figure or uipanel handle.
%
%   - varargin : Name(s) of the button(s) to add.
% 
%   Output:
% 
%   - obj     : An nb_buttonPanel object.
% 
%   Examples:
%
%   h = nb_buttonPanel(gcf,'Button1','Button2','Button3');
%   uicontrol(h,'style','edit',...
%               'string','Test',...
%               'button','Button1');
%   uicontrol(h,'style','edit',...
%               'string','Test2',...
%               'button','Button2');
%   p = uipanel(h,'Title','Test3',...
%                 'button','Button3')
%   uicontrol(p,'style','edit',...
%               'string','Test3',...
%               'button','Button3');
%    
% See also:
% uipanel
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    properties (SetAccess=protected) 
   
        % A uibuttongroup object. 
        buttonGroup         = []
        
        % Names of the buttons of the uibuttongroup.
        buttonNames         = {};
   
        % A vector of uicontrol handles representing the buttons.
        buttons             = [];
        
        % Handles to the nb_rowPanel that are switch between using the 
        % button group. See the children property of these objects to get
        % hold of the uicontrol object added by the uicontrol method of 
        % this class. 
        panels              = [];
        
        % Parent as a figure or uipanel handle.
        parent              = [];
        
        % Type of panels created for each button. Either 'nb_rowPanel'
        % or 'uipanel'. Default is 'nb_rowPanel'.
        type                = 'nb_rowPanel';
        
    end
    
    methods
        
        function obj = nb_buttonPanel(parent,varargin)
            
            if nargin < 1
                return
            end
            [obj.type,varargin] = nb_parseOneOptional('type','nb_rowPanel',varargin{:});
            
            if length(varargin) > 10
                error([mfilename ':: Cannot add more than 10 buttons!'])
            elseif length(varargin) < 1
                error([mfilename ':: Number of buttons cannot be empty.'])
            end
            
            if ~not(isa(parent,'figure') || isa(parent,'uipanel'))
                error([mfilename ':: The parent input must be a figure or uipanel handle.'])
            end
            obj.parent      = parent;
            obj.buttonNames = varargin;
            makeGUI(obj);
            
        end
          
    end
    
    methods(Access=protected)
        
        function makeGUI(obj)
           
            % Make button group object
            obj.buttonGroup = uibuttongroup(...
                'parent',              obj.parent,...
                'title',               '',...
                'background',          [1 1 1],...
                'Interruptible',       'off',...
                'units',               'normalized',...
                'position',            [0.02 0.02 0.18 0.96],...
                'SelectionChangeFcn',  @obj.changePanel); 
            
            % Make the buttons
            b = nan(1,length(obj.buttonNames));
            for ii = 1:length(obj.buttonNames)
                
               b(ii) = uicontrol(...
                    'units',       'normalized',...
                    'position',    [0, 1 - 0.1*ii, 1, 0.1],...
                    'background',  [1 1 1],...   
                    'parent',      obj.buttonGroup,...
                    'style',       'togglebutton',...
                    'string',      obj.buttonNames{ii}); 
                
            end
            obj.buttons = b;
            
            % Make panels
            if strcmpi(obj.type,'uipanel')
                p = nb_gobjects(1,length(obj.buttonNames));
                for ii = 1:length(obj.buttonNames)
                   p(ii) = uipanel(obj.parent,...
                      'title',               '',...
                      'visible',             'off',...
                      'borderType',          'none',... 
                      'units',               'normalized',...
                      'position',            [0.22, 0.02, 1 - 0.24, 0.96]);  
                end
            else
                p(1,length(obj.buttonNames)) = nb_rowPanel;
                for ii = 1:length(obj.buttonNames)
                   p(ii) = nb_rowPanel(obj.parent,...
                      'title',               '',...
                      'visible',             'off',...
                      'borderType',          'none',... 
                      'units',               'normalized',...
                      'position',            [0.22, 0.02, 1 - 0.24, 0.96]);  
                end
            end
            set(p(1),'visible','on');
            obj.panels = p;
            
        end
        
        function changePanel(obj,~,event)
            
            old  = event.OldValue;
            str  = get(old,'string');
            ind  = strcmpi(str,obj.buttonNames);
            set(obj.panels(ind),'visible','off');

            new  = event.NewValue;
            str  = get(new,'string');
            ind  = strcmpi(str,obj.buttonNames);
            set(obj.panels(ind),'visible','on');
            
        end
        
    end
    
end
