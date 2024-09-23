# Vapor Demo

# Environment

- Xcode 16.0
- Vapor 4.99.3

# Getting Started

## 1. Starting the API Server

### Using Xcode

1. Open `Package.swift`
2. Run the project in Xcode to launch the API server

### Using Docker

1. Ensure a container runtime is running (e.g., Docker Desktop, Lima, OrbStack, etc.)
1. Start the `app` service

```sh
$ docker compose up app --build
```

## (Optional) 2. Starting the Database Server

Some APIs interact with a database. If you plan to use these APIs, please start the database server before launching the API server.

1. Rename the `.env.example` file to `.env` by removing `.example`
2. Ensure a container runtime is running (e.g., Docker Desktop, Lima, OrbStack, etc.)
3. Start the `db` service

```sh
$ docker compose up db --build
```

4. Start the API server

## 3. Send a Request to the API Server

To verify the server is running correctly, you can send a request to http://127.0.0.1:8080 using `curl`. If you receive the response `It works!`, the setup is successful (you can also check this by opening http://127.0.0.1:8080 in your browser).

```sh
$ curl -v http://127.0.0.1:8080
*   Trying 127.0.0.1:8080...
* Connected to 127.0.0.1 (127.0.0.1) port 8080
> GET / HTTP/1.1
> Host: 127.0.0.1:8080
> User-Agent: curl/8.6.0
> Accept: */*
>
< HTTP/1.1 200 OK
< content-type: text/plain; charset=utf-8
< content-length: 9
< connection: keep-alive
< date: Mon, 23 Sep 2024 21:57:05 GMT
<
* Connection #0 to host 127.0.0.1 left intact
It works!%
```
