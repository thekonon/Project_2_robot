// message, direction, motor
int msg;    //Bitová zpráva ze seriové komunikace
bool dr1;   //Nastavení dir pinu 1
bool dr2;   //Nastavení dir pinu 2
int motor;  //Výběr motoru
int steps1;   //Aktuální hodnota stepů pro motor 1
int steps2;   //Aktuální hodnota stepů pro motor 2
// defines pins numbers
const int stepPinL = 5;
const int dirPinL = 6;
const int stepPinP = 9;
const int dirPinP = 10;

void setup() {
  // put your setup code here, to run once:
  pinMode(LED_BUILTIN, OUTPUT);
  Serial.begin(115200);
  dr1 = true;
  dr2 = true;
  steps1 = 0;
  steps2 = 0;

  // Sets the two pins as Outputs
  pinMode(stepPinL, OUTPUT);
  pinMode(dirPinL, OUTPUT);
  pinMode(stepPinP, OUTPUT);
  pinMode(dirPinP, OUTPUT);
}

void loop() {
  if (Serial.available())
  {
    msg = Serial.read();
    //Serial.println(msg);

    //Fáze výběru motoru
    //motor = 1 - výběr pravého (msg = 80 P),
    //motor = 2 - výběr levého (msg = 76 L),
    if (msg == 80)
    {
      motor = 1;
    }
    else if (msg == 76)
    {
      motor = 2;
    }

    //Fáze nastavení otáčení - výběr znaménka podle zprávy
    //Výběr motoru dle přednastaveného motoru
    if (msg == 43)
    {
      if (motor == 1)
      {
        dr1 = true;
      }
      else if (motor == 2)
      {
        dr2 = true;
      }
    }

    if (msg == 45)
    {
      if (motor == 1)
      {
        dr1 = false;
      }
      else if (motor == 2)
      {
        dr2 = false;
      }
    }

    //Nastaví směr otáčení
    if (motor == 1)
    {
      digitalWrite(dirPinL, dr1);
    }
    else if (motor == 2)
    {
      digitalWrite(dirPinP, dr2);
    }

    //Posbírání počtu stepů
    if (msg >= 48 && msg < 58)
    {
      if (motor == 1)
      {
        steps1 = steps1 * 10 + (msg - 48); //přidání nového čísla
        //Serial.print("Pridan step1: ");
        //Serial.println(steps1);
      }
      else if (motor == 2)
      {
        steps2 = steps2 * 10 + (msg - 48); //přidání nového čísla
        //Serial.print("Pridan step2: ");
        //Serial.println(steps2);
      }
    }

    //Pokus je konec zprávy tak dojde k vykonání
    if (msg == 99)
    {
      /*Serial.println("PO PŘEDKROKOVÁNÍM");
        Serial.println("PO KROKROVÁNÍ");
        Serial.print("Stepy1: ");
        Serial.print(dr1);
        Serial.print(" ");
        Serial.println(steps1);
        Serial.print("Stepy2: ");
        Serial.print(dr2);
        Serial.print(" ");
        Serial.println(steps2);
        Serial.print("Motor: ");
        Serial.println(motor);*/

      for (int x = 1; x <= steps1; x++)
      {
        st(stepPinL);
        //Serial.println("Krok praveho motoru: ");
        //Serial.println(x);
      }
      for (int x = 1; x <= steps2; x++)
      {
        st(stepPinP);
        //Serial.println("Krok leveho motoru: ");
        //Serial.println(x);
      }

      /*Serial.println("PO KROKROVÁNÍ");
        Serial.print("Stepy1: ");
        Serial.print(dr1);
        Serial.print(" ");
        Serial.println(steps1);
        Serial.print("Stepy2: ");
        Serial.print(dr2);
        Serial.print(" ");
        Serial.println(steps2);
        Serial.print("Motor: ");
        Serial.println(motor);*/
      steps1 = 0;
      steps2 = 0;
    }
  }
}

void st(int sp)
{
  digitalWrite(sp, HIGH);
  delayMicroseconds(100);
  digitalWrite(sp, LOW);
  delayMicroseconds(100);
  delayMicroseconds(500);
  //delay(1);
}
