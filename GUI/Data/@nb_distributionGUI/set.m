function set(gui, varargin)
% Syntax:
%
% set(gui, varargin)
%
% Description:
%
% Part of DAG.
% 
% Written by Henrik Halvorsen Hortemo and Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    for j = 1:2:size(varargin, 2)

        propertyName  = varargin{j};
        propertyValue = varargin{j + 1};
        
        try
            gui.(propertyName) = propertyValue;
        catch Err
            warning(Err.message);
        end

    end
    
    if ~isempty(gui.figureHandle)
        gui.updateGUI();
    end
    
end
