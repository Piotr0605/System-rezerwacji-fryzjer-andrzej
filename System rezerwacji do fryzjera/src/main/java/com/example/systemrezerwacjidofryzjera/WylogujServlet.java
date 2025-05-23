package com.example.systemrezerwacjidofryzjera;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

// Serwlet odpowiedzialny za wylogowanie użytkownika z systemu.
// Gdy użytkownik wchodzi na adres /wyloguj, zostaje wylogowany i przekierowany do strony logowania (index.jsp)
@WebServlet("/wyloguj")
public class WylogujServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        // Pobieramy bieżącą sesję (informacje o zalogowanym użytkowniku).
        // Jeśli sesja istnieje, kasujemy ją, co powoduje wylogowanie użytkownika.
        HttpSession session = req.getSession(false);
        if (session != null) {
            session.invalidate(); // 🔥 Usuwamy sesję
        }

        // Ustawiamy nagłówki odpowiedzi, które blokują cache,
        // aby po wylogowaniu nie można było wrócić do poprzednich stron za pomocą przycisku "wstecz" w przeglądarce.
        resp.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        resp.setHeader("Pragma", "no-cache");
        resp.setDateHeader("Expires", 0);

        // Przekierowujemy użytkownika na stronę logowania.
        resp.sendRedirect("index.jsp");
    }
}

/*
    PODSUMOWANIE DZIAŁANIA:

    - Ten serwlet obsługuje proces wylogowania.
    - Po wejściu na adres /wyloguj bieżąca sesja użytkownika jest usuwana (invalidate).
    - Dodatkowo ustawiane są nagłówki blokujące zapamiętywanie strony w pamięci podręcznej przeglądarki.
      Dzięki temu po wylogowaniu użytkownik nie może wrócić do zabezpieczonych stron poprzez cofanie w przeglądarce.
    - Po skutecznym wylogowaniu użytkownik jest przekierowywany na stronę logowania (index.jsp).
    - Kod ten zapewnia bezpieczeństwo i poprawną obsługę procesu wylogowania w aplikacji webowej.
*/
