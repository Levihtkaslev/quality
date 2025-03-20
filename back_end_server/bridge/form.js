const express = require("express");
const {postform, deleteform, responseform, respondiew, allreceivedforms, allsubmittedform, formdetails, opened, form } = require('../destination/form')
const router = express.Router();

router.post('/form',postform);
router.delete('/form/:id', deleteform);
router.post('/response', responseform);
router.get('/respondiew/:resid', respondiew);
router.get('/formsreceived/:departmentid',allreceivedforms);
router.get('/formsubmitted/:departmentid',allsubmittedform);
router.get('/formdetails/:formid',formdetails);
router.put('/opened/:formid',opened);
router.get('/form',form);

module.exports = router;