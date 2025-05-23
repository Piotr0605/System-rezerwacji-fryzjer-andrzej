package com.example.systemrezerwacjidofryzjera;

import java.sql.*;

// Klasa do obsługi zapisywania i wyszukiwania użytkowników w bazie danych.
public class UserStorage {

    // Metoda służąca do zapisywania nowego użytkownika do bazy danych.
    public static void saveUserToDatabase(User user) {
        // Przygotowujemy zapytanie SQL dodające użytkownika do tabeli 'users'
        String sql = "INSERT INTO users (first_name, last_name, email, phone, password, role) VALUES (?, ?, ?, ?, ?, ?)";

        // Próbujemy nawiązać połączenie z bazą danych i wykonać zapytanie
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            // Uzupełniamy zapytanie wartościami z obiektu 'user'
            stmt.setString(1, user.getFirstName()); // imię
            stmt.setString(2, user.getLastName());  // nazwisko
            stmt.setString(3, user.getEmail());     // e-mail
            stmt.setString(4, user.getPhone());     // numer telefonu
            stmt.setString(5, user.getPassword());  // hasło
            stmt.setString(6, user.getRole());      // rola ("klient" lub "fryzjer")

            stmt.executeUpdate(); // wykonujemy zapytanie dodające użytkownika do bazy
        } catch (SQLException e) {
            // Jeśli pojawi się błąd podczas operacji na bazie, wypisz go w konsoli
            e.printStackTrace();
        }
    }

    // Metoda do wyszukiwania użytkownika na podstawie adresu e-mail.
    // Zwraca obiekt User jeśli znajdzie, lub null jeśli nie ma takiego użytkownika.
    public static User getUserByEmail(String email) {
        // Przygotowujemy zapytanie SQL szukające użytkownika po e-mailu
        String sql = "SELECT * FROM users WHERE email = ?";

        // Próbujemy nawiązać połączenie i wykonać zapytanie
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, email); // podstawiamy podany e-mail
            ResultSet rs = stmt.executeQuery(); // wykonujemy zapytanie

            // Jeśli znaleziono użytkownika, pobierz jego dane i utwórz nowy obiekt User
            if (rs.next()) {
                int id = rs.getInt("id"); // pobieramy ID z bazy
                String firstName = rs.getString("first_name");
                String lastName = rs.getString("last_name");
                String phone = rs.getString("phone");
                String password = rs.getString("password");
                String role = rs.getString("role");

                // Tworzymy i zwracamy nowy obiekt User z danymi z bazy
                return new User(id, firstName, lastName, password, email, role, phone);
            }
        } catch (SQLException e) {
            // Jeśli coś pójdzie nie tak, wyświetlamy błąd
            e.printStackTrace();
        }

        // Jeśli nie znaleziono użytkownika, zwracamy null
        return null;
    }
}

/*
    PODSUMOWANIE DZIAŁANIA:

    - Ta klasa odpowiada za komunikację z bazą danych w zakresie zapisywania i wyszukiwania użytkowników.
    - saveUserToDatabase(User user):
        Dodaje nowego użytkownika do bazy na podstawie przekazanego obiektu User.
        Zostaje wywołana np. po rejestracji nowego konta.
    - getUserByEmail(String email):
        Pozwala znaleźć użytkownika na podstawie adresu e-mail i zwraca obiekt User z danymi tego użytkownika.
        Jest wykorzystywana m.in. podczas logowania, aby sprawdzić, czy taki użytkownik istnieje i czy hasło się zgadza.
    - Dzięki tej klasie rejestracja i logowanie użytkowników są możliwe w aplikacji.
*/
