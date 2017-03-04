package main

import (
	"html/template"
	"net/http"
)

type (
	// CounterBackend stores and retrieves counter
	CounterBackend interface {
		GetCounter() uint64
		AtomicIncCounter()
	}
)

const tpl = `<!doctype html>
<html>
<head>
    <title>GoCounter!</title>
    <link rel="stylesheet" href="style.css">
</head>

<body>
    You are number <strong>{{.}}</strong>
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

		tplInstance.Execute(rw, backend.GetCounter())
	}
}

func main() {
	var backend CounterBackend = new(MemoryCounter)

	http.Handle("/favicon.ico", http.NotFoundHandler())
	http.HandleFunc(
		"/style.css",
		func(rw http.ResponseWriter, req *http.Request) { http.ServeFile(rw, req, "frontend/dist/style.css") },
	)
	http.HandleFunc("/", IndexController(backend))

	http.ListenAndServe(":3333", nil)
}
