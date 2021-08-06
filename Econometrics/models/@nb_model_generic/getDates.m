function [sInd,eInd,indM] = getDates(opt,inputs)
% Syntax:
%
% [sInd,eInd,indM] = nb_model_generic.getDates(opt,inputs)
%
% Description:
%
% Static method
%
% See also:
% nb_model_generic.shock_decomposition
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    nobj    = size(opt,2);
    indM    = true(1,nobj); % The models that will be decomposed, sometimes the dates are outside the model samples
    sInd    = nan(1,nobj);
    sDate   = inputs.startDate;
    if ~isempty(sDate)
        sDate = nb_date.date2freq(sDate);
    end
    eInd    = nan(1,nobj);
    eDate   = inputs.endDate;
    if ~isempty(eDate)
        eDate = nb_date.date2freq(eDate);
    end
    
    if isempty(sDate) && isempty(eDate)
        return
    elseif not(isempty(sDate) || isempty(eDate))
        if eDate < sDate
            error([mfilename ':: The start date of the decomposition (''' sDate.toString ''') cannot be after the end date (''' eDate.toString ''').'])
        end
    end
        
    for ii = 1:nobj
        
        [dateS,freq] = nb_date.date2freq(opt{ii}(end).dataStartDate);
        sEst         = opt{ii}(end).estim_start_ind;
        eEst         = opt{ii}(end).estim_end_ind;

        if ~nb_isempty(inputs.fcstDB)
            eEst = eEst + size(inputs.fcstDB.endo,1);
        end
        
        if ~isempty(sDate)
            sDateM   = convert(sDate,freq);
            sInd(ii) = sDateM - dateS + 1;
            if sInd(ii) < sEst
                sInd(ii) = sEst;
            elseif sInd(ii) > eEst
                indM(ii) = false;
            end
        end
        
        if ~isempty(eDate)
            eDateM   = convert(eDate,freq);
            eInd(ii) = eDateM - dateS + 1;
            if eInd(ii) > eEst
                eInd(ii) = eEst;
            elseif eInd(ii) < sEst
                indM(ii) = false;
            end
        end
        
    end

end
