classdef nb_selectionPanel < handle
% Description:
%
% A class to make a selection panel.
%
% Constructor:
%
%   gui = nb_selectionPanel(parent,title,string,varargin)
% 
%   Input:
%
%   - parent : The parent, as an MATLAB figure or uipanel handle.
%
%   - title  : Sets the title of the selection list box.
%
%   - string : Sets the variables to select from. As a cellstr.
%
%   Optional input:
%
%   - 'position1' : Position of the selection panel in normal units. As
%                   a 1 x 4 double.
%
%   - 'position2' : Position of the assignment panel in normal units. As
%                   a 1 x 4 double.
%
%   - 'docktype'  : The type of docking. Either 'radiobutton', 'pushbutton' 
%                   or 'text'. Defualt is 'radiobutton'.
% 
%   Output:
% 
%   - gui     : The handle to the object.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

   properties (SetAccess=protected)
       
       % Handles to the add buttons. As MATLAB uicontrol handles.
       addButtons       = [];
       
       % Handle to the nb_dockedPanel, which contain the list boxes
       % which could be assign strings from the selListbox.
       %
       % The list boxes must be added by the user to this handle
       % using the uicontrol method of this class.
       assignPanel      = [];
       
       % Height of button in normalized units.
       buttonHeight     = 0.05;
       
       % Width of button in normalized units.
       buttonWidth      = 0.05;
       
       % The parent, as an MATLAB figure or uipanel handle.
       parent           = [];
       
       % Handles to the add buttons. As MATLAB uicontrol handles.
       removeButtons    = [];
       
       % Handle to the list box with the strings to select. As an
       % uicontrol object. (style='listbox').
       selListbox       = [];
       
       % The title of the selection listbox.
       selListTitle     = '';
       
       % Handle to the nb_dockedPanel, which contain the selection
       % list box
       selPanel         = [];
       
   end
   
   events
       ListChange
   end
   
   methods
      
       function obj = nb_selectionPanel(parent,title,string,varargin)
           
           if nargin < 3
               string = {};
               if nargin < 2
                   title = '';
               end
           end
           
           % Parse optional inputs
           position1 = [];
           position2 = [];
           dockType  = 'radiobutton';
           for ii = 1:2:size(varargin,2)
               inputName  = varargin{ii};
               inputValue = varargin{ii + 1};
               switch lower(inputName)
                   case 'position1'
                       position1 = inputValue;  
                   case 'position2'
                       position2 = inputValue; 
                   case 'docktype'
                       dockType  = inputValue; 
                   otherwise
                       error([mfilename ':: Unsupported input ' inputName])    
               end
           end
           
           % Assign parent
           obj.parent = parent;
           if nb_isFigure(obj.parent)
               backgroundColor = get(obj.parent,'color');
           else
               backgroundColor = get(obj.parent,'backgroundColor');
           end
           
           % Locations
           ySpace       = 0.04;
           yListStart   = 0.12;
           listHeight   = 1 - ySpace - yListStart;
           startListX1  = 0.04;
           listWidth    = 0.4;
           startListX2  = 1 - startListX1 - listWidth;
           
           if isempty(position1)
               position1 = [startListX1, yListStart, listWidth, listHeight];
           end
           
           if isempty(position2)
               position2 = [startListX2, yListStart, listWidth, listHeight];
           end
           
           % Selection panel
           obj.selPanel = nb_dockedPanel(...
               'backgroundColor', backgroundColor,...
               'parent',          obj.parent,...
               'units',           'normalized',...
               'BorderType',      'none',...
               'titleStyle',      'text',...
               'position',        position1);
           
           % Selction list box
           obj.selListbox = uicontrol(obj.selPanel,...
               'style',         'listbox',...
               'background',    [1 1 1],...
               'string',        string,...
               'title',         title,...
               'max',           length(string));
           
           % Assign panel (Which list boxes could be added to)
           obj.assignPanel = nb_dockedPanel(...
               'backgroundColor', backgroundColor,...
               'parent',          obj.parent,...
               'units',           'normalized',...
               'BorderType',      'none',...
               'titleStyle',      dockType,...
               'position',        position2);
           
           % Add listeners to docking of the listboxes and added
           % listboxes (must reposition the add and remove buttons)
           addlistener(obj.assignPanel,'changedUIComponentState',@obj.repositionAndChangeStateButtonsCallback);
           addlistener(obj.assignPanel,'addedUIComponent',@obj.repositionButtonsCallback);
           
       end
       
   end
   
   methods(Access=protected,Hidden=true)
       
       function addString(obj,~,~,id)
           
           % Get selected strings
           string  = get(obj.selListbox,'string');
           if isempty(string)
               return
           end
           index   = get(obj.selListbox,'value');
           strings = string(index);
           
           % Get the handle to the listbox to add the strings to
           childs  = obj.assignPanel.children;
           addList = childs(end - id*2 + 2);
           
           % Ensure no overlapping variables
           oldString = get(addList,'string');
           if iscell(oldString) && isscalar(oldString)
               if isempty(oldString{1})
                   oldString = {};
               end
           end
           if ~isempty(oldString)
               indexT     = ismember(strings,oldString);
               newStrings = strings(~indexT);
               strings    = [newStrings; oldString];
           end
           
           % Update the list of the removed variables
           set(addList,'string',sort(strings),'value',1,'max',length(strings));
           
           notify(obj, 'ListChange');       
           
       end
       
       function removeString(obj,~,~,id)
           
           % Get the handle to the listbox to add the strings to
           childs = obj.assignPanel.children;
           rmList = childs(end - id*2 + 2);
           
           % Get selected variables
           index        = get(rmList,'value');
           string       = get(rmList,'string');
           if isempty(string)
               return
           end
           stringsToDel = string(index);
           
           % Find out which to keep
           index         = ismember(string,stringsToDel);
           stringsToKeep = string(~index);
           
           % Update the list box of interest
           if isempty(stringsToKeep)
               set(rmList,'string',stringsToKeep);
           else
               set(rmList,'string',stringsToKeep,'value',1,'max',length(stringsToKeep));
           end
           
           notify(obj, 'ListChange');
           
       end
       
       function repositionAndChangeStateButtonsCallback(obj,~,event)
       % - event :  nb_additionalNumberEvent   
           
           id = event.number;
           visible = get(obj.addButtons(id),'visible');
           if strcmpi(visible,'on')
               set(obj.addButtons(id),'visible','off');
               set(obj.removeButtons(id),'visible','off');
           else
               set(obj.addButtons(id),'visible','on');
               set(obj.removeButtons(id),'visible','on');
           end
           repositionButtons(obj);
           
       end
       
       function repositionButtonsCallback(obj,~,~)
           
           repositionButtons(obj);
           
       end
       
       function repositionButtons(obj)
           
           childs   = obj.assignPanel.children;
           addB     = obj.addButtons;
           removeB  = obj.removeButtons;
           
           posB1    = ones(1,4);
           posB2    = ones(1,4);
           posRP    = obj.assignPanel.position;
           posLP    = obj.selPanel.position;
           
           for ii = 1:length(addB)
               
               uih      = childs(end - ii*2 + 2);
               pos      = get(uih,'position');
               posB1(1) = (posLP(1)+ posLP(3) + posRP(1) - obj.buttonWidth)*0.5 ;
               posB2(1) = posB1(1);
               posB1(2) = posRP(2) + (pos(2) + pos(4)/2)*posRP(4);
               posB2(2) = posB1(2) - obj.buttonHeight;
               posB1(3) = obj.buttonWidth;
               posB2(3) = obj.buttonWidth;
               posB1(4) = obj.buttonHeight;
               posB2(4) = obj.buttonHeight;
               set(addB(ii),'position',posB1);
               set(removeB(ii),'position',posB2);
               
           end
           
       end
       
   end
    
    
end
