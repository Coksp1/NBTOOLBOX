%% Get help on this example

help nb_ts

%% Set the folder of the NB toolbox
% This must be updated!

folder = nb_folder();

%% Initializing an object of class nb_ts

% Reading data from a excel spreadsheet
obj = nb_ts('example_ts_quarterly')

% Reading data from a specific sheet of a excel spreadsheet
% If it does not find the sheet name you provide it will read the
% first sheet of the excel spreadsheet and only set the data set 
% name to the provided string.
obj = nb_ts('example_ts_quarterly','sheet1')

% Reading data from a .mat file
obj = nb_ts('example_ts_quarterly_mat')
          
% Initializing an object of class nb_ts with a double
obj = nb_ts([2,2;2,2;2,2],'double','2012M1',{'Var1','Var2'})

% Initializing an object of class nb_ts with an nb_math_ts object
nb_math_tsObj = nb_math_ts([2,2;2,2;2,2],'2012M1');
obj           = nb_ts(nb_math_tsObj,'','',{'Var1','Var2'})

%% Creating a nb_ts object of random numbers

data = nb_ts.rand('2000Q1',20,3)

%% Transformation

% Take the log
dataC = data.log()

%% Creating a new variable

% Creating a new variable
dataC = data.deleteVariables('Var1');
dataC = data.createVariable('New variable','Var1-Var2')

%% Creating more variables at the same time

dataC = data.createVariable({'Var4','Var5'},...
            {'Var1-Var2','Var1./Var2'})

%% Converting

% Converting the frequency of the data object (lower)
dataC = data.convert(1)

% Converting the frequency of the data object (lower)
dataC = data.window('2002Q1','2003Q4');
data1 = dataC.convert(12)
data2 = dataC.convert(12,'linear')

% Change the base
dataC = data.window('2002Q1','2003Q4');
dataC = dataC.convert(12,'linear','interpolateDate','end')

% Change the base and renames the variables
dataC = data.window('2002Q1','2003Q4');
dataC = dataC.convert(12,'linear','interpolateDate','end','rename')

% Converting to a lower frequency and return the year 2003 even if 
% it is not finished.
dataC = data.window('2002Q1','2003Q3');
dataC = dataC.convert(1,'average','includeLast')

%% Merging

obj1 = nb_ts(ones(4,2),'','2012',{'Var1','Var2'});
obj2 = nb_ts(ones(4,1),'','2012','Var3');
obj3 = nb_ts(ones(4,2),'','2012',{'Var1','Var3'});

% Merging two object
obj4 = obj1.merge(obj2);
obj5 = obj1.merge(obj3)

% Merging two objects with different frequencies
obj1 = nb_ts(ones(2,2),'','2012',{'AUA_Var1','AUA_Var2'});
obj2 = nb_ts(ones(8,1),'','2012Q1','QUA_Var3');
obj3 = obj1.merge(obj2)

% The default setting for merging data with different frequencies
obj3 = obj1.merge(obj2,'start','none','on')

% (Only) change the base for the merging (Same converting method 
% and with renaming)
obj3 = obj1.merge(obj2,'end')

% Do linear interpolation with renaming
obj3 = obj1.merge(obj2,'start','linear')

% Do linear interpolation without renaming
obj3 = obj1.merge(obj2,'start','linear','off')

%% Save an object to a excel file

% Save the data to a excel spreadsheet with the default options.
obj = nb_ts(ones(8,2),'filename','2012Q1',{'QUA_Var1','QUA_Var2'});
obj.saveDataBase()

% Set the name of the written excel spreadsheet
obj = nb_ts(ones(8,2),'filename','2012Q1',{'QUA_Var1','QUA_Var2'});
obj.saveDataBase('saveName','test')

% Set the date format of the written excel spreadsheet
obj = nb_ts(ones(8,2),'filename','2012Q1',{'QUA_Var1','QUA_Var2'});
obj.saveDataBase('saveName','test','dateFormat','xls')

% Saving an object with more data sets:
obj = nb_ts(ones(8,2,2),{'data1','data2'},'2012Q1',...
            {'QUA_Var1','QUA_Var2'});

% Save it as separate excel files
obj.saveDataBase()

% Save it as one excel file each page as a separate worksheet
obj.saveDataBase('saveName','test2','append',1)

