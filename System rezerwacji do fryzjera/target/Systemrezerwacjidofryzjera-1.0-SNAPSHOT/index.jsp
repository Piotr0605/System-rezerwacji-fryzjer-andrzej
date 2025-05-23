<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>Logowanie</title>
    <style>
        html, body {
            margin: 0;
            padding: 0;
            height: 100%;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            color: white;
            background: url("img/tłologowania.png") no-repeat center center fixed;
            background-size: cover;
        }

        .container {
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            height: 100%;
            padding: 30px;
        }

        .welcome-bar {
            font-size: 3.1rem;
            font-weight: bold;
            background: rgba(0, 0, 0, 0.6);
            padding: 22px 44px;
            border-radius: 16px;
            margin-bottom: 44px;
            box-shadow: 0 6px 22px rgba(0, 0, 0, 0.7);
            text-align: center;
        }

        .form-container {
            background: rgba(0, 0, 0, 0.6);
            padding: 44px 33px;
            border-radius: 16px;
            backdrop-filter: blur(6px);
            -webkit-backdrop-filter: blur(6px);
            box-shadow: 0 0 22px rgba(0, 0, 0, 0.6);
            width: 100%;
            max-width: 440px;
            display: flex;
            flex-direction: column;
            align-items: center;
        }

        .form-container h2 {
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
            padding: 15px;
            margin: 13px 0;
            width: 100%;
            max-width: 330px;
            border: none;
            border-radius: 6px;
            background: #444;
            color: white;
            font-size: 1.1rem;
        }

        input[type="submit"] {
            background-color: #555;
            cursor: pointer;
            font-weight: bold;
        }

        input[type="submit"]:hover {
            background-color: #666;
        }

        a {
            color: #66ccff;
            text-decoration: underline;
        }

        .bottom-text {
            font-size: 1.3rem;
            margin-top: 30px;
            text-align: center;
        }

        .error {
            color: red;
            margin-top: 11px;
            text-align: center;
        }

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
    <div class="welcome-bar">
        Witaj w barbershopie u Andrzeja!
    </div>

    <div class="form-container">
        <h2>Zaloguj się</h2>

        <form method="post" action="login">
            <input type="text" name="email" placeholder="E-mail" required><br>
            <input type="password" name="password" placeholder="Hasło" required><br>
            <input type="submit" value="Zaloguj">
            <p class="bottom-text">
                Nie masz konta?
                <a href="register.jsp">Załóż je już teraz!</a>
            </p>
        </form>

        <p class="error">
            <%= request.getAttribute("error") != null ? request.getAttribute("error") : "" %>
        </p>
    </div>
</div>
</body>
</html>
