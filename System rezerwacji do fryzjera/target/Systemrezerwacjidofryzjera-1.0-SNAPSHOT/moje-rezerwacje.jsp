<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.example.systemrezerwacjidofryzjera.User" %>
<%@ page session="true" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
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
        body { background:#222; color:#fff; font-family:sans-serif; padding:20px; }
        .rezerwacje { background:#333; padding:20px; border-radius:10px; max-width:800px; margin:0 auto; }
        ul { list-style:none; padding:0; }
        li {
            background:#444; margin:10px 0; padding:15px; border-radius:5px;
            position:relative; color:#fff;
        }
        .cancel-btn {
            position:absolute; right:15px; top:15px;
            background:#c00; color:#fff; border:none;
            padding:6px 10px; border-radius:4px; cursor:pointer;
        }
        .cancel-btn:hover { background:#a00; }
        a { color:#ccc; text-decoration:underline; display:inline-block; margin-bottom:20px; }
        h1 { text-align:center; }
        .brak { text-align:center; font-style:italic; color:#bbb; }
        /* Modale */
        #confirmModal, #infoModal {
            display:none; position:fixed; top:0; left:0; right:0; bottom:0;
            background:rgba(0,0,0,0.6); align-items:center; justify-content:center; z-index:1000;
        }
        .modal-content {
            background:#fff; color:#000; padding:20px; border-radius:8px;
            max-width:400px; width:90%; text-align:center; box-shadow:0 2px 10px rgba(0,0,0,0.5);
        }
        .modal-content button {
            margin:10px 5px; padding:8px 16px; border:none; border-radius:4px; cursor:pointer;
        }
        #confirmYes { background:#28a745; color:#fff; }
        #confirmNo  { background:#dc3545; color:#fff; }
        #infoOk    { background:#007bff; color:#fff; }
    </style>
</head>
<body>
<div class="rezerwacje">
    <h1>Moje rezerwacje</h1>
    <a href="dashboard.jsp">⬅ Wróć do panelu</a>
    <ul id="lista-rezerwacji"></ul>
</div>

<!-- Modal potwierdzenia -->
<div id="confirmModal">
    <div class="modal-content">
        <div id="confirmMessage" style="margin-bottom:16px;"></div>
        <button id="confirmYes">Tak</button>
        <button id="confirmNo" >Anuluj</button>
    </div>
</div>
<!-- Modal informacji -->
<div id="infoModal">
    <div class="modal-content">
        <div id="infoMessage" style="margin-bottom:16px;"></div>
        <button id="infoOk">OK</button>
    </div>
</div>

<script>
    function showConfirm(msg, cb) {
        const modal = document.getElementById('confirmModal');
        document.getElementById('confirmMessage').innerText = msg;
        modal.style.display = 'flex';
        const yes = document.getElementById('confirmYes');
        const no  = document.getElementById('confirmNo');
        function clean() {
            modal.style.display = 'none';
            yes.removeEventListener('click', onYes);
            no.removeEventListener ('click', onNo);
        }
        function onYes(){ clean(); cb(true); }
        function onNo() { clean(); cb(false); }
        yes.addEventListener('click', onYes);
        no.addEventListener ('click', onNo);
    }
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

    document.addEventListener('DOMContentLoaded', ()=> {
        const ul = document.getElementById("lista-rezerwacji");

        fetch("<%=request.getContextPath()%>/pobierz-rezerwacje")
            .then(r=>r.ok? r.json() : Promise.reject(r.status))
            .then(data=>{
                if (!data.length) {
                    ul.innerHTML = "<li class='brak'>Brak rezerwacji</li>";
                    return;
                }
                ul.innerHTML = "";
                data.forEach(evt => {
                    console.log("REZERWACJA:", evt);
                    const li = document.createElement("li");

                    // wyświetlamy datę + tytuł
                    const dt = new Date(evt.start);
                    const fmt = dt.toLocaleString("pl-PL", { dateStyle:"full", timeStyle:"short" });
                    li.innerText = fmt + " – " + (evt.title || "Rezerwacja");

                    // przycisk
                    const btn = document.createElement("button");
                    btn.className = "cancel-btn";
                    btn.textContent = "Odwołaj wizytę";
                    btn.onclick = () => {
                        showConfirm(`Czy na pewno odwołać wizytę?\n${fmt}`, ok=>{
                            if (!ok) return;
                            fetch("<%=request.getContextPath()%>/odwolaj-rezerwacje", {
                                method:"POST",
                                headers:{"Content-Type":"application/x-www-form-urlencoded"},
                                body:new URLSearchParams({ reservation_id: evt.id })
                            })
                                .then(r2=>{
                                    if (r2.ok) {
                                        li.remove();
                                        if (!ul.children.length)
                                            ul.innerHTML = "<li class='brak'>Brak rezerwacji</li>";
                                        showInfo("Wizytę odwołano.");
                                    } else {
                                        showInfo("Nie udało się odwołać wizyty.");
                                    }
                                })
                                .catch(_=> showInfo("Błąd sieci. Spróbuj ponownie."));
                        });
                    };
                    li.appendChild(btn);
                    ul.appendChild(li);
                });
            })
            .catch(err=>{
                console.error("Błąd pobierania rezerwacji:", err);
                ul.innerHTML = "<li class='brak'>Błąd wczytywania rezerwacji</li>";
            });
    });
</script>
</body>
</html>
