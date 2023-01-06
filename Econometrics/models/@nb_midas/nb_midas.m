classdef nb_midas < nb_model_generic
% Description:
%
% A class for estimation of MIDAS (MIxed frequency DAta Sampling) models.
%
% y(tq+hq) = lambda*y(tq) + F(x(tm),x(tm-1),...,p) + e
%
% Where x(tm) are lagged exogneous variables of the model at high 
% frequency, and y is the dependent variable of the model.
%
% Superclasses:
%
% nb_model_generic
%
% Constructor:
%
%   obj = nb_midas(varargin)
% 
%   Optional input:
%
%   - See the set method for more on the inputs. 
%     (nb_model_estimate.set)
% 
%   Output:
% 
%   - obj : An nb_midas object.
% 
% See also:
% nb_model_generic, nb_model_estimate.set, nb_midas.help, nb_midas.template
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    properties
        
        
        
    end
    
    methods
        
        function obj = nb_midas(varargin)
        % Constructor

            obj         = obj@nb_model_generic();
            temp        = nb_midas.template();
            temp        = rmfield(temp,{'dependent','exogenous','frequency'});
            obj.options = temp;
            
            % The frequency of each series
            obj.dependent.frequency = {};
            obj.exogenous.frequency = {};
            
            obj = set(obj,varargin{:});
            
        end
        
    end
    
    methods (Hidden)
       
        function name = createName(obj)
            
            if ~isscalar(obj)
                error('This method only handle a scalar nb_model_name object.')
            end
            switch lower(obj.options.algorithm)
                case 'unrestricted'
                    algo = 'UN';
                otherwise
                    algo = upper(obj.options.algorithm);
            end
            name = ['MIDAS_' algo];
            if obj.options.AR
                name = [name '_AR'];
            end
            name = [name ,'_FREQ' int2str(obj.dependent.frequency{1})];
            name = [name ,'_L' int2str(obj.options.nLags)];
            NX   = nb_conditional(isempty(obj.exogenous.number),0,obj.exogenous.number) +...
                   nb_conditional(isempty(obj.endogenous.number),0,obj.endogenous.number) +...
                   obj.options.constant;
            name = [name ,'_NX' int2str(NX)];
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
                
                % Get the parameter names and values of the single eq
                [pName,pVal] = getParamOneEq([],[],obj.results,obj.estOptions(end));
                param        = struct('name',{pName},'value',pVal);
                
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
                % matrix of the MIDAS
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

