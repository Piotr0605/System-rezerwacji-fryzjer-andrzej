<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.example.systemrezerwacjidofryzjera.User" %>
<%
    User user = (User) session.getAttribute("user");
%>
<!DOCTYPE html>
<html lang="pl">
<head>
    <meta charset="UTF-8">
    <title>Panel fryzjera</title>
    <!-- FullCalendar -->
    <link href="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.8/index.global.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.8/index.global.min.js"></script>
    <style>
        body { margin:0; font-family:sans-serif;
            background:url("img/tłologowania.png") no-repeat center center fixed;
            background-size:cover; color:white;
        }
        .top-bar { background:#333; padding:20px;
            display:flex; justify-content:space-between; align-items:center;
        }
        .top-bar h1 { margin:0; font-size:28px }
        .top-bar a { color:#ccc; text-decoration:underline }
        .panel { padding:20px; max-width:1400px; margin:0 auto }
        #calendar { background:#fff; color:#000; border-radius:10px;
            padding:20px; margin-top:20px; height:900px; font-size:16px;
            box-shadow:0 6px 12px rgba(0,0,0,0.4);
        }
        .success-message { color:lightgreen; font-weight:bold; margin-top:10px }

        /* --- modalne okienka --- */
        #modalOverlay {
            display:none; position:fixed; top:0;left:0;right:0;bottom:0;
            background:rgba(0,0,0,0.6); align-items:center; justify-content:center;
            z-index:1000;
        }
        .modal-box {
            background:#fff; color:#000; padding:20px; border-radius:8px;
            max-width:400px; width:90%; text-align:center;
            box-shadow:0 2px 10px rgba(0,0,0,0.5);
            margin:0 auto;
        }
        .modal-box button {
            margin:10px 5px; padding:8px 16px;
            border:none; border-radius:4px; cursor:pointer;
        }
        #btnOk   { background:#007bff; color:#fff }
        #btnYes  { background:#28a745; color:#fff }
        #btnNo   { background:#dc3545; color:#fff }
        #promptInput {
            width:80%; padding:8px; margin:10px 0;
            border:1px solid #ccc; border-radius:4px;
            font-size:1rem;
        }
        /* --- /modale --- */
    </style>
</head>
<body>
<!-- overlay i trzy modal-boxy -->
<div id="modalOverlay">
    <div id="alertBox" class="modal-box" style="display:none;">
        <div id="alertMsg" style="margin-bottom:16px;"></div>
        <button id="btnOk">OK</button>
    </div>
    <div id="confirmBox" class="modal-box" style="display:none;">
        <div id="confirmMsg" style="margin-bottom:16px;"></div>
        <button id="btnYes">Tak</button>
        <button id="btnNo">Anuluj</button>
    </div>
    <div id="promptBox" class="modal-box" style="display:none;">
        <div id="promptMsg" style="margin-bottom:10px;"></div>
        <input id="promptInput" type="text"/>
        <div>
            <button id="promptOk">OK</button>
            <button id="promptCancel">Anuluj</button>
        </div>
    </div>
</div>
<!-- /modale -->

<div class="top-bar">
    <h1>Witaj, <%= user.getFirstName() %> (<%= user.getRole() %>)</h1>
    <a href="wyloguj" class="top-button">Wyloguj</a>
</div>
<div class="panel">
    Użytkownik: <%= user.getLastName() %> |
    Rola: <%= user.getRole().equals("fryzjer")?"Administrator":"Klient"%>
    <%
        String status = request.getParameter("status");
        if ("sukces".equals(status)) {
    %>
    <p class="success-message">✅ Godziny pracy zostały zapisane do bazy danych!</p>
    <%
        }
    %>
    <h2 style="margin-top:20px;">Kalendarz fryzjera</h2>
    <div id="calendar"></div>
</div>

