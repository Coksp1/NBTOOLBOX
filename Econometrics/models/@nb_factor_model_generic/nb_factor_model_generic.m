classdef (Abstract) nb_factor_model_generic 
% Description:
%
% An abstract superclass for all factor models
%
% Constructor:
%
%   No constructor exist. This class is abstract.
% 
% See also:
% nb_favar, nb_fmdyn, nb_fmsa
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    properties
        
        % A struct with the fields name, tex_name and number. The name 
        % field holds a cellstr with the names of all the variable(s) of 
        % the model observation equation, the tex_name holds the names in 
        % the tex format. The number field holds a double with the number 
        % of variables of the model observation equation. To set it use the 
        % set function. E.g. obj = set(obj,'observables',{'Var1','Var2'});
        % or use the <className>.template() method.
        %
        % If the model class also supports mixed frequency data, it has two
        % additional fields; frequency and mapping. These fields stores the
        % selected frequency and mapping for each element.
        observables      = struct(); 
 
    end
    
    
    methods
       
        varargout = getObservables(varargin)
        
    end
           
end
