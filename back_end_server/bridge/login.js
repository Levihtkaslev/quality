const express = require("express");
const {login} = require('../destination/login')
const router = express.Router();

router.post('/applogin',login)


module.exports = router;