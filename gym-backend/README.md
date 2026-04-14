# Gym Booking App — Backend

Node.js + Express + MongoDB REST API for the Gym Slot Booking Application.

## Prerequisites
- Node.js >= 18
- MongoDB running locally or a MongoDB Atlas URI

## Setup & Run

```bash
cd gym-backend

# 1. Install dependencies
npm install

# 2. Create your .env file
cp .env.example .env
# Edit .env and set your MONGO_URI and JWT_SECRET

# 3. Run in development mode (with nodemon)
npm run dev

# 4. Run in production
npm start
```

The server starts on `http://localhost:5000` by default.

## Environment Variables

| Variable        | Description                        | Example                                      |
|-----------------|------------------------------------|----------------------------------------------|
| `PORT`          | Port for the server                | `5000`                                       |
| `MONGO_URI`     | MongoDB connection string          | `mongodb://localhost:27017/gym_booking`      |
| `JWT_SECRET`    | Secret key for JWT signing         | `your_super_secret_key`                      |
| `JWT_EXPIRES_IN`| JWT token expiry duration          | `7d`                                         |

## API Endpoints

### Auth
| Method | Endpoint              | Auth     | Description         |
|--------|-----------------------|----------|---------------------|
| POST   | /api/auth/register    | None     | Register new user   |
| POST   | /api/auth/login       | None     | Login               |
| GET    | /api/auth/me          | Bearer   | Get current user    |

### Slots
| Method | Endpoint              | Auth     | Description                        |
|--------|-----------------------|----------|------------------------------------|
| GET    | /api/slots            | None     | Get slots (filter by date/upcoming)|
| GET    | /api/slots/:id        | None     | Get single slot                    |
| POST   | /api/slots            | Admin    | Create slot                        |
| PUT    | /api/slots/:id        | Admin    | Update slot                        |
| DELETE | /api/slots/:id        | Admin    | Delete slot                        |

### Bookings
| Method | Endpoint                   | Auth     | Description                    |
|--------|----------------------------|----------|--------------------------------|
| POST   | /api/bookings              | Member   | Book a slot                    |
| GET    | /api/bookings/my           | Member   | My bookings (upcoming & past)  |
| DELETE | /api/bookings/:id          | Member   | Cancel booking                 |
| PATCH  | /api/bookings/:id/cancel   | Member   | Cancel booking (alias)         |
| GET    | /api/bookings/slot/:slotId | Admin    | Bookings for a specific slot   |

### Admin
| Method | Endpoint         | Auth  | Description            |
|--------|------------------|-------|------------------------|
| GET    | /api/admin/stats | Admin | Stats & analytics      |
| GET    | /api/admin/users | Admin | List all members       |

## Seeding an Admin User

To create an admin, register normally then update via MongoDB:
```js
db.users.updateOne({ email: "admin@gym.com" }, { $set: { role: "admin" } })
```
Or pass `"role": "admin"` in the register body (allowed for initial setup).
