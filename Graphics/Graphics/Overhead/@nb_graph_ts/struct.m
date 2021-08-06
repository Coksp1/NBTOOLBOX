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

            case 'defaultfans'

                s.defaultFans = toString(obj.defaultFans);

            case 'endgraph'

                s.endGraph = toString(obj.endGraph);

            case 'fandatasets'

                if isa(obj.fanDatasets,'nb_ts')
                    fanD = struct(obj.fanDatasets);
                else
                    fanD = obj.fanDatasets;
                end
                s.fanDatasets = fanD;

            case 'simplerulesseconddata'

                s.simpleRulesSecondData = struct(obj.simpleRulesSecondData);

            case 'startgraph'

                s.startGraph = toString(obj.startGraph);

            case 'stopstrip'

                s.stopStrip = toString(obj.stopStrip);

            case 'xtickstart'

                s.xTickStart = toString(obj.xTickStart);

            otherwise                        
                s.(props{ii}) = obj.(props{ii});
        end

    end

    s.manuallySetEndGraph    = obj.manuallySetEndGraph;
    s.manuallySetStartGraph  = obj.manuallySetStartGraph;
    s.class                  = 'nb_graph_ts';

    obj.returnLocal = 0;

end
