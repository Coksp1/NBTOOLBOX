classdef nb_distributionGUI < handle & nb_historyGUI
% Description:
%
% A class for interactivly edit a nb_distribution object
%
% Constructor:
%
%   gui = nb_distributionGUI(parent, distribution, varargin)
% 
%   Examples:
%
%   nb_distributionGUI([], [nb_distribution, nb_distribution],...
%                      'editable', [true false]);
% 
% See also: 
% nb_distribution
%
% Written by Henrik Halvorsen Hortemo and Kenneth Sæterhagen Paulsen    
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    properties
        
        distribution        = [];
        parent              = [];
        figureHandle        = [];
        nbFigureHandle      = [];
        resizeFigure        = 'off';
        
        % 1 x N logical array
        editable            = [];
        
        % 'pdf' or 'cdf'
        functionType        = 'pdf';
        
        incrementMode       = 'off';
        
        % 'kernel' or an integer. See nb_distribution.increment.
        incrementSmoothing  = 50;
        
    end
    
    properties (Access = public, Hidden = true)
        currentDistributionIndex = 1;
        
        graphPanel = [];
        momentsPanel = [];
        distributionPanel = [];
        domainPanel = [];
        buttonPanel = [];
        
        % Menu bar
        pdfMenuItem = [];
        cdfMenuItem = [];
        
        incrementEnableMenuItem = [];
        kernelSmoothingMenuItem = [];
        neighbourhoodSmoothingMenuItem = [];
        smoothingMenuItem = [];
        
        % Graph panel
        plotter = [];
        
        % Moments panel
        meanText = [];
        medianText = [];
        modeText = [];
        varianceText = [];
        stdText = [];
        skewnessText = [];
        kurtosisText = [];
        
        % Controls panel
        distributionMenu = [];
        paramLabels = {};
        paramBoxes = {};
        percentileLabel = [];
        percentileButton = [];
        domainLowerBox = [];
        domainUpperBox = [];
        meanShiftBox = [];
        
        % Buttons panel
        currentDistributionMenu = [];
        
        % Store perc2DistCDF options
        percentiles = [];
        values      = [];
        startD      = [];
        endD        = [];
        
        % Available distributions
        distributions = {...
            'ast','beta', 'cauchy', 'chis', 'constant', 'exp', 'f', 'fgamma',...
            'finvgamma', 'gamma', 'invgamma', 'kernel', 'logistic', ...
            'lognormal', 'normal', 't', 'uniform', 'wald'}; 
    end
    
    properties (Dependent)
        currentDistribution
    end
    
    properties (Dependent, Access = protected)
        currentEditable
        paramNames
    end
    
    events
        done
    end
    
    methods
        function gui = nb_distributionGUI(parent, distribution, varargin)
            
            % These variables will be logged for undo/redo functionality
            gui@nb_historyGUI({'distribution'});
            
            if nargin < 2
                distribution = nb_distribution();
                if nargin < 1
                    parent = [];
                end
            end
            
            gui.parent = parent;
            gui.distribution = distribution;
            gui.addToHistory();
            
            gui.editable = true(size(gui.distribution));
            
            gui.set(varargin{:});
            
            gui.makeGUI();
        end
        
        function set.distribution(gui, distribution)
            gui.distribution = nb_copy(distribution);
            % Disable increment mode if not kernel distribution
            if ~strcmpi(gui.currentDistribution.type, 'kernel') %#ok<MCSUP>
               gui.incrementMode = 'off';  %#ok<MCSUP>
            end
        end
        
        function set.currentDistributionIndex(gui, index)
            gui.currentDistributionIndex = index;
            % Disable increment mode if not kernel distribution
            if ~strcmpi(gui.currentDistribution.type, 'kernel') %#ok<MCSUP>
               gui.incrementMode = 'off';  %#ok<MCSUP>
            end
        end
        
        function d = get.currentDistribution(gui)
            d = gui.distribution(gui.currentDistributionIndex);
        end
        
        function e = get.currentEditable(gui)
            e = gui.editable(gui.currentDistributionIndex);
        end
        
        function set.currentDistribution(gui, distribution)
           gui.distribution(gui.currentDistributionIndex) = distribution; 
        end
        
        function set.resizeFigure(gui,property)
           gui.resizeFigure = property;
           set(gui.nbFigureHandle, 'resize', property); %#ok<MCSUP>
        end
        
        function set.incrementMode(gui, value)
            gui.incrementMode = value;
            if strcmpi(gui.incrementMode, 'on')
                if ~strcmpi(gui.currentDistribution.type, 'kernel') %#ok<MCSUP>
                    gui.currentDistribution.convert(); %#ok<MCSUP>
                    gui.addToHistory();
                end
            end
        end
        
        function paramNames = get.paramNames(gui)
            switch gui.currentDistribution.type
                case 'ast'
                    paramNames = {'Location', 'Scale','Skew','Left tail','Right tail'};
                case 'beta'
                    paramNames = {'alpha', 'beta'};
                case 'cauchy'
                	paramNames = {'Location', 'Scale'};
                case 'chis'
                	paramNames = {'Degrees of freedom'};
                case 'constant'
                	paramNames = {'Value'};
                case 'exp'
                	paramNames = {'Rate'};
                case 'f'
                	paramNames = {'d1', 'd2'};
                case {'gamma','fgamma','finvgamma','invgamma'}
                	paramNames = {'Shape', 'Scale'};
                case 'kernel'
                	paramNames = {};
                case 'logistic'
                	paramNames = {'Location', 'Scale'};
                case 'lognormal'
                	paramNames = {'Mean', 'Standard deviation'};
                case 'normal'
                	paramNames = {'Mean', 'Standard deviation'};
                case 't'
                	paramNames = {'Degrees of freedom'};
                case 'uniform'
                	paramNames = {'Lower', 'Upper'};
                case 'wald'
                	paramNames = {'Mean', 'Shape'};
                otherwise
                	paramNames = {};
            end
        end
    end

end
