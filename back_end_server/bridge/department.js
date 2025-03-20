const express = require("express");
const {postdepartment, getdepartment, getdepartmentbyid, putdepartment, deletedepartment} = require('../destination/department')
const router = express.Router();

router.post('/departments',postdepartment);
router.get('/departments',getdepartment);
router.get('/departments/:id',getdepartmentbyid);
router.put('/departments/:id',putdepartment);
router.delete('/departments/:id',deletedepartment);

module.exports = router;