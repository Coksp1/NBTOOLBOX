classdef (Abstract) nb_model_generic < nb_model_forecast & nb_model_estimate
% Description:
%
% An abstract superclass of all model classes that is both estimated and 
% forecasted.
%
% Constructor:
%
%   No constructor exist. This class is abstract.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    properties (Dependent=true)
        
        % A struct with the parameter names of the model stored at the
        % field name, and the parameter value stored at the field value.
        % See also the getParameters method. 
        parameters
        
        % A struct with the fields name, tex_name and number. The name 
        % field holds a cellstr with the names of all the residuals, 
        % the tex_name holds the names in the tex format. The number 
        % field holds a double with the number of residuals. Cannot  
        % be set. Model must be solved for this proeprty to be up to date!
        %
        % Caution: For nb_dsge models the residuals and exogenous property 
        %          stores the same variables (after the model being 
        %          solved)!
        residuals
        
    end

    properties
       
        % Adds the posibility to add user data. Can be of any type
        userData        = '';
        
    end
    
    properties(SetAccess=protected)
        
        % A struct with the fields name, tex_name and number. The name 
        % field holds a cellstr with the names of all the dependent 
        % variables, the tex_name holds the names in the tex format. The 
        % number field holds a double with the number of dependent 
        % variables. To set it use the set function. E.g. obj = 
        % set(obj,'dependent',{'Var1','Var2'}); or use the 
        % <className>.template() method.
        %
        % Caution: For nb_dsge models this property stores the variables
        %          declared as endogenous in the model file, and will be
        %          the same as the endogenous property.
        dependent       = struct();
        
        % A struct with the fields name, tex_name and number. The name 
        % field holds a cellstr with the names of all the endogenous 
        % variables, the tex_name holds the names in the tex format. The 
        % number field holds a double with the number of endogenous 
        % variables. To set it use the set function. E.g. obj = 
        % set(obj,'endogenous',{'Var1','Var2'}); or use the 
        % <className>.template() method. 
        endogenous      = struct();
        
        % A struct with the fields name, tex_name and number. The name 
        % field holds a cellstr with the names of all the exogenous 
        % variables, the tex_name holds the names in the tex format. The 
        % number field holds a double with the number of exogenous 
        % variables. To set it use the set function. E.g. obj = 
        % set(obj,'exogenous',{'Var1','Var2'}); or use the 
        % <className>.template() method.
        %
        % Caution: For nb_dsge models the residuals and exogenous property 
        %          stores the same variables (after the model being 
        %          solved)!
        exogenous       = struct();
        
        % A struct storing the companion form of the model.
        %
        % Y_t = A*Y_t_1 + B*X_t + C*e_t, e ~ N(0,vcv)
        %
        % Observation equation (Factor models only):
        %
        % O_t = F*X_t + G*Y_t + u_t, u ~ N(0,R)
        %
        % Observation equation (ARIMA models only):
        %
        % X_t = G*Z_t + Y_t
        %
        % Fields:
        %
        % - A     : See the equation above. A nendo x nendo double.
        %
        % - B     : See the equation above. A nendo x nexo double.
        %
        % - C     : See the equation above. A nendo x nres 
        %           double.
        %
        % - endo  : A 1 x nendo cellstr with the decleared endogenous  
        %           variables.
        %
        % - exo   : A 1 x nexo cellstr with the decleared exogenous 
        %           variables.
        %
        % - res   : A 1 x nres cellstr with the decleared 
        %           residuals/shocks.
        %
        % - vcv   : Variance/covariance matrix of the 
        %           residuals/shocks. As a nres x nres double.
        %
        % - class : The name of the model class.
        %
        % Factor models and ARIMA models (only):
        %
        % - factors     : A 1 x nfact cellstr with the estimated  
        %                 factors and/or exogenous variables of the 
        %                 measurement equation.
        %
        % - F           : See the equation above. A nobs x nExo double. 
        %                 (Storing the impact of exogenous terms of the  
        %                 observation equation)
        %
        % - G           : See the equation above. A nobs x nfact double.
        %                 
        % - observables : A 1 x nobs cellstr with the decleared   
        %                 observable variables.
        %
        % - R           : Variance/covariance matrix of the 
        %                 residuals/shocks of the observation equation. 
        %                 As a nobs x nobs double. If not provided, it is
        %                 assumed to be 0.
        %
        % DSGE:
        %
        % - ss          : A nendo x 1 double with the steady-state of the 
        %                 model.
        %
        % - jacobian    : A neq x (nforward + nendo + nbackward + nres )
        %                 sparse double storing the jacobian of the model.
        %
        % - jacobianType: A 1 x (nforward + nendo + nbackward + nres )
        %                 indicating the type of each column of the
        %                 jacobian. 1 indicate leaded variables, 0 current
        %                 period variables, -1 indicate lagged variables,
        %                 and 2 indicate residuals (innovations).
        %
        % DSGE (with break-points):
        %
        % In this case the fields A, B, C and ss are all cell arrays with
        % size 1 x nbreaks. Each element has the size in the standard case.
        solution        = struct();
        
    end
    
    properties (Access=protected)
       
        % Property storing the tex names of the residuals.
        res_tex_names = {};
        
    end
   
    methods 
        
        function obj = nb_model_generic()
        % Constructor
        
            % Create identifier for this object
            obj.identifier = nb_model_name.findIdentifier();
        
            % Setup the model variables structures
            temp           = struct();
            temp.name      = {};
            temp.tex_name  = {};
            temp.number    = [];
            obj.dependent  = temp;
            obj.endogenous = temp;
            obj.exogenous  = temp;
            
        end
        
        function obj = solve(obj); end
        
        function param = get.parameters(obj) 
        
            param = getParametersNames(obj);
        
        end
        
        function residuals = get.residuals(obj) 

            if ~isfield(obj.solution,'res')
                residuals = struct('name',{{}},'tex_name',{{}},'number',[]);
            else
                if isempty(obj.res_tex_names)
                    obj.res_tex_names = strrep(obj.solution.res,'_','\_');
                elseif length(obj.res_tex_names) ~= length(obj.solution.res)
                    obj.res_tex_names = strrep(obj.solution.res,'_','\_');
                end
                residuals = struct('name',{obj.solution.res},'tex_name',{obj.res_tex_names},'number',length(obj.solution.res));
            end
            
        end
        
        function obj = setSolution(obj,solution)
            obj.solution = solution;
        end
        
        varargout = getHistory(varargin)
         
    end
    
    methods (Hidden=true)
        
        varargout = correctSolutionDuringRT(varargin)
        
        function tempObj = setNames(tempObj,inputValue,type)

            if isempty(inputValue)

               vars     = {};
               texVars  = {};
               block_id = [];

            else

                if strcmpi(type,'block_exogenous')

                    if ~iscellstr(inputValue)
                        inputValueT = nb_nestedCell2Cell(inputValue);
                        block_id    = nan(1,length(inputValueT));
                        for jj = 1:length(inputValue)
                            temp          = inputValue{jj};
                            ind           = ismember(inputValueT,temp);
                            block_id(ind) = jj;
                        end
                        inputValue = inputValueT;
                    else
                        block_id = ones(1,length(inputValue));
                    end

                else
                    if ~iscellstr(inputValue)
                        if isa(tempObj,'nb_exprModel')
                            if ~iscell(inputValue)
                                error(['The ' type ' option cannot be set to an object of class ' class(inputValue)])
                            end
                            inputValueT = nb_nestedCell2Cell(inputValue);
                            if ~iscellstr(inputValueT)
                                error([mfilename ':: The property ' type ' must be set to a cellstr or a nested cellstr.'])
                            end
                        else
                            error([mfilename ':: The property ' type ' must be set to a cellstr. {''Var1'',''"Var1_tex"'',...}'])
                        end
                    end
                end

                % Parse the cellstr for var names and tex names
                if isa(tempObj,'nb_exprModel')
                    vars    = inputValue;
                    texVars = inputValue;
                else
                    ind     = regexp(inputValue,'"\w+"');
                    indTex  = ~cellfun('isempty',ind);
                    texLoc  = find(indTex);
                    if isempty(texLoc)
                        vars    = inputValue;
                        texVars = inputValue;
                    else

                        if texLoc(1) == 1
                            error([mfilename ':: The decleared ' type ' variables can not start with a tex name. I.e. the notation "Var1".'])
                        elseif any(diff(texLoc,1,2) == 1)
                            error([mfilename ':: The decleared ' type ' variables can be given two consecutive tex names. I.e. the notation "Var1".'])
                        end
                        varLoc  = find(~indTex);
                        vars    = inputValue(~indTex);
                        texVars = vars;

                        % Find out where to place the tex names
                        [foundPlace,placeTex] = ismember(texLoc,varLoc + 1);
                        if ~all(foundPlace)
                            error([mfilename ':: Could not find a matching variable to one of the tex names.'])
                        end
                        texVars(placeTex) = inputValue(indTex);

                    end
                end

            end

            if iscolumn(vars)
                vars = vars';
            end
            if iscolumn(texVars)
                texVars = texVars';
            end

            % Create structure
            temp          = struct();
            temp.name     = vars;
            temp.tex_name = texVars;
            temp.number   = length(vars);

            if isa(tempObj,'nb_mfvar') || isa(tempObj,'nb_fmdyn')
                temp.frequency = cell(1,temp.number);
                temp.mapping   = repmat({''},[1,temp.number]);
                if isa(tempObj,'nb_mfvar')
                    temp.mixing = repmat({''},[1,temp.number]);
                end
            elseif isa(tempObj,'nb_midas')
                temp.frequency = cell(1,temp.number);
            end

            switch lower(type)
                case 'dependent'
                    tempObj.dependent = temp;
                case 'endogenous'   
                    tempObj.endogenous = temp;
                case 'exogenous'
                    tempObj.exogenous = temp;
                case 'factors'
                    if isa(tempObj,'nb_var')
                        tempObj.factors = temp;
                    else 
                        if ~isa(tempObj,'nb_fmdyn')
                            error([mfilename ':: Cannot set factor names for an object of class ' class(tempObj)])
                        end
                        if length(temp.name) ~= tempObj.factors.number
                            if tempObj.factors.number == 0
                                error([mfilename ':: The model has no factors to rename.'])
                            else
                                error([mfilename ':: The model has ' int2str(tempObj.factors.number),...
                                                 ', but you have assign ' int2str(length(temp.name)) '.'])
                            end
                        end
                        tempObj.factorNames = temp;
                    end
                case 'observables'
                    if isa(tempObj,'nb_dsge')
                        tempObj.observablesHidden = temp;
                    else
                        tempObj.observables = temp;
                    end
                case 'observablesfast'
                    tempObj.observablesFast = temp; 
                case 'block_exogenous'
                    temp.block_id           = block_id;
                    temp.num_blocks         = max(block_id);
                    tempObj.block_exogenous = temp; 

            end

        end
        
        function obj = setProps(obj,s)
            
            fields = fieldnames(s);
            for ii = 1:length(fields)
                try
                    obj.(fields{ii}) = s.(fields{ii});
                catch Err
                    if ~strcmpi(Err.identifier,'MATLAB:class:noSetMethod')
                        rethrow(Err)
                    end
                end
            end
            
        end
        
    end
    
    methods (Sealed=true)
        
        varargout = assignParameters(varargin)
        varargout = assignPosteriorDraws(varargin)
        varargout = conditionalTheoreticalMoments(varargin)
        varargout = dieboldMarianoTest(varargin)
        varargout = empiricalMoments(varargin)
        varargout = eq(varargin)
        varargout = forecast(varargin)
        varargout = getDependent(varargin)
        varargout = getDependentNames(varargin)
        varargout = getParameterDrawsMethods(varargin)
        varargout = getPredicted(varargin)
        varargout = getRecursiveEstimationGraph(varargin)
        varargout = getResidual(varargin)
        varargout = getResidualGraph(varargin)
        varargout = getResidualNames(varargin)
        varargout = getRoots(varargin)
        varargout = getVariablesList(varargin)
        varargout = irf(varargin)
        varargout = isestimated(varargin)
        varargout = isStateSpaceModel(varargin)
        varargout = isNB(varargin)
        varargout = issolved(varargin)
        varargout = jointPredictionBands(varargin)
        varargout = mincerZarnowitzTest(varargin)
        varargout = parameterDraws(varargin)
        varargout = print(varargin)
        varargout = print_estimation_results(varargin)
        varargout = shock_decomposition(varargin)
        varargout = simulate(varargin)
        varargout = simulatedMoments(varargin)
        varargout = solveVector(varargin)
        varargout = theoreticalMoments(varargin)
        varargout = uncertaintyDecomposition(varargin)
        varargout = uncondForecast(varargin)
        varargout = update(varargin)
        varargout = variance_decomposition(varargin)
         
    end
    
    methods (Access=protected)
        
        function param = getParametersNames(obj); end %#ok<MANU,STOUT>
        
    end
    
    methods (Static=true)
        
        varargout = constructScore(varargin)
        varargout = constructCondDB(varargin)
        varargout = evaluatePrior(varargin)
        varargout = getActual(varargin)
        varargout = graphCorrelation(varargin)
        varargout = initialize(varargin)
        varargout = plotMCF(varargin)
        varargout = plotMCFDistTest(varargin)
        varargout = plotMCFValues(varargin)
        
    end
    
    methods (Static=true,Access=protected)
        
        varargout = getDates(varargin)
         
    end
        
    methods (Static=true,Hidden=true)    
        
        varargout = defaultInputs(varargin)
        varargout = isMixedFrequencyStatic(varargin)
        varargout = loopForecast(varargin)
        varargout = templateGeneral(varargin)
        
        function t = groupIndexText(index)

            if isempty(index)
                t = '';
                return
            end
            
            t = [' of model group ' int2str(index(1,1))];
            r = t;
            g = 'group';
            for ii = 2:size(index,2)
                gi = ['sub' g];
                n  = regexprep(r,g,gi);
                t  = [t, n]; %#ok<AGROW>
                r  = n;
                g  = gi;
            end

        end
         
    end
    
    methods (Static, Sealed, Access = protected)
        
        function fcst = writeSimulationToDisk(fcst,index)
        % This is to save simulation/percentiles to disk to save memory   
        % when forecasting many models    
            
            if size(fcst.data,3) > 1 % Has there been produced any density forecast?
                
                pathToSave = nb_userpath('gui');
                if exist(pathToSave,'dir') ~= 7
                    try
                        mkdir(pathToSave)
                    catch %#ok<CTCH>
                        error(['You are standing in a folder you do not have writing access to (' pathToSave '). Please switch user path!'])
                    end
                end
                
                fData   = fcst.data(:,:,1:end-1,:);
                saveND  = ['simulations_' int2str(index) '_' nb_clock('vintagelong')];
                saveND  = [pathToSave '\' saveND];
                save(saveND,'fData')
                fcst.simPath = {saveND};
                fcst.data    = fcst.data(:,:,end,:); % Remove simulations from forecast data.
                
            end
            
        end
      
    end
    
end
    
