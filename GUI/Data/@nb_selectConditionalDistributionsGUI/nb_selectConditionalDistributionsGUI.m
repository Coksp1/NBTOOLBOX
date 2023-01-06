classdef nb_selectConditionalDistributionsGUI < handle & nb_historyGUI
% Description:
%
% A GUI class for selecting distributions to condition on.
%
% Constructor:
%
%   obj = nb_selectConditionalDistributionsGUI(dates, variables)
% 
%   Input:
%
%   - dates         : Cell array of date strings
% 
%   - variables     : Cell array of variable names
%
%   - distributions : A matrix of nb_distribution objects. Must match the 
%                     dates and variables property. Defualt is to produce
%                     a matrix that fit dates and variables, and assume
%                     that all elments are N(0,1).
%
%   Output:
% 
%   - obj      : An object of class nb_selectConditionalDistributionsGUI
% 
% Examples:
%   obj = nb_selectConditionalDistributionsGUI({'2010', '2011'}, ...
%                                              {'Var1', 'Var2'});
%
% Written by Henrik Halvorsen Hortemo and Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    properties
        
        % Cell array of date strings
        dates         = {};
        
        % Initial period to use to keep the autocorrelation with history
        initPeriods   = 0;
        
        % Cell array of variable names
        variables     = {};
        
        % length(dates) x length(variables) nb_distribution matrix
        distributions = nb_distribution();
        
        % A nb_model_genric object, needed for copula settings
        model         = [];
        
        % When using conditional information in terms of densities
        % on both shocks and (some) endogenous variables we must
        % restrict some of the (other) endogenous variables after
        % simulating draws using the conditional information
        % on the shocks only. This is to make the draws from the
        % conditional information of the endogenous variables
        % in sync with that of the shocks. Must be a 1xN cellstr,
        % where N is the (max) number shocks to condition on at
        % any period.
        restrictedVariables
        
        % The covariance matrix used for copula draws.
        sigma         = [];
        
    end
    
    properties (Access=protected)
        
        % Copied stuff
        copied = [];
        copiedLimits = {'lower',[],'upper',[]};
        
        % Selected cells
        selectedCells
        
        % Loaded distribution
        loaded = [];
        
        % Graphic handles
        covarianceOption        = [];
        lagsOption              = [];
        initPeriodsOption       = [];
        figureHandle            = [];
        figureHandle2           = [];
        tableHandle             = [];
        tableHandle2            = [];
        datePopMenu             = [];
        variablePopMenu         = [];
        meanShiftRadiobutton    = []
        datesListBox            = [];
        variablesListBox        = [];
        
    end
    
    methods
        function gui = nb_selectConditionalDistributionsGUI(dates, variables, distributions, model, sigma, initPeriods, restrictedVariables)
            
            % These variables will be logged for undo/redo functionality
            gui@nb_historyGUI({'dates', 'variables', 'distributions', 'model', 'sigma'});
            
            if nargin < 7
                restrictedVariables = {};
                if nargin < 6
                    initPeriods = 0;
                    if nargin < 5
                        sigma = [];
                        if nargin < 4
                            model = [];
                            if nargin<3
                                distributions = [];
                            end
                        end
                    end
                end
            end
            
            if isempty(distributions)
                dists(length(dates), length(variables)) = nb_distribution();
            else
                dists = distributions;
                if size(dists,1) ~= length(dates)
                    error([mfilename ':: Dimension 1 of the distributions input must match the dates input.'])
                end
                if size(dists,2) ~= length(variables)
                    error([mfilename ':: Dimension 2 of the distributions input must match the variables input.'])
                end
            end
            
            gui.dates               = dates;
            gui.variables           = variables;
            gui.distributions       = dists; 
            gui.model               = model;
            gui.sigma               = sigma;
            gui.initPeriods         = initPeriods;
            gui.restrictedVariables = restrictedVariables;
            
            gui.makeGUI();
            
        end
    end
    
    methods (Static=true)
        
        varargout = constructSigma(varargin);
        
    end

end
