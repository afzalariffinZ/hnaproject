const express = require('express');
const path = require('path');
const session = require('express-session');
const app = express();
const db = require('./models/db'); // Assuming db.js is in the models folder

// Dummy in-memory user storage
let users = [
  { username: "admin", password: "adminpass", role: "admin" },
  { username: "user", password: "userpass", role: "member" }
];

// Middleware
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));
app.use(express.urlencoded({ extended: true }));
app.use(express.static(path.join(__dirname, 'public')));


// Session middleware
app.use(
  session({
    secret: 'your-secret-key',
    resave: false,
    saveUninitialized: false,
    cookie: { httpOnly: true, secure: false, maxAge: 24 * 60 * 60 * 1000 }
  })
);

app.use((req, res, next) => {
  res.locals.user = req.session.user || null;
  next();
});

// Temporary in-memory cart
let cart = [];


// Home Route
app.get('/', (req, res) => {
  res.render('index', {
    title: 'Home Page',
    message: 'Welcome to my basic Express app!',
    user: req.session.user
  });
});

// Login Route
app.get('/login', (req, res) => {
  res.render('login', { error: null });
});

// Login Submission with role check
app.post('/loginAccount', async (req, res) => {
  const { username, password } = req.body;


  //find user in the database
  // const sql = 'SELECT * FROM customer_account WHERE username = ? AND password = ?';
  // const values = [username, password];
  // const [user] = await db.query(sql, values);
  // For demonstration, using in-memory user storage
  // In a real application, you should hash passwords and use a secure method to check them
  // const user = users.find(u => u.username === username && u.password === password);
  const sql = 'SELECT * FROM customer_account WHERE username = ? AND password = ?';
  const values = [username, password];
  const [user] = await db.query(sql, values);

  if (user && user.length > 0) {  // Check if user is found
    req.session.user = user[0];  // Ensure you're getting the first user in case of multiple results
    console.log('User logged in:', user[0].role);
    if (user[0].role === 'admin') {
      return res.redirect('/admin');
    } else {
      console.log('User logged in:', user[0].role);
      return res.redirect('/');
    }
  } else {
    res.render('login', { error: 'Invalid credentials. Please register.' });
  }
});


// Register Route
app.get('/register', (req, res) => {
  res.render('register');
});

// Register Submission (default role = member)
app.post('/registerAccount', async (req, res) => {

  //insert the logic to place the user in the database
  const {
    username,
    password, // Plain text password from form
    first_name,
    surname,
    email,
    dob,       // Ensure this is in 'YYYY-MM-DD' format for MySQL DATE type
    country,
    marketing_consent // This will be 'on' if a checkbox is checked, or undefined
  } = req.body;

  if (!username || !password || !first_name || !surname || !email || !dob || !country) {
    return res.status(400).send('All required fields (username, password, first_name, surname, email, dob, country) must be provided.');
  }

  try {

    const marketingConsentValue = marketing_consent === 'yes';

    const sql = `
            INSERT INTO customer_account
              (username, password, first_name, surname, email, dob, country, marketing_consent)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
          `;
    const role = 'member'; // Default role for new users

    const values = [
      username,
      password,
      first_name,
      surname,
      email,
      dob,
      country,
      marketingConsentValue, // Use the converted boolean value here
      role
    ];

    const [result] = await db.query(sql, values);

    console.log('User registered successfully. Insert ID:', result.insertId);

    req.session.user = {
      id: username,
      email: email,
      role: role
    };

    res.redirect('/');

  } catch (error) {
    console.error('Error registering account:', error);
    // ... (your existing error handling)
    if (error.code === 'ER_DUP_ENTRY') {
      if (error.message.includes('email_UNIQUE')) {
        return res.status(409).send('Registration failed: Email already exists.');
      } else if (error.message.includes('username_UNIQUE')) {
        return res.status(409).send('Registration failed: Username already exists.');
      }
      return res.status(409).send('Registration failed: Duplicate entry.');
    }
    res.status(500).send('Error registering account. Please try again later.');
  }
});

// Logout Route
app.get('/logout', (req, res) => {
  req.session.destroy(() => {
    res.redirect('/login');
  });
});