<script>
    // nadpisanie alert/confirm/prompt
    (function(){
        const overlay   = document.getElementById('modalOverlay'),
            alertBox  = document.getElementById('alertBox'),
            confirmBox= document.getElementById('confirmBox'),
            promptBox = document.getElementById('promptBox'),
            alertMsg  = document.getElementById('alertMsg'),
            confirmMsg= document.getElementById('confirmMsg'),
            promptMsg = document.getElementById('promptMsg'),
            promptInput = document.getElementById('promptInput'),
            btnOk     = document.getElementById('btnOk'),
            btnYes    = document.getElementById('btnYes'),
            btnNo     = document.getElementById('btnNo'),
            promptOk  = document.getElementById('promptOk'),
            promptCancel = document.getElementById('promptCancel');

        function hideAll(){
            overlay.style.display='none';
            [alertBox,confirmBox,promptBox].forEach(b=>b.style.display='none');
            [btnOk,btnYes,btnNo,promptOk,promptCancel].forEach(btn=>btn.onclick=null);
        }

        window.alert = function(msg){
            hideAll();
            alertMsg.innerText=msg;
            alertBox.style.display='block';
            overlay.style.display='flex';
            return new Promise(res=>{
                btnOk.onclick=()=>{ hideAll(); res(); };
            });
        };

        window.confirm = function(msg){
            hideAll();
            confirmMsg.innerText=msg;
            confirmBox.style.display='block';
            overlay.style.display='flex';
            return new Promise(res=>{
                btnYes.onclick = ()=>{ hideAll(); res(true); };
                btnNo .onclick = ()=>{ hideAll(); res(false); };
            });
        };

        window.prompt = function(msg, def=''){
            hideAll();
            promptMsg.innerText=msg;
            promptInput.value=def;
            promptBox.style.display='block';
            overlay.style.display='flex';
            return new Promise(res=>{
                promptOk.onclick     = ()=>{ hideAll(); res(promptInput.value); };
                promptCancel.onclick = ()=>{ hideAll(); res(null); };
            });
        };
    })();
</script>

<script>
    document.addEventListener('DOMContentLoaded', function(){
        const calendarEl = document.getElementById('calendar'),
            ctx = '<%=request.getContextPath()%>';

        const calendar = new FullCalendar.Calendar(calendarEl, {
            initialView:'dayGridMonth',
            locale:'pl',
            headerToolbar:{ left:'prev,next today', center:'title', right:'' },
            events:{
                url: ctx+'/pobierz-wszystkie-wydarzenia',
                method:'GET',
                failure:()=> alert('❌ Nie udało się pobrać wydarzeń z bazy danych.')
            },
            eventColor:'#3a87ad',
            eventTimeFormat:{ hour:'2-digit', minute:'2-digit', hour12:false },
            dateClick: async info => {
                // używamy prompt z aplikacji, i poprawnie tworzymy inputy
                const start = await prompt("Podaj godzinę rozpoczęcia (np. 08:00):","08:00");
                if (!start) return;
                const end   = await prompt("Podaj godzinę zakończenia (np. 17:00):","17:00");
                if (!end) return;
                const form = document.createElement("form");
                form.method="POST"; form.action="dodaj-godziny";
                const inputData  = Object.assign(document.createElement("input"), {type:"hidden", name:"data",  value:info.dateStr});
                const inputStart = Object.assign(document.createElement("input"), {type:"hidden", name:"start", value:start});
                const inputEnd   = Object.assign(document.createElement("input"), {type:"hidden", name:"koniec",value:end});
                form.append(inputData,inputStart,inputEnd);
                document.body.appendChild(form);
                form.submit();
            },
            eventClick: info => {
                confirm("Czy chcesz usunąć godzinę pracy?").then(ok=>{
                    if (!ok) return;
                    fetch(ctx+"/usun-godziny",{
                        method:"POST",
                        headers:{"Content-Type":"application/x-www-form-urlencoded"},
                        body:new URLSearchParams({ slot_id: info.event.extendedProps.slot_id })
                    })
                        .then(r=>{
                            if(r.ok){ info.event.remove(); alert("✅ Godzina pracy została usunięta!"); }
                            else alert("❌ Nie udało się usunąć godziny pracy.");
                        })
                        .catch(()=>alert("❌ Błąd podczas usuwania godziny pracy."));
                });
            }
        });

        calendar.render();
    });
</script>
</body>
</html>
