function res = print(obj,precision)
% Syntax:
%
% res = print(obj)
%
% Description:
%
% Print test results.
% 
% Input:
% 
% - obj : An object of class nb_chowTestStatistic.
% 
% Output:
% 
% - res : A string with the test results.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin<2
        precision = '';
    end
    
    if isempty(precision)
        precision = '%8.6f';
    else
        if ~ischar(precision)
            error([mfilename ':: The precision input must be of the type %8.6f.'])
        end
        precision(isspace(precision)) = '';
        if ~strncmp(precision(1),'%',1)||~all(isstrprop(precision([2,4]),'digit'))||...
           ~isstrprop(precision(end),'alpha')
            error([mfilename ':: The precision input must be of the type %8.6f.'])
        end
    end
   
    if isempty(fieldnames(obj.results))
        obj = doTest(obj);
    end
    
    options = obj.options;
    results = obj.results;
    m       = options.maxNumBreaks;
    q       = results.numCoeff;
    siglev  = results.siglev;
    
    estimbic = 0;
    estimlwz = 0;
    estimfix = 0;
    if ischar(options.criterion)
        switch lower(options.criterion)
            case 'bic'
                estimbic = 1;
            case 'lwz' 
                estimlwz = 1;
            otherwise
                error([mfilename 'The criterion option must be set to ''bic'' or ''lwz'' if given as a string.'])
        end
    elseif nb_isScalarInteger(options.criterion)
        estimfix = 1;
    else
        error([mfilename 'The criterion option must be set to ''bic'',''lwz'' or a scalar integer.'])
    end
    
    start = options.startDate;
    if isempty(start)
        start = obj.data.startDate;
    else
        start = nb_date.toDate(start,obj.data.frequency);
    end
    
    % Print results
    %--------------------------------------------------------------
    res = sprintf('Test: %s','Bai and Perron test for multiple breaks');
    res = char(res,sprintf('%s',nb_clock('gui')));
    res = char(res,'');
    
    res = char(res,'----------------------------------------------------------------------------');
    glob    = results.glob;
    datevec = results.datevec;
    for i=1:m
        res   = char(res,['The model with ' int2str(i) 'breaks has SSR : ' num2str(glob(i,1),precision)]);
        dates = start + datevec(1:i,i)';
        res   = char(res,['The dates of the breaks are    : ' toString(toString(dates))]);
    end
    
    %======================================================================
    
    res = char(res,'----------------------------------------------------------------------------');
    res = char(res,'Output from the testing procedures');
    res = char(res,'----------------------------------------------------------------------------');
    res = char(res,'a) supF tests against a fixed number of breaks');
    res = char(res,'----------------------------------------------------------------------------');
    res = char(res,'');
    
    ftest = results.ftest;
    for i = 1:m
        res = char(res,['The supF test for 0 versus ' int2str(i) ' breaks (scaled by number of estimated coefficients) is: ' num2str(ftest(i,1),precision)]);
    end
    
    res = char(res,'');
    if q < 11
        for j=1:4
            cv = baiPerron.getcv1(j,options.critical);
            res = char(res,['The critical values at the ' num2str(siglev(j,1)) '% level are (for 1 to ' int2str(m) '): ' nb_cellstr2String(nb_double2cell(cv(q,1:m),precision),' | ')]);
        end
    end
    res = char(res,'');

    res = char(res,'----------------------------------------------------------------------------');
    res = char(res,'b) Dmax tests against an unknown number of breaks');
    res = char(res,'----------------------------------------------------------------------------');
    res = char(res,['The UDmax test is: ' num2str(max(ftest),precision)]);
    res = char(res,'');
    if q < 11
        for j=1:4
            cvm = baiPerron.getdmax(j,options.critical);
            res = char(res,['The critical value at the ' num2str(siglev(j,1)) '% level is: ' num2str(cvm(q,1),precision)]);
        end
    end
    
