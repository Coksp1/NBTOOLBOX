function paused = report(inputs,h,index,kk,jj,display,note)
% Syntax:
%
% paused = nb_irfEngine.report(inputs,h,index,kk,jj,display)
%
% Description:
%
% Report status
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    replic = inputs.replic;
    paused = false;
    if display
        [paused,canceling] = nb_irfEngine.checkInputFile(inputs.filename);
        if canceling
            error([mfilename ':: User terminated'])
        end
        if inputs.pause
            if paused
                if ~inputs.parallel
                    fprintf(inputs.writer,['Worker ' index ' paused...']);
                end
                paused = true;
                return
            end
        end
        if ~inputs.parallel % I.e. if ran i parallel by nb_irfEngine.doParallel
            fprintf(inputs.writer.Value,['Finished with ' int2str(kk) ' replications in ' int2str(jj) ' tries of '...
                                         int2str(replic) ' on worker ' index '...\r\n']);
        end
    else
        if h.canceling
            error([mfilename ':: User terminated'])
        end

        try
            if rem(kk,note) == 0
                h.(['status' index]) = kk;
                h.(['text' index]) = ['Finished with ' int2str(kk) ' replications in ' int2str(jj) ' tries...'];
            end
        catch %#ok<CTCH>
            paused = true;
            return
        end
    end

end
