const express = require('express');

function createApp() {
  const app = express();
  app.use(express.bodyParser());
  app.post('/echo', (req, res) => {
    res.json({ received: req.body });
  });
  return app;
}

module.exports = { createApp };