%     res    = char(res,'----------------------------------------------------------------------------');
%     res    = char(res,'');
%     wftest = results.wftest;
%     for j=1:4
%         res = char(res,['The WDmax test at the ' num2str(siglev(j,1)) '% level is: ' num2str(max(wftest(:,j)),precision)]);
%     end
%     res = char(res,'----------------------------------------------------------------------------');

    res = char(res,'');
    res   = char(res,'----------------------------------------------------------------------------');
    res   = char(res,'supF(l+1|l) tests using global optimizers under the null');
    res   = char(res,'----------------------------------------------------------------------------');
    supfl = results.supfl;
    ndat  = results.ndat;
    for i=1:m-1
        res = char(res,['The supF(' int2str(i+1) '|' int2str(i) ') test is: ' num2str(supfl(i),precision)]);
        res = char(res,['It corresponds to a new break at: ' toString(start + ndat)]);
    end
    res = char(res,'----------------------------------------------------------------------------');
    res = char(res,'');
    
    if q < 11
        for j=1:4
            cv  = baiPerron.getcv2(j,options.critical);
            res = char(res,['The critical values of supF(l+1|l) at the ' num2str(siglev(j,1)) '% level are (for l = 1:' int2str(m) '): ' nb_cellstr2String(nb_double2cell(cv(q,1:m),precision),' | ')]);
        end
    end
    res = char(res,'');
    
    %======================================================================
    res = char(res,'----------------------------------------------------------------------------');
    res = char(res,'Output from the application of Information criteria');
    res = char(res,'----------------------------------------------------------------------------');
    
    bic = results.bic;
    lwz = results.lwz;
    for i= 1:m+1
        res = char(res,['With ' int2str(i-1) ' breaks: ']);
        res = char(res,['BIC = ' num2str(bic(i,1),precision)]) ;
        res = char(res,['LWZ = ' num2str(lwz(i,1),precision)]);
        res = char(res,'');
    end
    [~,mbic] = min(bic);
    [~,mlwz] = min(lwz);
    res = char(res,['The number of breaks chosen by BIC is : ' int2str(mbic-1)]);
    res = char(res,['The number of breaks chosen by LWZ is : ' int2str(mlwz-1)]);
    res = char(res,'----------------------------------------------------------------------------');
    res = char(res,'');
    
    %======================================================================
    if estimbic == 1
        res = char(res,'----------------------------------------------------------------------------');
        res = char(res,'Output from the estimation of the model selected by BIC');
        res = char(res,'----------------------------------------------------------------------------');
    elseif estimlwz == 1
        res = char(res,'----------------------------------------------------------------------------');
        res = char(res,'Output from the estimation of the model selected by LWZ');
        res = char(res,'----------------------------------------------------------------------------');
    elseif estimfix == 1
        res = char(res,'----------------------------------------------------------------------------');
        res = char(res,'Output from the estimation of the model selected by a fixed number of breaks');
        res = char(res,'----------------------------------------------------------------------------');
    end
    res = char(res,'');
    
    if results.selectedBreak == 0    
        res = char(res,'No breaks are selected found.');
    else
        
        pvdel = results.pvdel;
        bound = results.bound;
        
        res = char(res,'----------------------------------------------------------------------------');
        res = char(res,'Corrected standard errors for the coefficients');
        res = char(res,'----------------------------------------------------------------------------');

        d = (results.selectedBreak + 1)*q + length(options.fixed);
        for i=1:d
            res = char(res,['The corrected standard errors for coefficient ' int2str(i) ' is : ' num2str(sqrt(pvdel(i,i)),precision)]);
        end

        if options.robust==0 && options.hetdat==1 && options.hetvar==0
            res = char(res,'In thie case robust=0, hetdat=1 and hetvar=0, the "corrected" are the same');
            res = char(res,'as that of the printout except for a different small sample correction.');
        end
        
        res = char(res,'');
        res = char(res,'----------------------------------------------------------------------------');
        res = char(res,'Confidence intervals for the break dates');
        res = char(res,'----------------------------------------------------------------------------');
        for i=1:m
            res = char(res,['The 95% C.I. for the ' int2str(i) 'th break is : ' num2str(bound(i,1)) '-' num2str(bound(i,2))]);
            res = char(res,['The 90% C.I. for the ' int2str(i) 'th break is : ' num2str(bound(i,3)) '-' num2str(bound(i,4))]);
        end
    end
    res = char(res,'----------------------------------------------------------------------------');
    res = char(res,'');
    
    %======================================================================
    if options.estimseq
        
        nbreak  = results.nbreak;
        dateseq = results.dateseq;
        for j=1:4
            res = char(res,'----------------------------------------------------------------------------');
            res = char(res,['Output from the sequential procedure at significance level ' num2str(siglev(j,1)) '%']);
            res = char(res,'----------------------------------------------------------------------------');
            res = char(res,['The sequential procedure estimated the number of breaks: ' int2str(nbreak(j))]);
            if nbreak(j) >= 1
                dates = start + dateseq(j,1:nbreak(j,1));
                res   = char(res,['The break dates are: ' toString(toString(dates))]);
            end
            res = char(res,'----------------------------------------------------------------------------');
            res = char(res,'');
        end
        
        report = true;
        while j <= 4

            res = char(res,'----------------------------------------------------------------------------');
            res = char(res,'Output from the estimation of the model selected by the sequential method');
            res = char(res,['at significance level ' num2str(siglev(j,1)) '%']);
            if report
                if nbreak(j,1)==0
                    res = char(res,'----------------------------------------------------------------------------');
                    res = char(res,'The sequential procedure found no breaks.');
                else
                    res = char(res,'----------------------------------------------------------------------------');
                    res = char(res,'Corrected standard errors for the coefficients');
                    res = char(res,'----------------------------------------------------------------------------');

                    pvdel  = results.sequential.(['pvdel' int2str(j)]);
                    bound  = results.sequential.(['bound' int2str(j)]);

                    d = (nbreak(j,1) + 1)*q + length(options.fixed);
                    for i=1:d
                        res = char(res,['The corrected standard errors for coefficient ' int2str(i) ' is : ' num2str(sqrt(pvdel(i,i)),precision)]);
                    end

                    if options.robust==0 && options.hetdat==1 && options.hetvar==0
                        res = char(res,'In thie case robust=0, hetdat=1 and hetvar=0, the "corrected" are the same');
                        res = char(res,'as that of the printout except for a different small sample correction.');
                    end

                    res = char(res,'');
                    res = char(res,'----------------------------------------------------------------------------');
                    res = char(res,'Confidence intervals for the break dates');
                    res = char(res,'----------------------------------------------------------------------------');
                    for i = 1:nbreak(j,1)
                        res = char(res,['The 95% C.I. for the ' int2str(i) 'th break is : ' num2str(bound(i,1)) '-' num2str(bound(i,2))]);
                        res = char(res,['The 90% C.I. for the ' int2str(i) 'th break is : ' num2str(bound(i,3)) '-' num2str(bound(i,4))]);
                    end
                end
            end   

            j = j + 1;
            if j <= 4
                if nbreak(j,1) == nbreak(j-1,1);
                    if nbreak(j,1)==0
                        report = false;
                        res = char(res,['For the' num2str(siglev(j,1)) '% level, the model is the same as for the ' num2str(siglev(j-1,1)) '% level.']);
                        res = char(res,'The estimation is not repeated.');
                    else
                        if dateseq(j,1:nbreak(j,1)) == dateseq(j-1,1:nbreak(j-1,1))
                            res = char(res,['For the ' num2str(siglev(j,1)) '% level, the model is the same as for the ' num2str(siglev(j-1,1)) '% level.']);
                            res = char(res,'The estimation is not repeated.');
                            report = false;
                        end
                    end
                else
                    report = true;
                end
            end
            res = char(res,'----------------------------------------------------------------------------');
            res = char(res,'');

        end
        
    end
    
    %======================================================================
    if options.estimrep
        
        report = true;
        while j <= 4

            res = char(res,'----------------------------------------------------------------------------');
            res = char(res,['Output from the repartition procedure for the ' num2str(siglev(j,1)) '% significance level']);
            if report
                if nbreak(j,1)==0
                    res = char(res,'----------------------------------------------------------------------------');
                    res = char(res,'The sequential procedure found no break and ');
                    res = char(res,'the repartition procedure is skipped.');
                else
                    res = char(res,'----------------------------------------------------------------------------');
                    res = char(res,'Corrected standard errors for the coefficients');
                    res = char(res,'----------------------------------------------------------------------------');

                    pvdel  = results.repartition.(['pvdel' int2str(j)]);
                    bound  = results.repartition.(['bound' int2str(j)]);

                    d = (nbreak(j,1) + 1)*q + length(options.fixed);
                    for i=1:d
                        res = char(res,['The corrected standard errors for coefficient ' int2str(i) ' is:' num2str(sqrt(pvdel(i,i)),precision)]);
                    end

                    if options.robust==0 && options.hetdat==1 && options.hetvar==0
                        res = char(res,'In thie case robust=0, hetdat=1 and hetvar=0, the "corrected" are the same');
                        res = char(res,'as that of the printout except for a different small sample correction.');
                    end

                    res = char(res,'');
                    res = char(res,'----------------------------------------------------------------------------');
                    res = char(res,'Confidence intervals for the break dates');
                    res = char(res,'----------------------------------------------------------------------------');
                    for i = 1:nbreak(j,1)
                        res = char(res,['The 95% C.I. for the ' int2str(i) 'th break is: ' num2str(bound(i,1)) '-' num2str(bound(i,2))]);
                        res = char(res,['The 90% C.I. for the ' int2str(i) 'th break is: ' num2str(bound(i,3)) '-' num2str(bound(i,4))]);
                    end
                end
            end   

            j = j + 1;
            if j <= 4
                if nbreak(j,1) == nbreak(j-1,1);
                    if nbreak(j,1)==0
                        report = false;
                        res = char(res,['For the' num2str(siglev(j,1)) '% level, the model is the same as for the ' num2str(siglev(j-1,1)) '% level.']);
                        res = char(res,'The estimation is not repeated.');
                    else
                        if dateseq(j,1:nbreak(j,1)) == dateseq(j-1,1:nbreak(j-1,1))
                            res = char(res,['For the ' num2str(siglev(j,1)) '% level, the model is the same as for the ' num2str(siglev(j-1,1)) '% level.']);
                            res = char(res,'The estimation is not repeated.');
                            report = false;
                        end
                    end
                else
                    report = true;
                end
            end
            res = char(res,'----------------------------------------------------------------------------');
            res = char(res,'');

        end
        
    end
      
end
