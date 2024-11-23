function uih = nb_uitable(obj,varargin)
% Syntax:
%
% nb_uitable(obj,varargin)
%
% Description:
%
% Add a nb_uitable object to a row panel.
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
%              - 'parent'
% 
% Output:
% 
% uih        : The handle to the nb_uitable object.
%
% Written by Kenneth Sæterhagen Paulsen        

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    [ind,optStruct,opt] = interpretInputs(obj,varargin);
    uih                 = nb_uitable(obj.tabPanels(ind),optStruct{:},opt{:});

end
