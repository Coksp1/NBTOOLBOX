function [yData,outData,outp,err,mdl] = x12(data,startdate,dummy,options)
% Syntax:
%
% [yData,outData,outp,err,mdl] = x12(data,startdate,dummy,options)
%
% Description:
%
% Do x12 Census adjustment to time series using x12awin.exe.
%
% This is a file copied from the IRIS Toolbox an adapted to the
% NB Toolbox. 
%
% x12awin.exe is a program developed by: 
%
% U. S. Department of Commerce, U. S. Census Bureau
%
% X-12-ARIMA quarterly seasonal adjustment Method,
% Release Version 0.3  Build 192
% 
% This method modifies the X-11 variant of Census Method II
% by J. Shiskin A.H. Young and J.C. Musgrave of February, 1967.
% and the X-11-ARIMA program based on the methodological research
% developed by Estela Bee Dagum, Chief of the Seasonal Adjustment
% and Time Series Staff of Statistics Canada, September, 1979.
% 
% This version of X-12-ARIMA includes an automatic ARIMA model
% selection procedure based largely on the procedure of Gomez and
% Maravall (1998) as implemented in TRAMO (1996).
% 
% Input:
% 
% - data      : double
% 
% - startdate : An nb_date object.
%
% - dummy     : double.
%
% - options   : A structure with options.
%
% Output:
% 
% - yData     : A double with the original data appended backcast
%               and forecast.
%
% - outData   : The adjusted data.
%
% - outp      : A cellstr array with the output files from 
%               x12awin.exe
% 
% - err       : A cellstr array with error files from x12awin.exe
%
% - mdl       : A struct with ARIMA model estimates.
%
% Written by Jaromir Benes
% Modified by Kenneth Sæterhagen Paulsen

% Copyright (C) 2007-2017 IRIS Solutions Team. All rights reserved.

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    ind = find(strcmpi(options.mode,{'mult','add','pseudoadd','logadd','auto'}),1);
    if isempty(ind)
        warning([mfilename ':: Wrong input given to the ''mode'' input. Reset to ''auto''.'])
    end

    if ischar(options.output)
        options.output = {options.output};
    else
        options.output = {'d11'};
    end

    % Get the entire path to this file.
    thisdir = fileparts(mfilename('fullpath'));

    if strcmpi(options.specfile,'default')
        options.specfile = fullfile(thisdir,'default.spc');
    end

    %**************************************************************************

    kb   = options.backcast;
    kf   = options.forecast;
    nper = size(data,1);
    nx   = size(data,2);

    % Output data.
    outData = nan(nper,nx);
    yData   = nan(nper + kb + kf,nx);
   
    freq = startdate.frequency;
    if freq ~= 4 && freq ~= 12
        error('x12:frequencyUnadjustable',[mfilename ':: It is only possible to seasonally adjust monthly and quartely data.'])
    end
    
    mdl  = struct('mode',NaN,'spec',[],'ar',[],'ma',[]);
    mdl  = mdl(ones(1,nx));
    outp = cell(1,nx);
    err  = cell(1,nx);
    
    for i = 1 : nx
        
        [~,tmptitle] = fileparts(tempname(pwd()));
        first        = find(~isnan(data(:,i)),1);
        last         = find(~isnan(data(:,i)),1,'last');
        dataT        = data(first:last,i);
        proceed      = 1;
        
        if length(dataT) < 3*freq
            if options.warning
                warning('x12:threeYearWarning','X12 requires three or more years of observations.');
            end
            proceed = 0;
        end
        
        if length(dataT) > 70*freq
            if options.warning
                warning('x12:seventyYearWarning','X12 cannot handle more than 70 years of observations.');
            end
            proceed = 0;
        end
        
        if ~options.missing && any(isnan(dataT))
            if options.warning
                warning('x12:missingObservations',['Input data contain within-sample NaNs. ', ...
                    'To allow for in-sample NaNs, use the option ''missing'', 1.']);
            end
            proceed = 0;
        end
        
        if proceed
            
            if length(dataT) > 15*freq && kb > 0
                if options.warning
                    warning('x12:backcastWarning', 'X12 does not produce backcasts for time series longer than 15 years.');
                end
            end
            
            start                 = startdate + first - 1;
            [aux,fcast,bcast]     = xxrunx12(thisdir,tmptitle,dataT,start,dummy,options);
            outData(first:last,i) = aux;
            
            % Append forecasts and backcasts to original data.
            yData(first:last + kb + kf,i) = [bcast; dataT; fcast];
            
            % Catch output file.
            if exist([tmptitle,'.out'],'file')
                outp{i} = xxreadoutputfile([tmptitle,'.out']);
            end
            
            % Catch error file.
            if exist([tmptitle,'.err'],'file')
                err{i} = xxreadoutputfile([tmptitle,'.err']);
            end
            
            % Catch ARIMA model specification.
            if exist([tmptitle,'.mdl'],'file')
                mdl(i) = xxreadmodel([tmptitle,'.mdl'],outp{i});
            end
            
            % Delete all X12 files.
            if ~isempty(options.saveas)
                dosaveas(options,tmptitle)
            end
            
            % Delete temporary files
            if options.cleanup
                stat = warning();
                warning('off'); %#ok<WNOFF>
                delete([tmptitle,'.*']);
                warning(stat);
            end
            
        end
        
    end

