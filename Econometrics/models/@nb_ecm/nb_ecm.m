classdef nb_ecm < nb_model_generic
% Description:
%
% A class for estimation of error correction models.
%
% Superclasses:
%
% nb_model_generic
%
% Constructor:
%
%   obj = nb_ecm(varargin)
% 
%   Optional input:
%
%   - See the set method for more on the inputs. 
%     (nb_model_estimate.set)
% 
%   Output:
% 
%   - obj : An nb_ecm object.
% 
% See also:
% nb_model_generic, nb_model_estimate.set, nb_ecm.help, nb_ecm.template
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    properties
        
        
        
    end
    
    methods
        
        function obj = nb_ecm(varargin)
        % Constructor

            obj         = obj@nb_model_generic();
            temp        = nb_ecm.template();
            temp        = rmfield(temp,{'dependent','endogenous','exogenous'});
            obj.options = temp;
            obj         = set(obj,varargin{:});
            
        end
        
    end
    
    methods (Hidden)
       
        function name = createName(obj)
            
            if ~isscalar(obj)
                error('This method only handle a scalar nb_model_name object.')
            end
            name = 'ECM';
            if ~isempty(obj.options.modelSelection)
                name = [name ,'_MS'];
            end
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
                
                % Get the parameter names and values of the ecm
                opt = obj.estOptions(end);
                [pName,pVal] = getParamOneEq([],[],obj.results,opt);
                param = struct('name',{pName},'value',pVal);
                
            end
            
            function [pName,pVal] = getParamOneEq(pName,pVal,results,opt)
                
                % Get the parameter names and values of the single eq
                [s1,s2,s3] = size(results.beta);
                firstDim   = [opt.exogenous,opt.rhs];
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
        varargout = solveNormal(varargin)
        varargout = solveRecursive(varargin)       
    end
    
end
