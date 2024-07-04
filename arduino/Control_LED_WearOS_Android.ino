//Librerías
#include <WiFi.h>
#include <FirebaseESP32.h>

//Datos de conexión con Firebase
#define FIREBASE_HOST "control-led-a343c-default-rtdb.firebaseio.com"
#define FIREBASE_AUTH "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJodHRwczovL2lkZW50aXR5dG9vbGtpdC5nb29nbGVhcGlzLmNvbS9nb29nbGUuaWRlbnRpdHkuaWRlbnRpdHl0b29sa2l0LnYxLklkZW50aXR5VG9vbGtpdCIsImlhdCI6MTcyMDA2NDg5NCwiZXhwIjoxNzIwMDY4NDk0LCJpc3MiOiJmaXJlYmFzZS1hZG1pbnNkay04eng2cUBjb250cm9sLWxlZC1hMzQzYy5pYW0uZ3NlcnZpY2VhY2NvdW50LmNvbSIsInN1YiI6ImZpcmViYXNlLWFkbWluc2RrLTh6eDZxQGNvbnRyb2wtbGVkLWEzNDNjLmlhbS5nc2VydmljZWFjY291bnQuY29tIiwidWlkIjoidW5pcXVlLXVzZXItaWQifQ.irSIkp4e3aFxesOmCmnU68O5EJvqMdyzUN1-llS5BGU6QlUR9P0qCC5iL2AsFBOVfW_6f4LfcDhz7Cj6iUmQ4uaiJ8wRVqKLmD2_GEloXjlQKqdvEGU7uWkjuTSaXa1polyWNlHrx_1498QbpD6t-4CJ1k6VO6tiNr11ZrzRvrf7QIKx37hdiwtDp6xSI2PEiXi2LZHg9uUH67Cg9ipT3TgGVIdxnlM-f_eoSwVLsgUwbLAagsQQllUcVj5OHmogr7AcrVwkNXPQaGJPDB3yk7wH4NABu4UntRfz5KEqKrGHweqCofSpRmViywB97WfYLZOrMgupdo7Tvc-ZUNDf8g"

//Credenciales para conexión a RED WIFI
#define WIFI_SSID "FIBRATVSJR19682"//"LAPTOP-NOE"     
#define WIFI_PASSWORD "wlan642bbf"//"12345678" 

//Instancia de Firebase
FirebaseData firebaseData;
FirebaseAuth auth;
FirebaseConfig config;

// Puertos GPIO 15, 2 y 4
int redLed = 21, greenLed = 19, blueLed = 18;
int redColor = 0, greenColor = 0, blueColor = 0;

void setup() {
  Serial.begin(9600);
  delay(1000);

  pinMode(redLed, OUTPUT);
  pinMode(greenLed, OUTPUT);
  pinMode(blueLed, OUTPUT);

  // Inicialización de LED
  analogWrite(redLed, 0);
  analogWrite(greenLed, 0);
  analogWrite(blueLed, 0);

  //Conexión a RED
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to ");
  Serial.print(WIFI_SSID);
  while (WiFi.status() != WL_CONNECTED) {
    Serial.print(".");
    delay(500);
  }

  Serial.println();
  Serial.print("Conectando a: ");
  Serial.println(WIFI_SSID);
  Serial.print("La dirección IP es : ");
  Serial.println(WiFi.localIP());

  // Configuración de Firebase
  config.host = FIREBASE_HOST;
  config.signer.tokens.legacy_token = FIREBASE_AUTH;
  config.database_url = FIREBASE_HOST;

  // Inicialización de Firebase
  Firebase.begin(&config, &auth);
}

void loop() {
  //Obtenermos el valor del campo "color"
  if (Firebase.getString(firebaseData,"color")){              
      String color = firebaseData.stringData();
      // Parsear y aplicar los valores RGB
      parseRGB(color);
  }
  else{
    Serial.println(firebaseData.errorReason());
  }     

  delay(10);
}

void parseRGB(String color) {
  int commaIndex1 = color.indexOf(',');
  int commaIndex2 = color.lastIndexOf(',');

  if (commaIndex1 > 0 && commaIndex2 > commaIndex1) {
    redColor = color.substring(0, commaIndex1).toInt();
    greenColor = color.substring(commaIndex1 + 1, commaIndex2).toInt();
    blueColor = color.substring(commaIndex2 + 1).toInt();

    Serial.print(redColor);
    Serial.print(", ");
    Serial.print(greenColor);
    Serial.print(", ");
    Serial.println(blueColor);

    analogWrite(redLed, redColor);
    analogWrite(greenLed, greenColor);
    analogWrite(blueLed, blueColor);
  } else {
    Serial.println("Valor RGB incorrecto");
  }
}
