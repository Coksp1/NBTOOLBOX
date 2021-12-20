classdef (Abstract) nb_model_estimate < matlab.mixin.Heterogeneous & nb_modelData
% Description:
%
% An abstract superclass for all model objects that can be estimated.
%
% See also:
% nb_model_generic, nb_judgemental_forecast
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    properties

        % A struct storing all the results of the estimation.
        results         = struct();
         
    end

    properties (SetAccess=protected,Hidden=false)
        
        % A struct with estimation options. Output from the estimator
        % function. E.g. nb_olsEstimator.estimate.
        estOptions      = struct();
        
    end
    
    properties (SetAccess=protected,Hidden=true)
        
        % A struct with temporary output
        tempOutput         = struct;
        
    end
    
    methods
        
        function s = saveobj(obj)
            s = struct(obj);
        end
        
        function dispOne(obj)
           
            if isempty(obj.name)
                nameOfObj = 'unnamed';
            else
                nameOfObj = obj.name; 
            end
            className = class(obj);
            disp([nb_createLinkToClass(obj,className), ' (' nameOfObj ') with:'])
            disp(['   <a href="matlab: nb_model_estimate.dispProperties(''' className ''')">properties</a>'])
            disp(['   <a href="matlab: nb_model_estimate.dispMethods(''' className ''')">methods</a>']);
            disp(' ')
            
        end
        
    end
    
    methods (Sealed=true)
        
        function disp(obj)
            
            disp([nb_createLinkToClass(obj,'nb_model_estimate') ' consisting of:']);
            disp(' ')
            obj = obj(:);
            for ii = 1:size(obj,1)
                dispOne(obj(ii));
            end
            
        end

        varargout = estimate(varargin);
        varargout = set(varargin);
        
    end
    
    methods (Access = protected)

        varargout = wrapUpEstimation(varargin);
        
    end
    
    methods(Sealed=true,Hidden=true)
        
        function obj = setEstOptions(obj,estOptions)
            obj.estOptions = estOptions;
        end
        
        function obj = setOptions(obj,options)
            obj.options = options;
        end
        
        function obj = setResults(obj,results)
            obj.results = results;
        end

    end

    methods(Hidden=true,Abstract=true)
        varargout = getEstimationOptions(varargin)
        obj       = setNames(obj,inputValue,type)
        obj       = setProps(obj,s);
    end
    
    methods (Static=true)
        
        varargout = unstruct(varargin)
        
        function obj = loadobj(s)
            obj = nb_model_estimate.unstruct(s);
        end
        
    end
    
    methods (Static=true,Hidden=true)
        
        varargout = estimateOneLoop(varargin);
        varargout = loopEstimate(varargin);
        
        function dispProperties(className)
            props = properties(className);
            props = sort(props);
            for ii = 1:length(props)
                disp(nb_createLinkToClassProperty(className,props{ii}));
            end
            disp(' ');
        end
        
        function dispMethods(className)
            meths = methods(className);
            meths = sort(meths);
            for ii = 1:length(meths)
                disp(nb_createLinkToClassProperty(className,meths{ii}));
            end
            disp(' ');
        end
        
        function [inp,others] = parseOptional(varargin)
            % Parse options during call to estimate method
            
            if length(varargin) == 1 && isstruct(varargin{1})
                inp    = varargin{1};
                others = {};
            else
                inp                      = struct('inGUI','off');
                others                   = varargin;
                [inp.parallel,others]    = nb_parseOneOptionalSingle('parallel',0,1,others{:});
                [inp.waitbar,others]     = nb_parseOneOptionalSingle('waitbar',0,1,others{:});
                [inp.write,others]       = nb_parseOneOptionalSingle('write',false,true,others{:});
                [inp.remove,others]      = nb_parseOneOptionalSingle('remove',false,true,others{:});
                [inp.cores,others]       = nb_parseOneOptional('cores',[],others{:});
                [inp.fileToWrite,others] = nb_parseOneOptional('fileToWrite','',others{:});
                [inp.inputs,others]      = nb_parseOneOptional('inputs',{},others{:});
            end
            
        end
        
    end
    
    methods (Static, Sealed, Access = protected)
        
        function default_object = getDefaultScalarElement
            default_object = nb_singleEq();
        end
        
    end
   
    
end
