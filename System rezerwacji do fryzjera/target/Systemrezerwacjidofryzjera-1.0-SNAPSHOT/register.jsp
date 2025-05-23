<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>Rejestracja</title>
    <style>
        body {
            background-image: url("img/tłologowania.png");
            background-size: cover;
            background-position: center;
            background-repeat: no-repeat;
            margin: 0;
            height: 100vh;
            color: white;
            font-family: sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
        }
        .form-container h2 {
            font-size: 40px;
        }

        .form-container p {
            font-size: 30px;
        }

        .form-container p a {
            font-size: 22px;
        }

        .form-container {
            background: rgba(0, 0, 0, 0.4);
            padding: 200px;
            border-radius: 100px;
            backdrop-filter: blur(5px);
            -webkit-backdrop-filter: blur(5px);
            box-shadow: 0 0 100px rgba(0, 0, 0, 0.5);
            text-align: center;
        }

        input {
            padding: 20px;
            margin: 15px;
            width: 520px;
            border: none;
            border-radius: 50px;
            background: #444;
            color: white;
        }

        input[type="submit"] {
            background-color: #555;
            cursor: pointer;
        }

        input[type="submit"]:hover {
            background-color: #666;
        }

        a {
            color: #66ccff;
            text-decoration: underline;
        }

        .error-popup {
            position: relative;
            background-color: #ffdddd;
            color: #a94442;
            padding: 15px 40px 15px 20px;
            border: 1px solid #f5c6cb;
            border-radius: 5px;
            margin-bottom: 15px;
            font-size: 14px;
            box-shadow: 0 2px 6px rgba(0,0,0,0.3);
        }

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

    <% String error = (String) request.getAttribute("error"); %>
    <% if (error != null) { %>
    <div class="error-popup" id="popup">
        <span class="close-btn" onclick="document.getElementById('popup').style.display='none'">&times;</span>
        <%= error %>
    </div>
    <% } %>

    <form method="post" action="register">
        <input type="text" name="firstName" placeholder="Imię" required><br>
        <input type="text" name="lastName" placeholder="Nazwisko" required><br>
        <input type="email" name="email" placeholder="E-mail" required><br>
        <input type="text" name="phone" placeholder="Telefon" maxlength="9" pattern="[0-9]{9}" required><br>
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