end

%==================================================================
% Subfunctions.
%==================================================================

function dosaveas(options,tmptitle)

    [fpath,ftitle] = fileparts(options.saveas);
    list           = dir([tmptitle,'.*']);
    for ii = 1 : length(list)
        [~,~,fext] = fileparts(list(ii).name);
        copyfile(list(ii).name,fullfile(fpath,[ftitle,fext]));
    end

end

%**************************************************************************
function [DATA,FCAST,BCAST] = xxrunx12(THISDIR,TMPTITLE,DATA,STARTDATE,DUMMY,OPT)

    FCAST = zeros(0,1);
    BCAST = zeros(0,1);

    % Flip sign if all values are negative
    % so that multiplicative mode is possible.
    flipsign = false;
    if all(DATA < 0)
        DATA     = -DATA;
        flipsign = true;
    end

    % Check for the estimation mode.
    nonpositive = any(DATA <= 0);
    if strcmp(OPT.mode,'auto')
        if nonpositive
            OPT.mode = 'add';
        else
            OPT.mode = 'mult';
        end
    elseif strcmp(OPT.mode,'mult') && nonpositive
        if OPT.warning
            warning('x12:multNotAnOption',['Unable to use multiplicative mode because of ', ...
                'input data combine positive and non-positive numbers. Switching to additive mode.']);
        end
        OPT.mode = 'add';
    end

    % Write a spec file.
    xxspecfile(TMPTITLE,DATA,STARTDATE,DUMMY,OPT);

    % Set up a system command to run X12a.exe, enclosing the command in
    % double quotes.
    if ispc()
        command = ['"',fullfile(THISDIR,'x12awin.exe'),'" ',TMPTITLE];
    elseif ismac()
        command = ['"',fullfile(THISDIR,'x12amac'),'" ',TMPTITLE];
    elseif isunix()
        command = ['"',fullfile(THISDIR,'x12aunix'),'" ',TMPTITLE];
    else
        error('Cannot determine your operating system and choose the appropriate X12-ARIMA executable.');
    end

    [status,result] = system(command);
    if OPT.display
        disp(result);
    end

    % Return NaNs if X12 fails.
    if status ~= 0
        DATA(:) = NaN;
        if OPT.warning
            if ~ischar(result)
                warning('x12:unableToExecute','Unable to execute X12.');
            else
                warning('x12:unableToExecute',['Unable to execute X12; ' result]);
            end
        end
        return
    end

    % Read in-sample results.
    nper = length(DATA);
    [DATA,flagdata] = xxgetoutputdata(TMPTITLE,nper,OPT.output,2);

    % Read forecasts.
    flagfcast = true;
    kf        = OPT.forecast;
    if kf > 0
        [FCAST,flagfcast] = xxgetoutputdata(TMPTITLE,kf,{'fct'},4);
    end

    % Read backcasts.
    BCAST = zeros(0,1);
    kb    = OPT.backcast;
    if kb > 0
        BCAST = xxgetoutputdata(TMPTITLE,kb,{'bct'},4);
    end

    if ~flagdata || ~flagfcast
        warning('x12:unableToReadOutput', ...
            ['Unable to read X12 output file(s). This is most likely because ', ...
            'X12 failed to estimate an appropriate seasonal model or failed to ', ...
            'converge. Run X12 with three output arguments ', ...
            'to capture the X12 output and error messages.']);
        return
    end

    if flipsign
        DATA  = -DATA;
        FCAST = -FCAST;
        BCAST = -BCAST;
    end

