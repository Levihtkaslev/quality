const depart = require("../collectin_db/department.js");
const locat = require("../collectin_db/location.js");
const jwt = require('jsonwebtoken');
const JWT_SECRET = 'ghfjdghdxjgfhjxg';

exports.login = async(req, res) => {
    const{locationid, _id, password} = req.body;
    console.log(req.body);

    try {
        const getlocation = await locat.findById(locationid);
        
        if (!getlocation) {
            return res.status(400).json({ message: 'Invalid location' });
        }
        
        const getdepartment = await depart.findOne({ locationid, _id });
        
        if (!getdepartment) {
            return res.status(400).json({ message: 'Invalid department' });
        }

        if (password !== getdepartment.password) {
            return res.status(400).json({ message: 'Incorrect password' });
        }
        

        const token = jwt.sign({ departmentId: getdepartment._id, locationId: getdepartment.locationid }, JWT_SECRET, {expiresIn: '30d'});

        if (!locationid || !_id || !password) {
            return res.status(400).send('Missing fields');
          }

        return res.json({ message: 'Login successful', token, getdepartment, getlocation});
    } catch (error) {
        return res.status(500).json({ message: 'Server error', error });
        
    }
}