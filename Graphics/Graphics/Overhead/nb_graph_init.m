function obj = nb_graph_init(data)
% Syntax:
%
% obj = nb_graph_init(data)
%
% Description:
%
% A function to create a corresponding graph object to the provided data
% object
% 
% Input:
% 
% - data : Either an object of class nb_ts, nb_cs or nb_data.
% 
% Output:
% 
% - obj  : Either an object of class nb_graph_ts, nb_graph_cs and
%          nb_graph_data
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    type = class(data);
    switch type
        case 'nb_ts'            
            obj = nb_graph_ts(data);           
        case 'nb_cs'
            obj = nb_graph_cs(data);
        case 'nb_data'
            obj = nb_graph_data(data);
        otherwise
            error([mfilename ':: It is not possible to create a graph object of the provided data!']) 
    end
    
end
