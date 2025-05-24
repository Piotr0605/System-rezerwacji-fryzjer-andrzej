# System rezerwacji do fryzjera

## 📌 Opis projektu

System rezerwacji do fryzjera to aplikacja webowa napisana w języku Java z wykorzystaniem technologii JSP, Servletów oraz integracją z Full Calendar. Umożliwia klientom rezerwację wizyt, przeglądanie dostępnych terminów oraz zarządzanie swoimi rezerwacjami. System posiada także panel fryzjera do zarządzania dostępnością godzin.

## ⚙️ Główne funkcjonalności

- Rejestracja i logowanie użytkowników (klientów i fryzjerów)
- Dodawanie i usuwanie dostępnych godzin przez fryzjera
- Rezerwacja i odwoływanie wizyt przez klientów
- Wyświetlanie kalendarza z terminami
- Integracja z Full Calendar
- Integracja z Bazą danych MariaDB
- Rozdzielenie panelu użytkownika i fryzjera
- Wylogowywanie i zarządzanie sesją

## 🗂️ Struktura projektu

```
System rezerwacji do fryzjera/
│
├── src/
│   ├── main/
│   │   ├── java/com/example/systemrezerwacjidofryzjera/
│   │   │   ├── DatabaseConnection.java
│   │   │   ├── LoginServlet.java
│   │   │   ├── RegisterServlet.java
│   │   │   ├── ZarezerwujServlet.java
│   │   │   ├── WylogujServlet.java
│   │   │   └── ... (inne serwlety i klasy pomocnicze)
│   │   └── webapp/
│   │       ├── index.jsp
│   │       ├── register.jsp
│   │       ├── kalendarz.jsp
│   │       ├── dashboard.jsp
│   │       ├── fryzjer-dashboard.jsp
│   │       └── WEB-INF/web.xml
│
├── pom.xml
└── README.md
```

## 🛠️ Technologie

- Java 8+
- JSP & Servlety
- Maven
- HTML/CSS/JS
- Full Calendar API
- Apache Tomcat (rekomendowany)
- MariaDB / MySQL (opcjonalnie)

## 📦 Zależności (zdefiniowane w `pom.xml`)

- `javax.servlet-api`
- `gson`
- `google-api-client`
- `mariadb-java-client`

## ▶️ Uruchomienie

1. **Importuj projekt do IntelliJ IDEA lub innego IDE z obsługą Maven.**
2. **Skonfiguruj serwer Tomcat (lub inny serwer aplikacji Java EE).**
3. **Zbuduj projekt (`mvn clean package`).**
4. **Uruchom aplikację na serwerze (np. http://localhost:8080).**


## 👥 Autorzy

- Tomasz Złotkowski  
- Piotr Sienkiewicz  
- Kacper Kopaczewski
