<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.example.systemrezerwacjidofryzjera.User" %>
<%@ page session="true" %>
<%
    // === SEKCJA 1: Weryfikacja zalogowania użytkownika ===
    // Pobieramy bieżącą sesję (jeśli istnieje).
    HttpSession sesja = request.getSession(false);

    // Jeśli sesja nie istnieje LUB nie ma w niej obiektu 'user',
    // przekierowujemy użytkownika na stronę logowania (login.jsp).
    // Dzięki temu nikt niepowołany nie zobaczy panelu klienta.
    if (sesja == null || sesja.getAttribute("user") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Pobieramy obiekt User z sesji – żeby wyświetlić imię, mail itd.
    User user = (User) sesja.getAttribute("user");
%>
<!DOCTYPE html>
<html lang="pl">
<head>
    <meta charset="UTF-8">
    <title>Panel klienta</title>

    <!-- Ładujemy FullCalendar (biblioteka JS do nowoczesnego kalendarza) -->
    <link href="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.8/index.global.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.8/index.global.min.js"></script>

    <style>
        /* === Wygląd strony – ciemne tło, ładne karty, przyciski itp. === */
        body {
            margin: 0;
            font-family: sans-serif;
            background: url("img/tłologowania.png");
            background-size: cover;
            background-position: center;
            background-repeat: no-repeat;
            color: white;
        }
        .panel {
            background-color: #333;
            padding: 20px;
            border-radius: 10px;
            max-width: 1000px;
            margin: 40px auto;
        }
        .top-bar {
            display: flex;
            justify-content: flex-end;
            gap: 20px;
            margin-bottom: 20px;
        }
        .top-button {
            color: #ccc;
            text-decoration: underline;
            font-size: 16px;
            transition: color 0.3s;
        }
        .top-button:hover { color: white; }
        h1, h2 { text-align: center; }
        #calendar {
            background-color: white;
            color: black;
            border-radius: 10px;
            padding: 10px;
            margin-top: 20px;
        }
        /* --- MODAL: własne okienka alert/confirm, zamiast domyślnych przeglądarki --- */
        #modalOverlay {
            display: none;
            position: fixed; top: 0; left: 0; right: 0; bottom: 0;
            background: rgba(0,0,0,0.6);
            align-items: center; justify-content: center;
            z-index: 1000;
        }
        #modalBox {
            background: #fff; color: #000;
            padding: 20px; border-radius: 8px;
            max-width: 400px; width: 90%; text-align: center;
            box-shadow: 0 2px 10px rgba(0,0,0,0.5);
        }
        #modalBox button {
            margin: 10px 5px; padding: 8px 16px;
            border: none; border-radius: 4px; cursor: pointer;
        }
        #btnOk    { background: #007bff; color: #fff; }
        #btnYes   { background: #28a745; color: #fff; }
        #btnNo    { background: #dc3545; color: #fff; }
    </style>
</head>
<body>
<div class="panel">
    <div class="top-bar">
        <!-- Link do podglądu własnych rezerwacji (osobna strona) -->
        <a href="moje-rezerwacje.jsp" class="top-button">Moje rezerwacje</a>
        <!-- Link do wylogowania – usuwa sesję i przenosi do logowania -->
        <a href="wyloguj" class="top-button">Wyloguj</a>
    </div>

    <!-- === Powitanie + dane zalogowanego użytkownika === -->
    <h1>Witaj, <%= user.getFirstName() %> <%= user.getLastName() %></h1>
    <p>E-mail: <strong><%= user.getEmail() %></strong></p>
    <p>Telefon: <strong><%= user.getPhone() %></strong></p>
    <p>Rola: <strong><%= user.getRole() %></strong></p>

    <!-- Sekcja: kalendarz dostępnych terminów do rezerwacji -->
    <h2>Dostępne terminy do rezerwacji</h2>
    <div id="calendar"></div>
</div>

<!-- === MODALNE OKIENKA: niestandardowe alert/confirm (lepsze UX) === -->
<div id="modalOverlay">
    <div id="modalBox">
        <div id="modalMsg" style="margin-bottom:20px;"></div>
        <button id="btnYes" style="display:none;">Tak</button>
        <button id="btnNo" style="display:none;">Anuluj</button>
        <button id="btnOk" style="display:none;">OK</button>
    </div>
</div>

