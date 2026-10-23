const test = require('node:test');
const assert = require('node:assert');
const { createApp } = require('../app');

test('echoes the JSON body', async () => {
  const server = createApp().listen(0);
  try {
    const port = server.address().port;
    const response = await fetch(`http://127.0.0.1:${port}/echo`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ message: 'hello' }),
    });
    assert.strictEqual(response.status, 200);
    assert.deepStrictEqual(await response.json(), { received: { message: 'hello' } });
  } finally {
    server.close();
  }
});
