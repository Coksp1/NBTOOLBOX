classdef (Abstract) nb_graph_obj  < matlab.mixin.Copyable
% Description:
%
% A abstract class of the overhead graph classes 
%
% Superclasses:
%
% matlab.mixin.Copyable, handle
% 
% Subclasses:
%
% nb_graph, nb_table_data
%
% Constructor:
%
%   No constructor
% 
% Properties:
%
% See also:
% nb_graph, nb_table_data
%
% Written by Kenneth Sæterhagen Paulsen 

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    methods (Static=true,Hidden=true)
        
        function obj = fromStruct(s)
        % Convert a struct into either a nb_graph_data, nb_graph_ts or 
        % nb_graph_cs object     
            
            if isempty(s)
                obj = [];
                return
            end
        
            if ~isfield(s,'class')
                error([mfilename ':: The struct cannot be converted to a nb_graph_subplot, nb_graph_data, nb_graph_ts or nb_graph_cs object. It misses the class field.'])
            end
        
            switch s.class
                
                case 'nb_graph_ts'
                    
                    obj = nb_graph_ts.unstruct(s);
                    
                case 'nb_graph_cs'
                    
                    obj = nb_graph_cs.unstruct(s);
                    
                case 'nb_graph_data'
                    
                    obj = nb_graph_data.unstruct(s);
                    
                case 'nb_graph_subplot'
                    
                    obj = nb_graph_subplot.unstruct(s);

                case 'nb_table_ts'
                    
                    obj = nb_table_ts.unstruct(s);
                    
                case 'nb_table_cs'
                    
                    obj = nb_table_cs.unstruct(s);
                    
                case 'nb_table_data'
                    
                    obj = nb_table_data.unstruct(s);
                    
                case 'nb_table_cell'
                    
                    obj = nb_table_cell.unstruct(s);
                    
                case 'nb_graph_adv'
                    
                    obj = nb_graph_adv.unstruct(s);
                    
                otherwise
                    error([mfilename ':: Unsupported class ' s.class '.'])
            end
        
            
        end
        
    end

end
