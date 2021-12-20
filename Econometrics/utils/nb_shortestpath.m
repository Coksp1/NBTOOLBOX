function [dist,path,pred] = nb_shortestpath(A,u,e)
% Syntax:
%
% [dist,path,pred] = nb_shortestpath(A,u,e)
%
% Description:
%
% Calculate shortest distance and path between two vertices (nodes) in
% the graph A.
% 
% Input:
% 
% - A : A double or sparse double of size N x N.
%
% - u : The vertix (node) to start from. As an scalar integer.
%
% - e : The vertix (node) to end at. As an scalar integer.
% 
% Output:
% 
% - dist : A scalar double with the shortest distance between the vertices 
%          (nodes). If vertex e is not reachable from u inf will be
%          returned.
%
% - path : The shortes path between the two vertices. As a 1 x nSteps
%          double. If vertex e is not reachable from u [] is returned.
%
% - pred : The predecessors along the shortest path.
%
% Examples:
%
% W  = [.41 .99 .51 .32 .15 .45 .38 .32 .36 .29 .21];
% DG = sparse([6 1 2 2 3 4 4 5 5 6 1],[2 6 3 5 4 1 6 3 4 3 5],W);
%
% [dist,path,pred] = nb_shortestpath(DG,1,6)
%
% See also:
% gaimc.bfs, gaimc.dijkstra
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if ~issparse(A)
        A = sparse(A);
    end
    vecA = A(:);
    
    if all(vecA == 1 | vecA == 0 )
        [dist,~,pred] = gaimc.bfs(A,u);
        m             = dist;
    else
        % We have a weighted graph
        [dist,~,pred,m] = gaimc.dijkstra(A,u);
    end
    
    % Get the path
    m       = m(e) + 1;
    dist    = dist(e);
    if ~isfinite(dist)
        path = [];
        pred = [];
        return
    end
    path    = zeros(1,m);
    t       = m;
    path(1) = u;
    while (e ~= u) 
        path(t) = e; 
        e       = pred(e); 
        t       = t - 1;
    end

end
