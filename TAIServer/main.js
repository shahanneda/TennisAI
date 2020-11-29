const express = require('express')
const app = express()
const port = 3000
app.use(express.json());

app.get('/', (req, res) => {
  res.send('Hello World!')
})
app.post('/', (req, res) => {
  console.log(req.body);

  res.send('Hello World! post')
})

app.listen(port, () => {
  console.log(`Example app listening at http://localhost:${port}`)
})
