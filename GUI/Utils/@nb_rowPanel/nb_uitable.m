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
% - obj      : An nb_rowPanel object.
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
% The wanted uicontrol added to one of the panels. 
%
% Written by Kenneth Sæterhagen Paulsen        

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    uih = nb_uitable(obj.panel,varargin{:});

end
