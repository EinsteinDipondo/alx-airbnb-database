# 🏠 Airbnb SQL Database Project

This project simulates a **mini Airbnb database** to help you **master SQL joins and relational database design**.  
It includes schema definitions, sample data, and join query exercises to practice different types of SQL joins.

---

## 📁 Project Structure

| File | Description |
|------|--------------|
| `schema.sql` | Defines all database tables, constraints, and indexes. |
| `seed.sql` | Inserts realistic sample data into all tables. |
| `README.md` | Project documentation and learning instructions. |

---

## 🧱 Database Schema Overview

The database models key Airbnb features using six main tables:

| Table | Description |
|--------|--------------|
| **User** | Stores all platform users (guests, hosts, and admins). |
| **Property** | Contains listings created by hosts. |
| **Booking** | Records reservations made by guests. |
| **Payment** | Tracks payments linked to bookings. |
| **Review** | Stores reviews and ratings given by guests. |
| **Message** | Records messages exchanged between users. |

### 🔗 Table Relationships

- A **User (host)** can own many **Properties**.  
- A **User (guest)** can make many **Bookings**.  
- Each **Booking** can have one **Payment**.  
- A **Property** can have many **Reviews**.  
- **Messages** connect users through sender/recipient relationships.

---

## 🧪 Sample Data Overview

The `seed.sql` file provides realistic sample records, including:
- Two **hosts**, two **guests**, and one **admin**
- Multiple **properties**, **bookings**, **reviews**, and **messages**
- Various **booking statuses** (`confirmed`, `pending`, `canceled`)
- One **completed payment**

This ensures you can meaningfully test SQL joins and relational queries.

---

