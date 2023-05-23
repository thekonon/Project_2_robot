classdef robot < matlab.mixin.SetGet
    %Hlavní class pro ovládání robota
    %r = robot(),
    %Možnosti řízení:
    %r.moveTo([x, y]) pohne robotem na souřadnice x,y
    %r.sendSteps([Levá, Pravá]) pošle stepy krokovým motorům
    %r.rectangle pro vykreslení čtverce
    %r.circle(r) pro vykreslení kruhu o poloměru r


    properties
        %Numerické konstanty
        microstepping_constant {mustBeNumeric}

        %Numerické proměnné
        logging_object_connected                %bude log do objektu?
        x_state
        q_coordinates
        z_coordinates
        step_actual

        %Stringy
        port_list

        %Objektové funkce
        F_function
        J_function

        %Objektové proměnné
        logging_object
        arduino_object

        %Stavové proměnné
        logging_device_connected
    end

    properties (Constant)
        L = [50 100 100];               %l1 l2 l3
    end

    methods
        function obj = robot(microsteps_per_step, logging_obj)
            %Pokyny pro konstrukci objektu robota
            % -> první argument je mikrokrokování 1,2,4,8,16,32
            % -> druhý argument je objekt do kterého se budou přidávat stringy s
            % logem, logovací konzole

            %Nastavení hodnot z argumentů
            switch nargin
                case 0
                    obj.microstepping_constant = 1.8;
                case 1
                    obj.microstepping_constant = 1.8 / microsteps_per_step;
                case 2
                    obj.microstepping_constant = 1.8 / microsteps_per_step;
                    obj.logging_object = logging_obj;
                    obj.logging_device_connected = 1; %#ok<NASGU> 
            end

            %Zahajovací sekvence
            logText(obj, "Zahajuji vytvářecí sekvenci");
            %Odvození rovnic je externí funkce - proto logy zde
            logText(obj, "Zahájeno odvozování rovnic");
            [obj.F_function, obj.J_function] = odvozeniRovnic(obj.L);
            logText(obj, "Dokončeno odvozování rovnic"); 
            setInitialCoordinates(obj, 1);
%             connectArduino(obj);
            %V této fázi je robot v počáteční poloze - poloha 1 a je
            %připraven přijímat příkazy na pohyby

        end
        function moveTo(obj,q_new)
            %Přesune robota na dané souřadnice q_new
            stateToQZ(obj);         %Pro jistotu

            %Pro konzistenci -> aby to vždy byl sloup
            if size(q_new,1) == 1
                q_new = q_new.';
            end

            %Výpočet rozdílu v souřadnicích -> celkový potřebný přesun
            Dq = q_new - obj.q_coordinates;

            %Počet mezikroků, při / 1 je na každý 1 mm posunu XY
            %udělána jedna lineární interpolace, menší hodnotou je možné
            %přidávat rychlost a naopak
            n = round(norm(Dq) / 0.25);

            %Počet posunutí
            dq = Dq / n;
            
            %Samotný posun
            for k = 1 : n
                %Nová pozice ze staré, práce se stavem
                x_new = obj.x_state;
                x_new(1:2) = obj.x_state(1:2) + dq(1:2);
                obj.x_state = x_new;

                %Newton pro výpočet nových z_souřadnic
                obj.x_state = newton(obj.F_function, obj.J_function, obj.x_state, 3:6);
                stateToQZ(obj);
                
                %Dopočet nových potřebných kroků z úhlů
                step_wanted = zToK(obj);

                %Rozdíl mezi aktuálními kroku a potřebnými
                step_diff = step_wanted - obj.step_actual;
                sendSteps(obj, step_diff)
                pause(0.0015)        %Možnost zrychlení

                obj.step_actual = obj.step_actual + step_diff;
            end
            stateToQZ(obj);
        end
        function sendSteps(obj, steps)
            s1 = steps(1);
            s2 = steps(2);
            if s1 >= 0
                s1_char = char('+');
            elseif s1 < 0
                s1_char = char('-');
            end
            if s2 >= 0
                s2_char = char('+');
            elseif s2< 0
                s2_char = char('-');
            end
            fprintf(obj.arduino_object,'%c',char(['L', s1_char, num2str(abs(s1)), 'P', s2_char, num2str(abs(s2)), 'c']));
        end
        function circle(obj, r)
            phi = linspace(0,2*pi);
            for i = 1:length(phi)-1
                dq = r * [cos(phi(i+1))-cos(phi(i));...
                          sin(phi(i+1))-sin(phi(i))];
                obj.moveTo(obj.q_coordinates+dq);
            end
        end
        function rectangle(obj)
            obj.moveTo([25 175])
            obj.moveTo([25 150])
            obj.moveTo([50 150])
            obj.moveTo([50 175])
            obj.moveTo([25 175])
        end

        function avaiablePorts(obj)
            logText(obj, "Připojuji arduino")
            logText(obj, "Dostupné porty: ")
            obj.port_list = serialportlist;
            logText(obj, obj.port_list)
            logText(obj, "Zvol port na kterém je arduino - potvrď výběrem")
        end

        function successfully_connected = connectArduino(obj, COM_number)
            if COM_number == 0
                obj.arduino_object = pripojSe(obj.port_list(end));
                logText(obj, "Automatick zvolen "+obj.port_list(end))
                successfully_connected = 1;
            else

                for i = 1:numel(obj.port_list)
                    is_part_of_list_i(i) = strcmp("COM"+COM_number, obj.port_list(i));
                end
                if sum(is_part_of_list_i)>0
                    logText(obj, "Port souhlasí")
                    successfully_connected = 1;
                    obj.arduino_object = pripojSe("COM"+COM_number);
                    logText(obj, "Arduino připojeno")
                else
                    logText(obj, "Nevalidní port - není na seznamu");
                    successfully_connected = 0;
                end
            end           
        end
    end

    methods(Access = private)
        function logText(obj, text)
            %Vypsání do normální konzole
            disp(text)

            %Případné logování do konzole
            if obj.logging_device_connected
                old_text_string = string(obj.logging_object.Value);
                new_string = [old_text_string; text(:)];
                obj.logging_object.Value = new_string;
                scroll(obj.logging_object, 'bottom')
            end
        end
        function setInitialCoordinates(obj, position_type)
            logText(obj, "Nastavuji počáteční souřadnice")
            switch position_type
                case 1              %ramena dopředu
                    logText(obj, "Vybrán typ počátečních souřadnic 1")
                    %Počáteční odhad
                    q = [25; 197];
                    z = [90;  90; 33.8; 180+146.2]/180*pi;
                    %Zpřesnění souřadnic při konstantním z1 z2
                    obj.x_state = newton(obj.F_function,...
                        obj.J_function, [q; z], [1 2 5 6]);
            end
            stateToQZ(obj)
            obj.step_actual = zToK(obj);
        end
        function stateToQZ(obj)
            obj.q_coordinates = obj.x_state(1:2);
            obj.z_coordinates = obj.x_state(3:end);
        end
        function k = zToK(obj)
            z_deg = rad2deg(obj.z_coordinates(1:2));          %Rad -> deg
            k = round(z_deg/obj.microstepping_constant);
        end

        
    end
end