const mongoose = require("mongoose");

const form = new mongoose.Schema({
    fromdepartment : String,
    todepartmentid : String,
    todepartment : String,
    departmentname : String,
    locationname : String,
    locationid : String,
    subject : String,
    description : String,
    clinical : String,
    operatinal : String,
    finimpact : String,
    patimpact : String,
    severity : String,
    personsinvolved : [String],
    status: { type: String, default: 'Pending' },
    opened: { type: Boolean, default: false },
    createdtime : { type: Date, default: Date.now },
    targetno : String,
    targetname : String
});

form.methods.toJSON = function () {
    const formObject = this.toObject();
    
    
    if (formObject.createdtime instanceof Date) {
        formObject.createdtime = formObject.createdtime.toLocaleString('en-US', { timeZone: 'Asia/Kolkata' });
    }
    
    return formObject;
};

module.exports = mongoose.model('form', form);

// ***********************************END OF FORMS************************************* 