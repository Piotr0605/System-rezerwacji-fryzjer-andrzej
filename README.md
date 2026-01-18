# System rezerwacji do fryzjera

##  Opis projektu

System rezerwacji do fryzjera to aplikacja webowa napisana w języku Java z wykorzystaniem technologii JSP, Servletów oraz integracją z Full Calendar. Umożliwia klientom rezerwację wizyt, przeglądanie dostępnych terminów oraz zarządzanie swoimi rezerwacjami. System posiada także panel fryzjera do zarządzania dostępnością godzin.

##  Główne funkcjonalności

- Rejestracja i logowanie użytkowników (klientów i fryzjerów)
- Dodawanie i usuwanie dostępnych godzin przez fryzjera
- Rezerwacja i odwoływanie wizyt przez klientów
- Wyświetlanie kalendarza z terminami
- Integracja z Full Calendar
- Integracja z Bazą danych MariaDB
- Rozdzielenie panelu użytkownika i fryzjera
- Wylogowywanie i zarządzanie sesją

##  Struktura projektu

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

##  Technologie

- Java 8+
- JSP & Servlety
- Maven
- HTML/CSS/JS
- Full Calendar API
- Apache Tomcat (rekomendowany)
- MariaDB / MySQL (opcjonalnie)

## Schemat blokowy działania aplikacji
```index.jsp
  │
  ▼ (logowanie)
LoginServlet
  ├── jeśli klient  ─▶ dashboard.jsp
  └── jeśli fryzjer ─▶ fryzjer-dashboard.jsp

────────────────────────────────────────────
Dla klienta (dashboard.jsp):

  FullCalendar init
    │
    ▼
  GET /dostepne-sloty
    ▼
  DostepneSlotyServlet
    ▼
  < JSON z wolnymi terminami >

  Kliknięcie terminu
    ▼
  POST /zarezerwuj-slot
    ▼
  ZarezerwujSlotServlet

  Moje rezerwacje:
    ▼
  GET /pobierz-rezerwacje ─▶ PobierzRezerwacjeServlet
  POST /odwolaj-rezerwacje ─▶ OdwolajRezerwacjeServlet

────────────────────────────────────────────
Dla fryzjera (fryzjer-dashboard.jsp):

  FullCalendar init
    │
    ▼
  GET /pobierz-wszystkie-wydarzenia
    ▼
  PobierzWszystkieWydarzeniaServlet
    ▼
  < JSON z godzinami pracy i rezerwacjami >

  Kliknięcie dnia
    ▼
  POST /dodaj-godziny ─▶ DodajGodzinyServlet

  Kliknięcie wydarzenia
    ▼
  POST /usun-godziny ─▶ UsunGodzinyServlet

────────────────────────────────────────────
Wylogowanie:
  GET /logout ─▶ LogoutServlet ─▶ redirect → index.jsp
```

## Diagram działania apliakcji

```mermaid
graph LR
graph TD
    %% Logowanie
    Start((Logowanie)) --> LoginServlet{LoginServlet}
    LoginServlet -->|Klient| DashK[dashboard.jsp]
    LoginServlet -->|Fryzjer| DashF[fryzjer-dashboard.jsp]

    %% Panel Klienta
    subgraph "Panel Klienta"
    DashK --> CalK[FullCalendar Init]
    CalK --> GET_S[GET /dostepne-sloty]
    GET_S --> DS_Serv[DostepneSlotyServlet]
    DS_Serv --> JSON_S((JSON z terminami))
    
    ClickK[Kliknięcie terminu] --> POST_Z[POST /zarezerwuj-slot]
    POST_Z --> ZS_Serv[ZarezerwujSlotServlet]
    
    MyRez[Moje rezerwacje] --> GET_R[GET /pobierz-rezerwacje]
    GET_R --> PR_Serv[PobierzRezerwacjeServlet]
    MyRez --> POST_O[POST /odwolaj-rezerwacje]
    POST_O --> OR_Serv[OdwolajRezerwacjeServlet]
    end

    %% Panel Fryzjera
    subgraph "Panel Fryzjera"
    DashF --> CalF[FullCalendar Init]
    CalF --> GET_W[GET /pobierz-wszystkie-wydarzenia]
    GET_W --> PW_Serv[PobierzWszystkieWydarzeniaServlet]
    PW_Serv --> JSON_W((JSON godziny i rez.))
    
    ClickD[Kliknięcie dnia] --> POST_G[POST /dodaj-godziny]
    POST_G --> DG_Serv[DodajGodzinyServlet]
    
    ClickE[Kliknięcie wydarzenia] --> POST_UG[POST /usun-godziny]
    POST_UG --> UG_Serv[UsunGodzinyServlet]
    end

    %% Wylogowanie
    DashK & DashF --> Logout[GET /logout]
    Logout --> L_Serv[LogoutServlet]
    L_Serv --> Redirect[index.jsp]
```
##  Zależności (zdefiniowane w `pom.xml`)

