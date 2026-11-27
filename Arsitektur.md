# Arsitektur Sistem & Struktur Kode — TrashCycleControl

Dokumen ini menjelaskan desain arsitektur perangkat lunak, organisasi direktori, serta alur *Continuous Integration / Continuous Deployment* (CI/CD) yang diterapkan pada sistem **TrashCycleControl** (Frontend Flutter & Backend Laravel).

---

## 1. Gambaran Arsitektur Sistem (End-to-End)

Sistem dirancang menggunakan arsitektur *Client-Server* berbasis RESTful API dengan pemisahan tanggung jawab (*Separation of Concerns*) yang ketat di kedua sisi agar mudah diuji (*testable*) dan dikembangkan (*scalable*).

```mermaid
graph TD
    subgraph Mobile_Client [Frontend: Flutter Mobile SCADA]
        UI[Presentation Layer<br/>Views, Forms, Adaptive Layout]
        DOM[Domain Layer<br/>Validators, RBAC Rules, Threshold Logic]
        DATA[Data Layer<br/>Repositories, Local Storage, HTTP Interceptor]
        CORE[Core Services<br/>LogService, NotificationService, Network Guard]
        
        UI --> DOM
        UI --> DATA
        DATA --> CORE
    end

    subgraph Backend_Server [Backend: Laravel REST API]
        MW[Middleware<br/>Sanctum Auth & RBAC Role Guard]
        REQ[Form Requests<br/>Input Validation]
        CTRL[API Controllers<br/>Thin Request/Response Handler]
        SRV[Service Layer<br/>Business Logic, Sensor Threshold, Filtering]
        DB[(MySQL Database)]

        MW --> REQ
        REQ --> CTRL
        CTRL --> SRV
        SRV --> DB
    end

    DATA <-->|JSON / HTTPS + Bearer Token| MW