%% Get help on this example

help nb_data

%% Set the folder of the NB toolbox
% This must be updated!

folder = nb_folder();

%% Initializing an object of class nb_data

% Reading data from a excel spreadsheet
obj = nb_data('example_data')

% Reading data from a specific sheet of a excel spreadsheet
% If it does not find the sheet name you provide it will read the
% first sheet of the excel spreadsheet and only set the data set 
% name to the provided string.
obj = nb_data('example_data','sheet1')

% Reading data from a .mat file
obj = nb_data('example_data_mat')        
          
%% Initializing an object of class nb_ts with a double

obj = nb_data([2,2;2,2;2,2],'double',1,{'Var1','Var2'})

%% Creating a nb_data object of random numbers

obj = nb_data.rand(1,20,3)

%% Transformation

obj = obj.log()

%% Creating a new variable

% Creating a new variable
obj = obj.deleteVariables('Var3');
obj = obj.createVariable('New variable','Var1-Var2')

%% Creating more variables at the same time

obj = nb_data('example_data_mat');
obj = obj.createVariable({'Var4','Var5'},{'Var1-Var2','Var1./Var2'})

%% Merging

obj1 = nb_data(ones(4,2),'',1,{'Var1','Var2'});
obj2 = nb_data(ones(4,1)*2,'',1,'Var3');
obj3 = nb_data([ones(4,1),ones(4,1)*2],'',1,{'Var1','Var3'});

% Merging two object
obj4 = obj1.merge(obj2)
obj5 = obj1.merge(obj3)

%% Save an object to a excel file

% Save the data to a excel spreadsheet with the default options.
obj = nb_data(ones(8,2),'filename','1',{'QUA_Var1','QUA_Var2'});
obj.saveDataBase()

% Set the name of the written excel spreadsheet
obj = nb_data(ones(8,2),'filename',1,{'QUA_Var1','QUA_Var2'});
obj.saveDataBase('saveName','test')

% Saving an object with more data sets:
obj = nb_data(ones(8,2,2),{'data1','data2'},'2012Q1',...
            {'QUA_Var1','QUA_Var2'});

% Save it as separate excel files
obj.saveDataBase()

% Save it as one excel file each page as a separate worksheet
obj.saveDataBase('saveName','test2','append',1)

%% Save an object to a .mat file or .txt using the 'ext' option

% Save the data to a .mat file
obj = nb_data(ones(8,2),'filename',1,{'QUA_Var1','QUA_Var2'});
obj.saveDataBase('saveName','filename','ext','mat')

% Save the data to a .txt file
obj = nb_data(ones(8,2),'filename',1,{'QUA_Var1','QUA_Var2'});
obj.saveDataBase('ext','txt','saveName','filename')

%% Convert an nb_data object to an other MATLAB object

data = nb_data([2,2,2;2,2,2],'',1,{'Var1','Var2','Var3'});

% Convert to a structure
s   = data.toStructure()

% Convert to a cell
c   = data.asCell()

% Convert to a double
d   = data.double()

% Convert to an nb_cs object
cs  = data.tonb_cs(); 


%% Mathematical operators
% These operators work on matching series only! If some series are not in
% both objects nan values will be returned.

data1 = nb_data(ones(2,3)*3,'',1,{'Var1','Var2','Var3'});
data2 = nb_data(ones(2,3)*2,'',1',{'Var1','Var2','Var3'});

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

%% Logical operators
% These operators work only on matching series and matching object size!

data1 = nb_data([true(2,2), false(2,1)],'','1',{'Var1','Var2','Var3'});
data2 = nb_data([true(2,1), false(2,2)],'','1',{'Var1','Var2','Var3'});

data = data1 & data2
data = data1 | data2

data1 = nb_ts(ones(2,3)*3,'','1',{'Var1','Var2','Var3'});
data2 = nb_ts(ones(2,3)*2,'','1',{'Var1','Var2','Var3'});

data = data1 > data2
data = data1 >= data2
data = data1 == data2
data = data1 <= data2
data = data1 < data2
data = data1 ~= data2

%% Make a updatable nb_data object

% Reading data from a excel spreadsheet with full path
obj = nb_data([folder '\Examples\DataManagement\example_data']);

% Now changes can be made to the file and we can update the object
% given the changes in the data source
obj.update

% If you want to read from a specific worksheet of an excel file
% you must provide the extension.

%% Generic reading of excel with nb_readExcel
% A link will be added to the data source, as long as the full path is
% provided.

d = nb_readExcel([folder '\Examples\DataManagement\example_data']);

