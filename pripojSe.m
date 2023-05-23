function ardMega = pripojSe(com)
%Zajistí, že se dokáže arduino připojit - vypne ostatní zařízení
delete(instrfindall);

%Deklarace Arduina
try
    ardMega = serialport(com, 115200);
catch
    error(com+" nebyl na seznamu, nebo nelze navázat spojení")
end

%Otevření zápisu
fopen(ardMega);
pause(3); % - důlažité 3 sec na navázání spojení - bez toho to nejde
end