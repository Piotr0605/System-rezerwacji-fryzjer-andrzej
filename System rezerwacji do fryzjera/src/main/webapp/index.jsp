<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>Logowanie</title>
    <style>
        /*
           ---- WYGLĄD I UKŁAD STRONY ----
           Ustawiamy ładne, nowoczesne tło, czcionki i kolory, żeby użytkownikowi było przyjemnie korzystać z aplikacji.
        */
        html, body {
            margin: 0;           /* Usuwa domyślne marginesy przeglądarki */
            padding: 0;          /* Usuwa domyślne odstępy */
            height: 100%;        /* Wysokość całego okna przeglądarki */
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; /* Nowoczesna czcionka */
            color: white;        /* Białe litery */
            background: url("img/tłologowania.png") no-repeat center center fixed; /* Tło z pliku PNG */
            background-size: cover; /* Tło zawsze zakrywa całą stronę */
        }
        .container {
            /* Główny kontener, który centrowany jest na ekranie */
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            height: 100%;
            padding: 30px;
        }
        .welcome-bar {
            /* Duży, rzucający się w oczy pasek z nazwą salonu */
            font-size: 3.1rem;
            font-weight: bold;
            background: rgba(0, 0, 0, 0.6);   /* Półprzezroczyste czarne tło */
            padding: 22px 44px;
            border-radius: 16px;
            margin-bottom: 44px;
            box-shadow: 0 6px 22px rgba(0, 0, 0, 0.7); /* Lekki cień */
            text-align: center;
        }
        .form-container {
            /* Ramka z formularzem logowania */
            background: rgba(0, 0, 0, 0.6);    /* Lekko prześwitujący czarny prostokąt */
            padding: 44px 33px;
            border-radius: 16px;
            backdrop-filter: blur(6px);         /* Lekki blur tła za panelem */
            -webkit-backdrop-filter: blur(6px);
            box-shadow: 0 0 22px rgba(0, 0, 0, 0.6);
            width: 100%;
            max-width: 440px;                   /* Maksymalna szerokość panelu na większych ekranach */
            display: flex;
            flex-direction: column;
            align-items: center;
        }
        .form-container h2 {
            /* Nagłówek nad formularzem */
            margin-bottom: 33px;
            font-size: 2rem;
            text-align: center;
        }
        form {
            width: 100%;
            display: flex;
            flex-direction: column;
            align-items: center;
        }
        input {
            /* Wygląd wszystkich pól formularza */
            padding: 15px;
            margin: 13px 0;
            width: 100%;
            max-width: 330px;
            border: none;
            border-radius: 6px;
            background: #444;   /* Ciemne tło pól */
            color: white;
            font-size: 1.1rem;
        }
        input[type="submit"] {
            /* Przycisk "Zaloguj" - niebieskawy po najechaniu */
            background-color: #555;
            cursor: pointer;
            font-weight: bold;
        }
        input[type="submit"]:hover {
            background-color: #666;
        }
        a {
            /* Link do strony rejestracji */
            color: #66ccff;
            text-decoration: underline;
        }
        .bottom-text {
            /* Mały tekst pod przyciskiem, np. link do rejestracji */
            font-size: 1.3rem;
            margin-top: 30px;
            text-align: center;
        }
        .error {
            /* Wygląd komunikatu o błędzie */
            color: red;
            margin-top: 11px;
            text-align: center;
        }
        /* ---- RESPONSYWNOŚĆ - lepszy wygląd na smartfonach ---- */
        @media (max-width: 768px) {
            .welcome-bar {
                font-size: 2rem;
                padding: 17px 22px;
                margin-bottom: 28px;
            }
            .form-container {
                padding: 33px 24px;
                max-width: 90vw;
            }
            .form-container h2 {
                font-size: 1.6rem;
            }
            input {
                font-size: 1rem;
                padding: 14px;
            }
            .bottom-text {
                font-size: 1.1rem;
            }
        }
    </style>
</head>
<body>
<div class="container">
    <!-- Pasek powitalny na górze strony -->
    <div class="welcome-bar">
        Witaj w barbershopie u Andrzeja!
    </div>

    <!-- Panel logowania -->
    <div class="form-container">
        <h2>Zaloguj się</h2>

        <!--
            FORMULARZ LOGOWANIA:
            - metoda="post": dane (e-mail i hasło) będą wysyłane niewidoczne w adresie
            - action="login": po kliknięciu "Zaloguj" przeglądarka wysyła dane do Java Servlet o adresie "/login"
            - pola są oznaczone jako "required", więc bez ich wypełnienia nie można wysłać formularza
        -->
        <form method="post" action="login">
            <input type="text" name="email" placeholder="E-mail" required><br>
            <input type="password" name="password" placeholder="Hasło" required><br>
            <input type="submit" value="Zaloguj">
            <p class="bottom-text">
                Nie masz konta?
                <!-- Link do strony rejestracji (register.jsp) -->
                <a href="register.jsp">Załóż je już teraz!</a>
            </p>
        </form>

        <!--
            WYŚWIETLANIE KOMUNIKATU O BŁĘDZIE:
            Jeśli w requestcie ustawiono atrybut "error" (np. "Nieprawidłowy login"), to wyświetla go na czerwono pod formularzem.
            To JSP, więc "<%= ... %>" wstawia tekst bezpośrednio w HTML.
        -->
        <p class="error">
            <%= request.getAttribute("error") != null ? request.getAttribute("error") : "" %>
        </p>
    </div>
</div>
</body>
</html>

<%--
-------------------- PODSUMOWANIE --------------------
Ten plik to **strona logowania** do aplikacji fryzjerskiej.
- Całość jest schludnie ostylowana (ciemne tło, centralny formularz, responsywność na telefon).
- Najważniejszym elementem jest formularz, gdzie użytkownik wpisuje swój e-mail i hasło.
- Po kliknięciu "Zaloguj" dane są wysyłane do **serwletu Java** pod adresem `/login`, który sprawdza dane i loguje użytkownika.
- Jeśli dane są niepoprawne (np. złe hasło lub e-mail), na dole formularza pojawi się **komunikat o błędzie** (czerwony tekst).
- Jest też **link do strony rejestracji** dla nowych użytkowników.
- Ta strona nie sprawdza danych sama – wszystko robi backend (Java Servlet).

Można powiedzieć, że to "front-endowa" część logowania: ładna wizytówka i zbieracz danych. Cała prawdziwa logika (sprawdzanie loginu, sesja, przekierowania) odbywa się w Javie po stronie serwera.
--%>