end

%******************************************************************
function xxspecfile(TMPTITLE,DATA,STARTDATE,DUMMY,OPT)
% xxspecfile  Create and save SPC file based on a template.

    datayear = STARTDATE.year;
    if isa(STARTDATE,'nb_month')
        dataper = STARTDATE.month;
    else
        dataper = STARTDATE.quarter;
    end
    
    DUMMYSTART = STARTDATE - OPT.backcast;
    dummyyear  = DUMMYSTART.year;
    if isa(DUMMYSTART,'nb_month')
        dummyper = DUMMYSTART.month;
    else
        dummyper = DUMMYSTART.quarter;
    end

    spec = file2char(OPT.specfile);

    % Time series specs.

    % Check for the required placeholders $series_data$ and $x11_save$:
    if length(strfind(spec,'$series_data$')) ~= 1 || length(strfind(spec,'$x11_save$')) ~= 1
        error(['Invalid X12 spec file. Some of the required placeholders, ', ...
            '$series_data$ and $x11_save$, are missing or used more than once.']);
    end

    % Data.
    format = '%.8f';
    cdata  = sprintf(['    ',format,'\r\n'],DATA);
    cdata  = strrep(cdata,sprintf(format,-99999),sprintf(format,-99999.01));
    cdata  = strrep(cdata,'NaN','-99999');
    spec   = strrep(spec,'$series_data$',cdata);

    % Seasonal period.
    spec = strrep(spec,'$series_freq$',sprintf('%g',STARTDATE.frequency));
    
    % Start date.
    spec = strrep(spec,'$series_startyear$',sprintf('%g',datayear));
    spec = strrep(spec,'$series_startper$',sprintf('%g',dataper));
    
    % Save missing value adjusted series?
    if strcmp(OPT.output,'mv')
        spec       = strrep(spec,'$series_missingvaladj$','save = (mv)');
        OPT.output = setdiff(OPT.output,{'mv'});
    else
        spec = strrep(spec,'$series_missingvaladj$','');
    end    

    % Transform specs.
    if any(strcmp(OPT.mode,{'mult','pseudoadd','logadd'}))
        replace = 'log';
    else
        replace = 'none';
    end
    spec = strrep(spec,'$transform_function$',replace);

    % AUTOMDL specs.
    spec = strrep(spec,'$maxorder$',sprintf('%g %g',round(OPT.maxorder)));

    % FORECAST specs.
    spec = strrep(spec,'$forecast_maxback$',sprintf('%g',OPT.backcast));
    spec = strrep(spec,'$forecast_maxlead$',sprintf('%g',OPT.forecast));

    % REGRESSION specs. If there's no REGRESSSION variable, we cannot include
    % the spec in the spec file because X12 would complain. In that case, we
    % keep the entire spec commented out. If tdays is requested but no user
    % dummies are specified, we need to keep the dummy section commented out,
    % and vice versa.
    if OPT.tdays || ~isempty(DUMMY)
        
        spec = strrep(spec,'#regression ','');
        if OPT.tdays
            spec = strrep(spec,'#tdays ','');
            spec = strrep(spec,'$tdays$','td');
        end
        
        if ~isempty(DUMMY)
            
            spec = strrep(spec,'#dummy ','');
            ndummy = size(DUMMY,2);
            name = '';
            for i = 1 : ndummy
                name = [name,sprintf('dummy%g ',i)]; %#ok<AGROW>
            end
            spec = strrep(spec,'$dummy_type$',lower(OPT.dummytype));
            spec = strrep(spec,'$dummy_name$',name);
            spec = strrep(spec,'$dummy_data$',sprintf('    %.8f\r\n',DUMMY));
            spec = strrep(spec,'$dummy_startyear$',sprintf('%g',dummyyear));
            spec = strrep(spec,'$dummy_startper$',sprintf('%g',dummyper));
            
        end
        
    end

    % ESTIMATION specs.
    spec = strrep(spec,'$maxiter$',sprintf('%g',round(OPT.maxiter)));
    spec = strrep(spec,'$tolerance$',sprintf('%e',OPT.tolerance));

    % X11 specs.
    spec = strrep(spec,'$x11_mode$',OPT.mode);
    spec = strrep(spec,'$x11_save$',sprintf('%s ',OPT.output{:}));

    char2file(spec,[TMPTITLE,'.spc']);

