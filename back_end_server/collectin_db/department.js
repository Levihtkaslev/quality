const mongoose = require("mongoose");

const depart = new mongoose.Schema({
    locationid : { type: mongoose.Schema.Types.ObjectId, ref: 'locat'},
    departmentname : String,
    targetname : String,
    targetpos : String,
    targetno : String,
    password : String,
});

module.exports = mongoose.model("depart",depart); 

// ***********************************END OF DEPARTMENT*************************************