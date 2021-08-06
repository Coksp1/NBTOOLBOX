%% Get help on this example

help nb_cs

%% Set the folder of the NB toolbox
% This must be updated!

folder = nb_folder();

%% Initializing an object of class nb_cs

% Reading data from a excel spreadsheet
obj = nb_cs('example_cs')

% Reading data from a specific sheet of a excel spreadsheet
% If it does not find the sheet name you provide it will read the
% first sheet of the excel spreadsheet and only set the data set 
% name to the provided string.
obj = nb_cs('example_cs','sheet1')

% Reading data from a .mat file
obj = nb_cs('example_cs_mat')

%% Initializing an object of class nb_cs with a double

data = nb_cs([2,2,2;2,2,2;2,2,2],'double',...
            {'type1','type3','type2'},{'Var1','Var2','Var3'})

%% Transformation

% Take the growth of all the time-series stored in the object
dataC = data.log()
% Or
dataC = log(data);

%% Creating a new variable

dataC = data.createVariable('Var4','Var1./Var2')

%% Creating more variables in one method call

dataC = data.createVariable({'Var4','Var0'},{'Var1./Var2','2*Var1'})

%% Creating a new type

dataC = data.createType('type4','type1./type2')

%% Creating more types in one method call

dataC = data.createType({'type4','type0'},{'type1./type2','2*type1'})

%% Merging nb_cs objects

obj1 = nb_cs([2,2,2;2,2,2;2,2,2],'double',...
            {'type1','type3','type2'},{'Var1','Var2','Var4'});
        
obj2 = nb_cs([3,3,3;3,3,3;3,3,3],'double',...
            {'type1','type3','type2'},{'Var3','Var5','Var6'});        

m    = merge(obj1,obj2)

% or

m = [obj1,obj2]

%% Merging nb_cs objects which share some data

obj1 = nb_cs([2,2,2;2,2,2;2,2,2],'double',...
            {'type1','type3','type2'},{'Var1','Var2','Var3'});
        
obj2 = nb_cs([2,2,2;2,2,2;2,2,2],'double',...
            {'type1','type3','type2'},{'Var3','Var4','Var5'});        

m    = merge(obj1,obj2)

% or

m = [obj1,obj2]

%% Merging nb_cs objects which share the same variables, 
% but have different types

obj1 = nb_cs([2,2,2;2,2,2;1,1,1],'double',...
            {'type1','type3','type2'},{'Var1','Var2','Var3'});
        
obj2 = nb_cs([1,1,1;2,2,2],'double',...
            {'type2','type5'},{'Var1','Var2','Var3'});        

m    = merge(obj1,obj2)

% or

m = [obj1;obj2]

%% Save the data of the objects to excel

% Save the data to a excel spreadsheet (With the save name given 
% by the name of the data set. I.e. 'double'.)
obj = nb_cs([2,2,2;2,2,2;1,1,1],'double',...
            {'type1','type3','type2'},{'Var1','Var2','Var3'});
obj.saveDataBase()

% Set the save file name
obj = nb_cs([2,2,2;2,2,2;1,1,1],'double',...
            {'type1','type3','type2'},{'Var1','Var2','Var3'});
obj.saveDataBase('saveName','test')

% Save the multipage data object to one spreadsheet using the 
% append option
obj = nb_cs(ones(3,3,2)*2,{'page1','page2'},...
            {'type1','type3','type2'},{'Var1','Var2','Var3'});
obj.saveDataBase('saveName','test','append',1)


%% Save the data of the objects to different file formats

% Save the data to a .mat file
obj = nb_cs([2,2,2;2,2,2;1,1,1],'double',...
            {'type1','type3','type2'},{'Var1','Var2','Var3'});
obj.saveDataBase('saveName','filename','ext','mat')

% Save the data to a .txt file
obj = nb_cs([2,2,2;2,2,2;1,1,1],'double',...
            {'type1','type3','type2'},{'Var1','Var2','Var3'});
obj.saveDataBase('ext','txt','saveName','filename')

%% Convert to other MATLAB type/object

data = nb_cs([2,2,2;2,2,2;1,1,1],'double',...
            {'type1','type3','type2'},{'Var1','Var2','Var3'});

% Convert to a structure
s   = data.toStructure()

% Convert to a cell
c   = data.asCell()

% Convert to a double
d   = data.double()

%% Make an updatable nb_cs object

% Reading data from a excel spreadsheet
obj = nb_cs([folder '\Examples\DataManagement\example_cs']);
        
% Now changes can be made to the file and we can update the object
% given the changes in the data source
obj.update
        
%% Do transformation

obj = log(obj)

%% The object stores the transformation done to the object when updating!

obj.update