end

%**************************************************************************
function [DATA,FLAG] = xxgetoutputdata(TMPTITLE,NPER,OUTPUT,NCOL)

    if ischar(OUTPUT)
        OUTPUT = {OUTPUT};
    end
    
    FLAG   = true;
    DATA   = zeros(NPER,0);
    format = repmat(' %f',[1,NCOL]);
    for ioutput = 1 : length(OUTPUT)
        
        output = OUTPUT{ioutput};
        fid    = fopen(sprintf('%s.%s',TMPTITLE,output),'r');
        if fid > -1
            fgetl(fid); % skip first 2 lines
            fgetl(fid);
            read = fscanf(fid,format);
            fclose(fid);
        else
            read = [];
        end
        
        if length(read) == NCOL*NPER
            read          = reshape(read,[NCOL,NPER]).';
            DATA(:,end+1) = read(:,2); %#ok<AGROW>
        else
            DATA(:,end+1) = NaN; %#ok<AGROW>
            FLAG          = false;
        end
        
    end
    
end

%**************************************************************************
function C = xxreadoutputfile(FNAME)

    C = file2char(FNAME);
    C = strrep(C,sprintf('\r\n'),sprintf('\n'));
    C = strrep(C,sprintf('\r'),sprintf('\n'));
    C = regexprep(C,'^\s*\n','');
    C = regexprep(C,'\n\s*$','');
    C = regexprep(C,'\n\n+','\n\n');
    
end

