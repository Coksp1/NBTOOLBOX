classdef nb_favar < nb_var & nb_factor_model_generic
% Description:
%
% A class for estimation and identification of FA-VAR models.
%
% Superclasses:
%
% nb_factor_model_generic, nb_var, nb_model_generic
%
% Constructor:
%
%   obj = nb_favar(varargin)
% 
%   Optional input:
%
%   - See the set method for more on the inputs. 
%     (nb_model_estimate.set)
% 
%   Output:
% 
%   - obj : An nb_favar object.
% 
% See also:
% nb_model_generic, nb_model_estimate.set
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    properties
        
        % A struct with the fields name, tex_name and number. The name 
        % field holds a cellstr with the names of all the variable(s) of 
        % the model observation equation, the tex_name holds the names in 
        % the tex format. The number field holds a double with the number 
        % of variables of the model observation equation. To set it use the 
        % set function. E.g. obj = set(obj,'observablesFast',...
        % {'Var1','Var2'}); or use the <className>.template() method.
        %
        % These are the variables that are included in the observation 
        % equation, but are not included in the estimation of the factors.
        observablesFast  = struct(); 

    end
    
    methods
        
        function obj = nb_favar(varargin)
        % Constructor

            obj                         = obj@nb_var();
            temp                        = nb_favar.template();
            temp                        = rmfield(temp,{'dependent','exogenous','observables','observablesFast'});
            obj.options                 = temp;
            temp                        = struct();
            temp.name                   = {};
            temp.tex_name               = {};
            temp.number                 = [];
            obj.observables             = temp;
            obj.observablesFast         = temp;
            obj.solution.identification = struct();
            obj                         = set(obj,varargin{:});
            
        end
        
    end
    
    methods (Hidden)
       
        function name = createName(obj)
            
            if ~isscalar(obj)
                error('This method only handle a scalar nb_model_name object.')
            end

            name = 'FAVAR';
            switch lower(obj.options.missingMethod)
                case 'forecast'
                    name = [name ,'_F'];
                case 'kalmanfilter'
                    name = [name ,'_KF'];
            end
            if isempty(obj.options.modelSelection)
                name = [name ,'_L' int2str(obj.options.nLags)];
            else
                name = [name ,'_AL'];
            end
            NF   = nb_conditional(isempty(obj.options.nFactors),0,obj.options.nFactors);
            name = [name ,'_NF', int2str(NF)];
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
                firstDim   = [opt.exogenous,opt.factorsRHS];
                if opt.constant && opt.time_trend
                    firstDim = [{'Constant','Time Trend'},firstDim{:}];
                elseif opt.constant
                    firstDim = [{'Constant'},firstDim{:}];
                elseif opt.time_trend
                    firstDim = [{'Time Trend'},firstDim{:}];
                else
                    firstDim = [{},firstDim{:}];
                end
                secDim = [opt.dependent,opt.factors]';
                pName  = nb_strcomb(secDim,firstDim');
                pVal   = reshape(obj.results.beta,[s1*s2,1,s3]);
                
                % Get the parameter names and values of the covariance
                % matrix of the VAR
                [s1,s2,s3] = size(obj.results.sigma);
                pName2     = strcat('cov_',nb_strcomb(secDim,secDim));
                pVal2      = reshape(obj.results.sigma,[s1*s2,1,s3]);
                pName      = [pName;pName2];
                pVal       = [pVal;pVal2];
                
                % Get the parameter names and values of the observation eq
                [s1,s2,s3] = size(obj.results.lambda);
                if isempty(opt.observablesFast)
                    firstDim = ['constant',opt.factors,opt.dependent];
                else
                    firstDim = ['constant',opt.factors];
                end
                secDim = opt.observables';
                if isfield(opt,'observablesFast')
                    secDim = [secDim;opt.observablesFast'];
                end
                pName3 = nb_strcomb(secDim,firstDim');
                pVal3  = reshape(obj.results.lambda,[s1*s2,1,s3]);
                pName  = [pName;pName3];
                pVal   = [pVal;pVal3];
                
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