%% Save an object to a .mat file or .txt using the 'ext' option

% Save the data to a .mat file
obj = nb_ts(ones(8,2),'filename','2012Q1',{'QUA_Var1','QUA_Var2'});
obj.saveDataBase('saveName','filename','ext','mat')

% Save the data to a .txt file
obj = nb_ts(ones(8,2),'filename','2012Q1',{'QUA_Var1','QUA_Var2'});
obj.saveDataBase('ext','txt','saveName','filename')

%% Convert an nb_ts object to an other MATLAB object

data = nb_ts([2,2,2;2,2,2],'','1994Q1',{'Var1','Var2','Var3'});

% Convert to a structure
s   = data.toStructure()

% Convert to a cell
c   = data.asCell() 

% Convert to a double
d   = data.double()

% Convert to an nb_math_ts object
mts = nb_math_ts(data)
       
% Convert to an nb_cs object
cs  = data.tonb_cs()

%% Mathematical operators
% These operators work on matching series only! If some series are not in
% both objects nan values will be returned.

data1 = nb_ts(ones(2,3)*3,'','1994Q1',{'Var1','Var2','Var3'});
data2 = nb_ts(ones(2,3)*2,'','1994Q1',{'Var1','Var2','Var3'});

% Element-wise operators
data = data1-data2     % Element-wise minus
data = data1+data2     % Element-wise plus
data = data1.*data2    % Element-wise multiplication
data = data1.^data2    % Element-wise power
data = data1./data2    % Element-wise division

% Operators that act on all the data of the object
data = data1-2         % Minus (Only for scalars)
data = data1+2         % Plus (Only for scalars)
data = data1*2         % Multiplication (Only defined when 
                       % multiplied with a scalar)
data = data1^2         % Power (Only defined when taken power with 
                       % a scalar)                       
data = data1/2         % Only defined when divided by a scalar

%% Mathematical operators, part 2
% When calling the mathematical operators in this way, the variables are
% not matched, but instead the data of the two objects are taken as 
% matrices.

% Plus and minus of two object representing a single time series.
X = nb_ts(rand(10,1),'','2012','X')
Y = nb_ts(rand(10,1),'','2012','Y')
Z = callop(X,Y,@plus)
Q = callop(Z,Y,@minus)

% Divide all time series in D with the time series Y
D = nb_ts(rand(10,2),'','2012',{'Q','W'})
M = callop(D,Y,@rdivide)

% Plus two time series, see how it does not try to match variable names
D1 = nb_ts(rand(10,3),'','2012',{'X','Y','Z'},false)
D2 = nb_ts(rand(10,3),'','2012',{'Y','X','Q'},false)
D3 = callop(D1,D2,@plus)

% Compared to the normal plus operator
D4 = D1 + D2

%% Logical operators
% These operators work only on matching series and matching object size! 

data1 = nb_ts(logical([ones(2,2), zeros(2,1)]),'','1994Q1',...
                {'Var1','Var2','Var3'});
data2 = nb_ts(logical([ones(2,1), zeros(2,2)]),'','1994Q1',...
                {'Var1','Var2','Var3'});

data = data1 & data2
data = data1 | data2

data1 = nb_ts(ones(2,3)*3,'','1994Q1',{'Var1','Var2','Var3'});
data2 = nb_ts(ones(2,3)*2,'','1994Q1',{'Var1','Var2','Var3'});

data = data1 > data2
data = data1 >= data2
data = data1 == data2
data = data1 <= data2
data = data1 < data2
data = data1 ~= data2

%% Make a updatable nb_ts object

% Reading data from a excel spreadsheet with full path
obj = nb_ts([folder '\Examples\DataManagement\example_ts_quarterly']);

% Now changes can be made to the file and we can update the object
% given the changes in the data source
obj.update

% If you want to read from a specific worksheet of an excel file
% you must provide the extension.

%% Generic reading of excel with nb_readExcel
% A link will be added to the data source, as long as the full path is
% provided.

d = nb_readExcel([folder '\Examples\DataManagement\example_ts_quarterly']);

                     
%% Call any function on the data of the object

d1   = callfun(d,'func',@(x)1-x);
d1u  = update(d1)

[n,d2,d3] = callfun(d,'func',@test);
d2u       = update(d2)
d3u       = update(d3)
                     