%**************************************************************************
function MDL = xxreadmodel(FNAME,OUTPFILE)

    C   = file2char(FNAME);
    MDL = struct('mode',NaN,'spec',[],'ar',[],'ma',[]);

    % ARIMA spec block.
    arima = regexp(C,'arima\s*\{\s*model\s*=([^\}]+)\}','once','tokens');
    if isempty(arima) || isempty(arima{1})
        return
    end
    arima = arima{1};

    % Non-seasonal and seasonal ARIMA model specification
    spec = regexp(arima,'\((.*?)\)\s*\((.*?)\)','once','tokens');
    if isempty(spec) || length(spec) ~= 2 || isempty(spec{1}) || isempty(spec{2})
        return
    end
    specar = sscanf(spec{1},'%g').';
    specma = sscanf(spec{2},'%g').';
    if isempty(specar) || isempty(specma)
        return
    end

    % Estimated AR and MA coefficients.
    estar = regexp(arima,'ar\s*=\s*\((.*?)\)','once','tokens');
    estma = regexp(arima,'ma\s*=\s*\((.*?)\)','once','tokens');
    if isempty(estar) && isempty(estma)
        return
    end
    
    try
        estar = sscanf(estar{1},'%g').';
    catch %#ok<CTCH>
        estar = [];
    end
    
    try
        estma = sscanf(estma{1},'%g').';
    catch %#ok<CTCH>
        estma = [];
    end
    
    if isempty(estar) && isempty(estma)
        return
    end

    mode = NaN;
    if ~isempty(OUTPFILE) && ischar(OUTPFILE)
        tok = regexp(OUTPFILE,'Type of run\s*-\s*([\w\-]+)','tokens','once');
        if ~isempty(tok) && ~isempty(tok{1})
            mode = tok{1};
        end
    end

    % Create output struct only after we make sure all pieces have been read in
    % all right.
    MDL.mode = mode;
    MDL.spec = {specar,specma};
    MDL.ar   = estar;
    MDL.ma   = estma;

end

function [c,flag] = file2char(fname,type,lines)

    if nargin < 3
        lines = Inf;
        selectLines = false;
    else
        lines(round(lines) ~= lines | lines < 1) = [];
        if isempty(lines)
            c = '';
            return
        else
            selectLines = ~isequal(lines,Inf);
        end
    end

    if nargin < 2 || isempty(type)
        type = 'char';
    end

    if iscellstr(fname) && length(fname) == 1
        c    = fname{1};
        flag = true;
        return
    end

    flag = true;
    fid = fopen(fname,'r');
    if fid == -1
        if ~exist(fname,'file')
            error('FILE2CHAR cannot find file ''%s''.',fname);
        else
            error('FILE2CHAR cannot open file ''%s'' for reading.',fname);
        end
    end

    if strcmpi(type,'cellstrl')
        % Remove new line characters.
        c = {};
        while ~feof(fid)
            c{end+1} = fgets(fid); %#ok<AGROW>
        end
        c = do_lastempty(fid,c);
        if selectLines
            n = length(c);
            lines(lines < 1 | lines > n) = [];
            c = c(lines);
        end
    elseif strcmpi(type,'cellstrs') || selectLines
        % Keep new line characters.
        c = {};
        while ~feof(fid)
            c{end+1} = fgets(fid); %#ok<AGROW>
        end
        c = do_lastempty(fid,c);
        if selectLines
            n = length(c);
            lines(lines < 1 | lines > n) = [];
            c = c(lines);
        end
        if ~strcmpi(type,'cellstrs')
            c = [c{:}];
        end
    else
        c = char(transpose(fread(fid,type)));
    end

    if fclose(fid) == -1
        warning('iris:utils', ...
            'FILE2CHAR cannot close file ''%s'' after reading.',fname);
    end

end

function c = do_lastempty(fid,c)
        
    try %#ok<TRYNC>
        % If the last character is newline or return, there is an empty
        % line at the end of the file which is not read by `fgets`. We need
        % to add this empty line to `c`.
        fseek(fid,-1,'eof');
        test = fread(fid,1);
        if test == 10 || test == 13
            c{end+1} = '';
        end
    end

end

function char2file(char,fname,type)

    if nargin < 3
       type = 'char';
    end

    fid = fopen(fname,'w+');
    if fid == -1
        error('Cannot open file ''%s'' for writing.',fname);
    end

    if iscellstr(char)
       char = sprintf('%s\n',char{:});
       if ~isempty(char)
          char(end) = '';
       end
    end

    count = fwrite(fid,char,type);
    if count ~= length(char)
       fclose(fid);
       error('Cannot write character string to file ''%s''.',fname);
    end

    fclose(fid);

end
