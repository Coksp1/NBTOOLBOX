function res = mergeResults(res,resTemp)
% Syntax:
%
% res = nb_realTimeEstimator.mergeResults(res,resTemp)
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nb_isempty(res)
        remove     = {'includedObservations','elapsedTime'};
        fields     = fieldnames(resTemp);
        ind        = ismember(remove,fields);
        resTemp    = rmfield(resTemp,remove(ind));
        if isfield(resTemp,'beta')
            if iscell(resTemp.beta)
                resTemp.beta = {resTemp.beta};
            end
        end
        if isfield(resTemp,'stdBeta')
            if iscell(resTemp.stdBeta)
                resTemp.stdBeta = {resTemp.stdBeta};
            end
        end
        res = resTemp;
        return
    end

    % Some outputs we don't want to merge
    remove  = {'includedObservations','elapsedTime'};
    fields  = fieldnames(resTemp);
    ind     = ismember(remove,fields);
    resTemp = rmfield(resTemp,remove(ind));
    fields  = fieldnames(resTemp);
    for ii = 1:length(fields)
       
        % We only merge the numerical output
        tempFieldValue = resTemp.(fields{ii});
        if isnumeric(tempFieldValue) || isa(tempFieldValue,'nb_distribution')
            
            tempExFieldValue           = res.(fields{ii});
            [dim1,dim2,dim3,dim4,dim5] = size(tempExFieldValue);
            if dim4 > 1
                if size(tempFieldValue,3) > 1
                    tempExFieldValue(:,:,:,:,dim5+1) = tempFieldValue;
                else
                    d1 = size(tempFieldValue,1) - size(tempExFieldValue,1);
                    if d1 > 0
                        tempExFieldValue = [tempExFieldValue; nan(d1,dim2,dim3,dim4)]; %#ok<AGROW>
                    end
                    tempExFieldValue(:,:,dim3+1,:) = tempFieldValue;
                end
            elseif nb_sizeEqual(tempFieldValue,[dim1,dim2,dim3])
                if dim3 > 1
                    tempExFieldValue(:,:,:,dim4+1) = tempFieldValue;
                else
                    tempExFieldValue(:,:,dim3+1) = tempFieldValue;
                end
            else
                dim = size(tempFieldValue,1) - dim1;
                if dim > 0
                    tempExFieldValue             = [tempExFieldValue; nan(dim,dim2,dim3)]; %#ok<AGROW>
                    tempExFieldValue(:,:,dim3+1) = tempFieldValue;
                else
                    dimNew3 = size(tempFieldValue,3);
                    if dimNew3 > 1
                        dimNew1                   = size(tempFieldValue,1);
                        new                       = nan(dim1,dim2,dim3,dim4+1);
                        new(1:dimNew1,:,:,dim4+1) = tempFieldValue;
                        new(:,:,:,1:dim4)         = tempExFieldValue;
                        tempExFieldValue          = new;
                    else
                        dimNew1                     = size(tempFieldValue,1);
                        new                         = nan(dim1,dim2,dim3 + 1);
                        new(1:dimNew1,:,dim3+1:end) = tempFieldValue;
                        new(:,:,1:dim3)             = tempExFieldValue;
                        tempExFieldValue            = new;
                    end
                    
                end
            end
            res.(fields{ii}) = tempExFieldValue;
           
        elseif iscell(tempFieldValue)
            
            if any(strcmpi(fields{ii},{'beta','stdBeta'}))
                res.(fields{ii}) = [res.(fields{ii}),{tempFieldValue}];
            else
                res.(fields{ii}) = [res.(fields{ii}),tempFieldValue];
            end
            
        elseif strcmpi(fields{ii},'smoothed')
            
            % Merge smoothed estimates
            res.smoothed.variables = doOneSmoothed(res.smoothed.variables,resTemp.smoothed.variables);
            if isfield(res.smoothed,'errors')
                res.smoothed.errors = doOneSmoothed(res.smoothed.errors,resTemp.smoothed.errors);
            end
            if isfield(res.smoothed,'observables')
                res.smoothed.observables = doOneSmoothed(res.smoothed.observables,resTemp.smoothed.observables);
            end
            if isfield(res.smoothed,'shocks')
                res.smoothed.shocks = doOneSmoothed(res.smoothed.shocks,resTemp.smoothed.shocks);
            end
            if isfield(res.smoothed,'variances')
                res.smoothed.variances = doOneSmoothed(res.smoothed.variances,resTemp.smoothed.variances);
            end
            
        end
        
    end

end

%==========================================================================
function smoothedNew = doOneSmoothed(smoothedOld,smoothedNew)

    [TOld,n,p]  = size(smoothedOld.data);
    TNew        = size(smoothedNew.data,1);
    newVarData  = nan(TNew,n,p+1);

    newVarData(1:TOld,:,1:p) = smoothedOld.data;
    newVarData(:,:,p+1)      = smoothedNew.data;
    smoothedNew.data         = newVarData;

end
