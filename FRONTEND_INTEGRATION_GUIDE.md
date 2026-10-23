# NextNa Frontend Integration Guide

This guide contains everything you need to build the NextNa frontend (Flutter / Flutter Web).

---

## 1. Backend Environments

- **Live Cloud URL (Render):** `https://nextna-backend.onrender.com`
- **Local Development URL:** `http://localhost:8080`
- **Interactive Swagger Documentation:** [https://nextna-backend.onrender.com/swagger-ui.html](https://nextna-backend.onrender.com/swagger-ui.html)
- **OpenAPI 3.1 JSON Specification:** `https://nextna-backend.onrender.com/v3/api-docs`
- **Postman Collection:** `NextNa_Postman_Collection.json` in the root of the repository.

CORS is globally enabled for all origins (`*`) and all HTTP methods (`GET`, `POST`, `PUT`, `PATCH`, `DELETE`, `OPTIONS`).

---

## 2. The 3 Core Screens to Build

```
                             +----------------------------------------+
                             |       Live Spring Boot Backend         |
                             |  https://nextna-backend.onrender.com   |
                             +-------------------+--------------------+
                                                 |
         +---------------------------------------+---------------------------------------+
         |                                       |                                       |
         v                                       v                                       v
+-------------------------------+ +-------------------------------+ +-------------------------------+
|   1. Customer Virtual Buzzer  | |  2. Merchant Counter View     | |   3. Store Display Board      |
|    URL: /buzzer/:ticketId     | |    URL: /counter              | |    URL: /display              |
|                               | |                               | |                               |
| - Mobile web responsive       | | - Tablet / Desktop cashier    | | - TV / Tablet wall screen     |
| - Real-time SSE updates       | | - Queue control (Call, Serve) | | - Now Serving big display     |
| - Blue / Amber / Green state  | | - "Papunta Na" status badges  | | - Almost Next callout         |
| - Phone vibration on alert    | | - Gemini AI wait advisor      | | - Real-time SSE refresh       |
| - "Papunta Na Ako" button     | | - Daily financial analytics   | |                               |
+-------------------------------+ +-------------------------------+ +-------------------------------+
```

---

## 3. Screen 1: Customer Virtual Buzzer (`/buzzer/:ticketId`)

This is the primary user-facing feature. When a customer joins the queue or scans a receipt QR code, their phone opens `https://<frontend-url>/buzzer/<ticketId>`.

### Buzzer State Machine

The circular buzzer UI changes color and behavior according to the `status` field:

| State | Color Theme | Screen Details | User Action / Trigger |
|---|---|---|---|
| `IN_LINE` | 🔵 Cool Blue | Shows queue number, customer name, number of people ahead, and estimated wait minutes. | Idle waiting screen. |
| `ALMOST_NEXT` | 🟠 Amber (pulsing animation) | Trigger phone vibration (`HapticFeedback.heavyImpact()` or Web Vibration API). Shows: *"Almost your turn! Please start heading back to the shop."* | Prompts customer to tap **"Papunta Na Ako"**. |
| `NOW_SERVING` | 🟢 Vibrant Green | Ring animation and sound. Shows: *"Your turn now! Please proceed to the service counter."* | Customer enters the store. |
| `COMPLETED` | ⚪ Neutral / Grey | Shows: *"Service completed. Thank you for visiting!"* | Stream closes. |
| `CANCELLED` | 🔴 Dark Red / Grey | Shows: *"This ticket has been cancelled."* | Stream closes. |

### "Papunta Na Ako" (I am on my way) Button
- Available when state is `IN_LINE` or `ALMOST_NEXT`.
- When clicked:
  - Call: `PATCH /api/v1/queue/tickets/{ticketId}/on-my-way`
  - Button switches to disabled state: `✓ Shop notified: You are on your way!`
  - This immediately displays a green indicator on the merchant's screen so the customer is not skipped.

### Real-Time SSE Stream for Virtual Buzzer
- **Endpoint:** `GET /api/v1/notifications/buzzer/{ticketId}/stream`
- **Header:** `Accept: text/event-stream`
- **Events Pushed:**
  - `buzzer-status`: Initial buzzer snapshot on connect.
  - `buzzer-almost-next`: Pushed when 1 customer ahead.
  - `buzzer-now-serving`: Pushed when called.
  - `buzzer-on-my-way-ack`: Pushed when "Papunta Na Ako" is confirmed.
  - `buzzer-position-update`: Pushed when people ahead in queue changes.
  - `buzzer-completed`: Pushed when service ends.
  - `buzzer-cancelled`: Pushed if ticket is cancelled.

#### Buzzer Payload Schema
```json
{
  "ticketId": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "ticketNumber": 5,
  "customerName": "Juan Dela Cruz",
  "status": "ALMOST_NEXT",
  "peopleAhead": 1,
  "estimatedWaitMinutes": 10,
  "onMyWayConfirmed": false,
  "alertMessage": "Almost your turn! Please start heading back to the shop.",
  "timestamp": "2026-10-23T02:15:00Z"
}
```

---

## 4. Screen 2: Merchant Counter Dashboard (`/counter`)

This screen is used by the cashier or shop owner on a tablet or desktop.

### Key Capabilities:
1. **Queue Summary Bar:**
   - Active Customers, Waiting Count, Serving Count (from `GET /api/v1/queue/summary`).
2. **"Call Next" Action:**
   - Big prominent button: calls `POST /api/v1/queue/tickets/call-next`.
3. **Queue List:**
   - Table or cards showing active tickets ordered by number:
     - Ticket Number (e.g., `#5`)
     - Customer Name
     - State badge (`WAITING`, `ALMOST_NEXT`, `NOW_SERVING`)
     - **"Papunta Na Ako" Indicator:** If `onMyWayConfirmed == true`, show a glowing green badge: `🚶 Papunta Na`.
     - Action buttons:
       - `Call`: `PATCH /api/v1/queue/tickets/{id}/call`
       - `Serve`: `PATCH /api/v1/queue/tickets/{id}/serve`
       - `Complete`: `PATCH /api/v1/queue/tickets/{id}/complete`
       - `Cancel`: `PATCH /api/v1/queue/tickets/{id}/cancel`
       - `Override Wait`: `PATCH /api/v1/queue/tickets/{id}/override-wait` with `{"estimatedWaitMinutes": 15}`
4. **Issue Walk-In Ticket Modal:**
   - Fetch active services: `GET /api/v1/services?activeOnly=true`.
   - Form inputs: Customer Name, Service dropdown, optional manual wait override.
   - Submit: `POST /api/v1/queue/tickets`.
5. **AI Wait Time Predictor Widget:**
   - Call: `GET /api/v1/analytics/ai-prediction?serviceId={serviceId}&dayOfWeek={1-7}&hourOfDay={0-23}`.
   - Displays predicted wait minutes, AI confidence score, and advisory notes from Gemini AI.
6. **Financial Overview Card:**
   - Call: `GET /api/v1/analytics/overview`.
   - Shows today's completed services count, total revenue in PHP (₱), and average service duration.

---

## 5. Screen 3: Store Display Board (`/display`)

Designed for an overhead TV or tablet mounted near the waiting area.

### Real-Time SSE Stream for Display Board
- **Endpoint:** `GET /api/v1/notifications/display/stream`
- **Header:** `Accept: text/event-stream`
- **Events Pushed:**
  - `display-refresh`: Initial snapshot on connection.
  - `display-update`: Pushed whenever any ticket state changes.

#### Display Board Payload Schema
```json
{
  "eventType": "TICKET_CALLED",
  "currentServingNumber": 5,
  "currentServingCustomer": "Juan Dela Cruz",
  "almostNextNumber": 6,
  "almostNextCustomer": "Maria Clara",
  "totalWaitingCount": 3,
  "waitingNumbers": [7, 8, 9],
  "alertMessage": "Calling ticket #5 - Juan Dela Cruz",
  "timestamp": "2026-10-23T02:15:00Z"
}
```

### Display Layout Recommendation:
- **Left Column (60% width):** Giant card for **NOW SERVING**:
  - Number `#5` in huge green font.
  - Customer name below the number.
- **Right Column (40% width):**
  - Top Card: **ALMOST NEXT** `#6` in amber font.
  - Bottom Card: **IN LINE**: badges showing waiting numbers `[#7, #8, #9]`.

---

## 6. Complete API Reference

### 6.1 Service Catalog (`/api/v1/services`)

| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/api/v1/services?activeOnly=true` | List all active services |
| `GET` | `/api/v1/services/{id}` | Get service by ID |
| `POST` | `/api/v1/services` | Create new service |
| `PUT` | `/api/v1/services/{id}` | Update service details |
| `DELETE` | `/api/v1/services/{id}` | Deactivate service |
| `PATCH` | `/api/v1/services/{id}/activate` | Reactivate service |

#### Create Service Request Body:
```json
{
  "name": "Standard Haircut & Wash",
  "category": "BARBERSHOP",
  "unitPrice": 200.00,
  "baselineDurationMinutes": 20
}
```

---

### 6.2 Queue Operations (`/api/v1/queue`)

| Method | Endpoint | Description |
|---|---|---|
| `POST` | `/api/v1/queue/tickets` | Issue ticket (walk-in or online) |
| `GET` | `/api/v1/queue/tickets` | Get all active tickets |
| `GET` | `/api/v1/queue/tickets/{id}` | Get ticket by ID |
| `GET` | `/api/v1/queue/summary` | Get queue metrics summary |
| `POST` | `/api/v1/queue/tickets/call-next` | Call next waiting customer |
| `PATCH` | `/api/v1/queue/tickets/{id}/call` | Call specific ticket |
| `PATCH` | `/api/v1/queue/tickets/{id}/serve` | Start service on ticket |
| `PATCH` | `/api/v1/queue/tickets/{id}/complete` | Complete ticket |
| `PATCH` | `/api/v1/queue/tickets/{id}/cancel` | Cancel ticket |
| `PATCH` | `/api/v1/queue/tickets/{id}/on-my-way` | Customer confirms "Papunta Na Ako" |
| `PATCH` | `/api/v1/queue/tickets/{id}/override-wait` | Override wait time |

#### Issue Ticket Request Body:
```json
{
  "customerName": "Juan Dela Cruz",
  "serviceId": "srv-001",
  "manualWaitMinutesOverride": null
}
```

#### Queue Summary Response:
```json
{
  "totalActive": 3,
  "waitingCount": 2,
  "servingCount": 1,
  "currentlyServing": {
    "ticketId": "...",
    "ticketNumber": 4,
    "customerName": "Pedro Penduko",
    "state": "NOW_SERVING"
  },
  "activeTickets": [...]
}
```

---

### 6.3 Analytics & AI Advisor (`/api/v1/analytics`)

| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/api/v1/analytics/overview` | Dashboard overview with daily revenue and KPIs |
| `GET` | `/api/v1/analytics/financial-summary?from=2026-10-01&to=2026-10-31` | Daily financial reports |
| `GET` | `/api/v1/analytics/predictive-stats/{serviceId}` | Historical service duration telemetry |
| `GET` | `/api/v1/analytics/ai-prediction?serviceId={id}&dayOfWeek={1-7}&hourOfDay={0-23}` | Gemini AI wait time prediction |

---

### 6.4 Real-Time Notifications & SSE (`/api/v1/notifications`)

| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/api/v1/notifications/buzzer/{ticketId}/stream` | Virtual buzzer SSE stream |
| `GET` | `/api/v1/notifications/display/stream` | Store display board SSE stream |
| `GET` | `/api/v1/notifications/status` | Active stream connection counts |

---

## 7. Recommended Flutter Packages

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.2.2
  fetch_client: ^1.4.1
  flutter_riverpod: ^2.6.1
  vibration: ^2.0.1
  audioplayers: ^6.1.0
  intl: ^0.19.0
  google_fonts: ^6.2.1
```

---

## 8. Quick Web Vibration Fallback (JavaScript Interop)

For Flutter Web running in a mobile browser, phone vibration can be triggered with:

```dart
import 'dart:js_interop';

@JS('navigator.vibrate')
external bool _vibrate(JSArray<JSNumber> pattern);

void triggerBuzzerVibration() {
  try {
    final pattern = [200.toJS, 100.toJS, 200.toJS].toJS;
    _vibrate(pattern);
  } catch (_) {}
}
```
