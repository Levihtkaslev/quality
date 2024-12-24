const mongoose = require("mongoose");

const resform = new mongoose.Schema({
    reqformid :{type : mongoose.Schema.Types.ObjectId, ref : "form", required: true},
    explanation : { type : String, required: true},
    causes : { type : String, required: true},
    isprevented : { type : Boolean},
    notprereason : { type : String},
    futurepreaction : { type : String, required: true},
    immediate : {type : String},
    actiontype : [{ type : String}],
    resofimple : { type : String, required: true},
    capa : { type : String, required: true},
    createdtime : { type: Date }
});


resform.methods.toJSON = function () {
    const formObject = this.toObject();
    
    
    if (formObject.createdtime instanceof Date) {
        formObject.createdtime = formObject.createdtime.toLocaleString('en-US', { timeZone: 'Asia/Kolkata' });
    }
    
    return formObject;
};

module.exports = mongoose.model("resform",resform); 
