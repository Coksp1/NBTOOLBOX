classdef nb_singleEq < nb_model_generic
% Description:
%
% A class for estimation of single equation models.
%
% Superclasses:
%
% nb_model_generic
%
% Constructor:
%
%   obj = nb_singleEq(varargin)
% 
%   Optional input:
%
%   - See the set method for more on the inputs. 
%     (nb_model_estimate.set)
% 
%   Output:
% 
%   - obj : An nb_singleEq object.
% 
% See also:
% nb_model_generic, nb_model_estimate.set
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    properties
        
        
        
    end
    
    methods
        
        function obj = nb_singleEq(varargin)
        % Constructor

            obj         = obj@nb_model_generic();
            temp        = nb_singleEq.template();
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
            name = ['EQ_' upper(obj.options.estim_method)];
            if ~isempty(obj.options.modelSelection)
                name = [name ,'_MS'];
            end
            NX   = nb_conditional(isempty(obj.exogenous.number),0,obj.exogenous.number) +...
                   nb_conditional(isempty(obj.endogenous.number),0,obj.endogenous.number) +...
                   obj.options.constant + obj.options.time_trend;
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
                
                opt = obj.estOptions(end);
                res = obj.results;
                
                % Get the parameter names and values of the single eq
                if strcmpi(opt.estimator,'nb_tslsEstimator')
                
                    [pName,pVal] = getParamOneEq([],[],res.mainEq,opt.mainEq);
                    fst          = rmfield(res,'mainEq');
                    fields       = fieldnames(fst);
                    for ii = 1:length(fields)
                        fstRes       = fst.(fields{ii});
                        fstOpt       = opt.(fields{ii});
                        [pName,pVal] = getParamOneEq(pName,pVal,fstRes,fstOpt);
                    end
                    
                else
                    [pName,pVal] = getParamOneEq([],[],obj.results,opt);
                end
                
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
        
        varargout = solveNormal(varargin)
        
        varargout = solveOLSEq(varargin)
        
        varargout = solveRecursive(varargin)
        
        varargout = solveStepAhead(varargin)
        
        varargout = solveTSLSEq(varargin)
        
        varargout = solveTSLSEqRecursiv(varargin)
        
    end
    
end

