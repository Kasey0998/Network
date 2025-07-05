fetch('https://api.ipify.org?format=json')
  .then(response => response.json())
  .then(data => {
    document.getElementById('ip').innerText = `Server IP: ${data.ip}`;
  })
  .catch(error => {
    document.getElementById('ip').innerText = 'Server IP: Unable to fetch IP';
    console.error('Error fetching IP:', error);
  });
