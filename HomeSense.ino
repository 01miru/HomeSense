#include <SoftwareSerial.h>
#include "DHT.h"

#define DHTPIN 2
#define DHTTYPE DHT22
#define BLUETOOTH_SPEED 9600

SoftwareSerial mySerial(11, 10); // RX, TX

DHT dht(DHTPIN, DHTTYPE);

void setup() {
  Serial.begin(9600);
  mySerial.begin(BLUETOOTH_SPEED);
  dht.begin();
}

void loop() {
  delay(5000);

  float h = dht.readHumidity();
  float t = dht.readTemperature();

  if (isnan(h) || isnan(t)) {
    Serial.println("Failed to read from DHT sensor!");
    return;
  }

  String data = "H:" + String(h,2) + " T:" + String(t,2) + "\n";
  Serial.print(data);
  char charBuf[50];
  data.toCharArray(charBuf, 50);
  int bytesSent = mySerial.write(charBuf);
}
