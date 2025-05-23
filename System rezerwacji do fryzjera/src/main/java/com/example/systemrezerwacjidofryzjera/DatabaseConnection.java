package com.example.systemrezerwacjidofryzjera;

// Importujemy klasy potrzebne do pracy z bazą SQL (połączenie, wyjątki)
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

// Ta klasa pozwala nam połączyć się z bazą danych MariaDB (lub MySQL)
public class DatabaseConnection {

    // Adres bazy danych (URL), użytkownik i hasło
    private static final String URL = "jdbc:mariadb://localhost:3306/fryzjer";
    private static final String USER = "root";
    private static final String PASSWORD = "root";

    // Ta metoda tworzy nowe połączenie z bazą danych i je zwraca.
    // Jeśli coś pójdzie nie tak, rzuca wyjątek SQLException.
    public static Connection getConnection() throws SQLException {
        try {
            // Rejestrujemy sterownik bazy danych, żeby Java wiedziała jak rozmawiać z MariaDB
            Class.forName("org.mariadb.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            // Jeśli sterownik nie został znaleziony, zgłaszamy błąd
            throw new SQLException("❌ Sterownik MariaDB nie został znaleziony w classpath!", e);
        }

        // Informacja pomocnicza w konsoli – pokazuje próbę połączenia
        System.out.println("✅ Próba połączenia z bazą danych...");
        // Nawiązujemy i zwracamy połączenie z bazą
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }
}

/*
    PODSUMOWANIE:

    - Ta klasa odpowiada wyłącznie za łączenie się z bazą danych "fryzjer" na serwerze lokalnym.
    - Metoda getConnection() za każdym razem zwraca nowe połączenie do bazy danych, gotowe do użycia.
    - Połączenie nawiązywane jest na podstaw
