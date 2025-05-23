<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.example.systemrezerwacjidofryzjera.User" %>
<%@ page session="true" %>
<%
    // Pobierz obiekt użytkownika z sesji (jeśli ktoś jest zalogowany)
    User user = (User) session.getAttribute("user");
    if (user == null) {
        // Jeśli nie ma zalogowanego użytkownika (np. nie przeszedł logowania)
        // to przekieruj na stronę logowania i przerwij ładowanie tej strony
        response.sendRedirect("index.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="pl">
<head>
    <meta charset="UTF-8">
    <title>Moje rezerwacje</title>
    <style>
        /* Ustawienia wyglądu całej strony */
        body {
            background: #222;        /* ciemne tło */
            color: #fff;             /* białe litery */
            font-family: sans-serif; /* czytelna czcionka */
            padding: 20px;           /* trochę wolnej przestrzeni dookoła */
        }
        /* Wygląd głównego "pudełka" z rezerwacjami */
        .rezerwacje {
            background: #333;
            padding: 20px;
            border-radius: 10px;     /* zaokrąglenie rogów */
            max-width: 800px;
            margin: 0 auto;          /* wyśrodkowanie */
        }
        /* Wyłącz domyślne kropki przy liście */
        ul {
            list-style: none;
            padding: 0;
        }
        /* Każda rezerwacja na liście */
        li {
            background: #444;
            margin: 10px 0;
            padding: 15px;
            border-radius: 5px;
            position: relative;
            color: #fff;
        }
        /* Przycisk "Odwołaj wizytę" – pojawia się w prawym górnym rogu rezerwacji */
        .cancel-btn {
            position: absolute;
            right: 15px;
            top: 15px;
            background: #c00;         /* czerwone tło */
            color: #fff;
            border: none;
            padding: 6px 10px;
            border-radius: 4px;
            cursor: pointer;         /* rączka po najechaniu */
        }
        /* Po najechaniu na przycisk zmienia się odcień */
        .cancel-btn:hover {
            background: #a00;
        }
        /* Link "wróć do panelu" */
        a {
            color: #ccc;
            text-decoration: underline;
            display: inline-block;
            margin-bottom: 20px;
        }
        /* Nagłówek na środku */
        h1 {
            text-align: center;
        }
        /* Szare info jeśli brak rezerwacji */
        .brak {
            text-align: center;
            font-style: italic;
            color: #bbb;
        }
        /* ---------- MODALE (okienka wyskakujące) ---------- */
        /* Tło na cały ekran, żeby modal był widoczny */
        #confirmModal, #infoModal {
            display: none;              /* domyślnie ukryte */
            position: fixed;            /* zawsze na widoku */
            top: 0; left: 0; right: 0; bottom: 0;
            background: rgba(0,0,0,0.6);/* lekko przezroczyste ciemne tło */
            align-items: center;
            justify-content: center;
            z-index: 1000;              /* nad wszystkim innym */
        }
        /* Środek okienka (biała ramka z tekstem i przyciskami) */
        .modal-content {
            background: #fff;
            color: #000;
            padding: 20px;
            border-radius: 8px;
            max-width: 400px;
            width: 90%;
            text-align: center;
            box-shadow: 0 2px 10px rgba(0,0,0,0.5);
        }
        /* Przyciski w okienkach */
        .modal-content button {
            margin: 10px 5px;
            padding: 8px 16px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
        }
        /* Zielony przycisk "Tak" */
        #confirmYes { background: #28a745; color: #fff; }
        /* Czerwony przycisk "Anuluj" */
        #confirmNo  { background: #dc3545; color: #fff; }
        /* Niebieski przycisk "OK" */
        #infoOk    { background: #007bff; color: #fff; }
    </style>
</head>
<body>
<!-- Główne pole z rezerwacjami -->
<div class="rezerwacje">
    <h1>Moje rezerwacje</h1>
    <a href="dashboard.jsp">⬅ Wróć do panelu</a>
    <!-- Tu (JS) będzie wstawiana lista rezerwacji -->
    <ul id="lista-rezerwacji"></ul>
</div>

<!-- Okienko potwierdzenia odwołania rezerwacji -->
<div id="confirmModal">
    <div class="modal-content">
        <div id="confirmMessage" style="margin-bottom:16px;"></div>
        <button id="confirmYes">Tak</button>
        <button id="confirmNo" >Anuluj</button>
    </div>
</div>
<!-- Okienko informacyjne (np. po udanym anulowaniu) -->
<div id="infoModal">
    <div class="modal-content">
        <div id="infoMessage" style="margin-bottom:16px;"></div>
        <button id="infoOk">OK</button>
    </div>
</div>

<script>
    // POKAZUJE okno potwierdzenia (Tak/Anuluj) – używane gdy ktoś chce odwołać wizytę
    function showConfirm(msg, cb) {
        const modal = document.getElementById('confirmModal');
        document.getElementById('confirmMessage').innerText = msg; // treść okienka
        modal.style.display = 'flex'; // pokaż okno

        const yes = document.getElementById('confirmYes');
        const no  = document.getElementById('confirmNo');

        // Sprzątamy zdarzenia po kliknięciu (żeby nie dodało się 2x)
        function clean() {
            modal.style.display = 'none';
            yes.removeEventListener('click', onYes);
            no.removeEventListener ('click', onNo);
        }
        // Funkcje obsługujące kliknięcia
        function onYes(){ clean(); cb(true); }
        function onNo() { clean(); cb(false); }
        // Dodajemy obsługę przycisków
        yes.addEventListener('click', onYes);
        no.addEventListener ('click', onNo);
    }

    // POKAZUJE zwykłe info (np. "Wizytę odwołano") – po prostu "OK"
    function showInfo(msg, cb) {
        const modal = document.getElementById('infoModal');
        document.getElementById('infoMessage').innerText = msg;
        modal.style.display = 'flex';
        const ok = document.getElementById('infoOk');
        function clean() {
            modal.style.display = 'none';
            ok.removeEventListener('click', onOk);
        }
        function onOk(){ clean(); if(cb) cb(); }
        ok.addEventListener('click', onOk);
    }

    // --------------------- GŁÓWNY SKRYPT ----------------------
    document.addEventListener('DOMContentLoaded', ()=> {
        const ul = document.getElementById("lista-rezerwacji");

        // Pobieramy (przez AJAX) listę rezerwacji użytkownika z serwera (w tle, bez przeładowania strony)
        fetch("<%=request.getContextPath()%>/pobierz-rezerwacje")
            .then(r=>r.ok? r.json() : Promise.reject(r.status)) // Oczekujemy odpowiedzi typu JSON (tablica)
            .then(data=>{
                if (!data.length) {
                    // Jeżeli tablica jest pusta – nie ma żadnych rezerwacji
                    ul.innerHTML = "<li class='brak'>Brak rezerwacji</li>";
                    return;
                }
                ul.innerHTML = ""; // Czyścimy listę przed dodaniem nowych elementów
                data.forEach(evt => {
                    // Dla każdej rezerwacji tworzymy osobny element <li>
                    const li = document.createElement("li");

                    // Formatowanie daty na polski czytelny zapis
                    const dt = new Date(evt.start); // data rozpoczęcia rezerwacji
                    const fmt = dt.toLocaleString("pl-PL", { dateStyle:"full", timeStyle:"short" });

                    // W treści pokazujemy datę i tytuł rezerwacji (np. "Twoja rezerwacja")
                    li.innerText = fmt + " – " + (evt.title || "Rezerwacja");

                    // Tworzymy przycisk "Odwołaj wizytę"
                    const btn = document.createElement("button");
                    btn.className = "cancel-btn";
                    btn.textContent = "Odwołaj wizytę";
                    btn.onclick = () => {
                        // Po kliknięciu pokaż okno potwierdzenia
                        showConfirm(`Czy na pewno odwołać wizytę?\n${fmt}`, ok=>{
                            if (!ok) return; // Jeśli kliknięto Anuluj – nic nie rób
                            // Jeśli potwierdzono – wyślij żądanie POST do serwera aby anulować rezerwację
                            fetch("<%=request.getContextPath()%>/odwolaj-rezerwacje", {
                                method:"POST",
                                headers:{"Content-Type":"application/x-www-form-urlencoded"},
                                body:new URLSearchParams({ reservation_id: evt.id })
                            })
                                .then(r2=>{
                                    if (r2.ok) {
                                        // Jeśli się udało – usuń rezerwację z listy i pokaż info
                                        li.remove();
                                        if (!ul.children.length)
                                            ul.innerHTML = "<li class='brak'>Brak rezerwacji</li>";
                                        showInfo("Wizytę odwołano.");
                                    } else {
                                        // Jeśli serwer zwróci błąd
                                        showInfo("Nie udało się odwołać wizyty.");
                                    }
                                })
                                .catch(_=> showInfo("Błąd sieci. Spróbuj ponownie.")); // Jeśli błąd połączenia z serwerem
                        });
                    };
                    // Dodajemy przycisk do rezerwacji
                    li.appendChild(btn);
                    // Dodajemy całą rezerwację do listy na stronie
                    ul.appendChild(li);
                });
            })
            .catch(err=>{
                // Jeżeli nie udało się pobrać rezerwacji (np. serwer padł) – pokaż komunikat o błędzie
                console.error("Błąd pobierania rezerwacji:", err);
                ul.innerHTML = "<li class='brak'>Błąd wczytywania rezerwacji</li>";
            });
    });
</script>
</body>
</html>
