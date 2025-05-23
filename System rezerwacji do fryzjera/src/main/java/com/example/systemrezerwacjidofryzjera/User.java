package com.example.systemrezerwacjidofryzjera;

// Klasa reprezentująca użytkownika systemu (np. klienta lub fryzjera)
public class User {
    // Pola przechowujące dane użytkownika
    private int id;              // unikalny numer użytkownika (przydzielany przez bazę danych)
    private String firstName;    // imię
    private String lastName;     // nazwisko
    private String password;     // hasło (tekstowo, bez szyfrowania - to nie jest zalecane w prawdziwych aplikacjach!)
    private String email;        // adres e-mail (unikalny identyfikator użytkownika)
    private String role;         // rola użytkownika w systemie (np. "klient", "fryzjer")
    private String phone;        // numer telefonu

    // Konstruktor pełny: wykorzystywany, gdy znamy ID użytkownika (np. podczas pobierania z bazy)
    public User(int id, String firstName, String lastName, String password, String email, String role, String phone) {
        this.id = id;
        this.firstName = firstName;
        this.lastName = lastName;
        this.password = password;
        this.email = email;
        this.role = role;
        this.phone = phone;
    }

    // Konstruktor bez ID: wykorzystywany np. podczas rejestracji nowego użytkownika (ID zostanie nadane automatycznie w bazie)
    public User(String firstName, String lastName, String password, String email, String role, String phone) {
        this.firstName = firstName;
        this.lastName = lastName;
        this.password = password;
        this.email = email;
        this.role = role;
        this.phone = phone;
    }

    // Gettery (metody do pobierania wartości pól obiektu)
    public int getId() { return id; }
    public String getFirstName() { return firstName; }
    public String getLastName() { return lastName; }
    public String getPassword() { return password; }
    public String getEmail() { return email; }
    public String getRole() { return role; }
    public String getPhone() { return phone; }
}

/*
    PODSUMOWANIE DZIAŁANIA:

    - Ta klasa opisuje pojedynczego użytkownika systemu rezerwacji.
    - Przechowuje dane osobowe, hasło, e-mail, rolę (np. klient/fryzjer) i numer telefonu użytkownika.
    - Pozwala tworzyć nowe obiekty użytkownika oraz pobierać ich dane przez tzw. gettery.
    - Używana jest w całym systemie tam, gdzie potrzebujemy przekazać lub pobrać informacje o użytkowniku, np. podczas logowania, rejestracji lub wyświetlania danych w panelu użytkownika.
    - Jeśli korzystasz z tej klasy – operujesz na jednym użytkowniku i jego danych.
*/
