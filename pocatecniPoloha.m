function [x] = pocatecniPoloha(F, J)
    q = [25;197.25];                %Počáteční chtěná poloha
    z = [90;  90; 33.8; 180+146.2]/180*pi;
    disp("PocatecniPoloha")
    %Zpřesnění 
    x = newton(F,J, [q; z], [1 2 5 6]);
end