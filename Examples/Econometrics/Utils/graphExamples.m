%% Edmonds algorithm

W  = [4,7,3,2,1,2,2,11,3,1,3,5];
DG = sparse([1,1,1,1,2,3,3,4,4,5,6,7],[2,3,5,7,6,4,5,2,6,4,5,6],W); 
GT = nb_edmonds(DG);

%% Unweighted graph

W  = ones(1,11);
DG = sparse([6 1 2 2 3 4 4 5 5 6 1],[2 6 3 5 4 1 6 3 4 3 5],W);
[dist, ~, pred]   = gaimc.bfs(DG,1)
[dist, ~, pred,m] = gaimc.dijkstra(DG,1)
[dist,path,pred]  = nb_shortestpath(DG,1,6)

%% Weighted graph

W  = [.41 .99 .51 .32 .15 .45 .38 .32 .36 .29 .21];
DG = sparse([6 1 2 2 3 4 4 5 5 6 1],[2 6 3 5 4 1 6 3 4 3 5],W);
[dist, dt, pred,m] = gaimc.dijkstra(DG,1)

%% Generic function (+ giving the path)

W  = [.41 .99 .51 .32 .15 .45 .38 .32 .36 .29 .21];
DG = sparse([6 1 2 2 3 4 4 5 5 6 1],[2 6 3 5 4 1 6 3 4 3 5],W);
[dist,path,pred] = nb_shortestpath(DG,1,6)
