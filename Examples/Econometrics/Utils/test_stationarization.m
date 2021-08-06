
nb_clearall

%% Stationarize equations using the nb_st class and its subclasses

% Trending variables
X      = nb_stTerm('X',1.03,0);
Xlag   = nb_stTerm('X',1.03,-1);
Xlag2  = nb_stTerm('X',1.03,-2);
Xlead  = nb_stTerm('X',1.03,1);
Xlead2 = nb_stTerm('X',1.03,2);
Y      = nb_stTerm('Y',1.03,0);
Q      = nb_stTerm('Q',1/1.03,0);

% Unit root variable
U      = nb_stTerm('U',1.03,0,true);
Ulag   = nb_stTerm('U',1.03,-1,true);

% Non-trending variables
Z     = nb_stTerm('Z',1,0);
Zlag  = nb_stTerm('Z',1,-1);
Zlead = nb_stTerm('Z',1,1);

% Parameter
P1 = nb_stParam('P1',0.4);
P2 = nb_stParam('P2',0.6);

%% Division

Eq1  = X/Y
Eq2  = X/Xlag
Eq3  = Xlead/Xlag
Eq4  = Z/Zlag
Eq5  = P1/P2
Eq6  = P1/X
Eq7  = X/P2
Eq8  = Xlag2/Xlag
Eq9  = U/Ulag
Eq10 = X/U

%% Multiplication

Eq1 = X*Y
Eq2 = X*Xlag
Eq3 = Xlead*Xlag
Eq4 = Z*Zlag
Eq5 = P1*P2
Eq6 = P1*X
Eq7 = X*P2
Eq8 = Q*X

%% Power 

Eq1 = P1^P2
Eq2 = X^P2
Eq3 = X^P2*Y^(1-P2)

% Will result in an error, see property error!
EqErr1 = X^Y

%% Plus 

Eq1 = X + Y
Eq2 = X + Xlag
Eq3 = Z + 1
Eq4 = Z + P2
Eq5 = +Y

% Will result in an error, see property error!
EqErr1 = X + Z
EqErr2 = X + 1
EqErr3 = P1 + X 
EqErr4 = Q + X 

%% Minus

Eq1 = X - Y
Eq2 = X - Xlag
Eq3 = Z - 1
Eq4 = Z - P2
Eq5 = -X

% Will result in an error, see property error!
EqErr1 = X - Z
EqErr2 = X - 1
EqErr3 = P1 - X 

%% Exponential

Eq1 = exp(P1)
Eq2 = exp(Z)
Eq3 = exp(Z - P1)

% Will result in an error, see property error!
EqErr1 = exp(X)

%% Log

Eq1 = log(P1)
Eq2 = log(Z)
Eq3 = log(Z - P1)

% Will result in an error, see property error!
EqErr1 = log(X)

%% Square root

Eq1 = sqrt(P1)
Eq2 = sqrt(Z)
Eq3 = sqrt(Z - P1)
Eq4 = sqrt(X)
Eq5 = sqrt(X)*sqrt(Y)

%% Steady-state operator

Eq1 = steady_state(X)
Eq2 = steady_state(X + Y)
Eq3 = steady_state(P1)
Eq4 = steady_state(Z)
Eq5 = steady_state(Z - P1)

%% Log normal CDF

Eq1 = logncdf(Z,P1,P2)
Eq2 = logncdf(P1,P1,P2)
Eq3 = logncdf(X/Y,P1,P2)
Eq4 = logncdf(X/Y,0,2)

% Will result in an error, see property error!
EqErr1 = logncdf(X,P1,P2)

%% Log normal PDF

Eq1 = lognpdf(Z,P1,P2)
Eq2 = lognpdf(P1,P1,P2)
Eq3 = lognpdf(X/Y,P1,P2)
Eq4 = lognpdf(X/Y,0,2)

% Will result in an error, see property error!
EqErr1 = lognpdf(X,P1,P2)

%% Normal CDF

Eq1 = normcdf(Z)
Eq2 = normcdf(Z,P1,P2)
Eq3 = normcdf(P1,P1,P2)
Eq4 = normcdf(X/Y,P1,P2)
Eq5 = normcdf(X/Y,0,2)

% Will result in an error, see property error!
EqErr1 = normcdf(X,P1,P2)

%% Normal PDF

Eq1 = normcdf(Z)
Eq2 = normpdf(Z,P1,P2)
Eq3 = normpdf(P1,P1,P2)
Eq4 = normpdf(X/Y,P1,P2)
Eq5 = normpdf(X/Y,0,2)

% Will result in an error, see property error!
EqErr1 = normpdf(X,P1,P2)

%% Model operators

Eq1 = steady_state(X)
Eq2 = detrend(X)
Eq3 = bgp(X)


