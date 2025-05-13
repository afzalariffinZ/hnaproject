# Football Club Management Web App

The Football Club Management System is a full-stack web application designed to streamline football club operations and enhance the experience for both club members and administrators.

---

## 🛠 Tech Stack

- **Frontend**: HTML, CSS (Bootstrap 5), EJS (Embedded JavaScript Templates)
- **Backend**: Node.js, Express.js
- **Database**: MySQL
- **Server**: XAMPP (for MySQL service)

---

## ⚙️ How to Run This Project

### 1. Clone the Repository
git clone 
cd FYP---Football-Club-Management

### 2. Start MySQL Using XAMPP
Open XAMPP Control Panel
Start Apache and MySQL
Open phpMyAdmin and import the database (e.g. football_club.sql if provided)

### 3. Install Node.js Dependencies
npm install

### 4.Set Up the Database
Make sure the database credentials in models/db.js match your local XAMPP MySQL settings:
host: 'localhost',
user: 'root',
password: '',
database: 'your_database_name'

### 5. Run the app
node app.js
Then open your browser and go to:
http://localhost:3000



### Install also:
npm install mysql2 bcrypt
