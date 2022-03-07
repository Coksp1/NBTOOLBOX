classdef nb_exprModel < nb_model_generic
% Description:
%
% A class for estimation a model where each variable is allowed to be
% an expression of different variables, e.g.
%
% diff(y(t)) = beta(1)*diff(x(t)) + beta(2)*(log(y(t-1)) - log(x(t-1)))
%
% Superclasses:
%
% nb_model_generic
%
% Constructor:
%
%   obj = nb_exprModel(varargin)
% 
%   Optional input:
%
%   - See the set method for more on the inputs. 
%     (nb_model_estimate.set)
% 
%   Output:
% 
%   - obj : An nb_exprModel object.
% 
% See also:
% nb_model_generic, nb_model_estimate.set
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    properties
        
        
        
    end
    
    methods
        
        function obj = nb_exprModel(varargin)
        % Constructor

            obj         = obj@nb_model_generic();
            temp        = nb_exprModel.template();
            temp        = rmfield(temp,{'dependent','exogenous'});
            obj.options = temp;
            obj         = set(obj,varargin{:});
            
        end
        
    end
    
    methods (Hidden)
       
        function name = createName(obj)
            
            if ~isscalar(obj)
                error('This method only handle a scalar nb_model_name object.')
            end
            name = 'EXPR_MODEL';
            if ~isempty(obj.options.rollingWindow)
                name = [name ,'_RW' int2str(obj.options.rollingWindow)];
            end
            
        end
        
    end
    
    methods(Access=protected)
       
        function param = getParametersNames(obj)
            
            % Construct the coeff names
            if nb_isempty(obj.estOptions)
                param = struct('name',{{}},'value',[]);
            else
                % Get the parameter names and values
                [pName,pVal] = getParamOneEq([],[],obj.results,obj.estOptions(end));
                param = struct('name',{pName},'value',pVal);
            end
            
            function [pName,pVal] = getParamOneEq(pName,pVal,results,opt)
                
                % Get the parameter names and values of the single eq
                [s1,s2,s3] = size(results.beta);
                firstDim   = opt.exogenous;
                if opt.constant && opt.time_trend
                    firstDim = [{'Constant','Time Trend'},firstDim{:}];
                elseif opt.constant
                    firstDim = [{'Constant'},firstDim{:}];
                elseif opt.time_trend
                    firstDim = [{'Time Trend'},firstDim{:}];
                else
                    firstDim = [{},firstDim{:}];
                end
                secDim = opt.dependent';
                pNameT = nb_strcomb(secDim,firstDim');
                pValT  = reshape(results.beta,[s1*s2,1,s3]);
                pName  = [pName;pNameT];
                pVal   = [pVal;pValT];
                
                % Get the parameter names and values of the covariance
                % matrix of the VAR
                [s1,s2,s3] = size(results.sigma);
                pNameT     = strcat('cov_',nb_strcomb(secDim,secDim));
                pValT      = reshape(results.sigma,[s1*s2,1,s3]);
                pName      = [pName;pNameT];
                pVal       = [pVal;pValT];
                 
            end
            
        end
        
    end
    
    methods(Static=true)  
        varargout = template(varargin)
        varargout = help(varargin)
        varargout = solutionFunc(varargin)
        varargout = solveNormal(varargin)
        varargout = solveRecursive(varargin)
    end
    
end