// Admin Dashboard (Protected)
app.get('/admin/dashboard', (req, res) => {
  if (!req.session.user || req.session.user.role !== 'admin') {
    return res.redirect('/'); // or res.redirect('/login');
  }

  res.render('admin_dashboard', { user: req.session.user });
});

// Store Route
app.get('/store', (req, res) => {
  const gear = [
    { gear_id: 1, gear_name: 'Football', gear_desc: 'High-quality football', price_per_unit: 25.99 },
    { gear_id: 2, gear_name: 'Jersey', gear_desc: 'Team jersey', price_per_unit: 49.99 },
    { gear_id: 3, gear_name: 'Boots', gear_desc: 'Football boots', price_per_unit: 89.99 },
  ];

  res.render('store', { gear, cart });
});

// Add item to cart
app.post('/cart/add/:id', (req, res) => {
  const gearId = parseInt(req.params.id, 10);

  const gear = [
    { gear_id: 1, gear_name: 'Football', gear_desc: 'High-quality football', price_per_unit: 25.99 },
    { gear_id: 2, gear_name: 'Jersey', gear_desc: 'Team jersey', price_per_unit: 49.99 },
    { gear_id: 3, gear_name: 'Boots', gear_desc: 'Football boots', price_per_unit: 89.99 },
  ];

  const item = gear.find((g) => g.gear_id === gearId);
  if (!item) {
    return res.status(404).send('Item not found');
  }

  const existingItem = cart.find((c) => c.gear_id === gearId);
  if (existingItem) {
    existingItem.quantity += 1;
  } else {
    cart.push({ ...item, quantity: 1 });
  }

  res.redirect('/store?success=true');
});

// View cart
app.get('/cart', (req, res) => {
  const isMember = req.session.user && req.session.user.role === 'member';
  res.render('cart', { cart, isMember });
});

// Remove item from cart
app.post('/cart/remove/:id', (req, res) => {
  const gearId = parseInt(req.params.id, 10);
  if (isNaN(gearId)) {
    res.status(400).send('Invalid gear ID');
    return;
  }

  cart = cart.filter((item) => item.gear_id !== gearId);
  res.redirect('/cart');
});

// Update cart item quantity
app.post('/cart/update/:id', (req, res) => {
  const gearId = parseInt(req.params.id, 10);
  const newQuantity = parseInt(req.body.quantity, 10);

  if (isNaN(gearId) || isNaN(newQuantity) || newQuantity <= 0) {
    res.status(400).send('Invalid input');
    return;
  }

  const item = cart.find((item) => item.gear_id === gearId);
  if (item) {
    item.quantity = newQuantity;
  }
  res.redirect('/cart');
});

// Payment route
app.get('/payment', (req, res) => {
  const customer = req.session.user || { name: 'Guest', email: '', address: '' };
  res.render('payment', { cart, customer });
});

// Process payment
app.post('/payment/process', (req, res) => {
  cart = [];
  res.send('<h1>Payment Successful!</h1><p>Your order has been placed successfully.</p>');
});

// Static content routes
app.get('/schedule', (req, res) => {
  res.render('schedule');
});

app.get('/news', (req, res) => {
  res.render('news');
});

app.get('/players', (req, res) => {
  res.render('players');
});

//Route to membership page
app.get('/membership', (req, res) => {
  // Dummy user object — replace with real user session/db data
  const user = {
    username: 'john_doe',
    email: 'john@example.com',
    birthday: '1999-04-21',
    membershipTier: 'Gold',
    phone: '98765432',
    favoriteTeam: 'FC Barcha',
    joinDate: '2023-01-10'
  };

  res.render('membership', { user });
});

//Route to admin page
app.get('/admin', (req, res) => {

  if (!req.session.user || req.session.user.role !== 'admin') {
    return res.redirect('/'); // or res.redirect('/login');
  }
  // Dummy admin data for now
  // const adminData = {
  //   username: 'admin_john',
  //   email: 'admin@example.com',
  //   phone: '91234567',
  //   joinDate: '2023-06-15'
  // };

  const data = req.session.user || { name: 'Guest', email: '', address: '' };

  const adminData = {
    username: data.username,
    email: data.email,
    phone: '91234567',
    joinDate: data.dob
  };

  res.render('admin', { admin: adminData });
});

// Start Server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});
