classdef nb_nonLinearEq < nb_model_generic & nb_model_parse
% Description:
%
% A class for estimation of single non-linear equation models.
%
% Superclasses:
%
% nb_model_generic
%
% Constructor:
%
%   obj = nb_nonLinearEq(varargin)
% 
%   Optional input:
%
%   - See the set method for more on the inputs. 
%     (nb_model_estimate.set)
% 
%   Output:
% 
%   - obj : An nb_nonLinearEq object.
% 
% See also:
% nb_model_generic, nb_model_estimate.set, nb_nonLinearEq.template,
% nb_nonLinearEq.help
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    properties
        
        
    end
    
    methods
        
        function obj = nb_nonLinearEq(varargin)
        % Constructor

            obj         = obj@nb_model_generic();
            temp        = nb_nonLinearEq.template();
            temp        = rmfield(temp,{'dependent','exogenous'});
            temp.parser = nb_nonLinearEq.defaultParser();
            obj.options = temp;
            obj         = set(obj,varargin{:});
            
        end
              
    end
    
    methods (Hidden)
       
        function name = createName(obj)
            
            if ~isscalar(obj)
                error('This method only handle a scalar nb_model_name object.')
            end
            name = ['NONL_EQ_' upper(obj.options.estim_method)];
            V    = nb_conditional(isempty(obj.dependent.number),0,obj.dependent.number);
            NX   = nb_conditional(isempty(obj.exogenous.number),0,obj.exogenous.number);
            name = [name ,'_V' int2str(V)];
            name = [name ,'_NX' int2str(NX)];
            if ~isempty(obj.options.constraints)
                name = [name ,'_CONSTR'];
            end
            if ~isempty(obj.options.rollingWindow)
                name = [name ,'_RW' int2str(obj.options.rollingWindow)];
            end
            
        end
        
    end
    
    methods(Access=protected)
       
        function param = getParametersNames(obj)
            
            if ~nb_isempty(obj.parser)
                param = struct('name',    {obj.parser.parameters'},...
                               'value',   obj.results.beta,...
                               'isInUse', obj.estOptions.parser.parametersInUse);
            else
                param = struct('name',{{}},'value',[]);
            end
            
        end
        
    end
    
    methods (Static=true,Hidden=true)
        
        function parser = defaultParser()
           
            parser = struct(...
                'file','',...
                'dependent',{{}},...
                'exogenous',{{}},...
                'parameters',{{}},...
                'equations',{{}},...
                'constraints',{{}});
            
        end
        
    end
    
    methods (Static=true)
        
        varargout = help(varargin)
        varargout = parse(varargin)
        varargout = template(varargin)
        
    end
    
    methods (Static=true,Hidden=true)
        
        varargout = eq2func(varargin)
        
    end
    
end

