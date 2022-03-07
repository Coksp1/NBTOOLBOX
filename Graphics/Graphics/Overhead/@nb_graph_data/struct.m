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
% - obj : An object of class nb_graph_cs
%
% Output:
%
% - s   : A struct
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    s = struct@nb_graph(obj);

    obj.returnLocal = 1;

    props          = properties(obj);
    nb_graph_props = properties('nb_graph');
    for ii = 1:length(props)

        switch lower(props{ii})

            case nb_graph_props
            
            case 'db'

                s.DB = struct(obj.DB);

            otherwise
                s.(props{ii}) = obj.(props{ii});
        end

    end

    s.manuallySetEndGraph    = obj.manuallySetEndGraph;
    s.manuallySetStartGraph  = obj.manuallySetStartGraph;
    s.class                  = 'nb_graph_data';

    obj.returnLocal = 0;

end
