function helpText = help(option)
% Syntax:
%
% helpText = nb_baiPerronTestStatistic.help(option)
%
% Description:
%
% Get the help on the different test options.
% 
% Input:
% 
% - option   : Either 'all' or the name of the option you want to get the
%              help on.
% 
% Output:
% 
% - helpText : A char with the help.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 1
        option = 'all';
    end
    
    sHelp = struct();

    % Genereate help for the different options
    sHelp.constant = sprintf(...
        '-constant: Add constant to the estimated equation.');
    sHelp.criterion = sprintf([...
        '-criterion: The criterion option to use to decide the number of breaks. Either\n',...
        '''bic'' (bayesian information criterion), ''lwz'' (Liu, Wu and Zidek) or a number \n',...
        'with the fixed number of breaks (as an integer).']);
    sHelp.critical = sprintf([...
        '-critical: The return critical values of different tests. Either 0.05, 0.1, 0.15,\n',...
        ' 0.2 or 0.25.']);
    sHelp.dependent = sprintf([...
        '-dependent: A string with the dependent variable.']);
    sHelp.endDate = sprintf([...
        '-endDate: The ''endDate'' option is the last observation to be used to\n',...
        'estimate the breaks. Either a string with the date or an object of class nb_date.\n',...
        'If empty, last date avilable will be used.']);
    sHelp.eps = sprintf([...
        '-eps: Criterion for the convergence. Only if the ''fixed'' input is non-empty.']);
    sHelp.estimrep = sprintf([...
        '-estimrep: Set to 1 if want to estimate the model with the breaks selected\n',...
        'using the repartition method.']);
    sHelp.estimseq = sprintf([...
        '-estimseq: Set to 1 if want to estimate the model with the number of breaks\n',...
        'selected using the sequential procedure.']);
    sHelp.exogenous = sprintf(...
        '-exogenous: A cellstr with the exogenous variables of the model.');
    sHelp.fixed = sprintf([...
        '-fixed: A cellstr with the variables of the model to have fixed coefficients.\n',...
        'Use the ''initBeta'' option to set the coefficients.']);
    sHelp.hetdat = sprintf([...
        '-hetdat: Option for the construction of the F tests. Set to 1 if you want to\n',...
        'allow different moment matrices of the regressors across segments. If hetdat=0,\n',...
        'the same moment matrices are assumed for each segment and estimated from the\n',... 
        'full sample. It is recommended to set hetdat=1 if ''fixed'' is non-empty.']);
    sHelp.hetvar = sprintf([...
        '-hetvar: Option for the construction of the F tests. Set to 1 if want to allow\n',...
        'for the variance of the residuals to be different across segments. If hetvar=0,\n',...
        'the variance of the residuals is assumed constant across segments and constructed\n',...
        'from the full sample. This option is not available when ''robust'' is set to 1.']);
    sHelp.hetomega = sprintf([...
        '-hetomega: Used in the construction of the confidence intervals for the break\n',... 
        'dates. If hetomega=0, the long run covariance matrix of zu is assumed identical\n',... 
        'across segments (the variance of the errors u if ''robust'' is set to 0)']);
    sHelp.hetq = sprintf([...
        '-hetq: Used in the construction of the confidence intervals for the break dates.\n',... 
        'If hetq=0, the moment matrix of the data is assumed identical across segments.']);
    sHelp.initBeta = sprintf([...
        '-initBeta: Initial value of beta. Only if the ''fixed'' input is non-empty.\n',...
        'Must match the number of fixed coefficients.']);
    sHelp.maxi = sprintf([...
        '-maxi: Maximum number of iterations for the nonlinear procedure to obtain\n',...
        'global minimizers. Only if the ''fixed'' input is non-empty.']);
    sHelp.maxNumBreaks = sprintf(...
        '-maxNumBreaks: Maximum number of breaks. As an integer.');
    sHelp.minSegment = sprintf([...
        '-minSegment: Minimal length of a segment. Note: if ''robust'' is set to 1,\n',... 
        '''minSegment'' should be set at a larger value. Must be greater than the number,\n',...
        'of regressors + the number of deegrees of freedom you want. Default is\n',...
        'round(critical*T) (i.e. when empty)']);
    sHelp.prewhit = sprintf([...
        '-prewhit: Set to 1 if you want to apply AR(1) prewhitening prior to estimating\n',...
        'the long run covariance matrix.']);
    sHelp.printd = sprintf([...
        '-printd: set to 1 if want the output from the iterations to be printed. \n',...
        'Only if the ''fixed'' input is non-empty.']);
    sHelp.robust = sprintf([...
        '-robust: Set to 1 if youwant to allow for heterogeneity and autocorrelation\n',...
        'in the residuals, 0 otherwise. The method used is Andrews(1991) automatic\n',...
        'bandwidth with AR(1) approximation and the quadratic kernel. Note:\n',...
        'Do not set to 1 if lagged dependent variables are included as regressors.']);
    sHelp.startDate = sprintf([...
        '-startDate: The ''startDate'' option is the first observation to be used to\n',...
        'estimate the breaks. Either a string with the date or an object of class nb_date.\n',...
        'If empty, last date avilable will be used.']);
    sHelp.time_trend = sprintf(...
        '-time_trend: Add time trend to the estimated equation.');
    
    % Pick out the wanted help and send it to the user
    switch lower(option)
        case 'all'
            
            helpText = char(10);
            fields   = sort(fieldnames(sHelp));
            for ii = 1:length(fields)
                helpText = horzcat(helpText,sHelp.(fields{ii}),char(10),char(10)); %#ok<AGROW>
            end
            
        otherwise
            
            try
                helpText = sHelp.(option);
            catch %#ok<CTCH>
                if ischar(option)
                helpText = sprintf(['There is no available help for the option ''' option, '''.\n',...
                    'Valid inputs are either an option for the nb_singleEq class, or ''all''']);
                else
                    helpText = 'Input must be a string!';

                end
            end
    end
    
end

