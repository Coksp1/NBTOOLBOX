classdef nb_mfvar < nb_var & nb_calculate_generic
% Description:
%
% A class for estimation and identification of mixed frequency VAR models.
%
% Superclasses:
%
% nb_var, nb_model_generic, nb_calculate_generic
%
% Constructor:
%
%   obj = nb_mfvar(varargin)
% 
%   Optional input:
%
%   - See the set method for more on the inputs. 
%     (nb_model_estimate.set)
% 
%   Output:
% 
%   - obj : A nb_mfvar object.
% 
% See also:
% nb_model_generic, nb_model_estimate.set, nb_mfvar.template
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    methods
        
        function obj = nb_mfvar(varargin)
        % Constructor

            obj                         = obj@nb_var();
            temp                        = nb_mfvar.template();
            temp                        = rmfield(temp,{'dependent','exogenous','frequency','mapping','mixing'});
            obj.options                 = temp;
            obj.solution.identification = struct();
            
            % The frequency of each series
            obj.dependent.frequency       = {};
            obj.block_exogenous.frequency = {};
            obj.exogenous.frequency       = {};
            
            % The mapping of each series
            obj.dependent.mapping       = {};
            obj.block_exogenous.mapping = {};
            obj.exogenous.mapping       = {};
            
            % The mixing of each series
            obj.dependent.mixing       = {};
            obj.block_exogenous.mixing = {};
            obj.exogenous.mixing       = {};
            
            obj = set(obj,varargin{:});
            
            if ~nb_isempty(obj.options.prior)
                if strcmpi(obj.options.prior.type,'kkse')
                    obj.options.estim_method = 'tvpmfsv';
                else
                    obj.options.estim_method = 'bVar';
                end
            else
                obj.options.estim_method = 'ml';
            end
            
        end
        
    end
    
    methods (Hidden)
       
        function name = createName(obj)
            
            if ~isscalar(obj)
                error('This method only handle a scalar nb_model_name object.')
            end
            if ~nb_isempty(obj.options.prior)
                if obj.options.empirical
                    name = 'EMP_B_MF_VAR';
                else
                    name = 'B_MF_VAR';
                end
            else
                name = 'ML_MF_VAR';
            end
            if ~all(cellfun(@isempty,obj.dependent.mixing))
                name = [name ,'_MIX'];
            end
            if any(cellfun(@iscell,obj.dependent.frequency))
                name = [name ,'_CF'];
            end
            name = [name ,'_V' int2str(nb_conditional(isempty(obj.dependent.number), 0, obj.dependent.number))];
            name = [name ,'_L' int2str(obj.options.nLags)];
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
                firstDim   = [opt.exogenous,nb_cellstrlag(opt.dependent,opt.nLags)];
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
                % matrix of the VAR
                [s1,s2,s3] = size(obj.results.sigma);
                pName2     = strcat('cov_',nb_strcomb(secDim,secDim));
                pVal2      = reshape(obj.results.sigma,[s1*s2,1,s3]);
                pName      = [pName;pName2];
                pVal       = [pVal;pVal2];
                
                param = struct('name',{pName},'value',pVal);
                
            end
            
        end
          
    end
    
    methods(Static=true)
        
        varargout = constructScoreLowFreq(varargin)
        varargout = getFrequencyStatic(varargin)
        varargout = help(varargin)
        varargout = priorHelp(varargin)
        varargout = priorTemplate(varargin)
        varargout = solveNormal(varargin)
        varargout = solveRecursive(varargin)
        varargout = stateSpace(varargin)
        varargout = template(varargin)
        
    end
         
end

