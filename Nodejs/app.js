const express = require('express')
const app = express()
const port = 3000

app.get('/', (req, res) => {
  res.send('Hello World! Welcome to my Web Application!😀😀')
})

app.listen(port, () => {
  console.log(`Nodejs Application listening on port ${port}`)
})



// const express = require('express')
// const app = express()

// app.get('/', (req, res) => res.send('Hello World!!!!YYYYYaaaaaaaYYYY'))
// app.listen(3000, () => console.log('Server ready'))
