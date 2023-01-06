classdef nb_rw < nb_model_generic
% Description:
%
% A class for estimation of random walk models.
%
% Superclasses:
%
% nb_model_generic
%
% Constructor:
%
%   obj = nb_rw(varargin)
% 
%   Optional input:
%
%   - See the set method for more on the inputs. 
%     (nb_model_estimate.set)
% 
%   Output:
% 
%   - obj : An nb_rw object.
% 
% See also:
% nb_model_generic, nb_model_estimate.set
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    methods
        
        function obj = nb_rw(varargin)
        % Constructor

            obj            = obj@nb_model_generic();
            temp           = nb_rw.template();
            temp           = rmfield(temp,{'dependent','exogenous'});
            obj.options    = temp;
            obj            = set(obj,varargin{:});
            
        end
        
    end
    
    methods(Access=protected)
       
        function param = getParametersNames(obj)
            
            if nb_isempty(obj.estOptions)
                param = struct('name',{{}},'value',[]);
            else
                pName = nb_rwEstimator.getCoeff(obj.estOptions(end));
                param = struct('name',{pName},'value',obj.results.beta);
            end
            
        end
        
    end
    
    methods (Hidden)
       
        function name = createName(obj)
            
            if ~isscalar(obj)
                error('This method only handle a scalar nb_model_name object.')
            end
            name = 'RandomWalk';
            if ~isempty(obj.options.rollingWindow)
                name = [name ,'_RW' int2str(obj.options.rollingWindow)];
            end
            
        end
        
    end
    
    methods(Static=true)
        
        varargout = template(varargin)
        varargout = help(varargin)
        varargout = solveNormal(varargin)
        varargout = solveRecursive(varargin)
        varargout = solveRW(varargin)
        
    end
    
end

