function updatePanel(gui,selected)
% Syntax:
%
% updatePanel(gui,selected)
%
% Description:
%
% Part of DAG. Update the panel with the plot properties
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    switch lower(selected)

        case {'line','radar'}

            linePanel(gui);

        case {'grouped','stacked','area','dec'}

            barAndAreaPanel(gui);
            
        case {'pie','donut'}
            
            piePanel(gui);

    end

end
