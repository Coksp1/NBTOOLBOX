function checkOptions(options)
% Syntax:
%
% checkOptions(options)
%
% Description:
%
% Check if the fields of the options struct of the nb_synthesizer class 
% is correctly specified.
% 
% Input:
%
% - options : The options struct to check.
%
% Written by Per Bjarne Bye

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if isempty(options.varOfInterest) || ~nb_isOneLineChar(options.varOfInterest)
       error(['The varOfInterest option (the variable for which we should ',...
           'construct a synthetic series) must be specified as a char.']) 
    end
    
    if isempty(options.models) || ~isstruct(options.models)
        error(['The models options must be a struct array of the ',...
            'templates of the nb_mfvar models to combine.'])
    end
    
    if isempty(options.combinatorModel) || ~isstruct(options.combinatorModel)
        error(['The combinatorModel options must be a struct from the ',...
            'templates of the nb_mfvar models to combine.'])
    end
    
    for ii = 1:length(options.models)
       if ~ismember(options.varOfInterest,options.models(ii).dependent)
          error(['The number ' num2str(ii) ' model does not contain ',...
              options.varOfInterest ' among its dependent variables.']) 
       end
    end
    if size(options.models,1) ~= 1
        error('The models option must be a row vector.')
    end
    
    if isempty(options.folds) || ~iscell(options.folds)
       error('The folds input must be specified as a cell.')
    end
    
    if not(nb_sizeEqual(options.folds,[nan,2]) || nb_sizeEqual(options.folds,[1,3])) 
       error(['The folds option must be either a N x 2 cell containing the ',...
           'start dates of the folds in the first column and the end dates of ',...
           'the folds in the second column, or a 1 x 3 cell on the form ',...
           '{k,scoreStartDate,scoreEndDate} where k is the number of folds ',...
           'as an integer, scoreStartDate is the start of the scoring ',...
           'period, and scoreEndDate is the end of the scoring period.'])
    end
    
    if ~isempty(options.foldWeights)
        if size(options.foldWeights,1) ~= 1
            error(['The foldWeights option must be a row vector with k ',...
                'elements, where k is the number of folds.'])
        end
        if nb_sizeEqual(options.folds,[1,3])
            if size(options.foldWeights,2) ~= options.folds{1}
                error(['The foldWeights option must be a row vector with k ',...
                    'elements, where k is the number of folds.'])
            end
        else
            if size(options.foldWeights,2) ~= size(options.folds,1)
                error(['The foldWeights option must be a row vector with k ',...
                    'elements, where k is the number of folds.'])
            end
        end
    end
    
    if ~isempty(options.nModels) && ~nb_isScalarInteger(options.nModels,0)
        error('The nModels option must be a strictly positive scalar integer.')
    end
    
    if ~isempty(options.modelWeights)
        if size(options.modelWeights,1) ~= 1 || size(options.modelWeights,2) ~= options.nModels
            error('The modelWeights option must be a row vector with nModels elements.')
        end
    end
    
    if ~isempty(options.method) && ~nb_isScalarInteger(options.method,0,4)
        error('The method option must be either 1 or 2.')
    end
    
    if ~ismember(options.scoreCrit,nb_synthesizer.availableScoreCrit) 
        error(['The scoreCrit option must be one of the following (as a char): ',...
            nb_synthesizer.availableScoreCrit])
    end
    
    if options.method == 1
       if options.nModels > length(options.models)
           error(['The nModels option (' num2str(options.nModels) ') must be ',...
               'less or equal to the number of models (' num2str(length(options.models)) ').']) 
       end
    end
    
    freqs = nan(1,size(options.models,2));
    for ii = 1:size(options.models,2)
        if isempty(options.models(1).data)
            error(['The model number ' int2str(ii) ' does not have any assign data!'])
        end
        freqs(ii) = options.models(1).data.frequency;
    end
    freq = unique(freqs);
    if length(freq) > 1
        error('The data of the different models does not have the same frequency!')
    end
    
    if nb_sizeEqual(options.folds,[1,3])
        for ii = 2:3
            try
                nb_date.toDate(options.folds{1,ii},freq);
            catch Err
                nb_error(['The 2nd and 3rd elements of the folds input must be possible ',...
                    'to convert to a date object on the frequency ' int2str(freq)],Err)
            end
        end
    else
        for ii = 1:2
            for jj = 1:size(options.folds,1)
                try
                    nb_date.toDate(options.folds{jj,ii},freq);
                catch Err
                    nb_error(['Each element of the folds input must be possible ',...
                        'to convert to a date object on the frequency ' int2str(freq)],Err)
                end
            end
        end
    end
    
    if ~isempty(options.removePeriods)
    
        if ~iscell(options.removePeriods)
           error('The removePeriods input must be specified as a cell.')
        end
        if ~nb_sizeEqual(options.removePeriods,[nan,2])
           error(['The removePeriods option must be a Q x 2 cell containing the ',...
               'start dates of the periods to remove in the first column and ',...
               'the end dates of the periods to remove in the second column.'])
        end
        for ii = 1:2
            for jj = 1:size(options.removePeriods,1)
                try
                    nb_date.toDate(options.removePeriods{jj,ii},freq);
                catch Err
                    nb_error(['Each element of the removePeriods input must be possible ',...
                        'to convert to a date object on the frequency ' int2str(freq)],Err)
                end
            end
        end
    end
    
end
