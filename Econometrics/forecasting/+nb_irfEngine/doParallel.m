function [irfDataD,paused] = doParallel(method,model,options,results,inputs)
% Syntax:
%
% [irfDataD,paused] = nb_irfEngine.doParallel(method,model,options,...
%                                             results,inputs)
%
% Description:
%
% Produce IRFs with error bands in parallel.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    numCores = [];
    if isfield(inputs,'cores')
        numCores = inputs.cores;
    end
    
    % Open workers
    ret   = nb_openPool(numCores);
    cores = nb_poolSize();
    
    % Check if we should start from paused output
    cont = inputs.continue;
    if cont
    	irfDataF        = inputs.irfData;
        tested          = irfDataF(1,1,1,:);
        tested          = permute(tested,[4,1,2,3]);
        indNew          = isnan(tested);
        replic          = sum(indNew);
        inputs.continue = false;
    else
        replic = inputs.replic;
    end
    if replic < cores
        cores = 1;
    end
    
    % Create a manual input file
    pathToSave = nb_userpath('gui');
    if exist(pathToSave,'dir') ~= 7
        try
            mkdir(pathToSave)
        catch %#ok<CTCH>
            error(['The userpath specified is not valid for writing, which is needed in parallel mode. Your userptah is; ' nb_userpath])
        end
    end
    filename = [pathToSave,'\input_file_' nb_clock('vintagelong') '.txt'];
    writer   = fopen(filename,'w+');
    fclose(writer);
    fclose('all');
    inputs.filename = filename;
    
    % Preallocate inputs and outputs
    method           = {str2func(['nb_irfEngine.' method])};
    method           = method(:,ones(1,cores));
    inputs.parallelL = false;
    inputs.waitbar   = false; % To turn off waitbar
    inputs           = inputs(:,ones(1,cores));
    writer           = nb_funcToWrite('irf_worker','gui');
    for ii = 1:cores  
        inputs(ii).replic = ceil(replic/cores);
        inputs(ii).index  = ii;
        inputs(ii).writer = writer; 
    end
    
    % Secure that the number of replic is produced
    sumReplic            = sum([inputs.replic]);
    diffReplic           = sumReplic - replic;
    inputs(cores).replic = inputs(cores).replic - diffReplic;
    
    % Produce the irfs in parallel, each worker gets some number of
    % replications to do.
    irfDataT = cell(1,cores);
    paused   = cell(1,cores);
    parfor ii = 1:cores       
        meth = method{ii};
        [irfDataT{ii},paused{ii}] = meth(model,options,results,inputs(ii));
    end
    
    % Close workers if open up locally
    delete(writer);
    clear writer;
    nb_closePool(ret);
    
    % Close files for writing
    fclose('all');
    
    % Convert the output
    paused   = any([paused{:}]);
    periods  = inputs(1).periods;
    nShocks  = length(inputs(1).shocks);
    nVars    = length(inputs(1).variables) + length(inputs(1).variablesLevel);
    irfDataD = nan(periods+1,nVars,nShocks,replic);
    start    = 1;
    for ii = 1:cores
        ind                 = start:start + inputs(ii).replic - 1;
        irfDataD(:,:,:,ind) = irfDataT{ii};
        start               = start + inputs(ii).replic;
    end
    
    % Merge with already produced irfs
    if cont
        irfDataF(:,:,:,indNew) = irfDataD;
        irfDataD               = irfDataF;
    end
    
    % When some of the cores has been paused we order the output to make
    % missing irfs last.
    if paused
        tested   = irfDataD(1,1,1,:);
        tested   = permute(tested,[4,1,2,3]);
        test     = find(isnan(tested));
        test2    = find(~isnan(tested));
        order    = [test2;test];
        irfDataD = irfDataD(:,:,:,order);
    end
     
end
