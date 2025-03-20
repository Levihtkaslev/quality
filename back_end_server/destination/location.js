const locat = require("../collectin_db/location.js");

exports.postlocation = async (req, res) => {
    const { locationname } = req.body;
    try {
        const createlocation = new locat({ locationname });
        await createlocation.save();
    res.json(createlocation);
    } catch (error) {
        console.log("Error creating lcation", error);
    }
  }

exports.getlocation = async (req, res) => {
    const getlocations = await locat.find();
    res.json(getlocations);
}

exports.putlocation = async (req, res) => {
    const { locationname } = req.body;
    const updatelocation = await locat.findByIdAndUpdate(req.params.id, { locationname }, { new: true });
    res.json(updatelocation);
  }

  exports.deletelocation = async (req, res) => {
      await locat.findByIdAndDelete(req.params.id);
      res.json(
        { 
          message: 'Location deleted' 
        }
      );
    }