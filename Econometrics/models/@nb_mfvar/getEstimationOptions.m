function outOpt = getEstimationOptions(obj)
% Syntax:
%
% outOpt = getEstimationOptions(obj)
%
% Written by Kenneth Sæterhagen Paulsen       

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Set up the estimators
    %------------------------------------------------------
    obj  = obj(:);
    nobj = size(obj,1);
    if nobj > 1
        
        outOpt = cell(1,nobj);
        for ii = 1:nobj
            outOpt(ii) = getEstimationOptions(obj(ii));
        end
        
    elseif nobj == 1
           
        tempOpt      = obj.options;
        estim_method = tempOpt.estim_method;
        switch lower(estim_method)

            case {'bvar','ml','tvpmfsv'}

                % Get estimation options
                %-----------------------
                tempOpt.name = obj.name; 

                % Model settings
                exo  = obj.exogenous.name;
                endo = obj.endogenous.name;
                if ~isempty(endo)
                    exo = [exo,endo]; 
                end
                if ~isempty(tempOpt.nLags)
                    if ~isscalar(tempOpt.nLags)
                        error([mfilename ':: The nLags option must be a scalar for the nb_mfvar object.'])
                    end
                end
                
                tempOpt.dependent       = obj.dependent.name;
                tempOpt.block_exogenous = obj.block_exogenous.name;
                tempOpt.block_id        = obj.block_exogenous.block_id;
                tempOpt.exogenous       = exo;
                tempOpt.nLags           = tempOpt.nLags;
                
                % Data, dates, variables and types
                dataObj = tempOpt.data;
                if ~tempOpt.real_time_estim
                   if dataObj.numberOfDatasets > 1
                       if isempty(tempOpt.page)
                           tempOpt.page = dataObj.numberOfDatasets;
                       end
                       dataObj = window(dataObj,'','','',tempOpt.page);
                   end
                end
                tempOpt.data          = dataObj.data;
                tempOpt.dataStartDate = toString(dataObj.startDate);
                tempOpt.dayOfWeek     = dataObj.startDate.dayOfWeek;
                if ~isempty(tempOpt.estim_end_date)
                    tempOpt.estim_end_ind = (nb_date.toDate(tempOpt.estim_end_date,dataObj.frequency) - dataObj.startDate) + 1;
                else
                    tempOpt.estim_end_ind = [];
                end
                if ~isempty(tempOpt.estim_start_date)
                    tempOpt.estim_start_ind = (nb_date.toDate(tempOpt.estim_start_date,dataObj.frequency) - dataObj.startDate) + 1;
                else
                    tempOpt.estim_start_ind = [];
                end
                if ~isempty(tempOpt.recursive_estim_start_date)
                    tempOpt.recursive_estim_start_ind = (nb_date.toDate(tempOpt.recursive_estim_start_date,dataObj.frequency) - dataObj.startDate) + 1;
                else
                    tempOpt.recursive_estim_start_ind = [];
                end
                tempOpt.dataVariables           = dataObj.variables;
                tempOpt.estim_types             = {};
                tempOpt.requiredDegreeOfFreedom = 3;
                tempOpt = rmfield(tempOpt,{'estim_end_date','estim_start_date','recursive_estim_start_date'});

                % Mixed frequency options
                tempOpt.mapping   = [obj.dependent.mapping,obj.block_exogenous.mapping];
                tempOpt.mixing    = [obj.dependent.mixing,obj.block_exogenous.mixing];
                tempOpt.frequency = [obj.dependent.frequency,obj.block_exogenous.frequency];
                vars              = [obj.dependent.name,obj.block_exogenous.name];
                tempOpt           = check(tempOpt,dataObj,vars);
                
                if strcmpi(estim_method,'ml')
                    if ~nb_isempty(tempOpt.measurementEqRestriction)
                        error(['The ''measurementEqRestriction'' option is not ',...
                               'supported when ''estim_method'' is set to ''' estim_method '''.'])
                    end
                end
                
            otherwise

                error([mfilename ':: The estimation method ' estim_method ' is not supported.'])

        end

        % Assign estimation method (to make it possible to prevent 
        % looping over objects)
        tempOpt.estim_method = estim_method;
        tempOpt.class        = 'nb_mfvar';
        outOpt               = {tempOpt};
        
    end
    
end

%==========================================================================
function tempOpt = check(tempOpt,dataObj,vars)

    % Interpret the frequency change date
    for ii = 1:length(tempOpt.frequency)
        if iscell(tempOpt.frequency{ii})
            % Interpret the date input relative to data start
            % date (at this stage it is checked to be a nb_date
            % object!)
            date = tempOpt.frequency{ii}{2};
            if date.frequency ~= dataObj.frequency
                error([mfilename ':: The frequency of the change of frequency date for the variable '...
                                  vars{ii} ' is not ' nb_date.getFrequencyAsString(dataObj.frequency) '. Is ',...
                                  toString(date) '.'])
            end
            tempOpt.frequency{ii}{2} = (date - dataObj.startDate) + 1;
        end
    end

    % Check the mixing option
    for ii = 1:length(tempOpt.frequency)
        if ~isempty(tempOpt.mixing{ii})
            freqLow = tempOpt.frequency{ii};
            if iscell(freqLow)
                error([mfilename ':: The variable ' vars{ii} ' cannot have a changed frequency and mixing ',...
                                 'frequency variable (' tempOpt.mixing{ii}  ') at the same time.'])
            elseif isempty(freqLow)
                error([mfilename ':: The variable ' vars{ii} ' cannot have the default frequency when it is assign a mixing ',...
                                 'frequency variable (' tempOpt.mixing{ii}  ') at the same time.'])
            end
            indVar  = strcmpi(tempOpt.mixing{ii},vars);
            freqHigh = tempOpt.frequency{indVar};
            if ~isempty(freqHigh)
                if iscell(freqHigh)
                    error([mfilename ':: The variable ' vars{indVar} ', which is assign as a mixing frequency variable for ',...
                                      vars{ii}  ', cannot have changing frequency (i.e. the frequency cannot be given as a cell).'])
                elseif freqLow >= freqHigh
                    freqLow  = nb_date.getFrequencyAsString(freqLow);
                    freqHigh = nb_date.getFrequencyAsString(freqHigh);
                    error([mfilename ':: The variable ' vars{indVar} ' (' freqHigh '), which is assign as a mixing frequency variable for ',...
                                      vars{ii}  ' (' freqLow '), must have a higher frequency than ' vars{ii} '.'])
                end
            end

        end
    end
    tempOpt.indObservedOnly = ~cellfun(@isempty,tempOpt.mixing);

end
