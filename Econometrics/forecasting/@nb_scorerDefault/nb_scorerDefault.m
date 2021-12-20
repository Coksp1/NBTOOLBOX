classdef nb_scorerDefault < nb_scorerTimeDependent
% Description:
%
% A class for constructing scores based on evaluation results.
%
% Superclasses:
%
% nb_scorerTimeDependent, nb_scorer, nb_settableValueClass
%
% Constructor:
%
%   obj = nb_scorerDefault(varargin);
%
%   Input:
%
%   - varargin : Inputs given to the set method.
%
%   Output:
%
%   - obj      : An object of class nb_scorerDefault.
% 
% See also:
% nb_model_group_vintages.constructWeights,
% nb_model_forecast_vintages.getScore
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen    
    
    properties
        
        % false or true. Default is false, which means to report the score 
        % so that high value means a good model. For weighting the invert 
        % option must be set to false. See the documentation of scoreType
        % for a list of the score types in it non-inverted version. 
        invert          = false;
        
        % Give the value of the parameter of the exponential decaying 
        % weights on past forecast errors when constructing the score. 
        % If empty the weights on all  past forecast errors are equal.
        % 0 < lambda < 1, or empty (no decaying).
        lambda          = [];
        
        % A string with one of the following;  
        % - 'RMSE'  : One over root mean squared error.
        % - 'MSE'   : One over mean squared error.
        % - 'SMSE'  : One over squared mean squared error.
        % - 'RMAE'  : One over root mean absolute error.
        % - 'MAE'   : One over mean absolute error.
        % - 'SMAE'  : One over squared mean absolute error.
        % - 'ME'    : Mean error.
        % - 'STD'   : One over Standard error of the forecast 
        %             error.
        % - 'ESLS'  : Exponential of the sum of the log scores.
        % - 'EELS'  : Exponential of the mean of the log scores.
        % - 'MLS'   : Mean log score.
        %
        % Caution: See comment to the invert input!
        scoreType       = 'RMSE';
        
    end
    
    methods
        
        function obj = nb_scorerDefault(varargin)
            if nargin < 1
                return
            end
            obj = set(obj,varargin{:});
        end
        
        function obj = set.invert(obj,value)
            if ~nb_isScalarLogical(value)
                error([mfilename ':: The invert property must be set to a scalar integer.'])
            end
            obj.invert = value;
        end
        
        function obj = set.lambda(obj,value)
            if isempty(value)
                obj.lambda = [];
                return
            end
            if ~nb_isScalarNumber(value,0,1)
                error([mfilename ':: The lambda property must be set to a scalar number strictly between 0 and 1.'])
            end
            obj.lambda = value;
        end
        
        function obj = set.scoreType(obj,value)
            if ~nb_isOneLineChar(value)
                error([mfilename ':: The scoreType property must be set to a one line char.'])
            end
            supported = {'EELS','ESLS','MAE','ME','MLS','MSE','RMAE','RMSE','STD','equal','SMSE','SMAE'};
            if ~any(strcmpi(value,supported))
                error([mfilename ':: The scoreType property must be set to a prover score type. ' ...
                    value ' is not supported.'])
            end
            obj.scoreType = upper(value);
        end
          
        function ret = doInvertDuringScore(obj)
            
            scoresToInvert = {'RMSE','MSE','SMSE','RMAE','MAE','SMAE','STD'};
            ret            = any(strcmpi(obj.scoreType,scoresToInvert));
            
        end
        
        function s = struct(obj)
            s           = struct@nb_scorerTimeDependent(obj);
            s.class     = 'nb_scorerDefault';
            s.invert    = obj.invert;   
            s.lambda    = obj.lambda; 
            s.scoreType = obj.scoreType; 
        end
        
    end
    
    methods (Static=true)
        
        varargout = constructScore(varargin);
    
        function obj = unstruct(s)
        % Syntax:
        %
        % obj = nb_scorerDefault.unstruct(s)
        %
        % Description:
        %
        % Convert struct to a object.
        %
        % Written by Kenneth Sæterhagen Paulsen
        
            obj = nb_scorer.unstruct(s);
        
        end
        
    end
    
    methods (Access=protected)
    
        varargout = doFinalScore(varargin);
        varargout = doRecursiveScore(varargin);
        
    end
    
end

