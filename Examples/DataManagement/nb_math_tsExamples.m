%% Initializing an nb_math_ts object

var1 = nb_math_ts([1;2;3;4;5],'1994Q1')
var2 = nb_math_ts([0;1;2;3;4],'1994Q1')

%% Mathematical operators 

var3 = var1-var2
var4 = var3./var1
var5 = (var4.*var2)./var3

help nb_math_ts
