function h = nb_uicontrolDAG(gui,varargin)
% Syntax:
%
% value = nb_GUI.checkVersion()
%
% Description:
%
% Part of DAG
%
% Checks what version of MATLAB that is being used.
% If the version is old (before 2018b) we remove tooltips to elude any
% errors.
% 
% Written by Per Bjarne Bye
      
% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if ~isempty(gui) && gui.mVersion < 9.5
        % Remove tooltip
        idx                 = find(strcmpi(varargin, 'tooltip'));
        varargin(idx:idx+1) = [];
        h                   = uicontrol(varargin{:});
    % If user has a recent MATLAB version return the original input.
    else
        h = uicontrol(varargin{:});
    end
 
end
