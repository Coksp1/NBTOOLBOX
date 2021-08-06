%% Get help on this example

% Superclass of the nb_day, nb_week, nb_month, nb_quarter, nb_semiAnnual 
% and nb_year classes
help nb_date 

% Subclasses
help nb_day
help nb_week
help nb_month
help nb_quarter
help nb_semiAnnual 
help nb_year

%% A day

aDay = nb_day(1,1,2012)
aDay = nb_day('01.01.2012')
aDay = nb_day('2012M1D1')
% All will of course result in an object representing the same day


%% A month
aMonth = nb_month(1,2012)
aMonth = nb_month('01.01.2012')
aMonth = nb_month('31.01.2012')
aMonth = nb_month('2012M1')
% All will result in an object representing the same month


%% A quarter
aQuarter = nb_quarter(1,2012)
aQuarter = nb_quarter('01.01.2012')
aQuarter = nb_quarter('31.03.2012')
aQuarter = nb_quarter('2012Q1')
% All will result in an object representing the same quarter

%% A year
aYear = nb_year(2012)
aYear = nb_year('01.01.2012')
aYear = nb_year('31.12.2012')
aYear = nb_year('2012')
% All will result in an object representing the same year 


%% Plus and minus

% Both plus and minus operator are defined for these objects:
aQuarterAhead     = aQuarter + 1
aQuarterBackwards = aQuarter - 1
diff              = aQuarterAhead - aQuarter

%% Convert an object to a string

quarterAsString = aQuarter.toString()      % Will give '2012Q1'
quarterAsString = aQuarter.toString('xls') % Will give '01.01.2012'

%% Get all the dates between two dates as a cellstr:
anotherQuarter = nb_quarter(4,2012);
dates          = aQuarter:anotherQuarter
% Will result in:
% dates = 
% 
%     '2012Q1'
%     '2012Q2'
%     '2012Q3'
%     '2012Q4'

% See also the toDates method 

%% Initialize a date object from a string or a nb_date object

% If you are writing a function where a date input can be a string  
% or a date object. The nb_date.toDate function can be a nice tool. 
% Be aware that you must now which frequency you are tolerating.
dateObj = nb_date.toDate(aQuarter,4)
dateObj = nb_date.toDate('2012Q1',4)
% Both will result in the same object

%% Initialize an object with unknown frequency

% If you do not know the frequency, you can use the 
% nb_date.date2freq method.
[dateObj,frequency] = nb_date.date2freq(aQuarter)
[dateObj,frequency] = nb_date.date2freq('2012Q1')

% If you want to interpret dates of the format 'dd.mm.yyyy' you
% must provide a cellstr of dates (I.e. at least two dates)
% The last input to the method call below allows for this to be 
% checked
[dateObj,frequency] = nb_date.date2freq({'31.03.2012';...
                                         '30.06.2012'},'xls')                    
