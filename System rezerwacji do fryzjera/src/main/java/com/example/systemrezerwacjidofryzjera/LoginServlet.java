package com.example.systemrezerwacjidofryzjera;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

// Serwlet obsługujący logowanie użytkownika do systemu przez formularz na stronie (adres /login)
@WebServlet(name = "LoginServlet", value = "/login")
public class LoginServlet extends HttpServlet {

    // Ta metoda uruchamia się, gdy użytkownik wysyła formularz logowania (POST)
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Odczytaj dane wpisane przez użytkownika w formularzu logowania (e-mail i hasło)
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        // Pobierz użytkownika z bazy danych po adresie e-mail
        User user = UserStorage.getUserByEmail(email);

        // Sprawdź, czy użytkownik istnieje i hasło się zgadza
        if (user != null && user.getPassword().equals(password)) {
            // Jeśli logowanie się powiodło – zapisz użytkownika w sesji (będzie "zapamiętany" jako zalogowany)
            request.getSession().setAttribute("user", user);

            // Jeśli użytkownik jest fryzjerem, przekieruj go na panel fryzjera, inaczej na panel klienta
            if ("fryzjer".equalsIgnoreCase(user.getRole())) {
                response.sendRedirect("fryzjer-dashboard.jsp");
            } else {
                response.sendRedirect("dashboard.jsp");
            }

        } else {
            // Jeśli logowanie się nie udało (złe dane), dodaj informację o błędzie do żądania
            request.setAttribute("error", "Nieprawidłowy e-mail lub hasło");
            // Przekieruj z powrotem na stronę logowania, pokazując błąd użytkownikowi
            request.getRequestDispatcher("index.jsp").forward(request, response);
        }
    }
}

/*
    PODSUMOWANIE DZIAŁANIA:

    - Ten plik odpowiada za obsługę logowania użytkowników do systemu.
    - Po wysłaniu formularza logowania z danymi, serwlet sprawdza, czy taki użytkownik istnieje w bazie i czy podane hasło się zgadza.
    - Jeśli logowanie się uda – użytkownik zostaje zapisany w sesji (system pamięta, kto jest zalogowany), a następnie przekierowany na odpowiedni panel:
        - Jeśli jest fryzjerem: do fryzjer-dashboard.jsp (panel fryzjera)
        - Jeśli jest klientem: do dashboard.jsp (panel klienta)
    - Jeśli dane są niepoprawne, użytkownik zostaje o tym poinformowany na stronie logowania (index.jsp).
    - Dzięki temu mechanizmowi tylko poprawnie zalogowani użytkownicy mają dostęp do odpowiednich części systemu.
*/
