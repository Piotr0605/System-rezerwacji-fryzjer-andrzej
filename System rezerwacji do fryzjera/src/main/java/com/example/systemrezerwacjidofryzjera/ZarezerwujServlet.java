package com.example.systemrezerwacjidofryzjera;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.*;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.logging.*;

// Serwlet odpowiedzialny za dodawanie nowej rezerwacji przez klienta (np. po kliknięciu w wolny termin w kalendarzu)
@WebServlet("/zarezerwuj")
public class ZarezerwujServlet extends HttpServlet {

    // Logger do zapisywania ważnych informacji i ewentualnych błędów
    private static final Logger logger = Logger.getLogger(ZarezerwujServlet.class.getName());

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        // 1. Pobieranie użytkownika z aktualnej sesji (czyli kto jest zalogowany)
        HttpSession session = req.getSession(false);
        User user = session == null ? null : (User) session.getAttribute("user");

        // 2. Pobieranie slotu do rezerwacji, np. "15-12:00"
        String slotIdParam = req.getParameter("slot_id");
        logger.info("🔄 Otrzymano slot_idParam: [" + slotIdParam + "]");

        // 3. Sprawdzenie uprawnień i poprawności slotu
        if (user == null) {
            resp.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Nie jesteś zalogowany.");
            return;
        }
        if (slotIdParam == null || !slotIdParam.contains("-")) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Nieprawidłowy identyfikator slotu.");
            return;
        }

        // 4. Rozdzielamy slot_id na ID i godzinę (np. "15-12:00" → id=15, godzina=12:00)
        String[] parts = slotIdParam.split("-", 2);
        String idPart = parts[0].trim();
        String timePart = parts[1].trim();
        int godzinyPracyId;
        LocalTime godzina;
        try {
            godzinyPracyId = Integer.parseInt(idPart);
            godzina = LocalTime.parse(timePart);
        } catch (Exception e) {
            logger.warning("❌ Błąd parsowania slot_id: idPart=[" + idPart + "], timePart=[" + timePart + "]");
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Nieprawidłowy format slot_id.");
            return;
        }

        logger.info("🧪 Parsowanie OK: godzinyPracyId=" + godzinyPracyId + ", godzina=" + godzina);

        try (Connection conn = DatabaseConnection.getConnection()) {
            // 5. Sprawdzenie, czy wybrany termin nie jest już zajęty
            if (czySlotZajety(conn, godzinyPracyId, godzina)) {
                resp.sendError(HttpServletResponse.SC_CONFLICT, "Ten termin jest już zajęty.");
                return;
            }

            // 6. Pobranie daty z tabeli godziny_pracy (sprawdzamy, na jaki dzień przypada ten slot)
            LocalDate dataRezerwacji = null;
            String sqlData = "SELECT data FROM godziny_pracy WHERE id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(sqlData)) {
                stmt.setInt(1, godzinyPracyId);
                ResultSet rs = stmt.executeQuery();
                if (rs.next()) {
                    dataRezerwacji = rs.getDate("data").toLocalDate();
                } else {
                    resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Nie znaleziono dnia pracy.");
                    return;
                }
            }

            // 7. Wstawienie nowej rezerwacji do bazy danych (wraz z godziną i datą)
            String sql = "INSERT INTO rezerwacje (klient_id, godziny_pracy_id, godzina_rezerwacji, data_rezerwacji) VALUES (?, ?, ?, ?)";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setInt(1, getUserIdByEmail(conn, user.getEmail()));
                stmt.setInt(2, godzinyPracyId);
                stmt.setTime(3, Time.valueOf(godzina));
                stmt.setDate(4, Date.valueOf(dataRezerwacji));
                stmt.executeUpdate();
            }

            logger.info("✅ Zarezerwowano slot " + slotIdParam + " dla " + user.getEmail());
            resp.setStatus(HttpServletResponse.SC_OK);

        } catch (SQLException e) {
            logger.log(Level.SEVERE, "❌ Błąd bazy przy rezerwacji", e);
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Błąd rezerwacji: " + e.getMessage());
        }
    }

    // Pomocnicza metoda sprawdzająca, czy slot jest już zajęty (czy ktoś już go zarezerwował)
    private boolean czySlotZajety(Connection conn, int godzinyPracyId, LocalTime godzina) throws SQLException {
        String sql = "SELECT COUNT(*) FROM rezerwacje WHERE godziny_pracy_id = ? AND godzina_rezerwacji = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, godzinyPracyId);
            stmt.setTime(2, Time.valueOf(godzina));
            ResultSet rs = stmt.executeQuery();
            rs.next();
            return rs.getInt(1) > 0;
        }
    }

    // Pomocnicza metoda pobierająca ID użytkownika na podstawie jego e-maila
    private int getUserIdByEmail(Connection conn, String email) throws SQLException {
        String sql = "SELECT id FROM users WHERE email = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, email);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) return rs.getInt("id");
        }
        throw new SQLException("Użytkownik nie istnieje: " + email);
    }
}

/*
    PODSUMOWANIE DZIAŁANIA:

    - Serwlet przyjmuje żądanie POST na adres /zarezerwuj (np. gdy klient wybiera godzinę w kalendarzu i potwierdza rezerwację).
    - Sprawdza, czy użytkownik jest zalogowany i czy podano prawidłowy slot (np. "15-12:00").
    - Rozdziela slot na ID i godzinę.
    - Weryfikuje, czy slot jest dostępny (czy ktoś już nie zarezerwował tej godziny pracy fryzjera).
    - Jeśli slot jest wolny, pobiera datę pracy fryzjera i zapisuje nową rezerwację do bazy (z datą i godziną).
    - W przypadku błędów lub zajętego terminu wyświetla odpowiedni kod błędu i wiadomość.
    - Służy do obsługi rezerwacji terminów wizyty w aplikacji salonu fryzjerskiego.
*/
