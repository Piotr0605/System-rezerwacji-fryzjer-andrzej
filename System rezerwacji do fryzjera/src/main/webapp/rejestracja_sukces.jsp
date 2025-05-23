<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>Rejestracja zakończona</title>
    <!-- Automatyczne przekierowanie po 3 sekundach na stronę logowania (index.jsp) -->
    <meta http-equiv="refresh" content="3;url=index.jsp">
    <style>
        /* ------- WYGLĄD CAŁEJ STRONY -------- */
        body {
            background-color: #111;        /* Bardzo ciemne tło */
            color: white;                 /* Biały tekst */
            font-family: sans-serif;      /* Czytelna czcionka */
            display: flex;                /* Centrowanie zawartości w pionie i poziomie */
            justify-content: center;
            align-items: center;
            height: 100vh;                /* Pełna wysokość ekranu */
            margin: 0;                    /* Bez marginesów domyślnych */
        }

        /* ------- PUDEŁKO Z KOMUNIKATEM -------- */
        .message-box {
            text-align: center;                      /* Tekst wyśrodkowany */
            padding: 30px;                           /* Margines wewnętrzny */
            border-radius: 10px;                     /* Zaokrąglone rogi */
            background-color: rgba(0, 0, 0, 0.5);    /* Półprzezroczyste tło */
            box-shadow: 0 0 10px rgba(255, 255, 255, 0.1); /* Delikatny cień */
        }
    </style>
</head>
<body>
<!-- Główne pudło z informacją o sukcesie rejestracji -->
<div class="message-box">
    <h2>Rejestracja zakończona sukcesem!</h2>
    <p>Za chwilę zostaniesz przeniesiony do logowania...</p>
</div>
</body>
</html>
