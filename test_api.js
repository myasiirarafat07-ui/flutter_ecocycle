const https = require('https');

https.get('https://flutter-ecocycle.vercel.app/api/products', (res) => {
  let data = '';
  res.on('data', chunk => data += chunk);
  res.on('end', () => console.log(data));
}).on('error', err => console.log(err));
