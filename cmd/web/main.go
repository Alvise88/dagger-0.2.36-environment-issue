package main

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"os"

	"github.com/alexedwards/flow"
)

type Envelope map[string]any

func Write(w http.ResponseWriter, status int, data Envelope, headers http.Header) error {
	js, err := json.MarshalIndent(data, "", "\t")
	if err != nil {
		return err
	}

	js = append(js, '\n')

	for key, value := range headers {
		w.Header()[key] = value
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)

	_, err = w.Write(js)

	if err != nil {
		return fmt.Errorf("unable to convert to json: %w", err)
	}

	return nil
}

type Greet struct {
	Content string
}

func Greeting(ctx context.Context) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		// Use flow.Param() to retrieve the value of the named parameter from the
		// request context.
		// name := flow.Param(r.Context(), "name")

		name, found := os.LookupEnv("GREETING_NAME")

		if !found {
			name = "Alonzo Church"
		}

		greet := Greet{
			Content: fmt.Sprintf("Hello: %s", name),
		}

		w.Header().Set("Content-Type", "application/json")

		err := Write(w, http.StatusOK, Envelope{"greet": greet}, nil)

		if err != nil {
			http.Error(w, "The server encountered a problem and could not process your request", http.StatusInternalServerError)
		}
	}
}

func Routes(ctx context.Context) *flow.Mux {
	// Initialize a new router.
	mux := flow.New()

	// pipelines
	mux.HandleFunc("/greet/:name", Greeting(ctx), http.MethodGet)

	return mux
}

func main() {
	ctx := context.Background()

	port := "2323"

	err := http.ListenAndServe(fmt.Sprintf(":%s", port), Routes(ctx))

	if err != nil {
		fmt.Println("unable to run argoci cli")
	}
}
