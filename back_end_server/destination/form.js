const form = require("../collectin_db/form.js");
const resform = require("../collectin_db/responseform.js");

exports.postform = async (req, res) => {
    const {fromdepartment,
           todepartmentid, 
           todepartment,
           departmentname, 
           locationname,
           locationid,
           subject, 
           description, 
           clinical,
           operatinal, 
           patimpact,
           finimpact,
           severity,
           personsinvolved,
           targetno,
           targetname
        } = req.body;

    try {
        const newform = new form({fromdepartment, 
                                  todepartmentid,
                                  todepartment, 
                                  departmentname,
                                  locationname,
                                  locationid,
                                  subject, 
                                  description, 
                                  clinical, 
                                  operatinal,
                                  patimpact,
                                  finimpact,
                                  severity,
                                  personsinvolved, 
                                  status: "Pending",
                                  opened: false,
                                  targetno,
                                  targetname
                                });
        await newform.save();
        res.status(201).json(newform);
    } catch (error) {
        res.status(500).json({ message: 'Error creating form', error });
    }
}

exports.deleteform = async (req, res) => {
    await form.findByIdAndDelete(req.params.id);
    res.json({ message: 'Form deleted' });
  }

exports.responseform = async (req, res) => {
    try {
        
        const {
            reqformid,
            explanation,
            causes,
            isprevented,
            notprereason,
            futurepreaction,
            immediate,
            actiontype,
            resofimple,
            capa
        } = req.body;

        const response = new resform({
            reqformid,
            explanation,
            causes,
            isprevented,
            notprereason : isprevented? notprereason : undefined,
            futurepreaction,
            immediate,
            actiontype,
            resofimple,
            capa,
            createdtime: new Date()
        });
        const postedform = await response.save();
        await form.findByIdAndUpdate(reqformid, { status: "Completed" });
        res.status(201).json({ message: "Response submitted and form status changed" ,postedform});
    } catch (error) {
        console.error("Error submitting response form:", error);
        res.status(500).json({ error: "Failed to submit response form." });
    }
}

exports.respondiew = async (req, res) => {
    try {
        const formid = req.params.resid;
        const resforms = await resform.findOne({reqformid : formid});

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

exports.allreceivedforms = async(req, res) => {
    const { departmentid } = req.params;

    try {
        const getform = await form.find({ todepartment : departmentid }).sort({ createdtime: -1 }).exec();
        res.status(200).json(getform);
    } catch (error) {
        res.status(500).json({ message: 'Error fetching all Received forms', error });
    }
}

exports.allsubmittedform = async (req, res) => {
    const { departmentid } = req.params;
  
    try {
      const forms = await form.find({ fromdepartment: departmentid }).sort({ createdtime: -1 }).exec();
      res.status(200).json(forms);
    } catch (error) {
      res.status(500).json({ message: 'Error fetching submitted forms', error });
    }
}

exports.formdetails = async (req, res) => {
    const { formid } = req.params;
  
    try {
      const forms = await form.findById(formid);
      if (!forms) {
        return res.status(404).json({ message: 'Form not found' });
      }
      res.status(200).json(forms);
    } catch (error) {
      res.status(500).json({ message: 'Error fetching form details', error });
    }
}

exports.opened =  async (req, res) => {
    const { formid } = req.params;
    try {
      await form.findByIdAndUpdate(formid, { opened: true });
      res.status(200).send('Form marked as opened');
    } catch (err) {
      res.status(500).send('Error marking form as opened');
    }
  }

exports.form =  async (req, res) => {
    const { fromdepartment, todepartment, locationid } = req.query;

    const query = {};
    
    if (locationid) {
        query.locationid = locationid;
    }
    
    if (fromdepartment && todepartment) {
        query.$or = [
            { fromdepartment },
            { todepartment },
        ];
    } else if (fromdepartment) {
        query.fromdepartment = fromdepartment;
    } else if (todepartment) {
        query.todepartment = todepartment;
    }

    try {
        const forms = await form.find(query);
        console.log("Fetched Forms Query:", query, "Forms:", forms);
        res.status(200).json(forms);
    } catch (error) {
        console.error("Error fetching forms:", error);
        res.status(500).json({ error: "Internal Server Error" });
    }
}

