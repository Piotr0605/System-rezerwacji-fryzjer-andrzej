package com.example.systemrezerwacjidofryzjera;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.logging.*;

// To jest serwlet (program działający na serwerze) obsługujący dodawanie godzin pracy fryzjera.
// Jest wywoływany, gdy ktoś wyśle żądanie POST na adres /dodaj-godziny.
@WebServlet("/dodaj-godziny")
public class DodajGodzinyServlet extends HttpServlet {

    // Logger służy do zapisywania ważnych informacji, ostrzeżeń i błędów w logach serwera.
    private static final Logger logger = Logger.getLogger(DodajGodzinyServlet.class.getName());

    // Metoda wywołuje się, kiedy użytkownik (fryzjer) wysyła formularz z godzinami pracy.
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        // Pobieramy dane przesłane przez formularz: datę i przedział godzinowy.
        String data = req.getParameter("data");
        String startGodzina = req.getParameter("start");
        String koniecGodzina = req.getParameter("koniec");

        // Pobieramy aktualnego użytkownika z sesji (musi być zalogowany).
        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        // Jeśli czegokolwiek brakuje (np. użytkownika lub danych z formularza) – wysyłamy błąd do przeglądarki.
        if (data == null || startGodzina == null || koniecGodzina == null || user == null) {
            logger.warning("Brak wymaganych parametrów lub brak użytkownika w sesji.");
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Brak danych wejściowych");
            return;
        }

        // Próbujemy zapisać nowe godziny pracy do bazy danych.
        try (Connection conn = DatabaseConnection.getConnection()) {
            // Przygotowujemy polecenie SQL do dodania godzin pracy fryzjera.
            String sql = "INSERT INTO godziny_pracy (fryzjer_id, data, godzina_start, godzina_koniec) VALUES (?, ?, ?, ?)";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setInt(1, user.getId()); // Identyfikator fryzjera
                stmt.setString(2, data); // Data
                stmt.setString(3, startGodzina); // Godzina rozpoczęcia
                stmt.setString(4, koniecGodzina); // Godzina zakończenia
                stmt.executeUpdate(); // Zapisujemy dane do bazy
            }

            // Po udanym zapisie przekierowujemy fryzjera z powrotem do jego panelu z komunikatem o sukcesie.
            resp.sendRedirect("fryzjer-dashboard.jsp?status=sukces");
        } catch (SQLException e) {
            // Jeśli wystąpi błąd przy zapisie do bazy, zapisujemy go w logach i wysyłamy informację o błędzie.
            logger.log(Level.SEVERE, "Błąd bazy danych", e);
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Błąd bazy danych");
        }
    }
}

/*
    PODSUMOWANIE DZIAŁANIA:

    - Ten plik (serwlet) umożliwia fryzjerowi dodanie własnych godzin pracy do systemu (np. przez formularz w panelu fryzjera).
    - Program pobiera datę oraz godziny rozpoczęcia i zakończenia pracy oraz sprawdza, czy użytkownik (fryzjer) jest zalogowany.
    - Jeśli dane są poprawne, zapisuje nowy przedział godzinowy do bazy danych w tabeli "godziny_pracy".
    - Po udanym zapisie przekierowuje użytkownika do strony "fryzjer-dashboard.jsp" z komunikatem o sukcesie.
    - W przypadku błędów (np. problem z połączeniem z bazą lub brak danych) użytkownik widzi odpowiedni komunikat o błędzie.
    - Dzięki temu serwletowi fryzjer może ustalać, kiedy jest dostępny dla klientów w swoim kalendarzu pracy.
*/
