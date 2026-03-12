export default async function handler(req, res) {
  // Разрешаем нашему приложению общаться с сервером
  res.setHeader('Access-Control-Allow-Credentials', true);
  res.setHeader('Access-Control-Allow-Origin', '*'); 
  res.setHeader('Access-Control-Allow-Methods', 'GET,OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'X-CSRF-Token, X-Requested-With, Accept, Accept-Version, Content-Length, Content-MD5, Content-Type, Date, X-Api-Version');

  if (req.method === 'OPTIONS') {
    res.status(200).end();
    return;
  }

  // Получаем город
  const city = req.query.city;
  if (!city) {
    return res.status(400).json({ error: 'City is required' });
  }

  // Берем секретный ключ из Vercel
  const apiKey = process.env.OPENWEATHER_API_KEY;
  const url = `https://api.openweathermap.org/data/2.5/weather?q=${city}&appid=${apiKey}&units=metric`;

  try {
    const response = await fetch(url);
    const data = await response.json();
    
    if (!response.ok) {
      return res.status(response.status).json(data);
    }

    // Отдаем погоду
    res.status(200).json(data);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch weather' });
  }
}