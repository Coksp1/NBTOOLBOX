classdef nb_rowPanel < handle
% Description:
%
% A class for creating a row panels.
%
% Constructor:
%
%   obj = nb_rowPanel(varargin)
% 
%   Input:
%
%   - parent : A figure or uipanel handle.
% 
%   Output:
% 
%   - obj     : An nb_rowPanel object.
% 
%   Examples:
%
%   h = nb_rowPanel(gcf);
%   uicontrol(h,'style','edit',...
%               'string','Test1',...
%               'Title', 'First');
%   uicontrol(h,'style','edit',...
%               'string','Test2',...
%               'Title', 'Second');
%   uicontrol(h,'style','edit',...
%               'string','Test3',...
%               'Title', 'Third');  
% 
% See also:
% uipanel
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    properties

        % Default height of added uicontrol object in the first column.
        height1Column                = 0.053;
        
        % Default height of added uicontrol object in the second column.
        height2Column                = 0.055;
        
        % Number of added elements in the nb_rowPanel.
        numberOfElements             = 12;
        
        % Default x-direction start value for first column. 
        start1Column                 = 0.04;
        
        % Default x-direction start value for second column. 
        start2Column                 = 0.3;

        % Default width of second column.
        width2Column                 = 0.35;

    end

    properties (SetAccess=protected) 
   
        % A cell array of handles to the automatically added uicontrol  
        % (text) objects when the 'title' option is used or if 'column' is 
        % set to 1. 
        children1           = {};
        
        % A cell array of handles to the added uicontrol objects. 
        children2           = {};
        
        % A cell array of handles to the uicontrol objects added if 
        % 'column' is set to 3. 
        children3           = {};
        
        % Handle to the uipanel. 
        panel               = [];
        
        % Parent as a figure or uipanel handle.
        parent              = [];
        
    end
    
    properties (SetAccess=protected,Dependent=true)
       
        extraY1Column
        spaceY
        start3Column
        width1Column
        width3Column
        
    end
        
    methods
        
        function obj = nb_rowPanel(parent,varargin)
            
            if nargin < 1
                return
            end
            
            if ~not(isa(parent,'figure') || isa(parent,'uipanel'))
                error([mfilename ':: The parent input must be a figure or uipanel handle.'])
            end
            obj.parent = parent;
            makeGUI(obj);
            set(obj,varargin{:});
            
        end
        
        function value = get.width1Column(obj)
            value = obj.start2Column - obj.start1Column*2;      
        end
        
        function value = get.start3Column(obj)
            value = obj.start2Column + obj.width2Column + obj.start1Column;
        end
        
        function value = get.width3Column(obj)           
            value = (1 - obj.start2Column - obj.width2Column) - obj.start1Column*2;
        end
        
        function value = get.spaceY(obj)   
            value = (1 - obj.height2Column*obj.numberOfElements)/(obj.numberOfElements+1);
        end
        
        function value = get.extraY1Column(obj)  
            value = (obj.height2Column - obj.height1Column)/((obj.numberOfElements + 1)/2);
        end
          
    end
    
    methods(Access=protected)
        
        function makeGUI(obj)
            obj.panel = uipanel(...
                'parent',      obj.parent,...
                'title',       '',...
                'borderType',  'none',... 
                'units',       'normalized',...
                'position',    [0,0,1,1]); 
        end
        
    end
    
end
