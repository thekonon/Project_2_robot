function x = newton(F, J, x0, indexes, epsilon, max_n)
%DOKUMENTACE
%funkce vezme jako vstup function handler F, jakobián J a počáteční bod x0,
%iterace probíhá dokud není dosaženo v normě změna x požadované přesnosti,
%nebo není překročen počet 20 kroků
%Indexy co jsou zadány se zpřesňují, ostatní jsou konstantní

%bylo třeba přejít na univerzální jakobiány, kde zpřesňované proměnné jsou
%udávány pomocí indexů

if nargin == 4
    eps = 1e-5;
    n = 20;
    x = x0;
elseif nargin == 5
    eps = epsilon;
    n = 20;
    x = x0;
elseif nargin == 6
    eps = epsilon;
    n = max_n;
    x = x0;
end

for i = 0:n
    %disp(i+" / " + n)
    J_i = J(x.');
    dx = -J_i(:,indexes)\F(x.');
    x(indexes) = x(indexes) + dx;

    if norm(dx) < eps
        break;  
    end
end

end