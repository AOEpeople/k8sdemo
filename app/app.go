package main

import (
	"html/template"
	"math/rand"
	"net/http"
	"os"
	"time"
)

type (
	// CounterBackend stores and retrieves counter
	CounterBackend interface {
		GetCounter() uint64
		AtomicIncCounter()
	}
)

var (
	health bool = true
	me     int64
)

const tpl = `<!doctype html>
<html>
<head>
    <title>GoCounter!</title>
    <link rel="stylesheet" href="style.css">
</head>

<body>
bla bla bla <br/>
    Me: <strong>{{ .Me }}</strong><br/>
    You are number <strong>{{ .Count }}</strong>
</body>
</html>
`

// IndexController increments and renders the counter
func IndexController(backend CounterBackend) http.HandlerFunc {
	var tplInstance, err = template.New("tpl").Parse(tpl)

	if err != nil {
		panic(err)
	}

	return func(rw http.ResponseWriter, req *http.Request) {
		backend.AtomicIncCounter()

		tplInstance.Execute(
			rw,
			struct {
				Me    int64
				Count uint64
			}{
				Me:    me,
				Count: backend.GetCounter(),
			},
		)
	}
}

func SleepController(rw http.ResponseWriter, req *http.Request) {
	time.Sleep(10 * time.Second)
}

func PanicController(rw http.ResponseWriter, req *http.Request) {
	os.Exit(1)
}

func ScaleController(rw http.ResponseWriter, req *http.Request) {
	health = false
}

func HealthController(rw http.ResponseWriter, req *http.Request) {
	if health {
		rw.Write([]byte("ok"))
	} else {
		rw.WriteHeader(500)
	}
}

func main() {
	var backend CounterBackend = new(MemoryCounter)

	rand.Seed(time.Now().UTC().UnixNano())

	me = rand.Int63()

	http.Handle("/favicon.ico", http.NotFoundHandler())
	http.HandleFunc(
		"/style.css",
		func(rw http.ResponseWriter, req *http.Request) { http.ServeFile(rw, req, "frontend/dist/style.css") },
	)

	http.HandleFunc("/health", HealthController)
	http.HandleFunc("/sleep", SleepController)
	http.HandleFunc("/panic", PanicController)
	http.HandleFunc("/scale", ScaleController)
	http.HandleFunc("/", IndexController(backend))

	http.ListenAndServe(":3333", nil)
}
