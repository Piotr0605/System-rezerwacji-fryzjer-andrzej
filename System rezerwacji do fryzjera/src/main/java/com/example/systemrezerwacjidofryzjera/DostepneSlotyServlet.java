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

// Serwlet udostępniający dostępne sloty (wolne godziny) do rezerwacji na najbliższe 30 dni
@WebServlet("/dostepne-sloty")
public class DostepneSlotyServlet extends HttpServlet {

    // Metoda wywoływana przy każdym zapytaniu GET do tego serwletu (np. przez kalendarz na stronie)
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        // Lista slotów (godzin), które będą zwrócone jako odpowiedź
        List<Map<String, String>> sloty = new ArrayList<>();

        try (Connection conn = DatabaseConnection.getConnection()) {
            // Ustal dzisiejszą datę i datę za 30 dni (zakres przeszukania)
            LocalDate dzis = LocalDate.now();
            LocalDate za30dni = dzis.plusDays(30);

            // Zapytanie wybierające wszystkie godziny pracy w wybranym zakresie dat
            String sql = "SELECT * FROM godziny_pracy WHERE data BETWEEN ? AND ?";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setDate(1, java.sql.Date.valueOf(dzis));
                stmt.setDate(2, java.sql.Date.valueOf(za30dni));

                ResultSet rs = stmt.executeQuery();
                while (rs.next()) {
                    int godzinyPracyId = rs.getInt("id");
                    LocalDate data = rs.getDate("data").toLocalDate();
                    LocalTime start = rs.getTime("godzina_start").toLocalTime();
                    LocalTime koniec = rs.getTime("godzina_koniec").toLocalTime();

                    // Sprawdzenie każdej pełnej godziny w podanym przedziale czasowym
                    for (LocalTime godzina = start; godzina.isBefore(koniec); godzina = godzina.plusHours(1)) {
                        // Jeśli slot NIE jest już zajęty (nie ma rezerwacji), dodajemy go do listy dostępnych slotów
                        if (!czySlotZajety(conn, godzinyPracyId, godzina)) {
                            Map<String, String> slot = new HashMap<>();
                            slot.put("start", data + "T" + godzina);
                            slot.put("end", data + "T" + godzina.plusHours(1));
                            slot.put("slot_id", godzinyPracyId + "-" + godzina); // Np. "15-12:00"
                            sloty.add(slot);

                            // Informacja dla programisty – slot został dodany do listy dostępnych
                            System.out.println("🟢 Slot dodany: " + slot.get("start") + " | ID: " + slot.get("slot_id"));
                        }
                    }
                }
            }

            // Ustawiamy odpowiedni typ odpowiedzi (JSON) i zwracamy wszystkie dostępne sloty do przeglądarki
            resp.setContentType("application/json");
            PrintWriter out = resp.getWriter();
            out.print(new Gson().toJson(sloty));
            out.flush();

        } catch (SQLException e) {
            // Obsługa błędów bazy danych – wypisuje błąd w konsoli i informuje przeglądarkę o błędzie
            e.printStackTrace();
            resp.sendError(500, "Błąd bazy danych: " + e.getMessage());
        }
    }

    // Metoda sprawdzająca, czy slot (czyli konkretna godzina) nie został już zarezerwowany
    private boolean czySlotZajety(Connection conn, int godzinyPracyId, LocalTime godzina) throws SQLException {
        String sql = "SELECT COUNT(*) FROM rezerwacje WHERE godziny_pracy_id = ? AND godzina_rezerwacji = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, godzinyPracyId);
            stmt.setTime(2, Time.valueOf(godzina));
            ResultSet rs = stmt.executeQuery();
            // Jeśli liczba wyników jest większa niż 0, to slot jest już zajęty
            return rs.next() && rs.getInt(1) > 0;
        }
    }
}

/*
    PODSUMOWANIE DZIAŁANIA:

    - Ten plik odpowiada za generowanie i zwracanie listy wszystkich dostępnych do rezerwacji slotów (wolnych godzin) dla klientów.
    - Serwlet pobiera z bazy wszystkie godziny pracy fryzjerów z najbliższych 30 dni, dzieli je na pełne godziny.
    - Każdy slot (czyli konkretna godzina w ramach godzin pracy) jest sprawdzany pod kątem dostępności:
      jeśli nie ma jeszcze rezerwacji w tym czasie, jest dodawany do listy jako wolny termin.
    - Lista slotów jest zamieniana na format JSON i zwracana do przeglądarki (np. do wyświetlenia w kalendarzu na stronie).
    - Dzięki temu użytkownik widzi tylko naprawdę wolne godziny i może je łatwo zarezerwować przez system.
    - W przypadku błędów bazy danych użytkownik otrzyma komunikat o problemie.
*/
