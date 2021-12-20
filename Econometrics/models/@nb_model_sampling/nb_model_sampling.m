classdef (Abstract) nb_model_sampling
% Description:
%
% An abstract superclass for all model objects that can be sampled.
%
% See also:
% nb_model_generic, nb_dsge
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    properties (Dependent=true,SetAccess=protected)
        
        % The path to located the posterior sampling results.
        % Use nb_loadDraws to return a struct with the posterior
        % sampling options and output.
        posteriorPath   = '';
        
    end

    properties (SetAccess=protected)
        
        % The path to located the updated priors sampling results.
        % Use nb_loadDraws to return the output struct of the given
        % sampler.
        systemPriorPath = ''; 
        
    end
    
    methods
       
        function propertyValue = get.posteriorPath(obj)
            
            try
                propertyValue = obj.estOptions.pathToSave;
            catch
                propertyValue = '';
            end
            
        end
        
    end
    
    methods (Hidden=true)
       
        function obj = setSystemPriorPath(obj,value)
            obj.systemPriorPath = value;
        end
        
    end
    
    methods(Sealed=true)
        varargout = meanPlot(varargin);
        varargout = gelmanRubin(varargin);
        varargout = geweke(varargin);
        varargout = isSampled(varargin);
        varargout = sample(varargin);
        varargout = sampleSystemPrior(varargin);
        varargout = tracePlot(varargin);
    end

    methods(Hidden=true,Abstract=true)
        
    end
    
    methods(Static=true,Hidden=true)
       
    end
    
end
