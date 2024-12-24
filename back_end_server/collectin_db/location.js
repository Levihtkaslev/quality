const mongoose = require("mongoose");

const locat = new mongoose.Schema({
    locationname : { type: String, required: true },
});

module.exports = mongoose.model('locat', locat);

// ***********************************END OF LOATIONS*************************************