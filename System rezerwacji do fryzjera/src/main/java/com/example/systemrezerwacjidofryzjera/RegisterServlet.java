package com.example.systemrezerwacjidofryzjera;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

// Serwlet obsługujący rejestrację nowego użytkownika (klienta) w systemie
@WebServlet(name = "RegisterServlet", value = "/register")
public class RegisterServlet extends HttpServlet {

    // Ta metoda uruchamia się, gdy użytkownik wysyła formularz rejestracji (POST)
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Pobierz dane wpisane przez użytkownika w formularzu rejestracji
        String firstName = request.getParameter("firstName");
        String lastName = request.getParameter("lastName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String password = request.getParameter("password");

        // 2. Sprawdź, czy w bazie istnieje już użytkownik o podanym adresie e-mail
        if (UserStorage.getUserByEmail(email) != null) {
            // Jeśli taki e-mail już jest – przekaż informację o błędzie na stronę rejestracji
            request.setAttribute("error", "Użytkownik z tym e-mailem już istnieje!");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

        // 3. Utwórz nowy obiekt użytkownika z podanymi danymi (domyślnie jako "klient")
        User user = new User(firstName, lastName, password, email, "klient", phone);

        // 4. Zapisz nowego użytkownika do bazy danych
        UserStorage.saveUserToDatabase(user);

        // 5. Po poprawnej rejestracji przekieruj użytkownika na stronę z komunikatem o sukcesie
        response.sendRedirect("rejestracja_sukces.jsp");
    }
}

/*
    PODSUMOWANIE DZIAŁANIA:

    - Ten serwlet obsługuje proces rejestracji nowych użytkowników w systemie.
    - Po wypełnieniu i wysłaniu formularza na stronie rejestracji, metoda doPost() pobiera wszystkie dane od użytkownika.
    - Następnie sprawdza, czy w bazie nie istnieje już użytkownik z takim adresem e-mail (unikalność e-maila!).
    - Jeśli e-mail jest już zajęty, użytkownik otrzymuje informację o błędzie i pozostaje na stronie rejestracji.
    - Jeśli e-mail jest wolny, tworzony jest nowy użytkownik o roli "klient" i zapisywany w bazie danych.
    - Po udanej rejestracji użytkownik zostaje przekierowany na specjalną stronę "rejestracja_sukces.jsp", gdzie widzi potwierdzenie sukcesu.
    - Dzięki temu nowi użytkownicy mogą bezpiecznie i wygodnie zakładać konta w systemie rezerwacji.
*/
