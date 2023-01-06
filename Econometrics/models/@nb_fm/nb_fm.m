classdef nb_fm < nb_model_generic & nb_factor_model_generic
% Description:
%
% A class for estimation single equation factor model.
%
% y_t = beta*F_t + beta0*X_t + e_t
%
% Superclasses:
%
% nb_factor_model_generic, nb_model_generic
%
% Constructor:
%
%   obj = nb_fm(varargin)
% 
%   Optional input:
%
%   - See the set method for more on the inputs. 
%     (nb_model_estimate.set)
% 
%   Output:
% 
%   - obj : An nb_fm object.
% 
% See also:
% nb_model_generic, nb_model_estimate.set
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    methods
        
        function obj = nb_fm(varargin)
        % Constructor

            obj             = obj@nb_model_generic();
            temp            = nb_fm.template();
            temp            = rmfield(temp,{'dependent','exogenous','observables'});
            obj.options     = temp;
            temp            = struct();
            temp.name       = {};
            temp.tex_name   = {};
            temp.number     = [];
            obj.observables = temp;
            obj             = set(obj,varargin{:});
            
        end
        
    end

    methods (Hidden)
       
        function name = createName(obj)
            
            if ~isscalar(obj)
                error('This method only handle a scalar nb_model_name object.')
            end
            name = 'FM';
            if ~isempty(obj.options.modelSelection)
                name = [name ,'_MS'];
            end
            NF   = nb_conditional(isempty(obj.options.nFactors),0,obj.options.nFactors);
            name = [name ,'_NF', int2str(NF)];
            if obj.options.unbalanced
                name = [name, 'UNBAL'];
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
                
                opt = obj.estOptions(end);
                
                % Get the parameter names and values of the VAR
                [s1,s2,s3] = size(obj.results.beta);
                firstDim   = opt.factorsRHS;
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
                pName  = nb_strcomb(secDim,firstDim');
                pVal   = reshape(obj.results.beta,[s1*s2,1,s3]);
                
                % Get the parameter names and values of the covariance
                % matrix
                [s1,s2,s3] = size(obj.results.sigma);
                pName2     = strcat('cov_',nb_strcomb(secDim,secDim));
                pVal2      = reshape(obj.results.sigma,[s1*s2,1,s3]);
                pName      = [pName;pName2];
                pVal       = [pVal;pVal2];
                
                % Get the parameter names and values of the observation eq
                [s1,s2,s3] = size(obj.results.lambda);
                firstDim   = ['constant',opt.factors]';
                secDim     = opt.observables';
                pName3     = nb_strcomb(secDim,firstDim);
                pVal3      = reshape(obj.results.lambda,[s1*s2,1,s3]);
                pName      = [pName;pName3];
                pVal       = [pVal;pVal3];
                
                % Get the parameter names and values of the covariance
                % matrix of the observation equation
                [s1,s2,s3] = size(obj.results.R);
                pName4     = strcat('cov_',nb_strcomb(secDim,secDim));
                pVal4      = reshape(obj.results.R,[s1*s2,1,s3]);
                pName      = [pName;pName4];
                pVal       = [pVal;pVal4];
                
                param = struct('name',{pName},'value',pVal);
                
            end
            
        end
        
    end
    
    methods(Static=true)
        
        varargout = solveNormal(varargin)
        
        varargout = solveRecursive(varargin)
        
        varargout = template(varargin)
        
        varargout = priorTemplate(varargin)
        
        varargout = help(varargin)
        
    end
         
end

