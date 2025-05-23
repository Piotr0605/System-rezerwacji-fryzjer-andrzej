<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>Rejestracja</title>
    <style>
        /* ----- GŁÓWNE USTAWIENIA TŁA I UKŁADU ----- */
        body {
            background-image: url("img/tłologowania.png"); /* Obrazek w tle */
            background-size: cover;        /* Obrazek rozciąga się na całą stronę */
            background-position: center;   /* Wyśrodkowanie */
            background-repeat: no-repeat;  /* Bez powtórzeń */
            margin: 0;                     /* Brak marginesów domyślnych */
            height: 100vh;                 /* Cała wysokość okna przeglądarki */
            color: white;                  /* Domyślny kolor czcionki */
            font-family: sans-serif;       /* Czytelna czcionka */
            display: flex;                 /* Ustawienie wszystkiego w poziomie i pionie */
            justify-content: center;
            align-items: center;
        }
        /* --- Wygląd nagłówków i tekstów w kontenerze --- */
        .form-container h2 { font-size: 40px; }
        .form-container p  { font-size: 30px; }
        .form-container p a { font-size: 22px; }

        /* ----- WYGLĄD PUDŁA Z FORMULARZEM ----- */
        .form-container {
            background: rgba(0, 0, 0, 0.4);        /* Ciemne przezroczyste tło */
            padding: 200px;                        /* Duży margines wewnątrz pudła */
            border-radius: 100px;                  /* Zaokrąglone rogi */
            backdrop-filter: blur(5px);            /* Efekt rozmycia pod spodem (na nowych przeglądarkach) */
            -webkit-backdrop-filter: blur(5px);
            box-shadow: 0 0 100px rgba(0, 0, 0, 0.5); /* Cień pod pudłem */
            text-align: center;                    /* Tekst na środku */
        }

        /* ----- POLA FORMULARZA (input) ----- */
        input {
            padding: 20px;
            margin: 15px;
            width: 520px;                  /* Szerokie pola na desktopie */
            border: none;                  /* Bez ramki */
            border-radius: 50px;           /* Duże zaokrąglenie */
            background: #444;              /* Ciemne tło */
            color: white;
        }
        /* Przycisk "Zarejestruj" */
        input[type="submit"] {
            background-color: #555;
            cursor: pointer;               /* Rączka po najechaniu */
        }
        /* Po najechaniu na przycisk zmienia się kolor */
        input[type="submit"]:hover {
            background-color: #666;
        }

        /* Link "Zaloguj się" na dole */
        a {
            color: #66ccff;
            text-decoration: underline;
        }

        /* ----- WYGLĄD POPUPA BŁĘDU ----- */
        .error-popup {
            position: relative;
            background-color: #ffdddd; /* Jasnoczerwone tło */
            color: #a94442;           /* Czerwony tekst */
            padding: 15px 40px 15px 20px;
            border: 1px solid #f5c6cb;
            border-radius: 5px;
            margin-bottom: 15px;
            font-size: 14px;
            box-shadow: 0 2px 6px rgba(0,0,0,0.3);
        }
        /* Krzyżyk do zamknięcia popupu */
        .close-btn {
            position: absolute;
            top: 8px;
            right: 10px;
            color: #a94442;
            font-weight: bold;
            cursor: pointer;
        }
    </style>
</head>
<body>
<div class="form-container">
    <h2>Załóż konto</h2>

    <%
        // Pobierz ewentualny komunikat błędu z requesta (ustawiany np. jeśli ktoś próbuje założyć konto na już używany e-mail)
        String error = (String) request.getAttribute("error");
    %>
    <% if (error != null) { %>
    <!-- Popup z błędem (pokazuje się tylko jeśli w request jest error) -->
    <div class="error-popup" id="popup">
        <!-- Krzyżyk do zamknięcia (po kliknięciu ukrywa ten popup) -->
        <span class="close-btn" onclick="document.getElementById('popup').style.display='none'">&times;</span>
        <%= error %> <!-- Wyświetlenie tekstu błędu -->
    </div>
    <% } %>

    <!-- FORMULARZ REJESTRACJI -->
    <form method="post" action="register">
        <input type="text" name="firstName" placeholder="Imię" required><br>
        <input type="text" name="lastName"  placeholder="Nazwisko" required><br>
        <input type="email" name="email"     placeholder="E-mail" required><br>
        <!-- Pole na numer telefonu – tylko cyfry, dokładnie 9 znaków -->
        <input type="text" name="phone"      placeholder="Telefon" maxlength="9" pattern="[0-9]{9}" required><br>
        <input type="password" name="password" placeholder="Hasło" required><br>
        <input type="submit" value="Zarejestruj">
        <p style="margin-top: 15px; font-size: 14px;">
            Masz już konto?
            <a href="index.jsp">Zaloguj się</a>
        </p>
    </form>
</div>
</body>
</html>
