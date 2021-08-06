function [nowcast,missing] = checkForMissing(options,inputs,dep)
% Syntax:
%
% [nowcast,missing] = nb_forecast.checkForMissing(options,inputs,dep)
%
% Description:
%
% Check for missing data at the end of sample. Only handle one missing
% observation at the end here!
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    nowcast = 0;
    missing = [];
    if ~isfield(options,'missingData')
        
        if strcmpi(options.class,'nb_fmdyn')
            dep = dep(options.nFactors+1:end);
        end
        [ind,indV] = ismember(dep,options.dataVariables);
        if any(~ind)
            error([mfilename ':: Fatal error. Contact Kenneth S. Paulsen for help.'])
        end
        
        dataIsNan = isnan(options.data(:,indV));
        last      = find(~any(dataIsNan,2),1,'last');
        if last == options.estim_end_ind
            return
        end
        dataAll = options.data(last+1:options.estim_end_ind,indV);
        missing = isnan(dataAll);
        nowcast = options.estim_end_ind - last;
        
        if strcmpi(options.class,'nb_fmdyn')
            missing = [false(nowcast,options.nFactors), missing];
        end
        
    else
        
        % Here the estimation has been done by the nb_missingEstimator
        % package
        [ind,indV]    = ismember(dep,options.missingVariables);
        repVars       = dep(~ind);
        indV          = indV(ind);
        estim_end_ind = options.estim_end_ind;
        missingT      = options.missingData(1:estim_end_ind,indV);
        aMissing      = any(missingT,2);
        last          = find(~aMissing,1,'last');
        if estim_end_ind - last > 1
            if strcmpi(options.missingMethod,'kalman') 
                % We allow more missing observations, but we do not report
                % it in graphs and results
                nowcast = 1;
                missing = options.missingData(estim_end_ind,ind);
                if ~isempty(repVars)
                    [ind,indR] = ismember(repVars,options.dataVariables);
                    if any(~ind)
                        error([mfilename ':: Fatal error. Contact Kenneth S. Paulsen for help.'])
                    end
                    dataRep = options.data(estim_end_ind,indR);
                    missing = [missing, isnan(dataRep)];
                end
            elseif strcmpi(options.missingMethod,'forecast') || strcmpi(options.missingMethod,'kalmanFilter')
                nowcast = estim_end_ind - last;
                missing = options.missingData(last+1:estim_end_ind,ind);
                if ~isempty(repVars)
                    [ind,indR] = ismember(repVars,options.dataVariables);
                    if any(~ind)
                        error([mfilename ':: Fatal error. Contact Kenneth S. Paulsen for help.'])
                    end
                    dataRep = options.data(last+1:estim_end_ind,indR);
                    missing = [missing, isnan(dataRep)];
                end
            else
                message = [mfilename '::  It is not possible to forecast models with more than one missing observation at the end of the sample.'];
                if isfield(inputs,'index')
                    message = [message,' (Model '  int2str(inputs.index) ')'];
                end
                error(message);
            end
        elseif estim_end_ind - last == 1
            nowcast = 1;
            indM    = ismember(dep,options.missingVariables);
            missing = options.missingData(last+1,indM);
            if ~isempty(repVars)
                [ind,indR] = ismember(repVars,options.dataVariables);
                if any(~ind)
                    error([mfilename ':: Fatal error. Contact Kenneth S. Paulsen for help.'])
                end
                dataRep = options.data(last+1,indR);
                missing = [missing, isnan(dataRep)];
            end

        end
        
    end
    
end
