package main

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"strconv"
	"strings"

	_ "github.com/microsoft/go-mssqldb"
)

type Customer struct {
	ID        int    `json:"id"`
	FirstName string `json:"first_name"`
	LastName  string `json:"last_name"`
	Email     string `json:"email"`
	Phone     string `json:"phone"`
	City      string `json:"city"`
}

var db *sql.DB

func main() {
	connString := fmt.Sprintf("server=%s;user id=%s;password=%s;database=%s",
		os.Getenv("DB_HOST"), os.Getenv("DB_USERNAME"), os.Getenv("DB_PASSWORD"), os.Getenv("DB_DATABASE"))

	var err error
	db, err = sql.Open("sqlserver", connString)
	if err != nil {
		log.Fatal(err)
	}
	defer db.Close()

	http.HandleFunc("/customers", customersHandler)
	http.HandleFunc("/customers/", customerHandler)

	log.Println("listening on :8080")
	log.Fatal(http.ListenAndServe(":8080", nil))
}

func customersHandler(w http.ResponseWriter, r *http.Request) {
	switch r.Method {
	case http.MethodGet:
		rows, err := db.Query("SELECT id, first_name, last_name, email, phone, city FROM customer ORDER BY id")
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
		defer rows.Close()

		customers := []Customer{}
		for rows.Next() {
			var c Customer
			var phone, city sql.NullString
			if err := rows.Scan(&c.ID, &c.FirstName, &c.LastName, &c.Email, &phone, &city); err != nil {
				http.Error(w, err.Error(), http.StatusInternalServerError)
				return
			}
			c.Phone, c.City = phone.String, city.String
			customers = append(customers, c)
		}
		writeJSON(w, http.StatusOK, customers)

	case http.MethodPost:
		var c Customer
		if err := json.NewDecoder(r.Body).Decode(&c); err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}
		err := db.QueryRow(
			"INSERT INTO customer (first_name, last_name, email, phone, city) OUTPUT INSERTED.id VALUES (@p1, @p2, @p3, @p4, @p5)",
			c.FirstName, c.LastName, c.Email, c.Phone, c.City,
		).Scan(&c.ID)
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
		writeJSON(w, http.StatusCreated, c)

	default:
		w.WriteHeader(http.StatusMethodNotAllowed)
	}
}

func customerHandler(w http.ResponseWriter, r *http.Request) {
	id, err := strconv.Atoi(strings.TrimPrefix(r.URL.Path, "/customers/"))
	if err != nil {
		http.Error(w, "invalid id", http.StatusBadRequest)
		return
	}

	switch r.Method {
	case http.MethodGet:
		var c Customer
		var phone, city sql.NullString
		err := db.QueryRow("SELECT id, first_name, last_name, email, phone, city FROM customer WHERE id = @p1", id).
			Scan(&c.ID, &c.FirstName, &c.LastName, &c.Email, &phone, &city)
		if err == sql.ErrNoRows {
			http.Error(w, "not found", http.StatusNotFound)
			return
		} else if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
		c.Phone, c.City = phone.String, city.String
		writeJSON(w, http.StatusOK, c)

	case http.MethodDelete:
		if _, err := db.Exec("DELETE FROM customer WHERE id = @p1", id); err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
		w.WriteHeader(http.StatusNoContent)

	default:
		w.WriteHeader(http.StatusMethodNotAllowed)
	}
}

func writeJSON(w http.ResponseWriter, status int, v any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	json.NewEncoder(w).Encode(v)
}
