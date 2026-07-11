const https = require('https');

https.get('https://flutter-ecocycle.vercel.app/api/products', (res) => {
  console.log('Status Code:', res.statusCode);
  console.log('Headers:', res.headers);
  let data = '';
  res.on('data', chunk => data += chunk);
  res.on('end', () => console.log('Body:', data));
}).on('error', err => console.error(err));
