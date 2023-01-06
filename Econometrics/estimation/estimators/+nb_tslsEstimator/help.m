function helpText = help(option,maxChars)
% Syntax:
%
% helpText = nb_tslsEstimator.help
% helpText = nb_tslsEstimator.help(option)
% helpText = nb_tslsEstimator.help(option,maxChars)
%
% Description:
%
% Get the help on the different model options.
% 
% Input:
% 
% - option   : Either 'all' or the name of the option you want to get the
%              help on.
% 
% - maxChars : The max number of chars in the printout of (approx). This
%              applies to the second column of the printout. Default is
%              40.
% 
% Output:
% 
% - helpText : A char with the help.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 2
        maxChars = [];
        if nargin < 1
            option = 'all';
        end
    end
    
    % Genereate help for the different options
    helper   = nb_writeHelp('nb_tslsEstimator',option,'package','timeSeries');
    helper   = set(helper,'max',maxChars);
    helpText = help(helper);
    
end

% function helpText = help(option)
% % Syntax:
% %
% % helpText = nb_tslsEstimator.help(option)
% %
% % Description:
% %
% % Get the help on the different estimation options.
% % 
% % Input:
% % 
% % - option   : Either 'all' or the name of the option you want to get the
% %              help on.
% % 
% % Output:
% % 
% % - helpText : A char with the help.
% %
% % Written by Kenneth Sæterhagen Paulsen
% 
%     if nargin < 1
%         option = 'all';
%     end
% 
%     % Genereate help for the different options
%     sHelp.constant = sprintf([...
%         '-constant: A binary option that decides whether or not there will be a constant term in the model.\n',...
%         'If a Constant term is added, it will be the first variable on the right hand side.']);
%     sHelp.criterion = sprintf([...
%         '-criterion: The Criterion option decides the information criteria used for automatic lag length selection.\n',...
%         'The possible options are Akaike, Modified Akaike, Schwartz, Modified Schwartz, Hannan-Quinn\n',...
%         'and Modified Hannan Quinn. Note that this option will always be set to the shortened form,\n',...
%         'i.e. maic instead of Modified Akaike Information Criterion, and so on. You can set the \n',...
%         'information criterion using the set method. ']);
%     sHelp.data = sprintf(...
%         '-data: A double matrix with the data.');
%     sHelp.datastartdate = sprintf([...
%         '-dataStartDate: The start date of the assign data. Can be empty if cross-sectional is used. See dataTypes.\n',...
%         'This input must be of the format dd.mm.yy,ddmmyy,yyyyMm(m)d(d),yyyyWw(w),yyyyMm(m),yyyyQq(q),\n',...
%         'yyyyKk(k) or yyyy.']);
%     sHelp.datavariables = sprintf(...
%         '-dataVariables: A cellstr with the variables of the data. 1 x nvar');
%     sHelp.datatypes = sprintf([...
%         '-dataTypes: A cellstr with the types of the data. Should only be given if dealing with cross-sectional\n',...
%         ' data. 1 x ntypes']);
%     sHelp.dependent = sprintf([...
%         '-dependent: A cellstr with the dependent variables of the model. Must be a 1 x nvar cellstr.']);
%     sHelp.doTests = sprintf(...
%         '-doTests: Either 1 (true) to do the automatic tests, or 0 (false) to skip them.');
%     sHelp.endogenous = sprintf([...
%         '-endogenous: A cellstr with the endogenous variables of the model. I.e. the variables to be instrumented \n'...
%         'in the first stage of the estimation. Must be a 1 x nvar cellstr. See also instruments.']);
%     sHelp.estim_end_ind = sprintf([...
%         '-estim_end_ind: The estim_end_ind option is the final observation that will be included in the estimation.\n',...
%         'As an integer.']);
%     sHelp.estim_start_ind = sprintf([...
%         '-estim_start_ind: The estim_start_ind option is the first observation that will be included in the estimation.\n',...
%         'As an integer.']);
%     sHelp.estim_types = sprintf(...
%         ['-estim_types: estim_types are all the types of the nb_cs object being estimated.\n',...
%         'If the object being estimated isn''t an nb_cs object, this option will not be read.']);
%     sHelp.exogenous = sprintf([...
%         '-exogenous: A cellstr with the exogenous variables of the model. Must be a 1 x nvar cellstr.']);
%     sHelp.instruments = sprintf([...
%         '-instruments: The instrument property allows you to set instruments for endogenous variables in two stage least\n',...
%         'square estimation. The input must take the format (endoVar1, {instruments1},endoVar2,{instruments2}) and so on.']);
%     sHelp.maxlaglength = sprintf([...
%         '-maxLagLength: This option sets the maximum amount of lags allowed when lag length is automatic.']);
%     sHelp.modelselection = sprintf([...
%         '-modelSelection: Setting Model Selection to ''autometrics'' will result in the model automatically selecting\n',...
%         'the lag length that is decided to be the most fitting by the chose criterion.']);    
%     sHelp.modelselectionalpha = sprintf([...
%         '-modelSelectionAlpha: Sets the critical value for the tests used to determine optimal lag length.']);
%     sHelp.nlags = sprintf([...
%         '-nLags: Setting nLags will set the amount of lags used in the regression. Note that this will only be read\n',...
%         'if the option ''modelSelection'' is set to ''''']);
%     sHelp.nlagstests = sprintf([...
%         '-nLagsTests: Sets the number of lags to include in the printed output of the ARCH and autocorr tests.']);
%     sHelp.recursive_estim = sprintf([...
%         '-recursive_estim: A binary input deciding whether or not the estimation will be done recursivly. ']);
%     sHelp.recursive_estim_start_ind = sprintf([...
%         '-recursive_estim_start_ind: Starting period of recursive estimation.']);
%     sHelp.rollingwindow = sprintf([...
%         '-rollingWindow: Length of rolling window for recursive estimation, as a double.']);
%     sHelp.seasonaldummy = sprintf([...
%         '-seasonalDummy: I f you want to include seasonal dummies in your regression you can give; ''centered'' \n'...
%         'or ''uncentered''. Default is not to include them, i.e. ''''. Can only be added if the data is quarterly or \n'...
%         'monthly.']);
%     sHelp.stdtype = sprintf([...
%         '-stdType: Sets the type of standard errors to be calculated. Either ''h'' (homoskedasticity only), ''w'' (White \n',...
%         'heteroskedasticity robust) or ''nw'' (Newey-West heteroskedasticity and autocorrelation robust)']);
%     sHelp.time_trend = sprintf([...
%         '-time_trend: A binary input deciding whether or not to include a time trend in the estimation.']);
% 
%     % Pick out the wanted help and send it to the user
%     switch lower(option)
%         case 'all'
%             
%             helpText = char(10);
%             fields   = sort(fieldnames(sHelp));
%             for ii = 1:length(fields)
%                 helpText = horzcat(helpText,sHelp.(fields{ii}),char(10),char(10)); %#ok<AGROW>
%             end
%             
%         otherwise
%             
%             try
%                 helpText = sHelp.(option);
%             catch %#ok<CTCH>
%                 if ischar(option)
%                 helpText = sprintf(['There is no available help for the option ''' option, '''.\n',...
%                     'Valid inputs are either an option for the nb_singleEq class, or ''all''']);
%                 else
%                     helpText = 'Input must be a string!';
% 
%                 end
%             end
%     end
%     
% end

