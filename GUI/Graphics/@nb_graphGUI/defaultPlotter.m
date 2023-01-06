function graphObject = defaultPlotter(gui,graphObject,type,template)
% Syntax:
%
% graphObject = defaultPlotter(gui,graphObject,type,template)
%
% Description:
%
% Part of DAG. Add default graph settings for an initialized graph object
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 4
        template = gui.template;
        if nargin < 3
            type = gui.type;
        end
    end

    if isa(graphObject,'nb_graph')
        
        if graphObject.DB.numberOfVariables > 10
            vars = graphObject.DB.variables(1:10);
        else
            vars = graphObject.DB.variables;
        end
        
        graphObject.variablesToPlot = vars;
        graphObject.page            = 1;
        graphObject.legAuto         = 'on';

        % Add default colors
        cols = cell(1,size(vars,2)*2);
        kk   = 1;
        for ii = 1:size(vars,2)
            cols{kk}     = vars{ii};
            cols{kk + 1} = gui.parent.settings.defaultColors{ii};
            kk           = kk + 2;
        end
        graphObject.colors = cols;
    end
    
    % Apply default settings
    applyDefault(gui.parent,graphObject,template);

    % Convert to advanced graph
    if strcmpi(type,'advanced')
        graphObject = nb_graph_adv(graphObject);
    end
    
    % Assign local variables
    if isa(gui.parent,'nb_GUI')
        setSpecial(graphObject,'localVariables',gui.parent.settings.localVariables);
    end

end
