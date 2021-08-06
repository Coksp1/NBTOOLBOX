function s = struct(obj)
% Syntax:
%
% s = struct(obj)
%
% Description:
%
% Convert object to struct
% 
% Input:
% 
% - obj : An object of class nb_graph_ts
% 
% Output:
% 
% - s   : A struct
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    s = struct@nb_graph(obj);
  
    % Convert to struct
    obj.returnLocal = 1;

    props          = properties(obj);
    nb_graph_props = properties('nb_graph');
    for ii = 1:length(props)

        switch lower(props{ii})
            
            case nb_graph_props
                
            case 'barshadingdate'

                if iscell(obj.barShadingDate)  
                    out = obj.barShadingDate;
                    for jj = 2:2:length(out)
                        out{jj} = toString(out{jj});
                    end
                    s.barShadingDate = out;
                else
                    s.barShadingDate = toString(obj.barShadingDate);
                end

            case 'dashedline'

                s.dashedLine = toString(obj.dashedLine);

            case 'db'

                s.DB = struct(obj.DB);

            case 'endgraph'

                s.endGraph = toString(obj.endGraph);

            case 'startgraph'

                s.startGraph = toString(obj.startGraph);

            otherwise                        
                s.(props{ii}) = obj.(props{ii});
        end

    end

    s.manuallySetEndGraph    = obj.manuallySetEndGraph;
    s.manuallySetStartGraph  = obj.manuallySetStartGraph;
    s.class                  = 'nb_graph_bd';

    obj.returnLocal = 0;

end
