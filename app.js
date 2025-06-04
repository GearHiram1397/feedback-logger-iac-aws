const path = require('path');
const express = require('express');
require('dotenv').config();
const app = express();
const PORT = process.env.PORT || 3000;
const API_SECRET = process.env.API_SECRET || 'default_secret';

app.use(express.json());
// Serve built React files
const staticPath = path.join(__dirname, 'frontend', 'dist');
app.use(express.static(staticPath));

// POST /submit-feedback endpoint
app.post('/submit-feedback', (req, res) => {
  const apiKey = req.headers['x-api-key'];
  if (apiKey !== API_SECRET) {
    return res.status(403).json({ error: 'Unauthorized' });
  }

  const { message } = req.body;
  if (!message) {
    return res.status(400).json({ error: 'Message is required.' });
  }
  // Here you could add logic to store feedback, e.g., in a database or log
  console.log(`Feedback received: ${message}`);
  res.status(200).json({ status: 'success', message: 'Feedback received.' });
});

// Fallback to index.html for SPA routing
app.get('*', (_req, res) => {
  res.sendFile(path.join(staticPath, 'index.html'));
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
}); 
