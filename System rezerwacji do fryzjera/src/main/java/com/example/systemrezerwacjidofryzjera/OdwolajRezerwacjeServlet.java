package com.example.systemrezerwacjidofryzjera;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.*;

// Serwlet obsługujący odwoływanie (usuwanie) rezerwacji przez użytkownika (klienta)
@WebServlet("/odwolaj-rezerwacje")
public class OdwolajRezerwacjeServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        // Sprawdź, czy użytkownik jest zalogowany
        HttpSession session = req.getSession(false);
        User user = session == null ? null : (User) session.getAttribute("user");
        if (user == null) {
            // Jeśli nie jest zalogowany, zwróć błąd "401 Unauthorized"
            resp.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        // Pobierz identyfikator rezerwacji, którą użytkownik chce odwołać
        String pid = req.getParameter("reservation_id");
        if (pid == null) {
            // Jeśli nie podano ID rezerwacji, zwróć błąd "400 Bad Request"
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }
        int id;
        try {
            id = Integer.parseInt(pid); // Zamień tekstowy identyfikator na liczbę
        } catch (NumberFormatException e) {
            // Jeśli ID nie jest liczbą, zwróć błąd "400 Bad Request"
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        // Przygotuj zapytanie SQL do usunięcia rezerwacji, jeśli należy ona do tego użytkownika
        String sql = "DELETE FROM rezerwacje WHERE id = ? AND klient_id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);         // ID rezerwacji
            ps.setInt(2, user.getId()); // ID zalogowanego użytkownika
            int del = ps.executeUpdate(); // Wykonaj zapytanie (usuń rezerwację)
            if (del == 0) {
                // Jeśli nie usunięto żadnego wiersza – rezerwacja nie należy do tego użytkownika lub nie istnieje
                resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            } else {
                // Jeśli usunięcie się udało, wyślij status OK
                resp.setStatus(HttpServletResponse.SC_OK);
            }
        } catch (SQLException e) {
            // Jeśli pojawił się problem z bazą danych, zwróć błąd serwera
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
}

/*
    PODSUMOWANIE DZIAŁANIA:

    - Ten plik pozwala zalogowanemu użytkownikowi (klientowi) odwołać (usunąć) swoją rezerwację w systemie.
    - Serwlet sprawdza, czy użytkownik jest zalogowany i czy podano poprawny identyfikator rezerwacji.
    - Następnie usuwa rezerwację z bazy danych **tylko jeśli należy ona do zalogowanego użytkownika** (zabezpieczenie przed usuwaniem cudzych rezerwacji).
    - Jeśli operacja się powiedzie – zwraca status OK (200), jeśli rezerwacja nie należy do użytkownika – błąd FORBIDDEN (403).
    - W przypadku problemu z danymi wejściowymi (brak ID, zły format) zwraca odpowiedni błąd (400 Bad Request).
    - Dzięki temu użytkownik może samodzielnie anulować swoją rezerwację bez ingerencji administratora.
*/