- `javax.servlet-api`
- `gson`
- `google-api-client`
- `mariadb-java-client`

##  Uruchomienie

1. **Importuj projekt do IntelliJ IDEA lub innego IDE z obsługą Maven.**
2. **Skonfiguruj serwer Tomcat (lub inny serwer aplikacji Java EE).**
3. **Skonfiguruj bazę danych (MariaDB).**
4. **Zbuduj projekt (`mvn clean package`).**
5. **Uruchom aplikację na serwerze (np. http://localhost:8080).**


##  Instalacja MariaDB

1. Pobierz MariaDB z oficjalnej strony: https://mariadb.org/download/
2. Zainstaluj MariaDB (w czasie instalacji zapamiętaj hasło roota).
3. Uruchom serwer MariaDB.

---

##  Konfiguracja bazy danych

1. Zaloguj się do MariaDB:

    mysql -u root -p
    

2. Utwórz bazę danych:

    CREATE DATABASE fryzjer;
   
    USE fryzjer;
    
3. Utwórz tabele:

    sql
   
    CREATE TABLE users (
   
        id INT PRIMARY KEY AUTO_INCREMENT,
        first_name VARCHAR(50),
        last_name VARCHAR(50),
        email VARCHAR(100) UNIQUE,
        password VARCHAR(255),
        phone VARCHAR(20),
        role VARCHAR(20)
    );

    CREATE TABLE godziny_pracy (
   
        id INT PRIMARY KEY AUTO_INCREMENT,
        fryzjer_id INT,
        data DATE NOT NULL,
        godzina_start TIME NOT NULL,
        godzina_koniec TIME NOT NULL
    );

    CREATE TABLE rezerwacje (
   
        id INT PRIMARY KEY AUTO_INCREMENT,
        klient_id INT NOT NULL,
        godziny_pracy_id INT NOT NULL,
        godzina_rezerwacji TIME NOT NULL,
        data_rezerwacji DATETIME DEFAULT current_timestamp()
    );
   
4. Utwórz konto fryzjera (administratora):

    USE fryzjer
   
5. Użyj poniższego zapytania SQL, aby dodać fryzjera do tabeli users:

INSERT INTO users (first_name, last_name, email, password, phone, role)

VALUES ('Stanisław', 'Kowalewski', 'stanislaw.kowalewski@salon.pl', 'stas324', '123456789', 'fryzjer');

---

##  Konfiguracja po stronie aplikacji

1. Skonfiguruj połączenie z bazą w klasie DatabaseConnection.java:

    java
   
    private static final String URL = "jdbc:mariadb://localhost:3306/fryzjer";
   
    private static final String USER = "root";
   
    private static final String PASSWORD = "twoje_haslo";
    

3. Załaduj projekt w IntelliJ IDEA.
4. Upewnij się, że masz ustawiony serwer Tomcat w konfiguracji uruchamiania.
5. Uruchom projekt i otwórz http://localhost:8080.

---

##  Uwagi

- Pamiętaj, aby w bazie dodać przynajmniej jednego użytkownika o roli fryzjer, aby mieć dostęp do widoku zarządzania godzinami 



##  Autorzy

- Tomasz Złotkowski  
- Piotr Sienkiewicz  
- Kacper Kopaczewski
