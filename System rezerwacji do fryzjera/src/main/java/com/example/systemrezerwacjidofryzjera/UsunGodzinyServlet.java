package com.example.systemrezerwacjidofryzjera;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.sql.*;

// Serwlet odpowiadający za usuwanie godzin pracy fryzjera z bazy danych
@WebServlet("/usun-godziny")
public class UsunGodzinyServlet extends HttpServlet {
    // Logger do zapisywania informacji diagnostycznych (do konsoli lub pliku logów)
    private static final Logger logger = LoggerFactory.getLogger(UsunGodzinyServlet.class);

    // Główna metoda – wywoływana gdy wysyłany jest POST na adres /usun-godziny
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        // Pobieramy identyfikator slotu godzin pracy z żądania
        String slotId = req.getParameter("slot_id");
        logger.debug("Otrzymane slot_id = '{}'", slotId);

        // Sprawdzamy, czy podano slot_id
        if (slotId == null || slotId.isEmpty()) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Brak slot_id");
            return;
        }

        int id;
        try {
            // Jeśli slot_id zawiera "-", bierzemy tylko pierwszą część (ID liczbowy)
            String raw = slotId.contains("-") ? slotId.split("-",2)[0].trim() : slotId.trim();
            id = Integer.parseInt(raw);
            logger.debug("Parsuję ID = {}", id);
        } catch (NumberFormatException e) {
            // Jeśli nie udało się sparsować ID (np. ktoś podał tekst zamiast liczby)
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Nieprawidłowy format ID");
            return;
        }

        // Próba połączenia z bazą i usunięcia rekordu
        try (Connection conn = DatabaseConnection.getConnection()) {
            // Najpierw sprawdzamy, czy dla tego slotu nie istnieją już rezerwacje
            String checkSql = "SELECT COUNT(*) FROM rezerwacje WHERE godziny_pracy_id = ?";
            try (PreparedStatement checkStmt = conn.prepareStatement(checkSql)) {
                checkStmt.setInt(1, id);
                ResultSet rs = checkStmt.executeQuery();
                if (rs.next() && rs.getInt(1) > 0) {
                    // Jeśli są rezerwacje, nie można usunąć tej godziny pracy
                    resp.sendError(HttpServletResponse.SC_CONFLICT,
                            "Nie można usunąć: są istniejące rezerwacje.");
                    return;
                }
            }

            // Jeśli nie ma powiązanych rezerwacji, kasujemy godzinę pracy z bazy
            String deleteSql = "DELETE FROM godziny_pracy WHERE id = ?";
            try (PreparedStatement deleteStmt = conn.prepareStatement(deleteSql)) {
                deleteStmt.setInt(1, id);
                int count = deleteStmt.executeUpdate();
                if (count > 0) {
                    resp.setStatus(HttpServletResponse.SC_OK); // Usunięto poprawnie
                    logger.info("Usunięto godzinę pracy o ID={}", id);
                } else {
                    // Nie znaleziono rekordu do usunięcia
                    resp.sendError(HttpServletResponse.SC_NOT_FOUND,
                            "Nie znaleziono godziny pracy o ID=" + id);
                }
            }
        } catch (SQLException e) {
            // W przypadku błędów bazy danych zwracamy błąd i logujemy szczegóły
            logger.error("Błąd bazy przy usuwaniu ID=" + id, e);
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Błąd bazy (zajrzyj do logów).");
        }
    }
}

/*
    PODSUMOWANIE DZIAŁANIA:

    - Ten serwlet umożliwia usuwanie godzin pracy fryzjera z bazy danych na podstawie przekazanego slot_id.
    - Najpierw sprawdzane jest, czy dla wybranego slotu istnieją już rezerwacje – jeśli tak, usuwanie jest zablokowane (chroni to przed przypadkowym usunięciem terminu, na który zapisany jest klient).
    - Jeśli nie ma powiązanych rezerwacji, wpis w tabeli godzin pracy jest usuwany z bazy.
    - Jeśli operacja się powiedzie, zwracany jest status 200 (OK); jeśli godzina nie istnieje – status 404; jeśli są powiązane rezerwacje – status 409 (CONFLICT).
    - Serwlet obsługuje błędy: jeśli np. slot_id jest pusty lub niepoprawny, zgłaszany jest błąd; w przypadku błędów bazy danych także zwracany jest odpowiedni kod błędu.
    - Plik używany głównie z panelu fryzjera, gdzie można zarządzać (usuwać) swoimi godzinami pracy.
*/