<script>
    // === Zamiana domyślnych alert/confirm na własne okienka modalne (ładniejsze dla użytkownika) ===
    (function(){
        const overlay = document.getElementById('modalOverlay');
        const box     = document.getElementById('modalBox');
        const msgDiv  = document.getElementById('modalMsg');
        const btnOk   = document.getElementById('btnOk');
        const btnYes  = document.getElementById('btnYes');
        const btnNo   = document.getElementById('btnNo');

        // showModal – pokazuje okno modalne z wiadomością i odpowiednimi przyciskami
        function showModal(text, type, callback) {
            msgDiv.innerText = text;
            btnOk.style.display   = (type==='alert') ? 'inline-block' : 'none';
            btnYes.style.display  = (type==='confirm')? 'inline-block' : 'none';
            btnNo.style.display   = (type==='confirm')? 'inline-block' : 'none';
            overlay.style.display = 'flex';

            // Czyszczenie listenerów po kliknięciu przycisku
            function clean() {
                overlay.style.display = 'none';
                btnOk.removeEventListener('click', onOk);
                btnYes.removeEventListener('click', onYes);
                btnNo.removeEventListener('click', onNo);
            }
            // Definicje akcji dla przycisków
            function onOk()   { clean(); callback(); }
            function onYes()  { clean(); callback(true); }
            function onNo()   { clean(); callback(false); }

            // Podłączanie listenerów w zależności od typu okna
            if (type==='alert') {
                btnOk.addEventListener('click', onOk);
            } else {
                btnYes.addEventListener('click', onYes);
                btnNo .addEventListener('click', onNo);
            }
        }

        // Zastępujemy standardowy window.alert naszą funkcją showModal
        window.alert = function(text){
            showModal(text, 'alert', function(){});
        };
        // Zastępujemy window.confirm naszą wersją (z Promise, by obsłużyć asynchronicznie)
        window.confirm = function(text){
            return new Promise(resolve => showModal(text, 'confirm', resolve));
        };
    })();
</script>

<script>
    // === Po załadowaniu strony uruchamiamy kod JS, który tworzy i wyświetla kalendarz ===
    document.addEventListener('DOMContentLoaded', function () {
        const calendarEl = document.getElementById('calendar');        // Gdzie osadzić kalendarz
        const ctx = '<%= request.getContextPath() %>';                 // Ścieżka aplikacji (np. /FryzjerApp)

        // Inicjalizacja FullCalendar – najważniejszy element UI tej strony!
        const calendar = new FullCalendar.Calendar(calendarEl, {
            initialView: 'dayGridMonth',     // Widok miesięczny
            locale: 'pl',                    // Kalendarz po polsku
            headerToolbar: {
                left: 'prev,next today',
                center: 'title',
                right: ''
            },
            // Skąd pobieramy dostępne terminy? – serwlet /dostepne-sloty zwraca je w JSON
            events: {
                url: ctx + '/dostepne-sloty',         // Adres API (servlet w Javie)
                method: 'GET',
                extraParams: { t: Date.now() },       // Dodanie parametru, żeby nie korzystać z cache przeglądarki
                failure: () => alert('❌ Nie udało się załadować terminów.'),
                // Po sukcesie: do każdego terminu (slotu) dodajemy jego identyfikator do extendedProps
                success: (data) => {
                    data.forEach(evt => {
                        evt.extendedProps = { slot_id: evt.slot_id };
                    });
                }
            },
            // Co się dzieje po kliknięciu w termin?
            eventClick: async (info) => {
                const slotId = info.event.extendedProps.slot_id; // Pobieramy slot_id (np. 23-09:00)
                if (!slotId) {
                    await alert('❌ Brak poprawnego slot_id');
                    return;
                }
                // Pokaż datę/godzinę wybranego terminu
                const when = info.event.start.toLocaleString();
                // Potwierdź, czy użytkownik na pewno chce ten termin
                const ok = await confirm(`Czy chcesz zarezerwować ten termin?\n${when}`);
                if (!ok) return;
                // Wyślij zapytanie POST do serwera (serwlet /zarezerwuj) z wybranym slot_id
                fetch(ctx + '/zarezerwuj', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: new URLSearchParams({ slot_id: slotId })
                })
                    .then(resp => {
                        if (resp.ok) {
                            // Sukces: usuwamy slot z kalendarza i pokazujemy potwierdzenie
                            info.event.remove();
                            alert('✅ Termin został zarezerwowany!');
                        } else {
                            // Błąd: pokaż komunikat z serwera (np. slot już zajęty)
                            resp.text().then(txt => alert('❌ Nie udało się zarezerwować:\n' + txt));
                        }
                    })
                    .catch(() => alert('❌ Błąd sieci. Spróbuj ponownie.'));
            }
        });

        // Wyświetl kalendarz na stronie
        calendar.render();
    });
</script>
</body>
</html>

<!--
==================== PODSUMOWANIE ====================

Ta strona to **panel klienta** w systemie rezerwacji fryzjera.
1. Na początku weryfikuje, czy użytkownik jest zalogowany (jeśli nie – przekierowuje do logowania).
2. Wyświetla dane klienta (imię, nazwisko, mail, telefon, rola).
3. Pokazuje **nowoczesny kalendarz** z dostępnymi terminami (slotami) do rezerwacji.
4. Po kliknięciu w wolny termin pyta użytkownika (własny modal): "Czy chcesz zarezerwować ten termin?".
5. Jeśli użytkownik potwierdzi, wysyła żądanie do serwera. Po sukcesie termin znika z kalendarza.
6. Górny pasek pozwala przejść do własnych rezerwacji (moje-rezerwacje.jsp) lub się wylogować.
7. Całość jest bardzo czytelna, intuicyjna i łatwa w obsłudze nawet dla początkującego użytkownika.

Logika biznesowa (obsługa rezerwacji, dostępność terminów, autoryzacja) jest ukryta po stronie serwera w Java Servletach.
Front-End korzysta z FullCalendar, customowych modali i nowoczesnego stylu.

-->
