package com.example.systemrezerwacjidofryzjera;

import com.google.gson.Gson;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.*;

// Serwlet obsługujący pobieranie wszystkich rezerwacji zalogowanego użytkownika (klienta)
@WebServlet("/pobierz-rezerwacje")
public class PobierzRezerwacjeServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        // Pobieramy bieżącą sesję użytkownika (czyli sprawdzamy kto jest zalogowany)
        HttpSession session = req.getSession(false);
        User user = (session == null) ? null : (User) session.getAttribute("user");

        // Jeśli użytkownik nie jest zalogowany – od razu kończymy i zwracamy błąd 401
        if (user == null) {
            resp.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Nie jesteś zalogowany.");
            return;
        }

        // Lista, do której zostaną dodane rezerwacje pobrane z bazy danych
        List<Map<String, Object>> rezerwacje = new ArrayList<>();

        try (Connection conn = DatabaseConnection.getConnection()) {
            // Zapytanie SQL: wybierz wszystkie rezerwacje tego użytkownika, wraz z ich ID i godzinami
            String sql =
                    "SELECT r.id, r.data_rezerwacji, r.godzina_rezerwacji " +
                            "FROM rezerwacje r " +
                            "WHERE r.klient_id = (SELECT id FROM users WHERE email = ?)";

            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setString(1, user.getEmail());
                try (ResultSet rs = stmt.executeQuery()) {
                    while (rs.next()) {
                        int reservationId = rs.getInt("id"); // Pobieramy ID rezerwacji
                        LocalDate data = rs.getDate("data_rezerwacji").toLocalDate(); // Data rezerwacji
                        LocalTime start = rs.getTime("godzina_rezerwacji").toLocalTime(); // Godzina rozpoczęcia
                        LocalTime end   = start.plusHours(1); // Założenie: wizyta trwa godzinę

                        // Tworzymy mapę z danymi do zwrócenia (każda rezerwacja jako osobny wpis)
                        Map<String, Object> entry = new HashMap<>();
                        entry.put("id",          reservationId);            // ID rezerwacji
                        entry.put("title",       "Twoja rezerwacja");
                        entry.put("start",       data + "T" + start);      // Data + godzina początkowa
                        entry.put("end",         data + "T" + end);        // Data + godzina końcowa
                        entry.put("description", "Zarezerwowane przez Ciebie");
                        rezerwacje.add(entry);
                    }
                }
            }

            // Ustawiamy typ odpowiedzi jako JSON i przesyłamy dane do przeglądarki
            resp.setContentType("application/json");
            try (PrintWriter out = resp.getWriter()) {
                out.print(new Gson().toJson(rezerwacje));
            }

        } catch (SQLException e) {
            // Obsługa błędu bazy danych – informacja dla programisty oraz klienta
            e.printStackTrace();
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Błąd pobierania rezerwacji: " + e.getMessage());
        }
    }
}

/*
    PODSUMOWANIE DZIAŁANIA:

    - Ten serwlet służy do pobierania listy wszystkich rezerwacji zalogowanego użytkownika.
    - Sprawdza, czy użytkownik jest zalogowany – jeśli nie, zwraca błąd (401 Unauthorized).
    - Pobiera z bazy wszystkie rezerwacje należące do danego klienta (na podstawie e-maila użytkownika).
    - Każda rezerwacja jest opisana przez: ID, datę i godzinę startu oraz końca (przyjęto, że wizyta trwa godzinę).
    - Dane są wysyłane do przeglądarki w formacie JSON (może je odczytać np. JavaScript na stronie).
    - Dzięki temu użytkownik może wyświetlić swoje rezerwacje w panelu klienta lub na liście rezerwacji.
    - W razie błędu bazy danych użytkownik zobaczy informację o problemie.
*/
