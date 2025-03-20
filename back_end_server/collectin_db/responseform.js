const mongoose = require("mongoose");

const resform = new mongoose.Schema({
    reqformid :{type : mongoose.Schema.Types.ObjectId, ref : "form"},
    explanation : { type : String},
    causes : { type : String},
    isprevented : { type : Boolean},
    notprereason : { type : String},
    futurepreaction : { type : String,},
    immediate : {type : String},
    actiontype : [{ type : String}],
    resofimple : { type : String},
    capa : { type : String},
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
