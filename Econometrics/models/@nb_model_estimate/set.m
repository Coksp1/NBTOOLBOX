function obj = set(obj,varargin)
% Syntax:
%
% obj = set(obj,varargin)
%
% Description:
%
% Sets the properties or fields of the options property of the 
% nb_model_estimate objects (or objects wich is of a subclass of this 
% class).
%
% Caution : It may also set the fields of the options property of the 
%           object. See the <class>.template and <class>.help for more
%           on the different fields of the options property. E.g.
%           nb_var.template and nb_var.help.
%
% Caution : If the model is reformulated the estimation results and
%           solution will be deleted.
%
% Input:
%
% - obj : A vector of nb_model_estimate objects.
%
% Optional input:
%
% If number of inputs equals 1:
%
% - varargin{1} : A structure of fields to be set. See the
%                 template method of each model class for more.
%
% Else:
%
% - varargin    : ...,'inputName',inputValue,... arguments.
%
%                 Where you can set all fields of some properties
%                 of the object. (options, endogenous, exogenous)
%
% Output:
%
% - obj : A vector of nb_model_estimate objects.
%
% See also:
% nb_model_generic, nb_judgemental_forecast, nb_model_convert
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin == 1
        return
    end

    if nargin == 2
        if isstruct(varargin{1})
            varargin = nb_struct2cellarray(varargin{1});
        else
            error('Inputs must come in pairs.')
        end
    end

    obj  = obj(:);
    nobj = numel(obj);
    if nobj == 0
        error('Cannot set properties of a empty vector of nb_model_generic objects.')
    else

        for ii = 1:nobj

            numberOfInputs = size(varargin,2);
            if rem(numberOfInputs,2) ~= 0
                error('The optional input must come in pairs.')
            end

            fields = [fieldnames(obj(ii).options); 'shift'];
            for jj = 1:2:numberOfInputs

                inputName  = varargin{jj};
                inputValue = varargin{jj + 1};

                switch lower(inputName)
                    
                    case 'blocks'
                        
                        if isa(obj(ii),'nb_fmdyn')
                            obj(ii) = setBlocks(obj(ii),inputValue);
                        else
                            if isa(obj(ii),'nb_manualModel')
                                obj(ii).options.(inputName) = inputValue;
                            else
                                error(['Bad field name of the options property found; ' inputName])
                            end
                        end
                        
                    case 'constraints'

                        if ~any(strcmpi(inputName,fields))
                            error(['Bad field name of the options property found; ' inputName ' for an object of class ' class(obj) '.'])
                        end
                        if ~iscellstr(inputValue)
                            error('The constraints option must be set to a N x 1 cellstr.')
                        end
                        obj(ii).parser.constraints  = inputValue(:);
                        obj(ii).options.constraints = inputValue(:);
                        obj(ii).parser              = nb_nonLinearEq.constraints2func(obj(ii).parser);

                    case 'data'

                        if ~isa(inputValue,'nb_dataSource')
                            error('The ''data'' option must be set to a nb_dataSource object.')
                        end
                        obj(ii).dataOrig = inputValue;

                    case 'equations'

                        if isa(obj(ii),'nb_manualModel')
                            obj(ii).options.(inputName) = inputValue;
                        else
                            if ~any(strcmpi(inputName,fields))
                                error(['Bad field name of the options property found; ',...
                                    inputName ' for an object of class ' class(obj) '.'])
                            end
                            if ~iscellstr(inputValue)
                                error('The equations option must be set to a N x 1 cellstr.')
                            end
                            obj(ii).options.equations = inputValue(:);
                            obj(ii).parser.equations  = inputValue(:);
                            obj(ii).parser            = nb_nonLinearEq.eq2func(obj(ii).parser);    
                        end
                        
                    case {'exogenous','endogenous','dependent','block_exogenous','factors','observables','observablesfast'}

                        if isa(obj(ii),'nb_manualModel')
                            obj(ii).options.(inputName) = inputValue;
                            continue;
                        end
                        
                        if isa(obj(ii),'nb_dsge')
                            if ~(isNB(obj(ii)) && any(strcmpi(inputName,{'observables'})))
                                if any(strcmpi(inputName,{'observables'}))
                                    error(['The model (nr. ' int2str(ii) ') is a nb_dsge object (solved with RISE or Dynare), and you can not set the ' inputName ' option in this case.'])
                                else
                                    error(['The model (nr. ' int2str(ii) ') is a nb_dsge object, and you can not set the ' inputName ' option in this case.'])
                                end
                            end
                        elseif isa(obj(ii),'nb_judgemental_forecast')
                            error(['Bad field name of the options property found; ' inputName '. (For the nb_judgemental_forecast class).'])
                        end
                        obj(ii) = setNames(obj(ii),inputValue,inputName);
                        if ~(isa(obj(ii),'nb_dsge') || (isa(obj(ii),'nb_fmdyn') && strcmpi(inputName,'factors')) || isa(obj(ii),'nb_calculate_only'))
                            obj(ii).results = struct();
                            if isa(obj(ii),'nb_var')
                                obj(ii) = setSolution(obj(ii),struct('identification',struct()));
                            else
                                obj(ii) = setSolution(obj(ii),struct());
                            end
                        end
                        if isa(obj(ii),'nb_nonLinearEq')
                            obj(ii).parser.(inputName) = inputValue;
                        elseif isa(obj(ii),'nb_fmdyn')
                            if ~nb_isempty(obj(ii).estOptions)
                                % Used by the print method
                                obj(ii).estOptions.factors = inputValue;
                            end
                        end

                    case 'fcsthorizon'

                        if ~nb_isScalarInteger(inputValue)
                            error('The ''fcstHorizon'' property must be set to a positive integer.')
                        elseif inputValue < 0
                            error('The ''fcstHorizon'' property must be set to a positive integer.')
                        end
                        obj(ii).fcstHorizon = inputValue;    

                    case 'frequency'

                        if isa(obj(ii),'nb_mfvar') || isa(obj(ii),'nb_fmdyn') || isa(obj(ii),'nb_midas')
                            obj(ii) = setFrequency(obj(ii),inputValue);
                        else
                            if isa(obj(ii),'nb_manualModel') || isa(obj(ii),'nb_harmonizer')
                                obj(ii).options.(inputName) = inputValue;
                            else
                                error(['Bad field name of the options property found; ' inputName])
                            end
                        end

                    case 'macrovars'

                        if ~any(strcmpi(inputName,fields))
                            error(['Bad field name of the options property found; ' inputName])
                        end
                        try
                            obj(ii).options.macroVars = nb_macro.interpret(inputValue);
                        catch Err

                            if strcmpi(Err.identifier,'nb_macro:interpret')
                                [s1,s2,s3] = size(inputValue);
                                error(['The macroVars input cannot be assign an object of class ' class(inputValue)...
                                    ' of size ' int2str(s1) 'x' int2str(s2) 'x' int2str(s3)])
                            else
                                rethrow(Err)
                            end
                        end

                    case 'name'

                        if ischar(inputValue)
                            if numel(obj) > 1
                                nums       = strtrim(cellstr(int2str([1:nobj]'))); %#ok<NBRAK>
                                inputValue = strcat(inputValue(1,:),nums);
                            else
                                inputValue = cellstr(inputValue);
                            end
                        end

                        try
                            obj(ii).name = inputValue{ii};
                        catch %#ok<CTCH>
                            error(['The value given to the property ''name'' must be a cellstr with size 1x' int2str(nobj) ' '...
                                'when setting multiple nb_model_generic objects.'])
                        end

                    case 'needtobesolved'

                        if ~isa(obj(ii),'nb_dsge')
                            error(['Bad field name of the options property found; ' inputName])
                        end
                        obj(ii).needToBeSolved = inputValue;
                        
                    case 'nfactors'
                        
                        if isa(obj(ii),'nb_manualModel')
                            obj(ii).options.(inputName) = inputValue;
                        elseif isa(obj(ii),'nb_factor_model_generic')
                            if ~nb_isScalarInteger(inputValue,0)
                                error(['The ' inputName ' must be set to a positive integer.'])
                            end
                            if obj(ii).options.nFactors == inputValue
                                continue
                            end
                            if isa(obj(ii),'nb_fmdyn')
                                if ~isempty(obj(ii).options.blocks)
                                    obj(ii).factorNames    = {};
                                    obj(ii).options.blocks = [];
                                    warning('nb_fmdyn:removeBlocks',['The ' inputName ' is not consistent with ',...
                                        'the blocks options. Set the blocks option to empty.'])
                                end
                            end
                            obj(ii).options.nFactors = inputValue;
                        elseif isa(obj(ii),'nb_calculate_factors')
                            if ~(nb_isScalarInteger(inputValue,0) || isempty(inputValue))
                                error(['The ' inputName ' must be set to a positive integer or empty.'])
                            end
                            obj(ii).options.nFactors = inputValue;
                        else
                            error(['Bad field name of the options property found; ' inputName])
                        end

                    case 'prior'

                        if isa(obj(ii),'nb_manualModel')
                            obj(ii).options.(inputName) = inputValue;
                            continue
                        end
                        
                        if ~any(strcmpi(inputName,fields))
                            error(['Bad field name of the options property found; ' inputName])
                        end
                        obj(ii) = setPrior(obj(ii),inputValue);

                    case 'reporting'

                        if or(iscell(inputValue) && size(inputValue,2) == 3, isempty(inputValue))
                            obj(ii) = setReporting(obj(ii),inputValue);
                        else
                            error('The property reporting must be assign a Nx3 cell matrix.')
                        end

                    case 'mapping'

                        if isa(obj(ii),'nb_manualModel')
                            obj(ii).options.(inputName) = inputValue;
                            continue
                        end
                        
                        if not(isa(obj(ii),'nb_mfvar') || isa(obj(ii),'nb_fmdyn'))
                            error(['Bad field name of the options property found; ' inputName])
                        end
                        obj(ii) = setMapping(obj(ii),inputValue);
                        
                    case 'mixing'

                        if isa(obj(ii),'nb_manualModel')
                            obj(ii).options.(inputName) = inputValue;
                            continue
                        end
                        
                        if ~isa(obj(ii),'nb_mfvar')
                            error(['Bad field name of the options property found; ' inputName])
                        end
                        obj(ii) = setMixing(obj(ii),inputValue);      
                        
                    case 'measurementeqrestriction'

                        if isa(obj(ii),'nb_manualModel')
                            obj(ii).options.(inputName) = inputValue;
                            continue
                        end
                        if ~isa(obj(ii),'nb_var')
                            error(['Bad field name of the options property found; ' inputName])
                        end
                        if ~nb_isempty(inputValue)
                            obj(ii) = setMeasurementEqRestriction(obj(ii),inputValue);    
                        end
                        
                    case 'steady_state_change'

                        if ~any(strcmpi(inputName,fields))
                            error(['Bad field name of the options property found; ' inputName])
                        end
                        if isNB(obj(ii))
                            % Here we also trigger that the staticFunction
                            % must be re-created.
                            [obj(ii).options.steady_state_change,obj(ii).parser] = nb_dsge.interpretSteadyStateChange(obj(ii).parser,inputValue);
                        else
                            error('The ''steady_state_change'' option is not supported if the DSGE model is not solved with the NB toolbox.')
                        end

                    case {'steady_state_init','steady_state_fixed'}

                        if ~any(strcmpi(inputName,fields))
                            error(['Bad field name of the options property found; ' inputName])
                        end
                        if isNB(obj(ii))
                            obj(ii).options.(lower(inputName)) = nb_dsge.interpretSteadyStateInput(obj(ii).parser,inputValue,false,lower(inputName));
                        else
                            error(['The ''' inputName ''' option is not supported if the DSGE model is not solved with the NB toolbox.'])
                        end

                    case 'systemprior'

                        if isa(obj(ii),'nb_manualModel')
                            obj(ii).options.(inputName) = inputValue;
                            continue
                        end
                        if ~any(strcmpi(inputName,fields))
                            error(['Bad field name of the options property found; ' inputName])
                        end
                        if isempty(inputValue)
                            obj(ii).options.systemPrior = inputValue;
                        else
                            if ~isa(inputValue,'function_handle')
                                error(['The option ' inputName ' must be set to a function_handle. See setSystemPrior '...
                                    'for other alternatives.'])
                            end
                            obj(ii).options.systemPrior = inputValue;
                        end

                    case 'transformations'

                        if iscell(inputValue) && size(inputValue,2) == 4
                            obj(ii) = setTransformations(obj(ii),inputValue);
                        elseif isempty(inputValue)
                            obj(ii) = setTransformations(obj(ii),{});
                        else
                            error('The property transformations must be assign a Nx4 cell matrix or a empty cell.')
                        end

                    case 'userdata'

                        if ischar(inputValue)
                            if numel(obj) > 1
                                nums       = strtrim(cellstr(int2str([1:nobj]'))); %#ok<NBRAK>
                                inputValue = strcat(inputValue(1,:),nums);
                            else
                                inputValue = cellstr(inputValue);
                            end
                        end

                        try
                            obj(ii).userData = inputValue{ii};
                        catch %#ok<CTCH>
                            error(['The value given to the property ''userData'' must be a cellstr with size 1x' int2str(nobj) ' '...
                                'when setting multiple nb_model_generic objects.'])
                        end

                    otherwise

                        if isa(obj(ii),'nb_manualModel') || isa(obj(ii),'nb_manualCalculator')
                            obj(ii).options.(inputName) = inputValue;
                        else
                            ind = find(strcmpi(inputName,fields),1);
                            if isempty(ind)
                                error(['Bad field name of the options property found; ' inputName])
                            end
                            obj(ii).options.(fields{ind}) = inputValue;
                        end

                end

            end
        end

    end

end
