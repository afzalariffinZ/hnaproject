const mysql = require('mysql2');
const path = require('path');
const db = require(`../config.json`).database;

const connection = mysql.createConnection({
    host: db.host,
    user: db.user,
    password: db.password,
    database: db.name,
  });

connection.connect((err) => {
    if (err) {
        console.error('Error connecting to MySQL database: ', err);
        return;
    }
    console.log('Connected to MySQL database.');
});

module.exports = connection.promise();