classdef (Abstract) nb_model_parse < nb_model_options
% Description:
%
% An abstract superclass for all model objects that can be parsed.
%
% See also:
% nb_dsge, nb_nonLinearEq
%
% Written by Kenneth Sæterhagen Paulsen
  
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    properties (Dependent = true)
        
        % This property will store the info on the model, such as 
        % equations etc, otherwise it will be empty.
        %
        % Caution: If you are dealing with an object of class nb_dsge,
        %          this property will be empty, if the DSGE model is
        %          parsed with RISE or Dynare.
        parser;
        
    end
    
    methods
        
        function propertyValue = get.parser(obj)
           
            if isNB(obj)
                if isfield(obj.estOptions,'parser')
                    propertyValue = obj.estOptions.parser;
                end 
            else
                propertyValue = struct();
            end
            
        end
        
        function obj = set.parser(obj,value)
           
            if isNB(obj)
                if isfield(obj.estOptions,'parser')
                    estOptions        = obj.estOptions;
                    estOptions.parser = value;
                    obj               = setEstOptions(obj,estOptions);
                end 
            end
            
        end
        
    end
    
    methods(Sealed=true)
        
        varargout = addConstraints(varargin);
         
    end

    methods(Sealed=true,Hidden=true)

        varargout = parseMacro(varargin);
        
    end
    
    methods (Static=true, Sealed=true, Hidden=true)
        
        varargout = constraints2func(varargin)
        varargout = readFile(varargin)
        varargout = removeEquality(varargin)
        varargout = removeInequality(varargin)
        
        function [pars,paramN] = getParamTranslation(pars)

            nParam = length(pars);
            num    = 1:nParam;
            numS   = strtrim(cellstr(int2str(num')));
            paramN = strcat('pars(',numS ,')');

        end
        
    end
    
    methods (Static=true)
        
        varargout = constraints(varargin)
        
    end
    
end
