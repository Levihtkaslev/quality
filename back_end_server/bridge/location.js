const express = require("express");
const { postlocation, getlocation, putlocation, deletelocation } = require("../destination/location");
const router = express.Router();

router.post('/locations',postlocation);
router.get('/locations',getlocation);
router.put('/locations/:id',putlocation);
router.delete('/locations/:id',deletelocation);

module.exports = router;