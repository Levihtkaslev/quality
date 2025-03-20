const depart = require("../collectin_db/department.js");

exports.postdepartment = async(req, res) => {
    const {locationid, departmentname, targetname, targetpos, targetno, password} = req.body;
    
    try {
        const newdepart = new depart({locationid, departmentname, targetname, targetpos, targetno, password});
        await newdepart.save();
    res.json({
        message : "Department created!",
        newdepart
    });
    } catch (error) {
        console.log("Error", error)
    }
}

exports.getdepartment = async(req, res) => {
    const { locationid } = req.query;
    let query = {};
    if (locationid) {
        query.locationid = locationid; 
    }
    const getdepart = await depart.find(query).populate('locationid', 'locationname');
    res.json(getdepart);
}

exports.getdepartmentbyid = async (req, res) => {
    try {
        const formid = req.params.id;
        const resforms = await depart.find({locationid : formid});

        if (!resforms) {
            return res.status(404).json({ error: 'Responsed form is not found'});
          }
        res.status(200).json(resforms);

    } catch (error) {
        console.error("Error showing responde deepview:",error);
        res.status(500).json({
            error : "Error showing responde deepview"
        });
    }
}

exports.putdepartment = async(req, res) => {
    const {locationid, departmentname, targetname, targetno, password} = req.body;
    const updatedepart = await depart.findByIdAndUpdate(req.params.id, { departmentname, targetname, targetno, password, locationid }, { new: true });
    await updatedepart.save();
    res.json({
        message : "Department updated Successfully",
        updatedepart
    });
}

exports.deletedepartment = async(req,res) => {
    const deletedepart = await depart.findByIdAndDelete(req.params.id);
    
    if(!deletedepart){
        return res.status(404).json({
            message : "Department not found"
        })
    }
    res.json({
        message : "Department Deleted Successfully",
        deletedepart
    });
}