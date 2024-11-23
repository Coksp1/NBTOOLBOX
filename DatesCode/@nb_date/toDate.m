function dObj = toDate(date,frequency)
% Syntax:
%
% dObj = nb_date.toDate(date,frequency)
%
% Description:
% 
% A static method of the nb_date class.
%
% Transform a given date string to the corresponding date object
% given that the frequency is already know. 
%         
% If the frequency is not know, use the method date2freq() (handles
% also excel dates) or getFreq() (Only nb_ts dates).
% 
% Input:
% 
% - date       : 
%
%   Supported date formats:
%
%   > Daily         : 'dd.mm.yyyy' and 'yyyyMm(m)Dd(d)'
%
%   > Weekly        : 'dd.mm.yyyy' and 'yyyyWw(w)'
%
%   > Monthly       : 'dd.mm.yyyy' and 'yyyyMm(m)'
%
%   > Quarterly     : 'dd.mm.yyyy' and 'yyyyQq'
%
%   > Semiannually  : 'dd.mm.yyyy' and 'yyyySs'
%
%   > Yearly        : 'dd.mm.yyyy' and 'yyyy'   
%
%   > Secondly      : 'yyyy-mm-dd hh:nn:ss' and 'yyyymmddhhnnss'
%                      (only supported if this version of the toolbox
%                      inlcudes the nb_second class)
%
% - frequency :
%
%   > Daily         : 365
%
%   > Weekly        : 52
%
%   > Monthly       : 12
%
%   > Quarterly     : 4
%
%   > Semiannually  : 2
%
%   > Yearly        : 1  
% 
%   > Secondly      : 31536000
%
% Output:
% 
% - dObj      : 
%
%   > Daily         : An nb_day object
%
%   > Weekly        : An nb_week object
%
%   > Monthly       : An nb_month object
%
%   > Quarterly     : An nb_quarter object
%
%   > Semiannually  : An nb_semiAnnual object
%
%   > Yearly        : An nb_year object 
%
%   > Secondly      : An nb_second object
%  
% Examples:
% 
% dObj = nb_date.toDate('2012M1D1',365);
% dObj = nb_date.toDate('2012M1',12);
% dObj = nb_date.toDate('2012Q1',4);
% dObj = nb_date.toDate('2012S1',2);
% dObj = nb_date.toDate('2012',1);
%
% Written by Kenneth S. Paulsen
              
% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if isa(date,'nb_date')

        freq = getFreq(date);
        if freq ~= frequency   
            error([mfilename ':: Wrong frequency:: it must be ' nb_date.getFrequencyAsString(frequency)  ', but is ' nb_date.getFrequencyAsString(freq) '.'])
        else
            dObj = date;
        end

    else

        if isempty(date) || strcmpi(date,'empty date object')
            dObj = nb_date;
            return
        end
        
        if isempty(frequency)
            dObj = nb_date;
            return
        end

        switch frequency

            case 1

                if ischar(date)

                    try
                        dObj = nb_year(date);
                    catch  %#ok<CTCH>
                        error('nb_date:improperDate',[mfilename ':: Wrong frequency you ',...
                              'have given a improper date:: it must be yearly. I.e. ''yyyy'''...
                              ' or ''dd.mm.yyyy'', but is ''' date '''.'])
                    end 

                else
                    error([mfilename ':: Wrong input: it must either be a object which is a subclass of nb_date or a object of class char, but is ' class(date) '.'])
                end

            case 2

                if ischar(date)

                    try
                        dObj = nb_semiAnnual(date);
                    catch 
                        error('nb_date:improperDate',[mfilename ':: Wrong frequency you ',...
                              'have given a improper date:: it must be semiannually. I.e. ''yyyySs''',...
                              ' or ''dd.mm.yyyy'', but is ''' date '''.'])
                    end 

                else
                    error([mfilename ':: Wrong input: it must either be a object which is a subclass of nb_date or a object of class char, but is ' class(date) '.'])
                end

            case 4

                if ischar(date)

                    try
                        dObj = nb_quarter(date);
                    catch 
                        error('nb_date:improperDate',[mfilename ':: Wrong frequency or you ',...
                              'have given a improper date:: it must be quarterly. I.e. ''yyyyQq''',...
                              ' or ''dd.mm.yyyy'', but is ''' date '''.'])
                    end
                else
                    error([mfilename ':: Wrong input: it must either be a object which is a subclass of nb_date or a object of class char, but is ' class(date) '.'])   
                end

            case 12

                if ischar(date)

                    try
                        dObj = nb_month(date);
                    catch 
                        error('nb_date:improperDate',[mfilename ':: Wrong frequency or you ',...
                              'have given a improper date:: it must be monthly. I.e. ''yyyyMm(m)''',...
                              ' or ''dd.mm.yyyy'', but is ''' date '''.'])
                    end
                else
                    error([mfilename ':: Wrong input: it must either be a object which is a subclass of nb_date or a object of class char, but is ' class(date) '.'])    
                end
                
            case 52
                
                if ischar(date)

                    try
                        dObj = nb_week(date);
                    catch 
                        error('nb_date:improperDate',[mfilename ':: Wrong frequency or you ',...
                              'have given an improper date:: it must be weekly. I.e. ''yyyyWw(w)''',...
                              ' or ''dd.mm.yyyy'', but is ''' date '''.'])
                    end
                else
                    error([mfilename ':: Wrong input: it must either be a object which is a subclass of nb_date or a object of class char, but is ' class(date) '.']) 
                end

            case 365

                if ischar(date)

                    try
                        dObj = nb_day(date);
                    catch 
                        error('nb_date:improperDate',[mfilename ':: Wrong frequency or you ',...
                              'have given an improper date:: it must be daily. I.e. ''yyyyMm(m)Dd(d)''',...
                              ' or ''dd.mm.yyyy'', but is ''' date '''.'])
                    end
                else
                    error([mfilename ':: Wrong input: it must either be a object which is a subclass ',...
                        'of nb_date or a object of class char, but is ' class(date) '.']) 
                end
                
            case 31536000

                if ischar(date)

                    try
                        dObj = nb_second(date);
                    catch Err
                        if strcmpi(Err.message,'Undefined function ''nb_second'' for input arguments of type ''char''.')
                            error('nb_date:notSupported',['The version of the toolbox ',...
                                  'you are using does not support a secondly date.'])
                        else
                            error('nb_date:improperDate',[mfilename ':: Wrong frequency or you ',...
                                  'have given an improper date:: it must be secondly. I.e. ',...
                                  '''yyyy-mm-dd hh:nn:ss'' or ''yyyymmddhhnnss'', but is ''' date '''.'])
                        end
                    end
                else
                    error([mfilename ':: Wrong input: it must either be a object which is a subclass ',...
                        'of nb_date or a object of class char, but is ' class(date) '.']) 
                end    

            otherwise

                error([mfilename ':: Unsupported frequency'])

        end

    end
            
end
