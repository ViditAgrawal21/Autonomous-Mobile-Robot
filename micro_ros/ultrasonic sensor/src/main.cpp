#include <Arduino.h>

#define ECHOPIN 7// Pin to receive echo pulse
#define TRIGPIN 8// Pin to send trigger pulse

int distance;
void setup(){
  Serial.begin(9600);
  pinMode(ECHOPIN, INPUT);
  pinMode(TRIGPIN, OUTPUT);
  //digitalWrite(ECHOPIN, HIGH);

}
void loop(){
  digitalWrite(TRIGPIN, LOW); // Set the trigger pin to low for 2uS
  delayMicroseconds(2);
  digitalWrite(TRIGPIN, HIGH); // Send a 10uS high to trigger ranging
  delayMicroseconds(20);
  digitalWrite(TRIGPIN, LOW); // Send pin low again
  distance = pulseIn(ECHOPIN, HIGH)/58; // Read in times pulse
  //Serial.println(distance);
  Serial.print(distance);
  Serial.println("   cm");                   
  delay(50);// Wait 50mS before next ranging
}

// uint8_t Com[8] = {0x01,0x03,0x01,0x01,0x00,0x01,0xd4,0x36};

// unsigned int CRC16_2(unsigned char *buf, int len)
// {
//   unsigned int crc = 0xFFFF;
//   for (int pos = 0; pos < len; pos++)
//   {
//     crc ^= (unsigned int)buf[pos];
//     for (int i = 8; i != 0; i--)
//     {
//       if ((crc & 0x0001) != 0)
//       {
//         crc >>= 1;
//         crc ^= 0xA001;
//       }
//       else
//       {
//         crc >>= 1;
//       }
//     }
//   }

//   crc = ((crc & 0x00ff) << 8) | ((crc & 0xff00) >> 8);
//   return crc;
// }

// uint8_t readN(uint8_t *buf, size_t len)
// {
//   size_t offset = 0, left = len;
//   int16_t Tineout = 500;
//   uint8_t  *buffer = buf;
//   long curr = millis();
//   while (left) {
//     if (Serial.available()) {
//       buffer[offset] = Serial.read();
//       offset++;
//       left--;
//     }
//     if (millis() - curr > Tineout) {
//       break;
//     }
//   }
//   return offset;
// }

// int readDistance(void)
// {
//   uint8_t Data[10] = {0};
//   uint8_t ch = 0;
//   bool flag = 1;
//   int Distance = 0;
//   while (flag) {
//     delay(100);
//     Serial.write(Com, 8);
//     delay(10);
//     if (readN(&ch, 1) == 1) {
//       if (ch == 0x01) {
//         Data[0] = ch;
//         if (readN(&ch, 1) == 1) {
//           if (ch == 0x03) {
//             Data[1] = ch;
//             if (readN(&ch, 1) == 1) {
//               if (ch == 0x02) {
//                 Data[2] = ch;
//                 if (readN(&Data[3], 4) == 4) {
//                   if (CRC16_2(Data, 5) == (Data[5] * 256 + Data[6])) {
//                     Distance = Data[3] * 256 + Data[4];
//                     //Serial.println(Distance);
//                     flag = 0;
//                   }
//                 }
//               }
//             }
//           }
//         }
//       }
//     }
//     Serial.flush();

//   }
//   return Distance;
// }



// void setup()
// {
//   Serial.begin(115200);    
// }
// void loop()
// {
//   int Distance =readDistance();
//   Serial.print("Distance = ");
//   Serial.print(Distance);
//   Serial.println(" mm");
//   delay(500);
// }

