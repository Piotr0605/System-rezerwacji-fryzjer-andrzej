<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.example.systemrezerwacjidofryzjera.User" %>
<%@ page session="true" %>
<%
    HttpSession sesja = request.getSession(false);
    if (sesja == null || sesja.getAttribute("user") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    User user = (User) sesja.getAttribute("user");
%>
<!DOCTYPE html>
<html lang="pl">
<head>
    <meta charset="UTF-8">
    <title>Panel klienta</title>

    <!-- FullCalendar -->
    <link href="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.8/index.global.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.8/index.global.min.js"></script>

    <style>
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

        /* --- MODALNE OKIENKA --- */
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
        /* --- KONIEC OKIENEK --- */
    </style>
</head>
<body>
<div class="panel">
    <div class="top-bar">
        <a href="moje-rezerwacje.jsp" class="top-button">Moje rezerwacje</a>
        <a href="wyloguj" class="top-button">Wyloguj</a>
    </div>

    <h1>Witaj, <%= user.getFirstName() %> <%= user.getLastName() %></h1>
    <p>E-mail: <strong><%= user.getEmail() %></strong></p>
    <p>Telefon: <strong><%= user.getPhone() %></strong></p>
    <p>Rola: <strong><%= user.getRole() %></strong></p>

    <h2>Dostępne terminy do rezerwacji</h2>
    <div id="calendar"></div>
</div>

<!-- MODALNE OKIENKA -->
<div id="modalOverlay">
    <div id="modalBox">
        <div id="modalMsg" style="margin-bottom:20px;"></div>
        <button id="btnYes" style="display:none;">Tak</button>
        <button id="btnNo" style="display:none;">Anuluj</button>
        <button id="btnOk" style="display:none;">OK</button>
    </div>
</div>

<script>
    // Nadpisujemy alert i confirm
    (function(){
        const overlay = document.getElementById('modalOverlay');
        const box     = document.getElementById('modalBox');
        const msgDiv  = document.getElementById('modalMsg');
        const btnOk   = document.getElementById('btnOk');
        const btnYes  = document.getElementById('btnYes');
        const btnNo   = document.getElementById('btnNo');

        function showModal(text, type, callback) {
            msgDiv.innerText = text;
            btnOk.style.display   = (type==='alert') ? 'inline-block' : 'none';
            btnYes.style.display  = (type==='confirm')? 'inline-block' : 'none';
            btnNo.style.display   = (type==='confirm')? 'inline-block' : 'none';
            overlay.style.display = 'flex';

            function clean() {
                overlay.style.display = 'none';
                btnOk.removeEventListener('click', onOk);
                btnYes.removeEventListener('click', onYes);
                btnNo.removeEventListener('click', onNo);
            }
            function onOk()   { clean(); callback(); }
            function onYes()  { clean(); callback(true); }
            function onNo()   { clean(); callback(false); }

            if (type==='alert') {
                btnOk.addEventListener('click', onOk);
            } else {
                btnYes.addEventListener('click', onYes);
                btnNo .addEventListener('click', onNo);
            }
        }

        window.alert = function(text){
            showModal(text, 'alert', function(){});
        };
        window.confirm = function(text){
            return new Promise(resolve => showModal(text, 'confirm', resolve));
        };
    })();
</script>

<script>
    document.addEventListener('DOMContentLoaded', function () {
        const calendarEl = document.getElementById('calendar');
        const ctx = '<%= request.getContextPath() %>';

        const calendar = new FullCalendar.Calendar(calendarEl, {
            initialView: 'dayGridMonth',
            locale: 'pl',
            headerToolbar: {
                left: 'prev,next today',
                center: 'title',
                right: ''
            },
            events: {
                url: ctx + '/dostepne-sloty',
                method: 'GET',
                extraParams: { t: Date.now() },
                failure: () => alert('❌ Nie udało się załadować terminów.'),
                success: (data) => {
                    data.forEach(evt => {
                        evt.extendedProps = { slot_id: evt.slot_id };
                    });
                }
            },
            eventClick: async (info) => {
                const slotId = info.event.extendedProps.slot_id;
                if (!slotId) {
                    await alert('❌ Brak poprawnego slot_id');
                    return;
                }
                const when = info.event.start.toLocaleString();
                const ok = await confirm(`Czy chcesz zarezerwować ten termin?\n${when}`);
                if (!ok) return;
                fetch(ctx + '/zarezerwuj', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: new URLSearchParams({ slot_id: slotId })
                })
                    .then(resp => {
                        if (resp.ok) {
                            info.event.remove();
                            alert('✅ Termin został zarezerwowany!');
                        } else {
                            resp.text().then(txt => alert('❌ Nie udało się zarezerwować:\n' + txt));
                        }
                    })
                    .catch(() => alert('❌ Błąd sieci. Spróbuj ponownie.'));
            }
        });

        calendar.render();
    });
</script>
</body>
</html>
