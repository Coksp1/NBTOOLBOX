function uih = uicontrol(obj,varargin)
% Syntax:
%
% uicontrol(obj,varargin)
% uih = uicontrol(obj,varargin)
%
% Description:
%
% Add a uicontrol object to the tab panel.
% 
% Caution : The 'tab' input may be given to indicate the tab panel  
%           to add the uicontrol to. 
%
% Input:
% 
% - obj      : An nb_tabPanel object.
%
% - varargin : Optional inputs given to the MATLAB uicontrol 
%              function.
%
%              Prohibited properties : 
%
%              - 'parent' (set to obj.parent)
%
%              Extra properties :
%
%              - 'tab'  : Either the a one line char with the tab title
%                         or a scalar integer with the tab number. If not
%                         given 1 is default.
% 
% Output:
% 
% - uih     : A uicontrol object.
%
% Written by Kenneth Sæterhagen Paulsen        

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    [ind,optStruct,opt] = interpretInputs(obj,varargin);
    uih                 = uicontrol(obj.tabPanels(ind),optStruct{:},opt{:});

end
