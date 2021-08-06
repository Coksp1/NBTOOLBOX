function updatePanel(gui,selected)
% Syntax:
%
% updatePanel(gui,selected)
%
% Description:
%
% Part of DAG. Update the panel with the plot properties
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    switch lower(selected)

        case {'line','radar'}

            linePanel(gui);

        case {'grouped','stacked','area','dec'}

            barAndAreaPanel(gui);
            
        case {'pie','donut'}
            
            piePanel(gui);

    end

end
