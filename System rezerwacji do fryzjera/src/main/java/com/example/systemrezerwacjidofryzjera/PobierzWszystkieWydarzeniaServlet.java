package com.example.systemrezerwacjidofryzjera;

import com.google.gson.Gson;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.*;

// Serwlet służący do pobierania wszystkich wydarzeń (godzin pracy oraz rezerwacji) do wyświetlenia np. w kalendarzu fryzjera
@WebServlet("/pobierz-wszystkie-wydarzenia")
public class PobierzWszystkieWydarzeniaServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Tworzymy listę, do której będą dodawane wydarzenia (zarówno godziny pracy, jak i rezerwacje)
        List<Map<String, Object>> wydarzenia = new ArrayList<>();

        try (Connection conn = DatabaseConnection.getConnection()) {
            // 1) Pobieramy wszystkie godziny pracy fryzjera
            String sqlGodziny = "SELECT id, data, godzina_start, godzina_koniec FROM godziny_pracy";
            try (PreparedStatement stmt = conn.prepareStatement(sqlGodziny);
                 ResultSet rs = stmt.executeQuery()) {

                while (rs.next()) {
                    int id = rs.getInt("id");
                    LocalDate data = rs.getDate("data").toLocalDate();
                    LocalTime start = rs.getTime("godzina_start").toLocalTime();
                    LocalTime koniec= rs.getTime("godzina_koniec").toLocalTime();

                    // Każdy wpis godzin pracy zapisujemy jako osobne wydarzenie
                    Map<String, Object> godziny = new HashMap<>();
                    godziny.put("id",          id);
                    godziny.put("slot_id",     id);  // (opcjonalnie) unikalny identyfikator slotu
                    godziny.put("title",       "Godziny pracy");
                    godziny.put("start",       data + "T" + start);
                    godziny.put("end",         data + "T" + koniec);
                    godziny.put("description", "Dostępny w salonie");
                    wydarzenia.add(godziny);
                }
            }

            // 2) Pobieramy wszystkie rezerwacje klientów (wraz z imieniem i nazwiskiem klienta)
            String sqlRezerw = ""
                    + "SELECT r.id, r.data_rezerwacji, r.godzina_rezerwacji, u.first_name, u.last_name "
                    + "FROM rezerwacje r "
                    + " JOIN users u ON r.klient_id = u.id";
            try (PreparedStatement stmt = conn.prepareStatement(sqlRezerw);
                 ResultSet rs = stmt.executeQuery()) {

                while (rs.next()) {
                    int rezId = rs.getInt("id");
                    String klient = rs.getString("first_name") + " " + rs.getString("last_name");
                    LocalDate d = rs.getDate("data_rezerwacji").toLocalDate();
                    LocalTime s = rs.getTime("godzina_rezerwacji").toLocalTime();
                    LocalTime e = s.plusHours(1);

                    // Każdą rezerwację zapisujemy jako osobne wydarzenie
                    Map<String, Object> rezerwacja = new HashMap<>();
                    rezerwacja.put("id",          rezId);
                    rezerwacja.put("title",       "Rezerwacja – " + klient);
                    rezerwacja.put("start",       d + "T" + s);
                    rezerwacja.put("end",         d + "T" + e);
                    rezerwacja.put("description", "Zarezerwowane przez " + klient);
                    wydarzenia.add(rezerwacja);
                }
            }

            // 3) Zwracamy listę wszystkich wydarzeń w formacie JSON do przeglądarki (np. do wyświetlenia w kalendarzu)
            resp.setContentType("application/json");
            try (PrintWriter out = resp.getWriter()) {
                out.print(new Gson().toJson(wydarzenia));
            }

        } catch (SQLException e) {
            // Obsługa ewentualnych problemów z bazą danych
            e.printStackTrace();
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Błąd bazy danych: " + e.getMessage());
        }
    }
}

/*
    PODSUMOWANIE DZIAŁANIA:

    - Ten plik służy do pobierania wszystkich wydarzeń do kalendarza fryzjera (zarówno godzin pracy, jak i rezerwacji klientów).
    - Najpierw pobierane są godziny pracy fryzjera – każda jako osobne wydarzenie, z datą i przedziałem godzinowym.
    - Następnie pobierane są rezerwacje wszystkich klientów (każda również jako osobne wydarzenie z informacją o kliencie).
    - Oba typy wydarzeń są łączone w jedną listę i zwracane do przeglądarki w formacie JSON.
    - Dzięki temu na jednym kalendarzu można jednocześnie zobaczyć zarówno godziny pracy fryzjera, jak i wszystkie zaplanowane rezerwacje.
    - Plik nie wymaga podania żadnych danych wejściowych – wystarczy wykonać zapytanie GET pod adres /pobierz-wszystkie-wydarzenia.
*/
